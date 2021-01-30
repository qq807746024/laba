-module(mutisrv_shared_deport_mod).

-behaviour(gen_server).

-include("common.hrl").

-export([call_get_airlaba_pools/0, cast_add_pool/3,
	 code_change/3, get_mod_pid/0, handle_call/3,
	 handle_cast/2, handle_info/2, init/1, start_link/1,
	 terminate/2]).

-define(AIRLABA_RANK_POOL_NAME, airlaba_rank_pool).

-define(CACHE_STATE_SYNC_TIMER, 1000 * 3).

-record(state,
	{pub, sub, airlaba_rankpool_tmp_modify = 0,
	 airlaba_pool_tmp_modify = 0,
	 airlaba_rankpool_ori_poolnum = 0,
	 airlaba_pool_ori_poolnum = 0}).

start_link(ModProcessName) ->
    gen_server:start_link(?MODULE, [ModProcessName], []).

init([ModProcessName]) ->
    % process_flag(trap_exit, true),
    % util_process:register_local(ModProcessName, self()),
    % State = #state{pub = priv_init_redis_pub()},
    % erlang:send_after(?CACHE_STATE_SYNC_TIMER, self(),
	% 	      sync_redis),
    %{ok, State}.
	{ok, ok}.

get_mod_pid() -> misc:get_mod_pid(?MODULE).

terminate(_Reason, _State) ->
    ?ERROR_LOG("~p terminated ", [?MODULE]), ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

handle_call(Request, From, State) ->
    try do_call(Request, From, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p",
		     [{Error, Reason, Request, From},
		      erlang:get_stacktrace()]),
	  {reply, ok, State}
    end.

handle_cast(Msg, State) ->
    try do_cast(Msg, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p",
		     [{Error, Reason, Msg}, erlang:get_stacktrace()]),
	  {noreply, State}
    end.

handle_info(Info, State) ->
    try do_info(Info, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p",
		     [{Error, Reason, Info}, erlang:get_stacktrace()]),
	  {noreply, State}
    end.

call_get_airlaba_pools() ->
    {ok, PoolNum, RankPoolNum} =
	gen_server:call(mutisrv_shared_deport_mod:get_mod_pid(),
			airlaba_pools),
    {PoolNum, RankPoolNum}.

cast_add_pool(airlaba_rankpool_pool, PoolNum,
	      RankPoolNum) ->
    gen_server:cast(mutisrv_shared_deport_mod:get_mod_pid(),
		    {airlaba_rankpool_pool, PoolNum, RankPoolNum});
cast_add_pool(_, _, _) -> bad_argv.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_cast({airlaba_rankpool_pool, PoolNum, RankPoolNum},
	State) ->
    #state{airlaba_rankpool_tmp_modify =
	       OldAirlabaRankPoolModify,
	   airlaba_pool_tmp_modify = OldAirlabaPoolModify} =
	State,
    NewAirlabaRankPool = OldAirlabaRankPoolModify +
			   RankPoolNum,
    NewAirlabaPool = OldAirlabaPoolModify + PoolNum,
    {noreply,
     State#state{airlaba_rankpool_tmp_modify =
		     NewAirlabaRankPool,
		 airlaba_pool_ori_poolnum = NewAirlabaPool}};
do_cast(_Msg, State) -> {noreply, State}.

do_info(sync_redis, State) ->
    NewState = priv_sync_with_redis(State),
    erlang:send_after(?CACHE_STATE_SYNC_TIMER, self(),
		      sync_redis),
    {noreply, NewState};
do_info(_Info, State) -> {noreply, State}.

do_call(airlaba_pools, _From, State) ->
    #state{airlaba_pool_ori_poolnum = PoolNum,
	   airlaba_rankpool_ori_poolnum = RankPoolNum} =
	State,
    {reply, {ok, PoolNum, RankPoolNum}, State};
do_call(_Request, _From, State) ->
    {reply, bad_argv, State}.

priv_init_redis_pub() ->
    {ok, Instance} = eredis:start_link("Redis", 6379),
    Instance.

priv_sync_with_redis(State) ->
    #state{pub = Instance,
	   airlaba_rankpool_tmp_modify = AirlabaRankPoolModify} =
	State,
    {ok, AirlabaRankPool} = eredis:q(Instance,
				     ["INCRBY", ?AIRLABA_RANK_POOL_NAME,
				      AirlabaRankPoolModify]),
    %AirlabaRankPool = eredis:q(Instance, ["GET", ?AIRLABA_RANK_POOL_NAME]),
    State#state{airlaba_rankpool_ori_poolnum =
		    erlang:binary_to_integer(AirlabaRankPool),
		airlaba_rankpool_tmp_modify = 0}.
