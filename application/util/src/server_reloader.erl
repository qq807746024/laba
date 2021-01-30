%%%-------------------------------------------------------------------
%%% @author yilin.jiang
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 四月 2018 20:59
%%%-------------------------------------------------------------------
-module(server_reloader).
-include_lib("kernel/include/file.hrl").

-behaviour(gen_server).
-export([start/0, start_link/0]).
-export([stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {last, tref}).

%% External API

%% -spec start() -> ServerRet
%% -doc Start the reloader.
start() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

%% -spec start_link() -> ServerRet
%% -doc Start the reloader.
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% -spec stop() -> ok
%% -doc Stop the reloader.
stop() ->
  gen_server:call(?MODULE, stop).

%% gen_server callbacks

%% -spec init([]) -> {ok, State}
%% -doc gen_server init, opens the server in an initial state.
init([]) ->
  erlang:send_after(3000, self(), doit),
  TRef = code:root_dir(),
  {ok, #state{last = stamp(), tref = TRef}}.

%% -spec handle_call(Args, From, State) -> tuple()
%% -doc gen_server callback.
handle_call(stop, _From, State) ->
  {stop, shutdown, stopped, State};
handle_call(_Req, _From, State) ->
  {reply, {error, badrequest}, State}.

%% -spec handle_cast(Cast, State) -> tuple()
%% -doc gen_server callback.
handle_cast(_Req, State) ->
  {noreply, State}.

%% -spec handle_info(Info, State) -> tuple()
%% -doc gen_server callback.
handle_info(doit, State) ->
  erlang:send_after(3000, self(), doit),
  Now = stamp(),
  doit(State#state.tref, State#state.last, Now),
  {noreply, State#state{last = Now}};
handle_info(_Info, State) ->
  {noreply, State}.

%% -spec terminate(Reason, State) -> ok
%% -doc gen_server termination callback.
terminate(_Reason, _State) ->
  ok.


%% -spec code_change(_OldVsn, State, _Extra) -> State
%% -doc gen_server code_change callback (trivial).
code_change(_Vsn, State, _Extra) ->
  {ok, State}.

%% Internal API

doit(Root, From, To) ->
  [case file:read_file_info(Filename) of
     {ok, FileInfo} when FileInfo#file_info.mtime >= From,
       FileInfo#file_info.mtime < To ->
       reload(Module);
     {ok, _} ->
       unmodified;
     {error, enoent} ->
       %% The Erlang compiler deletes existing .beam files if
       %% recompiling fails.  Maybe it's worth spitting out a
       %% warning here, but I'd want to limit it to just once.
       gone;
     {error, Reason} ->
       io:format("Error reading ~s's file info: ~p~n",
         [Filename, Reason]),
       error
   end || {Module, Filename} <- code:all_loaded(), is_list(Filename) andalso not(lists:prefix(Root, Filename))].

%% @spec reload_all(Module :: atom()) ->
%%         [{purge_response(), load_file_response()}]
%% @type purge_response() = boolean()
%% @type load_file_response() = {module, Module :: atom()}|
%%                              {error, term()}
%% @doc Ask each member node of the riak ring to reload the given
%%      Module.  Return is a list of the results of code:purge/1
%%      and code:load_file/1 on each node.
%reload_all(Module) ->
%     Nodes = [node()|nodes()],
%     [rpc:call(Node, ?MODULE, reload, [Module]) ||
%        Node <- Nodes].

reload(Module) ->
  io:format("Reloading ~p ...", [Module]),
  code:purge(Module),%% 清除当前模块的代码，即移除当前模块被标记为旧版本的代码。如果某些erlang进程还使用这些旧版本代码，这些进程将被先杀死，然后代码被删除
  case code:load_file(Module) of
    {module, Module} ->
      io:format(" ok.~n"),
      reload;
%%      case erlang:function_exported(Module, test, 0) of
%%        true ->
%%          io:format(" - Calling ~p:test() ...", [Module]),
%%          case catch Module:test() of
%%            ok ->
%%              io:format(" ok.~n"),
%%              reload;
%%            Reason ->
%%              io:format(" fail: ~p.~n", [Reason]),
%%              reload_but_test_failed
%%          end;
%%        false ->
%%          reload
%%      end;
    {error, Reason} ->
      io:format(" fail: ~p.~n", [Reason]),
      error
  end.


stamp() ->
  erlang:localtime().
