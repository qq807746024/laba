%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 三月 2017 18:30
%%%-------------------------------------------------------------------
-module(laba_mod).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include("laba.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/laba_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(TIMER_SEC_FRESH, 3).	%% 3s检测刷新一次
-define(DIC_POOL_NUM, dic_pool_num).
-define(TIMER_SEC_SYN_TO_DB, 60).	%% 60s同步到db上
-define(TIMER_SEC_CHK_RANK, 60). %% 60s检查一次排行榜是否发榜

-define(DIC_POOL_NUM_SUPER_LABA, dic_pool_num_super_laba).	% 超级水果
-define(SUPER_LABA_RANK_REWARD_LIMIT, 1000000000).  %% 拉霸中奖限制

-define(DIC_AIRLABA_POOL_NUM, dic_airlaba_pool_num). % 空战 laba 奖池

-define(IS_POOLNUM_NOTIFY_FULL_SERVER, false). % 奖池是否全服广播（超级拉吧，飞机）

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,
	init_ets/0,
	init_ets_super_laba/0,
	init_laba_depot/0,
	%init_airlaba_pool/0,
	send_super_laba_rank_reward/1,
	get_laba_pool_config/2,
	is_fruit_pool_enough_then_update/7,
	is_super_fruit_pool_enough_then_update/7,
	is_airlaba_pool_enough_then_update/7,
	cast_to_notice_player_airlaba_pool_num/1,
	cast_to_notice_player_pool_num_super_laba/1,
	cast_to_notice_player_pool_num/1,
	cast_add_airlaba_pool/2
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
	%% 总数定时刷新 1s 刷新

	%% 初始laba库存 之后1分钟同步一次到db
	init_laba_depot(),
	init_airlaba_pool(),

	erlang:send_after(?TIMER_SEC_FRESH *1000, self(), {'check_notice_pool_change', 0,{0,0},{0,0}}),
	erlang:send_after(?TIMER_SEC_SYN_TO_DB *1000, self(), 'update_laba_depot_to_db'),
	erlang:send_after(?TIMER_SEC_SYN_TO_DB *1000, self(), 'update_airlaba_pool_to_db'),
	erlang:send_after(?TIMER_SEC_CHK_RANK * 1000, self(), 'chk_rank'),

	ets:delete_all_objects(?ETS_LABA_PLAYER_INFO),
	init_ets(),
	init_ets_super_laba(),
	State = #state{},
	{ok, State}.

init_laba_depot() ->
	case laba_depot_info_db:get(1) of
		{ok, [LabaDepot]} ->
			LabaDepotNum = LabaDepot#laba_depot_info.total_depot;
		_ ->
			LabaDepotNum = player_util:get_server_const(?CONST_CONFIG_KEY_FRUIT_INIT_POOL_NUM)
	end,
	put(?DIC_POOL_NUM, LabaDepotNum),
	case laba_depot_info_db:get(2) of
		{ok, [LabaDepot2]} ->
			case LabaDepot2#laba_depot_info.total_depot of
				{A, _} ->
					if
						not is_integer(A) ->
							LabaDepotNum2 = {?SUPER_LABA_RANK_REWARD_LIMIT, 0};
						true ->
							LabaDepotNum2 = LabaDepot2#laba_depot_info.total_depot
					end;
				_ ->
					LabaDepotNum2 = {?SUPER_LABA_RANK_REWARD_LIMIT, 0}
			end;
		_ ->
			LabaDepotNum2 = {?SUPER_LABA_RANK_REWARD_LIMIT, 0}
	end,
	put(?DIC_POOL_NUM_SUPER_LABA, LabaDepotNum2).

init_airlaba_pool() ->
	{PoolNum, RankPoolNum} = case airlaba_pool_db:get(1) of
		{ok, [AirLabaPool]} ->
			{AirLabaPool#airlaba_pool.pool_num, AirLabaPool#airlaba_pool.rank_pool_num};
		_ ->
			player_util:get_server_const(?CONST_CONFIG_KEY_AIRLABA_POOL_DEFAULT_VAL)
	end,
	put(?DIC_AIRLABA_POOL_NUM, {PoolNum, RankPoolNum}).


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

%% 分奖池
do_call({'call_dis_pool_num', {AddNum, _}, DisPercent, PlayerInfo},  _From, State) ->
	NowNum = get(?DIC_POOL_NUM),
	Reply =
		if
			DisPercent > 0 ->
				[Config1] = ets:lookup(?ETS_LABA_CONST_LIST, 2),
				[Config2] = ets:lookup(?ETS_LABA_CONST_LIST, 1),
				{FaxRateP, FaxRateR} = Config1#laba_const_config.param,
				SystemTax = Config2#laba_const_config.param,
				PoolRewardTax = (FaxRateP + FaxRateR + SystemTax) / 100,
				Rewardnum = trunc(DisPercent* (NowNum + AddNum) * (1 - PoolRewardTax)),
				update_pool_win_player(PlayerInfo, Rewardnum,1),
				put(?DIC_POOL_NUM, min(2000000000,max(0, NowNum + AddNum - Rewardnum))),
				%?INFO_LOG("OldPool~p, Reward~p, NowPool~p", [NowNum, Rewardnum, get(?DIC_POOL_NUM)]),
				{ok, Rewardnum};
			true ->
				?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}]),
				false
		end,
	{reply, Reply, State};

