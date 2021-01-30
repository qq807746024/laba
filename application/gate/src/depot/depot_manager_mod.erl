%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 13:50
%%%	金币库存管理
%%%-------------------------------------------------------------------
-module(depot_manager_mod).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

%% 每分钟写一次库
-define(DEPOT_COUNT, depot_count).	%% 总库存值
-define(TODAY_DEPOT_COUNT, today_depot_count).	%% 今天库存值
-define(CAR_DEPOT_COUNT, car_depot_count).	%% 豪车库存值
-define(CAR_SPECIAL_COUNT, car_special_count). % 豪车库存辅助
-define(HUNDRED_DEPOT_COUNT, hundred_depot_count).	%% 百人库存值
-define(HUNDRED_SPECIAL_POOL,hundred_special_pool). %% 百人水池
-define(FRUIT_SPECIAL_POOL, fruit_special_pool). %% 水果狂欢水池
-define(SUPER_FRUIT_SPECIAL_POOL, super_fruit_special_pool). %% 超级水果水池
-define(AIRLABA_SPECIAL_POOL, airlaba_special_pool). %% laba 空战水池
-define(AIRLABA_SPECIAL_POOL_HTTP_SYNC, airlaba_special_pool_http_sync). % http 同步前 airlaba 水池变动次数

-define(AIRLABA_SPECIAL_POOL_HTTP_SYNC_MAX_COUNT, 100). % airlaba 水池变动多少次同步给 http 后台一次

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,

	get_gold_depot/1,
	add_to_depot/1,
	add_to_depot/2,
	is_fruit_pool_enough_then_update/7,
	is_super_fruit_pool_enough_then_update/7,
	is_airlaba_pool_enough_then_update/7
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
% !FIXME 这些字段应该放在 state 里面
-record(state, {}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),
	init_depot(),
	NowSecond = util:now_seconds(),
	erlang:send_after(60*1000, self(), {'syn_depot_to_db', NowSecond}),	%% 1分钟同步一次到库
	State = #state{},
	{ok, State}.

