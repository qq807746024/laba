-module(test_result_manager_mod).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,
	hand_laba_testtype1_finish/3,
	print_laba_testtype1_result/0,
	reset_laba_testtype1_result/0
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {
	laba_testtype1_result
}).

-record(laba_testtype1_result, {
	min_left = 1000000, max_left = 0, min_times = 1000000, max_times = 0, min_clip = 1000000, max_clip = 0,
	num_of_all = 0,
	num_lv_1 = 0, num_lv_2 = 0, num_lv_3 = 0, num_lv_4 = 0, num_lv_5 = 0, num_lv_6 = 0, num_lv_7 = 0,
	num_lv_8 = 0, num_lv_9 = 0, num_lv_10 = 0, num_lv_11 = 0, num_lv_12 = 0, num_lv_13 = 0, num_lv_14 = 0,
	num_lv_15 = 0, num_lv_16 = 0, num_lv_17 = 0, num_lv_18 = 0, num_lv_19 = 0
}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),
	State = #state{
		laba_testtype1_result = #laba_testtype1_result{}
	},
	{ok, State}.

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

do_call(Request, From, State) ->
	?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
	{reply, ok, State}.

do_cast({reset_laba_testtype1_result}, State) ->
	NewState = State#state{
		laba_testtype1_result = #laba_testtype1_result{}
	},
	{noreply, NewState};