do_call({'call_dis_pool_num_super_laba', {AddNumPool, AddNumRank}, DisPercent, PlayerInfo},  _From, State) ->
	{NowNumPool, NowNumRank} = get(?DIC_POOL_NUM_SUPER_LABA),
	Reply =
		if
			DisPercent > 0 ->
				[Config1] = ets:lookup(?ETS_LABA_CONST_LIST, 5),
				[Config2] = ets:lookup(?ETS_LABA_CONST_LIST, 4),
				{FaxRateP, _} = Config1#laba_const_config.param,
				SystemTax = Config2#laba_const_config.param,
				PoolRewardTax = (FaxRateP + SystemTax) / 100,
				Rewardnum = trunc(DisPercent* (NowNumPool + AddNumPool) * (1 - PoolRewardTax)),
				update_pool_win_player(PlayerInfo, Rewardnum,2),
				%?INFO_LOG("call_dis_pool_num_super_laba~p~n",[{DisPercent* (NowNum + AddNum),Rewardnum}]),
				put(?DIC_POOL_NUM_SUPER_LABA, {min(2000000000,max(0, NowNumPool + AddNumPool - Rewardnum)), NowNumRank + AddNumRank}),
				%?INFO_LOG("OldPool~p, Reward~p, NowPool~p", [NowNum, Rewardnum, get(?DIC_POOL_NUM)]),
				{ok, Rewardnum};
			true ->
				?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}]),
				false
		end,
	{reply, Reply, State};

do_call('call_pool_num',  _From, State) ->
	NowNum = get(?DIC_POOL_NUM),
	{reply,{ok, NowNum}, State};

do_call('call_super_pool_num',  _From, State) ->
	{NowNum, _} = get(?DIC_POOL_NUM_SUPER_LABA),
	{reply, {ok,NowNum}, State};

do_call(Request, From, State) ->
	?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
	{reply, ok, State}.

do_cast({'refresh_laba_config'},State)->
	init_ets(),
	{noreply, State};

