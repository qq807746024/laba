%%%-------------------------------------------------------------------
%%% @author yilin.jiang
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 3. 五月 2018 21:42
%%%-------------------------------------------------------------------
-module(server_time).
-behaviour(gen_server).

%%%===================================================================
%%% API functions
%%%===================================================================
-export([
  now_seconds/0,
  now_milseconds/0,
  start_link/0,
  localtime/0,
  datebin/0,
  datebin2/0,
  nowstr/0,
  nowstr2/0
]).
%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).
-record(state, {start_at, ref}).
-define(CLOCK, 1000).

%% ====================================================================
%% External functions
%% ====================================================================
now_seconds() ->
  ets:lookup_element(?MODULE, 'now_seconds', 2).
localtime() ->
  ets:lookup_element(?MODULE, 'localtime', 2).
datebin() ->
  ets:lookup_element(?MODULE, 'datebin', 2).
datebin2() ->
  <<Year:4/binary, Month:2/binary, Day:2/binary>> = datebin(),
  <<Year/binary, "-", Month/binary, "-", Day/binary>>.
nowstr() ->
  ets:lookup_element(?MODULE, 'nowstr', 2).
nowstr2() ->
  <<Year:4/binary, Month:2/binary, Day:2/binary, Hour:2/binary, Minute:2/binary, Seconds:2/binary>> = list_to_binary(nowstr()),
  binary_to_list(<<Year/binary, "-", Month/binary, "-", Day/binary, " ", Hour/binary, ":", Minute/binary, ":", Seconds/binary>>).

%
now_milseconds() ->
  {MegaSecs, Secs, MicroSecs} = os:timestamp(),
  (MegaSecs * 1000000 + Secs) * 1000 + MicroSecs div 1000.

%% ====================================================================
%% Server functions
%% ====================================================================
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  ets:new(?MODULE, [set, protected, named_table, {read_concurrency, true}]),
  do_update_time(),
  {ok, Ref} = timer:send_interval(?CLOCK, {'event', 'clock'}),
  State = #state{
    start_at = now_seconds(),
    ref = Ref
  },
  {ok, State}.

%% do update  
do_update_time() ->
  {MegaSecs, Secs, _MicroSecs} = os:timestamp(),
  {{Y, M, D}, {H, Mi, S}} = erlang:localtime(),

  ets:insert(?MODULE, {'localtime', {{Y, M, D}, {H, Mi, S}}}), % 5
  ets:insert(?MODULE, {'nowstr', lists:append([to_s2(I) || I <- [Y, M, D, H, Mi, S]])}),%2
  ets:insert(?MODULE, {'datebin', iolist_to_binary([to_s2(I) || I <- [Y, M, D]])}), %6
  ets:insert(?MODULE, {'now_seconds', MegaSecs * 1000000 + Secs}).%3

to_s2(Int) when Int < 10 ->
  lists:concat(["0", Int]);
to_s2(Int) ->
  integer_to_list(Int).

handle_call(_Request, _From, State) ->
  {reply, State, State}.

handle_cast({'retime', Time}, State) ->
  timer:cancel(State#state.ref),
  {ok, Ref} = timer:send_interval(Time, {'event', 'clock'}),
  {noreply, State#state{ref = Ref}};
%
handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({event, clock}, State) ->
  do_update_time(),
  {noreply, State};
handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, State) ->
  ets:delete(?MODULE),
  timer:cancel(State#state.ref),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

