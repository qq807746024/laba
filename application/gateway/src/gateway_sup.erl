
-module(gateway_sup).
-include("../../gate/include/logger.hrl").
-behaviour(supervisor).

%% API
-export([
         start_link/0, 
         tcp_listener_started/2, 
         tcp_listener_stopped/4, 
         start_client/2
        ]).

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
    ClientPlugin = socket_callback:get_client_mod(),
    Port = config_app:get_tcp_port(),
    OnStartup = {?MODULE, tcp_listener_started, []},
    OnShutdown = {?MODULE, tcp_listener_stopped, []},
    AcceptCallback = {?MODULE, start_client, []},
    AcceptorCount = 10,
    {ok, { {one_for_one, 5, 10}, [
                                  ?CHILD(tcp_client_sup, supervisor, [ClientPlugin]),
                                  ?CHILD(tcp_listener_sup, supervisor, [Port ,OnStartup, OnShutdown, AcceptCallback, AcceptorCount])
                                 ]
         } }.

tcp_listener_started(IPAddress, Port) ->
    ?INFO_LOG("~p Game tcp listener started at ~p : ~p ~p", [?MODULE, IPAddress, Port, self()]).

tcp_listener_stopped(LSock, IPAddress, Port, Reason) ->
    ?INFO_LOG("~p Game tcp listener Stopped at ~p, info : ~p ~p", [?MODULE, {LSock, IPAddress, Port}, Reason, self()]).

start_client(_Sock, _Pid) ->
    ok.

