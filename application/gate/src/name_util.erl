%% @author zouv
%% @doc @todo 名称库

-module(name_util).
-include_lib("db/include/mnesia_table_def.hrl").

-define(BIG_LETTER_LIST, ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]).
-define(SMALL_LETTER_LIST, ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]).
%% ====================================================================
%% API functions
%% ====================================================================
-export([
	make_player_name/0,
	make_robot_name/0,
	make_robot_name_head/1
]).

%% ====================================================================
%% Internal functions
%% ====================================================================

%% 生成机器人昵称
make_config_rand_name() ->
	TableLength = mnesia:table_info(player_name_random_info, size),
	Idx_First = util:rand(1, TableLength),
	case player_name_random_info_db:get_base(Idx_First) of
		{ok, [NameData1]} ->
			FirstName = (NameData1#player_name_random_info.family_name);
		_ ->
			FirstName = "NaN"
	end,
	FirstName.

%% 生成玩家昵称
make_init_rand_name() ->
	BigWordFun = fun() -> lists:nth(util:rand(1,26), ?BIG_LETTER_LIST) end,
	SmallWordFun = fun() -> lists:nth(util:rand(1,26), ?SMALL_LETTER_LIST) end,
	lists:concat(["玩家_", BigWordFun(), SmallWordFun(), BigWordFun(), SmallWordFun(), BigWordFun(), SmallWordFun()]).


%% 生成机器人名字
make_robot_name() ->
	make_robot_name(0).

make_robot_name(Index) ->
	TempPlayerName = make_config_rand_name(),
	case player_util:is_player_name_exists(TempPlayerName) of
	%% 昵称已存在
		{true, _PlayerInfo} ->
			if
				Index < 10 ->
					make_robot_name(Index + 1);
				true ->
					?ERROR_LOG("make robot name Overflow ! ~p~n", [erlang:localtime()]),
					erlang:integer_to_list(util:now_seconds() * 10)
			end;
		_ ->
			TempPlayerName
	end.

%% 生成机器人名字
make_player_name() ->
	make_player_name(0).

make_player_name(Index) ->
	TempPlayerName = make_init_rand_name(),
	case player_util:is_player_name_exists(TempPlayerName) of
	%% 昵称已存在
		{true, _PlayerInfo} ->
			if
				Index < 10 ->
					make_player_name(Index + 1);
				true ->
					?ERROR_LOG("make player name Overflow ! ~p~n", [erlang:localtime()]),
					erlang:integer_to_list(util:now_seconds() * 10)
			end;
		_ ->
			TempPlayerName
	end.

%% 生成机器人名字
make_robot_name_head(AccountId1) ->
	HeadSize = mnesia:table_info(player_head_icon, size),
	NameSize = mnesia:table_info(player_name_random_info, size),
	AccountId = AccountId1 rem 1000000,

	if
		AccountId > HeadSize ->
			UseHeadId = util:rand(1, HeadSize);
		true ->
			UseHeadId = AccountId
	end,
	UseHeadIcon =
		case player_head_icon_db:get_base(UseHeadId) of
			{ok, [UseHead]} ->
				UseHead#player_head_icon.texture;
			_ ->
				""
		end,
	if
		AccountId > NameSize ->
			Sex = util:rand(0, 1),
			UseName = make_player_name();
		true ->
			case player_name_random_info_db:get_base(AccountId) of
				{ok, [PlayerNameBase]} ->
					UseName = PlayerNameBase#player_name_random_info.family_name,
					Sex = list_to_integer(PlayerNameBase#player_name_random_info.sex);
				_ ->
					Sex = util:rand(0, 1),
					UseName = make_player_name()
			end
	end,
	{UseHeadIcon, UseName, Sex}.