init_depot() ->
	%% 从db取值
	case gold_depot_info_db:get(1) of
		{ok, [Data]} ->
			{_, _, AirlabaFix, _} = Data#gold_depot_info.airlaba_special_pool,
			if
				0 =:= length(AirlabaFix) ->
					?INFO_LOG("Found old data for airlaba, upgrade....~n"),
					FixedData = Data#gold_depot_info {
						airlaba_special_pool = {0, 0, [0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
					};
				true ->
					FixedData = Data
			end,
			case check_today_depot(FixedData) of
				Data ->
					NewData = Data;
				NewData ->
					gold_depot_info_db:write(NewData)
			end;
		_ ->
			NewData = #gold_depot_info{
				id = 1,
				total_depot = 0,	%% 总库存
				today_depot = 0,		%% 当天库存
				car_depot = 0,      %% 豪车库存
				car_special = {0, 0, 0, 0},
				update_second = 0,		%% 上次更新库存时间
				hundred_depot = 0,
				hundred_niu_special_pool = {0,0},
				fruit_special_pool = {[0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0]},
				super_fruit_special_pool = {[0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0]},
				airlaba_special_pool = {0, 0, [0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
			},
			gold_depot_info_db:write(NewData)
	end,
	?INFO_LOG("gold_depot_info_db-->~n~p", [NewData]),
	%% 存dict 和 ets
	TotalDepot = NewData#gold_depot_info.total_depot,
	TodayDepot = NewData#gold_depot_info.today_depot,
	CarDepot = NewData#gold_depot_info.car_depot,
	put(?DEPOT_COUNT, TotalDepot),
	put(?TODAY_DEPOT_COUNT, TodayDepot),
	put(?CAR_DEPOT_COUNT,CarDepot),
	put(?CAR_SPECIAL_COUNT, NewData#gold_depot_info.car_special),
	put(?HUNDRED_DEPOT_COUNT,NewData#gold_depot_info.hundred_depot),
	put(?HUNDRED_SPECIAL_POOL,NewData#gold_depot_info.hundred_niu_special_pool),
	put(?FRUIT_SPECIAL_POOL, NewData#gold_depot_info.fruit_special_pool),
	put(?SUPER_FRUIT_SPECIAL_POOL, NewData#gold_depot_info.super_fruit_special_pool),
	put(?AIRLABA_SPECIAL_POOL, NewData#gold_depot_info.airlaba_special_pool),
	put(?AIRLABA_SPECIAL_POOL_HTTP_SYNC, 0),
	ets:insert(?ETS_GOLD_DEPOT_INFO, NewData),
	ok.

check_today_depot(Data) ->
	NowSecond = util:now_seconds(),
	case util:is_same_date(NowSecond, Data#gold_depot_info.update_second) of
		true ->
			Data;
		_ ->
			Data#gold_depot_info{
				today_depot = 0,		%% 当天库存
				car_depot = 0,
				hundred_depot = 0,
				update_second = NowSecond		%% 上次更新库存时间
			}
	end.

priv_get_fruit_pool_num(BetIndex, Config, PoolList) ->
	{_, UnionList} = lists:keyfind(BetIndex, 1, Config#fruit_pool_config.pool_config),
	case UnionList of
		all ->
			lists:foldl(fun(Num, Acc) ->
				Acc + Num
			end, 0, PoolList);
		_ ->
			lists:foldl(fun(Index, Acc) ->
				Acc + lists:nth(Index, PoolList)
			end, 0, UnionList)
	end.

priv_set_fruit_pool_num(BetIndex, AddNum, PoolList) ->
	util_lists:setnth(BetIndex, PoolList, AddNum + lists:nth(BetIndex, PoolList)).

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

% 空战 laba 获取水池（实时）
do_call({'is_airlaba_pool_enough_then_update', _BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, ?TEST_TYPE_TRY_PLAY, IsForceUpdate}, _From, State) ->
	{AddToCurPool, AddToSharedPool} = AddToPool,
	{NowPoolShared, NoModify, NowCurPoolList, NoModifyCurList} = get(?AIRLABA_SPECIAL_POOL),
	NowCurPool = lists:nth(BetIndex, NowCurPoolList),
	TotalNowNumShared = AddToSharedPool + NowPoolShared,
	TotalNowNumCur = AddToCurPool + NowCurPool,
	if
		IsUseSharedPool ->
			TotalNowNum = TotalNowNumCur + TotalNowNumShared;
		true ->
			TotalNowNum = TotalNowNumCur
	end,
	Result = TotalNowNum >= PayFromPool,
	if
		IsForceUpdate orelse Result ->
			LeftNumCur = TotalNowNumCur - PayFromPool,
			if 
				LeftNumCur >= 0 ->
					% 当级水池够赔
					NewPoolCur = LeftNumCur,
					NewPoolShared = TotalNowNumShared;
				true ->
					NewPoolCur = 0,
					NewPoolShared = TotalNowNumShared + LeftNumCur
			end,
			NewCurPoolList = util_lists:setnth(BetIndex, NowCurPoolList, NewPoolCur),
			put(?AIRLABA_SPECIAL_POOL, {NewPoolShared, NoModify, NewCurPoolList, NoModifyCurList}),
			SyncCount = get(?AIRLABA_SPECIAL_POOL_HTTP_SYNC),
			if 
				SyncCount >= ?AIRLABA_SPECIAL_POOL_HTTP_SYNC_MAX_COUNT ->
					put(?AIRLABA_SPECIAL_POOL_HTTP_SYNC, 0),
					http_send_mod:do_cast_http_post_fun(post_airlaba_pool_log,[NewPoolShared, NewCurPoolList,
						?TEST_TYPE_TRY_PLAY, util:now_seconds()]);
				true ->
					put(?AIRLABA_SPECIAL_POOL_HTTP_SYNC, SyncCount + 1)
			end;
		true ->
			skip
	end,
	{reply, {ok, Result}, State};

do_call({'is_airlaba_pool_enough_then_update', _BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, ?TEST_TYPE_ENTERTAINMENT, IsForceUpdate}, _From, State) ->
	{AddToCurPool, AddToSharedPool} = AddToPool,
	{NoModify, NowPoolShared, NoModifyCurList, NowCurPoolList} = get(?AIRLABA_SPECIAL_POOL),
	NowCurPool = lists:nth(BetIndex, NowCurPoolList),
	TotalNowNumShared = AddToSharedPool + NowPoolShared,
	TotalNowNumCur = AddToCurPool + NowCurPool,
	if
		IsUseSharedPool ->
			TotalNowNum = TotalNowNumCur + TotalNowNumShared;
		true ->
			TotalNowNum = TotalNowNumCur
	end,
	Result = TotalNowNum >= PayFromPool,
	if
		IsForceUpdate orelse Result ->
			LeftNumCur = TotalNowNumCur - PayFromPool,
			if 
				LeftNumCur >= 0 ->
					% 当级水池够赔
					NewPoolCur = LeftNumCur,
					NewPoolShared = TotalNowNumShared;
				true ->
					NewPoolCur = 0,
					NewPoolShared = TotalNowNumShared + LeftNumCur
			end,
			NewCurPoolList = util_lists:setnth(BetIndex, NowCurPoolList, NewPoolCur),
			put(?AIRLABA_SPECIAL_POOL, {NoModify, NewPoolShared, NoModifyCurList, NewCurPoolList}),
			SyncCount = get(?AIRLABA_SPECIAL_POOL_HTTP_SYNC),
			if 
				SyncCount >= ?AIRLABA_SPECIAL_POOL_HTTP_SYNC_MAX_COUNT ->
					put(?AIRLABA_SPECIAL_POOL_HTTP_SYNC, 0),
					http_send_mod:do_cast_http_post_fun(post_airlaba_pool_log,[NewPoolShared, NewCurPoolList,
						?TEST_TYPE_ENTERTAINMENT, util:now_seconds()]);
				true ->
					put(?AIRLABA_SPECIAL_POOL_HTTP_SYNC, SyncCount + 1)
			end;
		true ->
			skip
	end,
	{reply, {ok, Result}, State};

% 获取水果狂欢水池（实时）
do_call({BetIndex, AddNum, SetNum, PayNum, _EarnPec, 'is_fruit_pool_enough_then_update', ?TEST_TYPE_TRY_PLAY, IsForceUpdate}, _From, State) ->
	{NowPool, NoModify} = get(?FRUIT_SPECIAL_POOL),
	[Config] = ets:lookup(?ETS_FRUIT_POOL_CONFIG, {laba, ?TEST_TYPE_TRY_PLAY}),
	NowNum = priv_get_fruit_pool_num(BetIndex, Config, NowPool),
	TotalNowNum = AddNum + NowNum,
	Result = TotalNowNum >= PayNum,
	%?INFO_LOG("is_fruit_pool_enough_then_update==>~p~n", [{BetIndex, NowNum, TotalNowNum, Result, NowPool}]),
	if
		IsForceUpdate orelse Result ->
			SubNum = AddNum - PayNum,
			LeftNum = TotalNowNum - PayNum,
			NewPool = priv_set_fruit_pool_num(BetIndex, SubNum, NowPool),
			put(?FRUIT_SPECIAL_POOL, {NewPool, NoModify}),
			http_send_mod:do_cast_http_post_fun(post_fruit_pool_log,[BetIndex, LeftNum, LeftNum - NowNum, SetNum - AddNum, 0,
				?TEST_TYPE_TRY_PLAY, NewPool, util:now_seconds()]);
		true ->
			skip
	end,
	%?INFO_LOG("1 fruit pool current num ~p, now pay num ~p, left ~p, ~p~n", [TotalNowNum, PayNum, LeftNum, Result]),
	{reply, {ok, Result}, State};

do_call({BetIndex, AddNum, SetNum, PayNum, _EarnPec, 'is_fruit_pool_enough_then_update', ?TEST_TYPE_ENTERTAINMENT, IsForceUpdate}, _From, State) ->
	{NoModify, NowPool} = get(?FRUIT_SPECIAL_POOL),
	[Config] = ets:lookup(?ETS_FRUIT_POOL_CONFIG, {laba, ?TEST_TYPE_ENTERTAINMENT}),
	NowNum = priv_get_fruit_pool_num(BetIndex, Config, NowPool),
	TotalNowNum = AddNum + NowNum,
	Result = TotalNowNum >= PayNum,
	if
		IsForceUpdate orelse Result ->
			SubNum = AddNum - PayNum,
			LeftNum = TotalNowNum - PayNum,
			NewPool = priv_set_fruit_pool_num(BetIndex, SubNum, NowPool),
			put(?FRUIT_SPECIAL_POOL, {NoModify, NewPool}),
			http_send_mod:do_cast_http_post_fun(post_fruit_pool_log,[BetIndex, LeftNum, LeftNum - NowNum, SetNum - AddNum, 0,
				?TEST_TYPE_ENTERTAINMENT, NewPool, util:now_seconds()]);
		true ->
			skip
	end,
	%?INFO_LOG("2 fruit pool current num ~p, now pay num ~p, left ~p, ~p~n", [TotalNowNum, PayNum, LeftNum, Result]),
	{reply, {ok, Result}, State};

do_call({BetIndex, AddNum, SetNum, PayNum, _EarnPec, 'is_super_fruit_pool_enough_then_update', ?TEST_TYPE_TRY_PLAY, IsForceUpdate}, _From, State) ->
	{NowPool, NoModify} = get(?SUPER_FRUIT_SPECIAL_POOL),
	[Config] = ets:lookup(?ETS_FRUIT_POOL_CONFIG, {super_laba, ?TEST_TYPE_TRY_PLAY}),
	NowNum = priv_get_fruit_pool_num(BetIndex, Config, NowPool),
	TotalNowNum = AddNum + NowNum,
	Result = TotalNowNum >= PayNum,
	if
		IsForceUpdate orelse Result ->
			SubNum = AddNum - PayNum,
			LeftNum = TotalNowNum - PayNum,
			NewPool = priv_set_fruit_pool_num(BetIndex, SubNum, NowPool),
			put(?SUPER_FRUIT_SPECIAL_POOL, {NewPool, NoModify}),
			http_send_mod:do_cast_http_post_fun(post_super_fruit_pool_log,[BetIndex, LeftNum, LeftNum - NowNum, SetNum - AddNum, 0,
				?TEST_TYPE_TRY_PLAY, NewPool, util:now_seconds()]);
		true ->
			skip
	end,
	%?INFO_LOG("1 super fruit pool current num ~p, now pay num ~p, left ~p, ~p~n", [TotalNowNum, PayNum, LeftNum, Result]),
	{reply, {ok, Result}, State};

do_call({BetIndex, AddNum, SetNum, PayNum, _EarnPec, 'is_super_fruit_pool_enough_then_update', ?TEST_TYPE_ENTERTAINMENT, IsForceUpdate}, _From, State) ->
	{NoModify, NowPool} = get(?SUPER_FRUIT_SPECIAL_POOL),
	[Config] = ets:lookup(?ETS_FRUIT_POOL_CONFIG, {super_laba, ?TEST_TYPE_ENTERTAINMENT}),
	NowNum = priv_get_fruit_pool_num(BetIndex, Config, NowPool),
	TotalNowNum = AddNum + NowNum,
	Result = TotalNowNum >= PayNum,
	if
		IsForceUpdate orelse Result ->
			SubNum = AddNum - PayNum,
			LeftNum = TotalNowNum - PayNum,
			NewPool = priv_set_fruit_pool_num(BetIndex, SubNum, NowPool),
			put(?SUPER_FRUIT_SPECIAL_POOL, {NoModify, NewPool}),
			http_send_mod:do_cast_http_post_fun(post_super_fruit_pool_log,[BetIndex, LeftNum, LeftNum - NowNum, SetNum - AddNum, 0,
				?TEST_TYPE_ENTERTAINMENT, NewPool, util:now_seconds()]);
		true ->
			skip
	end,
	%?INFO_LOG("2 super fruit pool current num ~p, now pay num ~p, left ~p, ~p~n", [TotalNowNum, PayNum, LeftNum, Result]),
	{reply, {ok, Result}, State};

do_call(Request, From, State) ->
	?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
	{reply, ok, State}.

%% 修改库存
do_cast({'add_to_depot', AddNum}, State) ->
	NowDepot = get(?DEPOT_COUNT),
	NewDepot = NowDepot + AddNum,
	put(?DEPOT_COUNT, NewDepot),

	NowTodayDepot = get(?TODAY_DEPOT_COUNT),
	NewTodayDepot = NowTodayDepot + AddNum,
	put(?TODAY_DEPOT_COUNT, NewTodayDepot),
	{noreply, State};

%% 修改豪车库存
do_cast({'add_to_car_depot', AddNum}, State) ->
	NowCarDepot = get(?CAR_DEPOT_COUNT),
	NewCarDepot = NowCarDepot + AddNum,
	put(?CAR_DEPOT_COUNT, NewCarDepot),

	NowDepot = get(?DEPOT_COUNT),
	NewDepot = NowDepot + AddNum,
	put(?DEPOT_COUNT, NewDepot),

	NowTodayDepot = get(?TODAY_DEPOT_COUNT),
	NewTodayDepot = NowTodayDepot + AddNum,
	put(?TODAY_DEPOT_COUNT, NewTodayDepot),

	{OldCost, OldAlreadyGiveback, OldAdjust, OldEarn} = get(?CAR_SPECIAL_COUNT),
	NewEarn = OldEarn + AddNum,
	put(?CAR_SPECIAL_COUNT, {OldCost, OldAlreadyGiveback, OldAdjust, NewEarn}),
	http_send_mod:do_cast_http_post_fun(post_car_pool_log,[NewEarn + OldAdjust, NewCarDepot, AddNum ,util:now_seconds()]),
	{noreply, State};

do_cast({'set_car_special_adjust', Adjust}, State) ->
	{OldCost, OldAlreadyGiveback, _, OldEarn} = get(?CAR_SPECIAL_COUNT),
	put(?CAR_SPECIAL_COUNT, {OldCost, OldAlreadyGiveback, Adjust, OldEarn}),
	{noreply, State};

do_cast({'set_car_total_earn', Earn}, State) ->
	{OldCost, OldAlreadyGiveback, OldAdjust, _} = get(?CAR_SPECIAL_COUNT),
	put(?CAR_SPECIAL_COUNT, {OldCost, OldAlreadyGiveback, OldAdjust, Earn}),
	{noreply, State};

do_cast({'set_car_special', NewPlayerCost, NewAlreadyGiveback}, State) ->
	{_, _, OldAdjust, OldEarn} = get(?CAR_SPECIAL_COUNT),
	put(?CAR_SPECIAL_COUNT, {NewPlayerCost, NewAlreadyGiveback, OldAdjust, OldEarn}),
	{noreply, State};

do_cast({'add_car_special', AddPlayerCost, AddAlreadyGiveback}, State) ->
	{PlayerCost, AlreadyGiveback, Adjust, Earn} = get(?CAR_SPECIAL_COUNT),
	put(?CAR_SPECIAL_COUNT, {PlayerCost + AddPlayerCost, AlreadyGiveback + AddAlreadyGiveback, Adjust, Earn}),
	{noreply, State};

%% 修改百人库存
do_cast({'add_to_hundred_depot', AddNum}, State) ->
	NowCarDepot = get(?HUNDRED_DEPOT_COUNT),
	NewCarDepot = NowCarDepot + AddNum,
	put(?HUNDRED_DEPOT_COUNT, NewCarDepot),
	%?INFO_LOG("NewCarDepot ~p~n",[NewCarDepot]),

	NowDepot = get(?DEPOT_COUNT),
	NewDepot = NowDepot + AddNum,
	put(?DEPOT_COUNT, NewDepot),

	NowTodayDepot = get(?TODAY_DEPOT_COUNT),
	NewTodayDepot = NowTodayDepot + AddNum,
	put(?TODAY_DEPOT_COUNT, NewTodayDepot),
	{noreply, State};

%% 修改百人水池
do_cast({'add_to_hundred_special_pool',AddNum1,AddNum2},State)->
	{_NowCarDepot,Recovery} = get(?HUNDRED_SPECIAL_POOL),
	%?INFO_LOG("NewCarDepot ~p~n",[NewCarDepot]),
	NewDepot = {AddNum1,AddNum2 + Recovery},
	put(?HUNDRED_SPECIAL_POOL, NewDepot),
	{noreply, State};

%% 修改水果库存
do_cast({'add_to_fruit_pool',AddNum, ?TEST_TYPE_TRY_PLAY},State)->
	{NowNum,NoModify} = get(?FRUIT_SPECIAL_POOL),

	NewDepot = {NowNum + AddNum, NoModify},
	put(?FRUIT_SPECIAL_POOL, NewDepot),
	{noreply, State};
do_cast({'add_to_fruit_pool',AddNum, ?TEST_TYPE_ENTERTAINMENT},State)->
	{NoModify, NowNum} = get(?FRUIT_SPECIAL_POOL),

	NewDepot = {NoModify, NowNum + AddNum},
	put(?FRUIT_SPECIAL_POOL, NewDepot),
	{noreply, State};

do_cast({'add_to_super_fruit_pool',AddNum, ?TEST_TYPE_TRY_PLAY},State)->
	{NowNum,NoModify} = get(?SUPER_FRUIT_SPECIAL_POOL),

	NewDepot = {NowNum + AddNum, NoModify},
	put(?SUPER_FRUIT_SPECIAL_POOL, NewDepot),
	{noreply, State};
do_cast({'add_to_super_fruit_pool',AddNum, ?TEST_TYPE_ENTERTAINMENT},State)->
	{NoModify, NowNum} = get(?SUPER_FRUIT_SPECIAL_POOL),

	NewDepot = {NoModify, NowNum + AddNum},
	put(?SUPER_FRUIT_SPECIAL_POOL, NewDepot),
	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info({'syn_depot_to_db', OldSecond}, State) ->
	NowSecond = util:now_seconds(),
	erlang:send_after(10*1000, self(), {'syn_depot_to_db', NowSecond}),	%% 1分钟同步一次到库
	case util:is_same_date(OldSecond, NowSecond) of
		true ->
			TotalDepot = get(?DEPOT_COUNT),
			TodayDepot = get(?TODAY_DEPOT_COUNT),
			NewRec = #gold_depot_info{
				id = 1,
				total_depot = TotalDepot,
				today_depot = TodayDepot,
				car_depot = get(?CAR_DEPOT_COUNT),
				car_special = get(?CAR_SPECIAL_COUNT),
				hundred_depot = get(?HUNDRED_DEPOT_COUNT),     %%百人库存
				hundred_niu_special_pool = get(?HUNDRED_SPECIAL_POOL),
				fruit_special_pool = get(?FRUIT_SPECIAL_POOL),
				super_fruit_special_pool = get(?SUPER_FRUIT_SPECIAL_POOL),
				airlaba_special_pool = get(?AIRLABA_SPECIAL_POOL),
				update_second = NowSecond
			};
		_ ->
			TotalDepot = get(?DEPOT_COUNT),
			put(?TODAY_DEPOT_COUNT, 0),
			put(?HUNDRED_DEPOT_COUNT, 0),
			put(?CAR_DEPOT_COUNT, 0),
			NewRec = #gold_depot_info{
				id = 1,
				total_depot = TotalDepot,
				today_depot = 0,
				car_depot = 0,
				car_special = get(?CAR_SPECIAL_COUNT),
				hundred_depot = 0,
				hundred_niu_special_pool = get(?HUNDRED_SPECIAL_POOL),
				fruit_special_pool = get(?FRUIT_SPECIAL_POOL),
				super_fruit_special_pool = get(?SUPER_FRUIT_SPECIAL_POOL),
				airlaba_special_pool = get(?AIRLABA_SPECIAL_POOL),
				update_second = NowSecond
			}
	end,

	gold_depot_info_db:write(NewRec),
	ets:insert(?ETS_GOLD_DEPOT_INFO, NewRec),
	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

get_gold_depot(Type) ->
	[Data] = ets:lookup(?ETS_GOLD_DEPOT_INFO, 1),
	case Type of
		'total' ->
			Data#gold_depot_info.total_depot;
		'today' ->
			Data#gold_depot_info.today_depot;
		'car'->
			Data#gold_depot_info.car_depot;
		'car_special' ->
			Data#gold_depot_info.car_special;
		'hundred'->
			Data#gold_depot_info.hundred_depot;
		'special_pool' ->
			Data#gold_depot_info.hundred_niu_special_pool;
		_ ->
			0
	end.

is_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate) ->
	gen_server:call(get_mod_pid(), {BetIndex, AddNum, SetNum, PayNum, EarnPec, 'is_fruit_pool_enough_then_update', TestType, IsForceUpdate}).

is_airlaba_pool_enough_then_update(BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, TestType, IsForceUpdate) ->
	gen_server:call(get_mod_pid(), {'is_airlaba_pool_enough_then_update', BetNum, BetIndex, AddToPool, PayFromPool, IsUseSharedPool, TestType, IsForceUpdate}).

is_super_fruit_pool_enough_then_update(BetIndex, AddNum, SetNum, PayNum, EarnPec, TestType, IsForceUpdate) ->
	gen_server:call(get_mod_pid(), {BetIndex, AddNum, SetNum, PayNum, EarnPec, 'is_super_fruit_pool_enough_then_update', TestType, IsForceUpdate}).

add_to_depot(AddNum) ->
	gen_server:cast(get_mod_pid(), {'add_to_depot', AddNum}).

%% 加豪车和 百人库存
add_to_depot(AddNum,'car') ->
	gen_server:cast(get_mod_pid(), {'add_to_car_depot', AddNum});
add_to_depot({NewPlayerCost, NewAlreadyGiveback}, 'set_car_special') ->
	gen_server:cast(get_mod_pid(), {'set_car_special', NewPlayerCost, NewAlreadyGiveback});
add_to_depot({AddPlayerCost, AddAlreadyGiveback}, 'add_car_special') ->
	gen_server:cast(get_mod_pid(), {'add_car_special', AddPlayerCost, AddAlreadyGiveback});
add_to_depot(Adjust, 'set_car_special_adjust') ->
	gen_server:cast(get_mod_pid(), {'set_car_special_adjust', Adjust});
add_to_depot(Earn, 'set_car_total_earn') ->
	gen_server:cast(get_mod_pid(), {'set_car_total_earn', Earn});
add_to_depot(AddNum,'hundred') ->
	gen_server:cast(get_mod_pid(), {'add_to_hundred_depot', AddNum});
add_to_depot({AddNum1,AddNum2},'hundred_special_pool') ->
	http_send_mod:do_cast_http_post_fun(post_brpool_log,[{AddNum1,AddNum2},util:now_seconds()]),
	gen_server:cast(get_mod_pid(), {'add_to_hundred_special_pool', AddNum1,AddNum2});
add_to_depot({AddNum, TestType}, 'fruit_pool') ->
	gen_server:cast(get_mod_pid(), {'add_to_fruit_pool', AddNum, TestType});
add_to_depot({AddNum, TestType}, 'super_fruit_pool') ->
	gen_server:cast(get_mod_pid(), {'add_to_super_fruit_pool', AddNum, TestType}).
