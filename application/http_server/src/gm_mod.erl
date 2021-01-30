%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 四月 2017 17:07
%%%-------------------------------------------------------------------
-module(gm_mod).
-author("wodong_0013").

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("gate/include/common.hrl").
-include_lib("gate/include/mysql_log.hrl").

%% API
-export([
	do_send_mail/5,



	check_role_exist/1,
	add_announcement/4,

	get_online_count/0,

	set_game_fax/3,
	set_forbid_state/3,
	set_niu_blacklist/4,
	get_niu_blacklist_rand/1

]).
%% 发送邮件
do_send_mail(Title, Content, RoleId, Type, Reward) ->
	case ntools:reward_content_to_reward_list(Reward) of
		{true, RewardList} ->
			case Type of
				0 ->
					case check_role_exist(list_to_integer(RoleId)) of
						{true, ToPlayerId} ->
							player_mail:send_system_mail(ToPlayerId, 1, ?MAIL_TYPE_GM_SEND_TO_SINGLE, Title, Content, RewardList),
							log_util:add_gm_oprate(?MLOG_ETS_GM_success, send_mail, [Title, Content, RoleId, Type, Reward]),
							{0, ""};
						_ ->
							log_util:add_gm_oprate(?MLOG_ETS_GM_error, error_mail, [Title, Content, RoleId, Type, Reward]),
							{1, "玩家不存在"}
					end;
				1 ->
					send_mail_to_all_player(Title, Content, RewardList),
					log_util:add_gm_oprate(?MLOG_ETS_GM_success, send_mail, [Title, Content, RoleId, Type, Reward]),
					{1, ""};
				_ ->
					log_util:add_gm_oprate(?MLOG_ETS_GM_error, error_mail, [Title, Content, RoleId, Type, Reward]),
					{1, "群发类型错误"}
			end;
		{false, Err} ->
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, error_mail, [Title, Content, RoleId, Type, Reward]),
			{1, Err}
	end.

%% 发送全服玩家 系统邮件
send_mail_to_all_player(Title, Content, RewardList) ->
	case player_info_db:get_first() of
		'$end_of_table' ->
			skip;
		FirstKey ->
			PlayerInfo = player_info_db:get_player_info(FirstKey),
			send_next_player_id_mail(PlayerInfo#player_info.id, Title, Content, RewardList)
	end.

send_next_player_id_mail(ToPlayerId, Title, Content, RewardList) ->
	player_mail:send_system_mail(ToPlayerId, 1, ?MAIL_TYPE_GM_SEND_TO_ALL, Title, Content, RewardList),
	case player_info_db:get_next(ToPlayerId) of
		'$end_of_table' ->
			skip;
		NextKey ->
			PlayerInfo = player_info_db:get_player_info(NextKey),
			send_next_player_id_mail(PlayerInfo#player_info.id, Title, Content, RewardList)
	end.

check_role_exist(RoleId) ->
	case player_info_db:get_base(RoleId) of
		{ok, [_PlayerInfo]} ->
			{true, RoleId};
		_ ->
			false
	end.







add_announcement(BeginDateTime1, EndDateTime1, IntervalSeconds1, Content) ->
	BeginDateTime = util:string_to_term(BeginDateTime1),
	EndDateTime = util:string_to_term(EndDateTime1),
	IntervalSeconds = list_to_integer(IntervalSeconds1),
	
	case BeginDateTime of
		{{_, _, _}, {_, _, _}} ->
			V1 = true;
		_ ->
			V1 = {false, "起始时间格式错误"}

	end,
	case EndDateTime of
		{{_, _, _}, {_, _, _}} ->
			V2 = true;
		_ ->
			V2 = {false, "截止时间格式错误"}
	end,
	if
		V1 /= true ->
			V1;
		V2 /= true ->
			V2;
		IntervalSeconds < 5 ->
			{false, "公告的间隔时间不能小于5秒"};
		true ->
			%?INFO_LOG("1111111"),
			announcement_server:trigger_add_gm_announcement(BeginDateTime, EndDateTime, IntervalSeconds, Content),
			true
	end.


get_online_count() ->
	ets:info(?ETS_ONLINE, size).


set_game_fax(_Type, _Rate, _Fax) ->
	true.

%% 0解禁 1禁止 (1登入 2聊天)
set_forbid_state(RoleId, Type, Flag) ->
	?INFO_LOG("RoleId, Type, Flag ~p~n",[{RoleId, Type, Flag}]),
	case Type of
		1 ->
			%% 目前只做踢下线
			case player_info_db:get_base(RoleId) of
				{ok, [_PlayerInfo]} ->
					ntools:kick_one(RoleId);
				_ ->
					{false, "玩家不存在"}
			end;
		2 ->
			case role_manager:get_roleprocessor(RoleId) of
				{ok, Pid} ->
					role_processor_mod:cast(Pid, {'handle', player_chat, set_chat_forbid, [Flag]});
				_ ->
					case player_info_db:get_base(RoleId) of
						{ok, [PlayerInfo]} ->
							NewPlayerInfo = PlayerInfo#player_info{chat_forbid_state = Flag},
							DBFun = fun() -> player_info_db:t_write_player_info(NewPlayerInfo) end,
							case dal:run_transaction_rpc(DBFun) of
								{atomic, _} ->
									true;
								_ ->
									{false, "数据库出错"}
							end;
						_ ->
							{false, "玩家不存在"}
					end
			end;
		_ ->
			{false, "type错误"}
	end.

%% 看牌黑名单
set_niu_blacklist(RoleId, _Type, 1, Rand1) ->
	Rand = min(100, max(0,Rand1)),
	Rec = #niu_blacklist{player_id = RoleId, flag = 1, rand = Rand},
	case role_manager:get_roleprocessor(RoleId) of
		{ok, Pid} ->
			role_processor_mod:cast(Pid, {'set_niu_blacklist', Rec});
		_ ->
			DBFun = fun() ->
				ets:insert(?ETS_NIU_BLACKLIST, Rec),
				niu_blacklist_db:t_write(Rec)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					{true, "加入黑名单成功"};
				_ ->
					{false, "加入失败1"}
			end
	end;

%% 看牌黑名单
set_niu_blacklist(RoleId, _Type, 0, _Rand) ->
	case ets:lookup(?ETS_NIU_BLACKLIST, RoleId) of
		[PlayerData] ->
			NewPlayerData = PlayerData#niu_blacklist{flag = 0, rand = 0},
			case role_manager:get_roleprocessor(RoleId) of
				{ok, Pid} ->
					role_processor_mod:cast(Pid, {'set_niu_blacklist', NewPlayerData});
				_ ->
					DBFun = fun() ->
						ets:insert(?ETS_NIU_BLACKLIST, NewPlayerData),
						niu_blacklist_db:t_write(NewPlayerData)
					end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							{true, "删除成功"};
						_ ->
							{false, "删除失败1"}
					end
			end;
		_ ->
			{false, "不存在"}
	end.

get_niu_blacklist_rand(PlayerId) ->
	case ets:lookup(?ETS_NIU_BLACKLIST, PlayerId) of
		[Data] ->
			Data#niu_blacklist.rand;
		_ ->
			0
	end.