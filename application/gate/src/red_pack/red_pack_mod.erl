%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 21:39
%%%-------------------------------------------------------------------
-module(red_pack_mod).
-author("wodong_0013").

-behaviour(gen_server).
%% API

-record(state, {}).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/red_pack_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,
	get_red_pack_all_num/0,
	init_ets/0
]).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),
	init_ets(),
	erlang:send_after(120*1000, self(), 'check_out_time_redpack'),
	State = #state{},
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


init_ets() ->
	ets:delete_all_objects(?ETS_RED_PACK),
	ets:delete_all_objects(?ETS_PLAYER_RED_PACK_SEARCH_KEY),
	RedPackInfoList = red_pack_info_db:get(),
	lists:map(fun(E) ->
		ets:insert(?ETS_RED_PACK, E) end, RedPackInfoList).

do_cast({'match_and_change_red_pack_search_key', Id, NextKey}, State) ->
	Pattern = #ets_player_red_pack_search_key{
		_ = '_',
		key = Id
	},
	case ets:match_object(?ETS_PLAYER_RED_PACK_SEARCH_KEY, Pattern) of
		[] ->
			skip;
		List ->
			%?INFO_LOG("match_and_change_red_pack_search_key~p~n",[List]),
			NewList =
				lists:map(fun(E) ->
					E#ets_player_red_pack_search_key{
						key = NextKey
					} end, List),
			%?INFO_LOG("new_list~p~n",[NewList]),
			lists:foreach(fun(E) ->
				ets:insert(?ETS_PLAYER_RED_PACK_SEARCH_KEY, E) end, NewList)
	end,
	{noreply, State};

%% do_cast({'red_pack_num_change', Num}, State) ->
%% 	{ok, [Info]} = red_pack_total_info_db:get(1),
%% 	OldNum = Info#red_pack_total_info.all_red_pack_num,
%% 	NewInfo = Info#red_pack_total_info{
%% 		all_red_pack_num = max(0, (OldNum + Num))
%% 	},
%% 	save_red_pack_total_info(NewInfo),
%% 	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

%% 清除过期红包
do_info('check_out_time_redpack', State) ->
	%% 创建时间需大于该时间
	erlang:send_after(120*1000, self(), 'check_out_time_redpack'),

	CheckSecond = util:now_seconds() - 12*3600,
	ets:foldl(fun(E, _Acc) ->
		if
			E#red_pack_info.create_time > CheckSecond ->
				skip;
			true ->
				player_redpack_util:do_cancel_redpack(E)
		end end, [], ?ETS_RED_PACK),
	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

%% init_red_pack_total_info() ->
%% 	case red_pack_total_info_db:get(1) of
%% 		{ok, [_Info]} ->
%% 			skip;
%% 		_ ->
%% 			Info = #red_pack_total_info{
%% 				key = 1,
%% 				all_red_pack_num = 0
%% 			},
%% 			save_red_pack_total_info(Info)
%% 	end.

%% save_red_pack_total_info(Info) ->
%% 	DBFun = fun() ->
%% 		red_pack_total_info_db:t_write(Info)
%% 	end,
%% 	DBSuccessFun = fun() -> void end,
%% 	case dal:run_transaction_rpc(DBFun) of
%% 		{atomic, _} ->
%% 			DBSuccessFun();
%% 		{aborted, Reason} ->
%% 			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
%% 			error
%% 	end.


get_red_pack_all_num() ->
	ets:info(?ETS_RED_PACK, size).