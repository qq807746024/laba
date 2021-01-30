%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 13:50
%%%	金币库存管理
%%%-------------------------------------------------------------------
-module(diamond_fudai_mod).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-define(TODAY_ALREADY_REWARD_PLAYER_LIST, today_already_reward_player_list).	%% 总奖励的玩家
-define(TODAY_BUY_PLAYER_LIST, today_buy_player_list).	%% 购买的玩家

-define(DIAMOND_FUDAI_CONFIG, next_id_by_draw_config).	%% {id, man_need}

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,

	do_draw_lucky_man/3
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),

	%% 初始化列表
	init_list(),

	%% 初始化配置表
	init_config(),
	%% 隔天重置人数列表
	NowSecond = util:now_seconds(),
	erlang:send_after(60000, self(), {'check_fresh', NowSecond}),
	State = #state{},
	{ok, State}.

init_config() ->
	{ok, [Config]} = diamond_fudai_config_db:get(1),
	put(?DIAMOND_FUDAI_CONFIG, Config).


init_list() ->
	NowSecond = util:now_seconds(),
	case diamond_fudai_reward_player_db:get(1) of
		{ok, [FudaiInfo]} ->
			NewFudaiInfo = check_old(FudaiInfo, NowSecond),
			if
				NewFudaiInfo == FudaiInfo ->
					skip;
				true ->
					diamond_fudai_reward_player_db:write(NewFudaiInfo)
			end;
		_ ->
			NewFudaiInfo = #diamond_fudai_reward_player{
				key = 1,
				player_id_list = [],
				already_reward_player_list = [],
				update_second = NowSecond
			},
			diamond_fudai_reward_player_db:write(NewFudaiInfo)
	end,
	put(?TODAY_ALREADY_REWARD_PLAYER_LIST, NewFudaiInfo#diamond_fudai_reward_player.already_reward_player_list),
	put(?TODAY_BUY_PLAYER_LIST, NewFudaiInfo#diamond_fudai_reward_player.player_id_list).

check_old(FudaiInfo, NowSecond) ->
	case util:is_same_date(FudaiInfo#diamond_fudai_reward_player.update_second, NowSecond) of
		true ->
			FudaiInfo;
		_ ->
			#diamond_fudai_reward_player{
				key = 1,
				player_id_list = [],
				already_reward_player_list = [],
				update_second = NowSecond
			}
	end.

%% ====================================================================
handle_call(Request, From, State) ->
	try
		do_call(Request, From, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod call Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Request}, erlang:get_stacktrace()]),
			{reply, ok, State}
	end.

%% ====================================================================
handle_cast(Msg, State) ->
	try
		do_cast(Msg, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

%% ====================================================================
handle_info(Info, State) ->
	try
		do_info(Info, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Info}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

%% ====================================================================
terminate(_Reason, _State) ->
	?ERROR_LOG("~p terminated ~n", [?MODULE]),
	ok.

%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

do_call('fudai_player_list', _From, State) ->
	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
	OldTimesList = get(?TODAY_ALREADY_REWARD_PLAYER_LIST),
	{reply, {OldBuyList,OldTimesList}, State};

do_call({'is_fudai_buy',PlayerId}, _From, State) ->
	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
	Flag = lists:member(PlayerId,OldBuyList),
	{reply, Flag, State};

do_call(Request, From, State) ->
	?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
	{reply, ok, State}.

%% 更新已购买玩家列表 判断人数
do_cast({'buy_fudai', PlayerId}, State) ->
	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
	case lists:member(PlayerId, OldBuyList) of
		true ->
%%			?INFO_LOG("Error ~p~n fudai buy twice",[{?MODULE, ?LINE}]),
			skip;
		_ ->
			NewBuyList = [PlayerId|OldBuyList],
			put(?TODAY_BUY_PLAYER_LIST, NewBuyList),
			NewFudaiInfo = check_draw_lucky_man(NewBuyList, get(?TODAY_ALREADY_REWARD_PLAYER_LIST)),
			diamond_fudai_reward_player_db:write(NewFudaiInfo)
	end,
	{noreply, State};

do_cast({'buy_fudai_list', List}, State) ->
	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
	NewBuyList=
	lists:foldl(fun(E,Acc) ->

	case lists:member(E, Acc) of
		true ->
%%			?INFO_LOG("Error ~p~n fudai buy twice",[{?MODULE, ?LINE}]),
			Acc;
		_ ->
			[E|Acc]
	end end,OldBuyList,List),
	put(?TODAY_BUY_PLAYER_LIST, NewBuyList),
	NewFudaiInfo = check_draw_lucky_man(NewBuyList, get(?TODAY_ALREADY_REWARD_PLAYER_LIST)),
	diamond_fudai_reward_player_db:write(NewFudaiInfo),
	{noreply, State};

do_cast({'refresh'}, State) ->
	put(?TODAY_ALREADY_REWARD_PLAYER_LIST, []),
	{noreply, State};

%% 增加福袋奖池
do_cast({'add_num', Num}, State) ->
	% 改变福袋奖池
	if
		Num == 0 ->
			skip;
		true ->

			NewInfo = add_ets_lucky_bag(Num),
			NewLuckyBagInfo = #lucky_bag_pool{
				id = 1,
				num = NewInfo#ets_lucky_bag.num
			},
			DBFun = fun() ->
				lucky_bag_pool_db:t_write(NewLuckyBagInfo)
				end,
			{atomic, _} = dal:run_transaction_rpc(DBFun),


			% 通知房间里的玩家
			FirstKey = ets:first(?ETS_NIUNIU_ROOM),
			notice_players(FirstKey)
	end,


