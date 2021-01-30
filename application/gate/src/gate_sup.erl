
-module(gate_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type, Params), {I, {I, start_link, Params}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	%% 初始化日志系统
    %filelib:ensure_dir("../log/"),
	%{{Yeah, Month, Day}, _} = calendar:local_time(),
	%DayInfoStr = io_lib:format("~p-~p-~p",[Yeah, Month, Day]),
	%FileName = lists:concat(["../log/log_", DayInfoStr, ".log"]),
    %FileName = "../log/log_node.log",
    %% error_logger:logfile({open, FileName}),
	
%% 	db_tools:wait_tables_in_dbnode(),

    {ok, { {one_for_all, 5, 10}, [
                                  ?CHILD(announcement_server, worker, []),
                                  ?CHILD(roleid_generator_sup, supervisor, []),
                                  ?CHILD(role_processor_sup, supervisor, []),
                                  ?CHILD(role_manager, worker, [])
                                 ]} }.


