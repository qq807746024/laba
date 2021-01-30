-module(tcp_listener_sup).

-behaviour(supervisor).

-export([
		 start_link/4, 
		 start_link/5,
		 init/1
		]).

start_link(Port, OnStartup, OnShutdown, AcceptCallback) ->
    start_link( Port, OnStartup, OnShutdown, AcceptCallback, 1).

start_link(Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount) ->
    supervisor:start_link({local,?MODULE},?MODULE, {Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount}).

init({ Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount}) ->
	{ok, {{one_for_all, 10, 10},
          [
		   {tcp_acceptor_sup, 
			{tcp_acceptor_sup, start_link, [AcceptCallback]},
			transient, 
			infinity, 
			supervisor, 
			[tcp_acceptor_sup]},
		   
		   {tcp_listener, 
			{tcp_listener, start_link, [Port,  AcceptorCount, OnStartup, OnShutdown]},
			transient, 
			100, 
			worker, 
			[tcp_listener]}
		  ]}}.


