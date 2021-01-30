-module(tcp_listener).
-include("../../gate/include/logger.hrl").
-behaviour(gen_server).

-record(state, {
				listen_socket, 	
				on_startup,	
				on_shutdown,
				acceptors
			   }).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([
		 start_link/4,
		 query_port/0
		]).

start_link(Port, AcceptorCount, OnStartup, OnShutdown) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {Port, AcceptorCount, OnStartup, OnShutdown}, []).

init({Port, AcceptorCount, {M, F, A} = OnStartup, OnShutdown}) ->
	process_flag(trap_exit, true),
	Opts = [binary, {reuseaddr, true}, {packet, 2},{keepalive, true}, {backlog, 256}, {active, false}],
	case gen_tcp:listen(Port, Opts) of
		{ok, ListenSocket} ->
			 FunStartAcceptor = 
				 fun(AccIndex, Acc)->
					 {ok, _EPid} = supervisor:start_child(tcp_acceptor_sup, [ListenSocket, AccIndex]),
					 AcceptorName = tcp_acceptor:get_proc_name(AccIndex),
					 [AcceptorName | Acc]
				 end,
             ProcNameList = util:foldl(FunStartAcceptor, [], util:seq(1, AcceptorCount)),
			 apply(M,F,A ++ [ListenSocket, Port]),
			 State = 
				 #state{
						listen_socket = ListenSocket,
						on_startup = OnStartup, 
						on_shutdown = OnShutdown,
						acceptors = ProcNameList
					   },
			 {ok, State};
		{error, Reason} ->
			?ERROR_LOG("listen port Error! info = ~p", [{Port, Opts, Reason}]),
			{stop, Reason}
	end.

handle_call(reset_opt, _From, #state{listen_socket = Listen_socket} = State) ->
	inet:setopts(Listen_socket,[{packet, 0}]),
	?INFO_LOG("inet:getopts active,packet ~p ~n",[inet:getopts(Listen_socket, [active,packet])]),
    Reply = ok,
    {reply, Reply, State};

handle_call({query_port}, _From, #state{listen_socket = LSock} = State) ->
	{ok, {_IPAddress, Port}} = inet:sockname(LSock),
	Reply = Port,
	{reply, Reply, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, #state{listen_socket=LSock, on_shutdown = {M,F,A}}) ->
    {ok, {IPAddress, Port}} = inet:sockname(LSock),
    gen_tcp:close(LSock),
    apply(M, F, A ++ [LSock, IPAddress, Port, Reason]).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

query_port()->
	gen_server:call(?MODULE, {query_port} ,infinity).


