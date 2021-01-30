%% @author zouv
%% @doc @todo 服务器开/关接口

-module(main).

-include("common.hrl").

-define(APP_LIST, [asn1, crypto, public_key, ssl, inets, hipe, mnesia, syntax_tools, compiler, goldrush, lager, util,
                   protobuffs,rfc4627_jsonrpc,mysql,statistic_server,
                   network_proto, db, gate, login, gateway, percent_encoding, http_server]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1, stop/0]).

%% -------------------------
%% 开启服务器
%% -------------------------
start(TempNodeIndex) ->
	[TempNodeIndex1] = TempNodeIndex,
	NodeIndex = erlang:list_to_integer(atom_to_list(TempNodeIndex1)),
	config_app:set_node_index(NodeIndex),
	%% 开启应用
	SuccList = start_app(?APP_LIST, []),
	if
		length(SuccList) == length(?APP_LIST) ->
			ok;
		true ->
			lager:log(error, self(), "___SERVER APP START FAILURE !!!", [])
	end,
	%% 应对写入数据库较频繁报错
	mnesia_monitor:set_env(dc_dump_limit, 40),
	mnesia_monitor:set_env(dump_log_write_threshold, 50000),
	ok.

%% 开启应用
start_app([], AccList) ->
	AccList;
start_app([E | L], AccList) ->
	case application:start(E) of
		ok ->
			start_app(L, [E | AccList]);
		{error, {SkipError, App}} ->
			io:format("~n error! application = ~p, info = ~p~n", [E, {SkipError, App}]),
			AccList;
		{error, Reason} ->
			stop_app(AccList),
			throw({error, {E, Reason}}),
			AccList
	end.

%% 停止应用
stop_app([]) ->
	ok;
stop_app([E | L]) ->
	application:stop(E),
	io:format("~n ___stop application : ~p", [E]),
	stop_app(L).

%% %% 加载配置
%% load_base_config([]) ->
%% 	%mnesia_monitor:set_env(dump_log_write_threshold, 5000).
%% 	ok;
%% load_base_config([E | L]) ->
%% 	data_gen:import_config(E),
%% 	load_base_config(L).

%% -------------------------
%% 停止服务器
%% -------------------------
%main:stop().
stop() ->
    gate_app:stop(0),
    init:stop().

%% ====================================================================
%% Internal functions
%% ====================================================================