%%	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
%%	case lists:member(PlayerId, OldBuyList) of
%%		true ->
%%			?INFO_LOG("Error ~p~n fudai buy twice",[{?MODULE, ?LINE}]),
%%			skip;
%%		_ ->
%%			NewBuyList = [PlayerId|OldBuyList],
%%			put(?TODAY_BUY_PLAYER_LIST, NewBuyList),
%%			NewFudaiInfo = check_draw_lucky_man(NewBuyList, get(?TODAY_ALREADY_REWARD_PLAYER_LIST)),
%%			diamond_fudai_reward_player_db:write(NewFudaiInfo)
%%	end,
	{noreply, State};

do_cast({'add_num_and_add_reward_times',Num,PlayerId},State)->
	if
		Num == 0 ->
			skip;
		true ->
			NewInfo = add_ets_lucky_bag(Num),
			NewLuckyBagInfo = #lucky_bag_pool{
				id = 1,
				num = NewInfo#ets_lucky_bag.num
			},
			DBFun = fun() ->
				lucky_bag_pool_db:t_write(NewLuckyBagInfo)
							end,
			{atomic, _} = dal:run_transaction_rpc(DBFun),


			% 通知房间里的玩家
			FirstKey = ets:first(?ETS_NIUNIU_ROOM),
			notice_players(FirstKey)
	end,

	OldBuyList = get(?TODAY_BUY_PLAYER_LIST),
	RewardList = get(?TODAY_ALREADY_REWARD_PLAYER_LIST),
	NewTimesList =
		case lists:keyfind(PlayerId,1, RewardList) of
			false ->
	%%			?INFO_LOG("Error ~p~n fudai buy twice",[{?MODULE, ?LINE}]),
				[{PlayerId,1}|RewardList];
			{PlayerId,OldTimes} ->
				lists:keystore(PlayerId,1,RewardList,{PlayerId,OldTimes+1})
		end,
	put(?TODAY_ALREADY_REWARD_PLAYER_LIST,NewTimesList),
	NewFudaiInfo = check_draw_lucky_man(OldBuyList, NewTimesList),
	diamond_fudai_reward_player_db:write(NewFudaiInfo),
	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info({'check_fresh', OldSecond}, State) ->
	NowSecond = util:now_seconds(),
	erlang:send_after(60000, self(), {'check_fresh', NowSecond}),
	case util:is_same_date(OldSecond, NowSecond) of
		true ->
			skip;
		_ ->
			NewFudaiInfo = #diamond_fudai_reward_player{
				key = 1,
				player_id_list = [],
				already_reward_player_list = [],
				update_second = NowSecond
			},
			diamond_fudai_reward_player_db:write(NewFudaiInfo),
			put(?TODAY_ALREADY_REWARD_PLAYER_LIST, NewFudaiInfo#diamond_fudai_reward_player.already_reward_player_list),
			put(?TODAY_BUY_PLAYER_LIST, NewFudaiInfo#diamond_fudai_reward_player.player_id_list)
	end,
	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

%% 检测是否开始 抽奖
check_draw_lucky_man(NewBuyList, OldAlreadyRewardList) ->
%%	NowNum = length(NewBuyList),
%%	FudaiConfig = get(?DIAMOND_FUDAI_CONFIG),
%%	CheckFlag = (NowNum rem FudaiConfig#diamond_fudai_config.man_need) == 0,
%%	if
%%		CheckFlag ->
%%			%% 又到达人数条件
%%			NewAlreadyRewardList = do_draw_lucky_man(NewBuyList, OldAlreadyRewardList, FudaiConfig#diamond_fudai_config.reward_diamond);
%%		true ->
%%			NewAlreadyRewardList = OldAlreadyRewardList
%%	end,
	#diamond_fudai_reward_player{
		key = 1,
		player_id_list = NewBuyList,
		already_reward_player_list = OldAlreadyRewardList,
		update_second = util:now_seconds()
	}.

%% 随机一玩家发奖励 (判断是否在房间中)
do_draw_lucky_man(NewBuyList, OldAlreadyRewardList, RewardDiamond) ->
	LastBuyList =
		lists:foldl(fun(E, Acc) ->
			lists:delete(E, Acc) end, NewBuyList, OldAlreadyRewardList),
	%% 获取所有房间 过滤出10等级
	AllRedpackRoomIdList =
		ets:foldl(fun(E, Acc) ->
			case E#niu_room_info.room_level of
				10 ->
					[E#niu_room_info.room_id|Acc];
				_ ->
					Acc
			end end, [], ?ETS_NIUNIU_ROOM),

	%% 获取在房间中列表
	AllInroomPlayer = ets:tab2list(?ETS_NIUNIU_PLAYER_IN_GAME),
	InRoomPlayerIdList =
		lists:foldl(fun(E, Acc) ->
			case lists:member(E#player_niu_room_info.room_id, AllRedpackRoomIdList) of
				true ->
					[E#player_niu_room_info.player_id|Acc];
				_ ->
					Acc
			end end, [], AllInroomPlayer),

	InRoomLastList =
		lists:foldl(fun(E, Acc) ->
			case lists:member(E, LastBuyList) of
				true ->
					[E|Acc];
				_ ->
					Acc
			end end, [], InRoomPlayerIdList),
	case InRoomLastList of
		[] ->
			OldAlreadyRewardList;
		_ ->
			DrawPlayerId = lists:nth(util:rand(1, length(InRoomLastList)), InRoomLastList),
			put(?TODAY_ALREADY_REWARD_PLAYER_LIST, [DrawPlayerId|OldAlreadyRewardList]),
			do_reward_lucky_man(DrawPlayerId, RewardDiamond),
			[DrawPlayerId|OldAlreadyRewardList]
	end.

%% 邮件通知该玩家 发送全服通知
do_reward_lucky_man(DrawPlayerId, RewardDiamond) ->
	case player_info_db:get_base(DrawPlayerId) of
		{ok, [PlayerInfo]} ->
			Content = io_lib:format("恭喜您被福神砸中大奖，获得福袋奖励（~p钻石）！", [RewardDiamond]),
			player_mail:send_system_mail(DrawPlayerId, 1, ?MAIL_TYPE_DIAMOND_FUDAI, "恭喜获得福袋", Content,
				[{?ITEM_ID_DIAMOND, RewardDiamond}]),
			announcement_server:diamond_fudai_draw(PlayerInfo#player_info.player_name, RewardDiamond);
		_ ->
			?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}])
	end.

notice_players(CurKey)->
	case CurKey of
		'$end_of_table' ->
			skip;
		_->
			[RoomInfo|_] = ets:lookup(?ETS_NIUNIU_ROOM,CurKey),
			if
				RoomInfo#niu_room_info.room_level == 10 ->
					gen_fsm:send_all_state_event(RoomInfo#niu_room_info.room_pid, 'fudai_change');
				true ->
					skip
			end,
			NextKey = ets:next(?ETS_NIUNIU_ROOM,CurKey),
			notice_players(NextKey)
	end.

add_ets_lucky_bag(Num)->
	[Info|_] = ets:lookup(?ETS_LUCKY_BAG,1),
	OldNum = Info#ets_lucky_bag.num,
	NewInfo = Info#ets_lucky_bag{
		num = OldNum+Num
	},
	ets:insert(?ETS_LUCKY_BAG,NewInfo),
	http_send_mod:do_cast_http_post_fun(post_redpool,[OldNum+Num,util:now_seconds()]),
	NewInfo.