do_cast({printf_laba_testtype1_result}, State) ->
	?INFO_LOG("laba testtype1 result: ===> ~p~n", [State#state.laba_testtype1_result]),
	{noreply, State};
do_cast({laba_testtype1_finish, LeftNum, ClipNum, Times}, State)->
	Old1 = State#state.laba_testtype1_result,
	if
		Old1#laba_testtype1_result.min_left > LeftNum ->
			Old2 = Old1#laba_testtype1_result {
				min_left = LeftNum
			};
		true ->
			Old2 = Old1
	end,
	if
		Old2#laba_testtype1_result.max_left < LeftNum ->
			Old3 = Old2#laba_testtype1_result {
				max_left = LeftNum
			};
		true ->
			Old3 = Old2
	end,
	if
		Old3#laba_testtype1_result.min_times > Times ->
			Old4 = Old3#laba_testtype1_result {
				min_times = Times
			};
		true ->
			Old4 = Old3
	end,
	if
		Old4#laba_testtype1_result.max_times < Times ->
			Old5 = Old4#laba_testtype1_result {
				max_times = Times
			};
		true ->
			Old5 = Old4
	end,
	if
		Old5#laba_testtype1_result.min_clip > ClipNum ->
			Old6 = Old5#laba_testtype1_result {
				min_clip = ClipNum
			};
		true ->
			Old6 = Old5
	end,
	if
		Old6#laba_testtype1_result.max_clip < ClipNum ->
			Old7 = Old6#laba_testtype1_result {
				max_clip = ClipNum
			};
		true ->
			Old7 = Old6
	end,
	Old8 = Old7#laba_testtype1_result {
		num_of_all = Old6#laba_testtype1_result.num_of_all + 1
	},
	if
		ClipNum >= 4500 ->
			Old9 = Old8#laba_testtype1_result {
				num_lv_1 = Old8#laba_testtype1_result.num_lv_1 + 1
			};
		true ->
			Old9 = Old8
	end,
	if
		ClipNum >= 250000 ->
			Old10 = Old9#laba_testtype1_result {
				num_lv_2 = Old9#laba_testtype1_result.num_lv_2 + 1
			};
		true ->
			Old10 = Old9
	end,
	if
		ClipNum >= 450000 ->
			Old11 = Old10#laba_testtype1_result {
				num_lv_3 = Old10#laba_testtype1_result.num_lv_3 + 1
			};
		true ->
			Old11 = Old10
	end,
	if
		ClipNum >= 1000000 ->
			Old12 = Old11#laba_testtype1_result {
				num_lv_4 = Old11#laba_testtype1_result.num_lv_4 + 1
			};
		true ->
			Old12 = Old11
	end,
	if
		ClipNum >= 2000000 ->
			Old13 = Old12#laba_testtype1_result {
				num_lv_5 = Old12#laba_testtype1_result.num_lv_5 + 1
			};
		true ->
			Old13 = Old12
	end,
	if
		ClipNum >= 4000000 ->
			Old14 = Old13#laba_testtype1_result {
				num_lv_6 = Old13#laba_testtype1_result.num_lv_6 + 1
			};
		true ->
			Old14 = Old13
	end,
	if
		ClipNum >= 8000000 ->
			Old15 = Old14#laba_testtype1_result {
				num_lv_7 = Old14#laba_testtype1_result.num_lv_7 + 1
			};
		true ->
			Old15 = Old14
	end,
	if
		ClipNum >= 15000000 ->
			Old16 = Old15#laba_testtype1_result {
				num_lv_8 = Old15#laba_testtype1_result.num_lv_8 + 1
			};
		true ->
			Old16 = Old15
	end,
	if
		ClipNum >= 30000000 ->
			Old17 = Old16#laba_testtype1_result {
				num_lv_9 = Old16#laba_testtype1_result.num_lv_9 + 1
			};
		true ->
			Old17 = Old16
	end,
	if
		ClipNum >= 50000000 ->
			Old18 = Old17#laba_testtype1_result {
				num_lv_10 = Old17#laba_testtype1_result.num_lv_10 + 1
			};
		true ->
			Old18 = Old17
	end,
	if
		ClipNum >= 100000000 ->
			Old19 = Old18#laba_testtype1_result {
				num_lv_11 = Old18#laba_testtype1_result.num_lv_11 + 1
			};
		true ->
			Old19 = Old18
	end,
	if
		ClipNum >= 200000000 ->
			Old20 = Old19#laba_testtype1_result {
				num_lv_12 = Old19#laba_testtype1_result.num_lv_12 + 1
			};
		true ->
			Old20 = Old19
	end,
	if
		ClipNum >= 400000000 ->
			Old21 = Old20#laba_testtype1_result {
				num_lv_13 = Old20#laba_testtype1_result.num_lv_13 + 1
			};
		true ->
			Old21 = Old20
	end,
	if
		ClipNum >= 750000000 ->
			Old22 = Old21#laba_testtype1_result {
				num_lv_14 = Old21#laba_testtype1_result.num_lv_14 + 1
			};
		true ->
			Old22 = Old21
	end,
	if
		ClipNum >= 1500000000 ->
			Old23 = Old22#laba_testtype1_result {
				num_lv_15 = Old22#laba_testtype1_result.num_lv_15 + 1
			};
		true ->
			Old23 = Old22
	end,
	if
		ClipNum >= 3000000000 ->
			Old24 = Old23#laba_testtype1_result {
				num_lv_16 = Old23#laba_testtype1_result.num_lv_16 + 1
			};
		true ->
			Old24 = Old23
	end,
	if
		ClipNum >= 5000000000 ->
			Old25 = Old24#laba_testtype1_result {
				num_lv_17 = Old24#laba_testtype1_result.num_lv_17 + 1
			};
		true ->
			Old25 = Old24
	end,
	if
		ClipNum >= 15000000000 ->
			Old26 = Old25#laba_testtype1_result {
				num_lv_18 = Old25#laba_testtype1_result.num_lv_18 + 1
			};
		true ->
			Old26 = Old25
	end,
	if
		ClipNum >= 50000000000 ->
			Old27 = Old26#laba_testtype1_result {
				num_lv_19 = Old26#laba_testtype1_result.num_lv_19 + 1
			};
		true ->
			Old27 = Old26
	end,
	NewState = State#state {
		laba_testtype1_result = Old27
	},
	{noreply, NewState};
do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

hand_laba_testtype1_finish(LeftNum, ClipNum, Times) ->
	gen_server:cast(get_mod_pid(), {laba_testtype1_finish, LeftNum, ClipNum, Times}).

print_laba_testtype1_result() ->
	gen_server:cast(get_mod_pid(), {printf_laba_testtype1_result}).

reset_laba_testtype1_result() ->
	gen_server:cast(get_mod_pid(), {reset_laba_testtype1_result}).
