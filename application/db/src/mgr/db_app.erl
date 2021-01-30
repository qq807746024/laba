-module(db_app).

-behaviour(application).

-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
%%  %% 分离出数据库
%% 	case application:get_env(db, join_external) of
%% 		{ok, DBJoinExternal} ->
%% 			ok;
%% 		_ ->
%% 			DBJoinExternal = 0
%% 	end,
%% 	if
%% 		%% 1使用了外部DB
%% 		DBJoinExternal == 1 ->
%% 			{ok, Pid} = db_external_sup:start_link();
%% 		true ->
%% 			{ok, Pid} = db_sup:start_link(),
%% 			if
%% 				%% 2DB节点，加载配置数据
%% 				DBJoinExternal == 2 ->
%% 					db_external_main:import_config("game.config");
%% 				true ->
%% 					skip
%% 			end
%% 	end,
%% 	{ok, Pid}.
    
    {ok, Pid} = db_sup:start_link(),
    
    import_config(),
    
    {ok, Pid}.

stop(_State) ->
    ok.

import_config() ->
    {ok, List} = application:get_env(db, 'data_files'),
    util:foreach(fun(EFile) ->
                      data_gen:import_config(EFile)
                  end, 
                  List),
    ok.