do_cast({'rank_reward_check', RankList},State) ->
	{Ori, NowNum} = get(?DIC_POOL_NUM_SUPER_LABA),
	if
		NowNum  > 0 ->
			RewardNum = NowNum,
			put(?DIC_POOL_NUM_SUPER_LABA, {Ori, NowNum}),

			ConfigList = fruit_rank_reward_config_db:get(),
			PbList =
			lists:foldl(fun(E,Acc) ->
				{ok,EId} = id_transform_util:role_id_to_internal(E#pb_rank_info.player_uuid),
				if
					E#pb_rank_info.rank > 30  ->
						Acc;
					EId == 0 ->
						Acc;
					true ->
						GoldNum =
							case lists:keyfind(E#pb_rank_info.rank,#fruit_rank_reward_config.key,ConfigList) of
								false ->
									0;
								Tuple->
									trunc(Tuple#fruit_rank_reward_config.percent * RewardNum /100)
							end,
						Content  = io_lib:format("恭喜您在上一周的超级水果排行榜中名列第[[5bf6de]~p[-]],获得[[5bf6de]~p[-]]金币的排名奖励。", [E#pb_rank_info.rank, GoldNum]),
						player_mail:send_system_mail(EId, 1, ?MAIL_TYPE_SUPER_LABA_RANK_REWARD, "超级水果", Content, [{?ITEM_ID_GOLD, GoldNum}]),
						EPb = #pb_hundred_last_week_data{
							rank = E#pb_rank_info.rank,
							reward_gold = GoldNum,
							name1_round_win = "--",
							name2_total_win = E#pb_rank_info.player_name
						},
						[EPb|Acc]
				end
				end,[],RankList),

			RankData = #fruit_rank_history{
				date = util:now_to_local_string(),
				rank = PbList
			},
			fruit_rank_history_db:clean(),
			fruit_rank_history_db:write(RankData);
		true ->
			%put(?DIC_POOL_NUM_SUPER_LABA, ?SUPER_LABA_RANK_REWARD_LIMIT),
			RankData1 = #fruit_rank_history{
				date = util:now_to_local_string(),
				rank = []
			},
			fruit_rank_history_db:clean(),
			fruit_rank_history_db:write(RankData1)
	end,
	{noreply, State};

%% 进入房间时发送
do_cast({'cast_to_notice_player_pool_num', GateId}, State) ->
	Msg = packet_pool_num_msg_enter(),
	%?INFO_LOG("cast_to_notice_player_pool_num ~p~n",[Msg]),
	tcp_client:send_data(GateId, Msg),
	{noreply, State};

do_cast({'cast_to_notice_player_pool_num_super_laba', GateId}, State) ->
	Msg = packet_pool_num_super_laba_msg_enter(),
	%?INFO_LOG("cast_to_notice_player_pool_num ~p~n",[Msg]),
	tcp_client:send_data(GateId, Msg),
	{noreply, State};

do_cast({'cast_to_notice_player_airlaba_pool_num', GateId}, State) ->
	Msg = packet_airlaba_pool_msg_enter(),
	tcp_client:send_data(GateId, Msg),
	{noreply, State};

%% 增加奖池数量
do_cast({'cast_add_pool_num', {AddNum, AddRank}}, State) ->
	{NowNum, NowRank} = get(?DIC_POOL_NUM),
	put(?DIC_POOL_NUM, {NowNum + AddNum, NowRank + AddRank}),
	{noreply, State};

do_cast({'cast_add_pool_num_super_laba', {AddPoolNum, AddRankNum}}, State) ->
	{NowNumPool, NowNumRank} = get(?DIC_POOL_NUM_SUPER_LABA),
	put(?DIC_POOL_NUM_SUPER_LABA, {NowNumPool + AddPoolNum, NowNumRank + AddRankNum}),
	{noreply, State};

do_cast({'cast_add_airlaba_pool', PoolAdd, RankAdd}, State) ->
	{OldPoolNum, OldRankNum} = get(?DIC_AIRLABA_POOL_NUM),
	put(?DIC_AIRLABA_POOL_NUM, {OldPoolNum + PoolAdd, OldRankNum + RankAdd}),
	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info('update_laba_depot_to_db', State) ->
	NowNum = get(?DIC_POOL_NUM),
	NowNum2 = get(?DIC_POOL_NUM_SUPER_LABA),
	%?INFO_LOG("update_laba_depot_to_db -->~p~n", [{NowNum, NowNum2}]),
	Rec = #laba_depot_info{id = 1, total_depot = NowNum},
	Rec2 = #laba_depot_info{id = 2, total_depot = NowNum2},
	laba_depot_info_db:write(Rec),
	laba_depot_info_db:write(Rec2),
	erlang:send_after(?TIMER_SEC_SYN_TO_DB *1000, self(), 'update_laba_depot_to_db'),
	{noreply, State};

do_info('update_airlaba_pool_to_db', State) ->
	{PoolNum, RankPoolNum} = get(?DIC_AIRLABA_POOL_NUM),
	airlaba_pool_db:write(#airlaba_pool{
		id = 1,
		pool_num = PoolNum,
		rank_pool_num = RankPoolNum
	}),
	erlang:send_after(?TIMER_SEC_SYN_TO_DB *1000, self(), 'update_airlaba_pool_to_db'),
	{noreply, State};


do_info({'check_notice_pool_change', OldNum,{OldNum2Pool,OldNum2Rank},{OldALPoolNum, OldALRankPoolNum}}, State) ->
	NowNum = get(?DIC_POOL_NUM),
	{NowNum2Pool, NowNum2Rank} = get(?DIC_POOL_NUM_SUPER_LABA),
	%{NowALPoolNum, NowALRankPoolNum} = get(?DIC_AIRLABA_POOL_NUM),
	{NowALPoolNum, NowALRankPoolNum} = {0, 0},%mutisrv_shared_deport_mod:call_get_airlaba_pools(),
	if
		OldNum =/= NowNum ->
			send_to_all_pool_num_msg(NowNum);
		true ->
			skip
	end,
	if
		?IS_POOLNUM_NOTIFY_FULL_SERVER ->
			if
				OldNum2Pool =/= NowNum2Pool orelse OldNum2Rank =/= NowNum2Rank orelse OldALPoolNum =/= NowALPoolNum orelse OldALRankPoolNum =/= NowALRankPoolNum ->
					send_to_all_pool_num_ol(NowNum2Pool, NowNum2Rank, NowALPoolNum, NowALRankPoolNum);
				true ->
					skip
			end;
		true ->
			if
				OldNum2Pool =/= NowNum2Pool orelse OldNum2Rank =/= NowNum2Rank ->
					send_to_all_pool_num_super_laba_msg(NowNum2Pool, NowNum2Rank);
				true ->
					skip
			end,
			if
				OldALPoolNum =/= NowALPoolNum orelse OldALRankPoolNum =/= NowALRankPoolNum ->
					send_to_all_pool_num_airlaba_msg(NowALPoolNum, NowALRankPoolNum);
				true ->
					skip
			end
	end,
	erlang:send_after(?TIMER_SEC_FRESH *1000, self(), {'check_notice_pool_change', NowNum,{NowNum2Pool,NowNum2Rank},{NowALPoolNum,NowALRankPoolNum}}),
	{noreply, State};

do_info('chk_rank', State) ->
	IsTimeToCleanRank = airlaba_bet_rank_reward_mod:is_time_to_clean_rank(),
	if
		?IS_MUTISRV_RANK ->
			rank_mod:sync_airlaba_rank();
		IsTimeToCleanRank ->
			{NowALPoolNum, NowALRankPoolNum} = get(?DIC_AIRLABA_POOL_NUM),
			rank_mod:post_send_and_clean_airlaba_rank(NowALRankPoolNum),
			put(?DIC_AIRLABA_POOL_NUM, {NowALPoolNum, 0});
		true ->
			skip
	end,
	erlang:send_after(?TIMER_SEC_CHK_RANK * 1000, self(), 'chk_rank'),
	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

%% 发送给所有人奖池数量
send_to_all_pool_num_msg(NowNum) ->
	Msg = packet_pool_num_msg(NowNum),
	ets:foldl(fun(ERec, _Acc) ->
		if
			ERec#ets_laba_player_info.is_robot orelse ERec#ets_laba_player_info.is_in_airlaba ->
				skip;
			true ->
				EPlayerId = ERec#ets_laba_player_info.player_id,
				tcp_client:send_data(hundred_niu_event_handler:get_player_gate_id(EPlayerId), Msg)
		end end , [], ?ETS_LABA_PLAYER_INFO).

send_to_all_pool_num_super_laba_msg(NowNum, RankNum) ->
	Msg = packet_pool_num_super_laba_msg(NowNum, RankNum),
	ets:foldl(fun(ERec, _Acc) ->
		if
			ERec#ets_laba_player_info.is_robot orelse ERec#ets_laba_player_info.is_in_airlaba ->
				skip;
			true ->
				EPlayerId = ERec#ets_laba_player_info.player_id,
				tcp_client:send_data(hundred_niu_event_handler:get_player_gate_id(EPlayerId), Msg)
		end end , [], ?ETS_SUPER_LABA_PLAYER_INFO).

send_to_all_pool_num_ol(SFNowNumPool, SFNowNumRank, ALPoolNum, ALRankPoolNum) ->
	MsgSF = packet_pool_num_super_laba_msg(SFNowNumPool, SFNowNumRank),
	MsgAL = packet_airlaba_pool_msg(ALPoolNum, ALRankPoolNum),
	ets:foldl(fun(ERec, _Acc) ->
		if
			undefined =/= ERec#ets_online.gate_pid ->
				%?INFO_LOG("---000---"),
				tcp_client:send_data(ERec#ets_online.gate_pid, MsgSF),
				tcp_client:send_data(ERec#ets_online.gate_pid, MsgAL);
			true ->
				skip
		end
	end , [], ?ETS_ONLINE).

send_to_all_pool_num_airlaba_msg(PoolNum, RankPoolNum) ->
	Msg = packet_airlaba_pool_msg(PoolNum, RankPoolNum),
	ets:foldl(fun(ERec, _Acc) ->
		if
			ERec#ets_laba_player_info.is_robot orelse not ERec#ets_laba_player_info.is_in_airlaba ->
				skip;
			true ->
				EPlayerId = ERec#ets_laba_player_info.player_id,
				tcp_client:send_data(hundred_niu_event_handler:get_player_gate_id(EPlayerId), Msg)
		end end , [], ?ETS_LABA_PLAYER_INFO).

packet_pool_num_msg_enter() ->
	NowNum = get(?DIC_POOL_NUM),
	packet_pool_num_msg2(NowNum, 0).

packet_pool_num_super_laba_msg_enter() ->
	{NowNum, RankNum} = get(?DIC_POOL_NUM_SUPER_LABA),
	%?INFO_LOG("sasasasa -->~p~n", [{NowNum, RankNum}]),
	packet_pool_num_msg2(NowNum, RankNum).

packet_airlaba_pool_msg_enter() ->
	{PoolNum, RankPoolNum} = get(?DIC_AIRLABA_POOL_NUM),
	packet_airlaba_pool_msg(PoolNum, RankPoolNum).

packet_pool_num_msg(NowNum) ->
	packet_pool_num_msg2(NowNum, 0).

packet_pool_num_super_laba_msg(NowNum, RankNum) ->
	packet_pool_num_msg2(NowNum, RankNum).

packet_pool_num_msg2(NowNum, RankNum) ->
	#sc_laba_pool_num_update{
		total_pool_num = integer_to_list(NowNum),
		total_rank_num = integer_to_list(RankNum)
	}.

packet_airlaba_pool_msg(PoolNum, RankPoolNum) ->
	#sc_airlaba_pool_num_update {
		pool_num = integer_to_list(PoolNum),
		rank_pool_num = integer_to_list(RankPoolNum)
	}.

init_ets() ->
	ConfigList = laba_fruit_config_db:get_base(),
	lists:foreach(fun(ERec) ->
		ets:insert(?ETS_LABA_FRUIT_CONFIG, ERec) end, ConfigList).

init_ets_super_laba() ->
	ConfigList = super_fruit_config_db:get(),
	lists:foreach(fun(ERec) ->
		ets:insert(?ETS_SUPER_LABA_FRUIT_CONFIG, ERec) end, ConfigList).


update_pool_win_player(PlayerInfo, Rewardnum,1) ->
	{ok, PlayerUuid} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
	NowSec = util:now_seconds(),
	NewInfo = #pb_pool_win_player_info{
		player_uuid = PlayerUuid,
		icon_url = PlayerInfo#player_info.icon,
		player_name = PlayerInfo#player_info.player_name,
		vip_level = PlayerInfo#player_info.vip_level,
		win_gold = integer_to_list(Rewardnum),
		c_time = NowSec
	},
	laba_win_player_db:write(#laba_win_player{key = {NowSec,1},info = NewInfo}),
	update_win_player_ets(?ETS_LAST_WIN_POOL_PLAYER,{NowSec,NewInfo},1);

update_pool_win_player(PlayerInfo, Rewardnum,2) ->
	{ok, PlayerUuid} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
	NowSec = util:now_seconds(),
	NewInfo = #pb_pool_win_player_info{
		player_uuid = PlayerUuid,
		icon_url = PlayerInfo#player_info.icon,
		player_name = PlayerInfo#player_info.player_name,
		vip_level = PlayerInfo#player_info.vip_level,
		win_gold = integer_to_list(Rewardnum),
		c_time = NowSec
	},
	laba_win_player_db:write(#laba_win_player{key = {NowSec,2},info = NewInfo}),
	update_win_player_ets(?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER,{NowSec,NewInfo},2).

update_win_player_ets(EtsName,{Key,Val},Type)->
	Length = ets:info(EtsName,size),
	if
		Length >= 10 ->
			FirstKey = ets:first(EtsName),
			ets:delete(EtsName,FirstKey),
			ets:insert(EtsName,#ets_data{key = Key,value = Val}),
			laba_win_player_db:delete({FirstKey,Type});
		true ->
			ets:insert(EtsName,#ets_data{key = Key,value = Val})
	end.

send_super_laba_rank_reward(RankList)->
	gen_server:cast(get_mod_pid(),{'rank_reward_check',RankList}).

get_laba_pool_config(TestType, LabaType) ->
	case LabaType of
		?TYPE_LABA ->
			ets:lookup(?ETS_FRUIT_POOL_CONFIG, {laba, TestType});
		?TYPE_SUPER_LABA ->
			ets:lookup(?ETS_FRUIT_POOL_CONFIG, {super_laba, TestType});
		_ ->
			[]
	end.

is_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate) ->
	depot_manager_mod:is_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate).

is_super_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate) ->
	depot_manager_mod:is_super_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate).

is_airlaba_pool_enough_then_update(BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, TestType, IsForceUpdate) ->
	depot_manager_mod:is_airlaba_pool_enough_then_update(BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, TestType, IsForceUpdate).

cast_to_notice_player_airlaba_pool_num(GateId) ->
	gen_server:cast(laba_mod:get_mod_pid(), {'cast_to_notice_player_airlaba_pool_num', GateId}).

cast_to_notice_player_pool_num_super_laba(GateId) ->
	gen_server:cast(laba_mod:get_mod_pid(), {'cast_to_notice_player_pool_num_super_laba', GateId}).

cast_to_notice_player_pool_num(GateId) ->
	gen_server:cast(laba_mod:get_mod_pid(), {'cast_to_notice_player_pool_num', GateId}).

cast_add_airlaba_pool(PoolAdd, RankAdd) ->
	if
		?IS_MUTISRV_RANK ->
			mutisrv_shared_deport_mod:cast_add_pool(airlaba_rankpool_pool, PoolAdd, RankAdd);
		true ->
			gen_server:cast(laba_mod:get_mod_pid(), {'cast_add_airlaba_pool', PoolAdd, RankAdd})
	end.
