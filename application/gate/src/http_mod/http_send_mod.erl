%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 四月 2017 15:41
%%%-------------------------------------------------------------------
-module(http_send_mod).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").


%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,
	do_cast_http_post_fun/2
]).

-record(state, {}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

%% ====================================================================
init([ModProcessName]) ->
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),

	%% 发送在线数据
	send_after_post_online_info(),
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

do_cast({'post_http', FunName, ParamList}, State) ->
	erlang:apply(http_static_util, FunName, ParamList),
	{noreply, State};

do_cast('do_send_all_userinfo', State) ->
	ntools:send_all_player_http_userinfo(),
	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info('post_online_info', State) ->
	http_static_util:post_online_info(),
	send_after_post_online_info(),
	{noreply, State};

%% 补发一次统计
do_info({http, {_RequestId, Result}}, State)->
	case Result of
		{{_, 200, _}, _, Content} ->
			{ok, JsonData, _} = rfc4627:decode(Content),
			{ok, Code} = rfc4627:get_field(JsonData, "code"),
			case Code of
				1 ->
					{ok, Msg} = rfc4627:get_field(JsonData, "msg"),
					%PlayerInfo = player_util:get_dic_player_info(),
					io:format("Post Url ~ts~n", [Msg]);
				_ ->
					skip
			end;
		_ ->
			skip
	end,
	%erlang:apply(http_static_util, post_url_base_one_time, ParamList),
	{noreply, State};

%% %% 补发一次统计
%% do_info({'do_http_request', ParamList}, State)->
%% 	%erlang:apply(http_static_util, post_url_base_one_time, ParamList),
%% 	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

send_after_post_online_info() ->
	erlang:send_after(5*60000, self(), 'post_online_info').

%% 异步
do_cast_http_post_fun(FunName, ParamList) ->
	gen_server:cast(get_mod_pid(), {'post_http', FunName, ParamList}).