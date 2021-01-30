-module(db_master).

-include("../../gate/include/logger.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-record(state, {}).

start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

init([]) ->
	db_ini:db_init(),
	db_ini:db_modules_list_init([filename:dirname(code:which(?MODULE))]),
	db_ini:db_init_disc_tables(),
	{ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, _State) ->
	?ERROR_LOG("dbmaster terminate Reason ~p ~n",[Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


