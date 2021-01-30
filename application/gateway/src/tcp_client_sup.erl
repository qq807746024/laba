-module(tcp_client_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

start_link([OnSocketReceive, OnSocketClose]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [OnSocketReceive, OnSocketClose]).

init([OnSocketReceive, OnSocketClose]) ->
	{ok, {{simple_one_for_one, 5, 60}, [{tcp_client, 				
                                         {tcp_client, start_link, [OnSocketReceive, OnSocketClose]},
                                         temporary,
                                         brutal_kill,
                                         worker,
                                         []}]
         }}.


