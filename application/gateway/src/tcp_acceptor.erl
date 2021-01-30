-module(tcp_acceptor).
-include("../../gate/include/logger.hrl").
-behaviour(gen_server).

%% API
-export([
		 start_link/3, 
		 get_proc_name/1
		]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-record(state, {
				callback, 
				socket, 
				ref
			   }).

start_link(AcceptCallback, LSock, AcceptorIndex) ->
    gen_server:start_link(?MODULE, {AcceptCallback, LSock,AcceptorIndex}, []).

init({AcceptCallback, LSock, AcceptorIndex}) ->
	put(acceptor_index, AcceptorIndex),
	erlang:register(get_proc_name(AcceptorIndex), self()),
    gen_server:cast(self(), 'accept'),
	State = 
		#state{
			   callback = AcceptCallback, 
			   socket = LSock
			  },
    {ok, State}.

%% ===== call =====
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% ===== cast =====
handle_cast('accept', State) ->
    accept(State);

handle_cast(_Msg, State) ->
    {noreply, State}.

%% ===== info =====
%% 消息接收
handle_info({inet_async, LSock, Ref, {ok, ClientSocket}}, State = #state{callback = {M, F, A}, socket = LSock, ref = Ref}) ->
    {ok, Mod} = inet_db:lookup_socket(LSock),
    inet_db:register_socket(ClientSocket, Mod),
    try
        {ok, ChildPid} = supervisor:start_child(tcp_client_sup, []),
        ok = gen_tcp:controlling_process(ClientSocket, ChildPid),
        {PeerAddress, _PeerPort} = inet_op(fun() -> inet:peername(ClientSocket) end),
        PeerIP = inet_parse:ntoa(PeerAddress),
        tcp_client:socket_ready(ChildPid, ClientSocket, PeerIP),
        %{Address, Port} = inet_op(fun() -> inet:sockname(LSock) end),
        %?INFO_LOG("~p connection on ~s:~p, from ~s:~p, ~p~n",[?MODULE, inet_parse:ntoa(Address), Port, PeerIP, PeerPort, ChildPid]),
        apply(M, F, A ++ [ClientSocket, ChildPid])
    catch
        {inet_error, Reason} ->
            gen_tcp:close(ClientSocket),
            ?INFO_LOG("unable to accept TCP connection: ~p~n", [Reason]);
        OtherReason ->
            ?INFO_LOG("unable to accept TCP connection: ~p~n", [OtherReason])
    end,
    accept(State);

%% 断开
handle_info({inet_async, LSock, Ref, {error, closed}},	State=#state{socket=LSock, ref=Ref}) ->
    {stop, normal, State};

%% 捕捉错误
handle_info({inet_async, _LSock, _Ref, {error, Reason}}, State) ->
	?INFO_LOG("~p error: ~p ~p ~n", [{?MODULE, get(acceptor_index), erlang:localtime(), Reason}]),
	accept(State);

%% 捕获
handle_info({inet_async, _LSock, _Ref, E}, State) ->
    ?INFO_LOG("~p error: ~p ~p ~n", [{?MODULE, get(acceptor_index), erlang:localtime(), E}]),
    accept(State);

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, _State) ->
	?INFO_LOG("~p terminate! info : ~p ~p ~p ~p~n", [?MODULE, get(acceptor_index), Reason, self(), erlang:localtime()]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ==================================================
throw_on_error(E, Thunk) ->
    case Thunk() of
        {error, Reason} -> throw({E, Reason});
        {ok, Res}       -> Res;
        Res             -> Res
    end.

inet_op(F) -> 
	throw_on_error(inet_error, F).

%% 获取注册的进程名
get_proc_name(AcceptorIndex)->
    Name = "acceptor_" ++ integer_to_list(AcceptorIndex),
    try
        erlang:list_to_existing_atom(Name)
    catch
        _:_ ->  erlang:list_to_atom(Name)
    end.

accept(State = #state{socket = LSock}) ->
    case prim_inet:async_accept(LSock, -1) of
        {ok, Ref} ->
			{noreply, State#state{ref = Ref}};
        Error -> 
			{stop, {cannot_accept, Error}, State}
    end.


