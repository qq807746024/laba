-module(tcp_acceptor_sup).

-behaviour(supervisor).

-export([start_link/1, init/1]).

start_link(AcceptCallback) ->
	supervisor:start_link({local,?MODULE}, ?MODULE, AcceptCallback).
	
init(AcceptCallback) ->
	{ok, {{simple_one_for_one, 10, 10}, [{tcp_acceptor, 
										  {tcp_acceptor, start_link, [AcceptCallback]},
										  transient, 
										  brutal_kill, 
										  worker, 
										  [tcp_acceptor]}]
		 }}.


