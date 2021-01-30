-module(car_rank_reward_mod).

-author("lk").

-behaviour(gen_server).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-export([code_change/3, get_mod_pid/0, handle_call/3,
	 handle_cast/2, handle_info/2, init/1, start_link/1, send_reward/2,
     is_time_to_clean_rank/0, get_start_and_end_days/0,
	 terminate/2]).

-define(CAR_RANK_REWARD_MOD_STATE_CACHE_KEY, car_rank_reward_mod_state_cache_key).

-record(state, {key = 0, this_period_start_time = 0, period = 0, special_time_of_day = 0}).


start_link(ModProcessName) ->
    gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() -> misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
    process_flag(trap_exit, true),
    util_process:register_local(ModProcessName, self()),
    State = init_ets(),
    erlang:send_after(60 * 1000, self(), update_state),
    {ok, State}.

is_time_to_clean_rank() ->
    case game_earn_gold_rank_detail_config_db:get(car) of
        {ok, [DetailConfig]} ->
            #game_earn_gold_rank_detail_config {
                period = PeriodDays,
                special_time_of_day = SpecialTimeOfDay
            } = DetailConfig,
            is_time_to_check_rank(PeriodDays, SpecialTimeOfDay);
        _ ->
            true
    end.

get_start_and_end_days() ->
    case ets:lookup(?ETS_RANK_MOD_TIME_CACHE, ?CAR_RANK_REWARD_MOD_STATE_CACHE_KEY) of
        [Ets] ->
            #ets_data {
                value = State
            } = Ets,
            #state{
                this_period_start_time = Start,
                period = PeriodDays,
                special_time_of_day = SpecialTimeOfDay
            } = State;
        _ ->
            Start = 0,
            PeriodDays = 0,
            SpecialTimeOfDay = {0, 0, 0}
    end,
    StartSec = util:get_special_day_start_second(Start) + util:hour_to_second_0(SpecialTimeOfDay),
    EndSec = StartSec + (PeriodDays * 86400) - 1,
    {StartSec - ?DIFF_SECONDS_0000_1970, EndSec - ?DIFF_SECONDS_0000_1970}.

%% ====================================================================
handle_call(Request, From, State) ->
    try do_call(Request, From, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod call Error! info = ~p~n, stack = "
		     "~p~n",
		     [{Error, Reason, Request}, erlang:get_stacktrace()]),
	  {reply, ok, State}
    end.

%% ====================================================================
handle_cast(Msg, State) ->
    try do_cast(Msg, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod cast Error! info = ~p~n, stack = "
		     "~p~n",
		     [{Error, Reason, Msg}, erlang:get_stacktrace()]),
	  {noreply, State}
    end.

%% ====================================================================
handle_info(Info, State) ->
    try do_info(Info, State) catch
      Error:Reason ->
	  ?ERROR_LOG("mod cast Error! info = ~p~n, stack = "
		     "~p~n",
		     [{Error, Reason, Info}, erlang:get_stacktrace()]),
	  {noreply, State}
    end.

%% ====================================================================
terminate(_Reason, _State) ->
    ?ERROR_LOG("~p terminated ~n", [?MODULE]), ok.

%% ====================================================================
code_change(_OldVsn, State, _Extra) -> {ok, State}.

send_reward(RankList, PoolDivide) ->
    gen_server:cast(get_mod_pid(),{'earn_gold_rank_reward_check', RankList, PoolDivide}).

%% === 内部
init_ets_from_db(Rank) ->
    case game_earn_gold_rank_reward_config_db:get_base({car, Rank}) of
        {ok, [Config]} ->
            ets:insert(?ETS_CAR_EARN_GOLD_RANK_REWARD_CONFIG, Config),
            init_ets_from_db(Rank + 1);
        _ ->
            skip
    end.

init_ets() ->
    init_ets_from_db(1),
    update_state().

do_call(Request, From, State) ->
    ?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
    {reply, ok, State}.

do_cast({'earn_gold_rank_reward_check', RankList, PoolDivide}, _State) ->
    ConfigList = ets:tab2list(?ETS_CAR_EARN_GOLD_RANK_REWARD_CONFIG),
    case game_earn_gold_rank_detail_config_db:get(car) of
        {ok, [DetailConfig]} ->
            #game_earn_gold_rank_detail_config {
                period = PeriodDays,
                special_time_of_day = SpecialTimeOfDay,
                title = Title,
                context_tmpl = Tmpl
            } = DetailConfig,
            DoCheck = is_time_to_check_rank(PeriodDays, SpecialTimeOfDay),
            if 
                true =:= DoCheck ->
                    if
                        0 < PoolDivide ->
                            MaxRank = length(ConfigList),
                            RewardRankList = lists:foldl(
                                fun(E, Acc) ->
                                    {ok,EId} = id_transform_util:role_id_to_internal(E#pb_rank_info.player_uuid),
                                    if 
                                        E#pb_rank_info.rank > MaxRank ->
                                            skip;
                                        EId == 0 ->
                                            skip;
                                        true ->
                                            GoldNum =
                                                case lists:keyfind({car, E#pb_rank_info.rank},#game_earn_gold_rank_reward_config.key,ConfigList) of
                                                    false ->
                                                        0;
                                                    Tuple ->
                                                        trunc(Tuple#game_earn_gold_rank_reward_config.winpool_divide * PoolDivide / 10000)
                                                end,
                                            Content = io_lib:format(Tmpl, [E#pb_rank_info.rank, GoldNum]),
                                            player_mail:send_system_mail(EId, 1, ?MAIL_TYPE_CAR_RANK_REWARD, Title, Content, [{?ITEM_ID_GOLD, GoldNum}]),
                                            [E#pb_rank_info{
                                                gold_num = GoldNum
                                            } | Acc]
                                    end
                                end, [], RankList);
                        true ->
                            RewardRankList = []
                    end,
                    LastData = #daily_rank_reward_history {
                        type = car,
                        date = util:now_to_local_string(),
                        reward_records = RewardRankList
                    },
                    daily_rank_reward_history_db:write(LastData);
                true ->
                    skip
            end;
        _ ->
            ?ERROR_LOG("Config is missing... earn_gold_rank_reward_check~n")
    end,
    {noreply, update_state()};

do_cast(Msg, State) ->
    ?ERROR_LOG("mod cast bad match! info = ~p~n",
	       [{?MODULE, Msg, State}]),
    {noreply, State}.

do_info(update_state, _State) ->
    erlang:send_after(60*1000, self(), update_state),
    {noreply, update_state()};

do_info(Info, State) ->
    ?ERROR_LOG("mod info bad match! info = ~p~n",
	       [{?MODULE, Info, State}]),
    {reply, ok, State}.


calc_days() ->
    case daily_rank_reward_history_db:get(car) of
        {ok, [OldData]} ->
            #daily_rank_reward_history {
                date = LastCheckDate
            } = OldData,
            <<Year:4/binary, "-", Month:2/binary, "-", Day:2/binary>> = list_to_binary(LastCheckDate),
            LastCheckDateSeconds = calendar:datetime_to_gregorian_seconds({{list_to_integer(binary_to_list(Year)),
                list_to_integer(binary_to_list(Month)),list_to_integer(binary_to_list(Day))},{0,0,0}}),
            NowSeconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
            {LastCheckDateSeconds, util:get_diff_days(LastCheckDateSeconds, NowSeconds)};
        _ ->
            LastCheckDateSeconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
            {LastCheckDateSeconds, util:get_diff_days(LastCheckDateSeconds, LastCheckDateSeconds)}
    end.

is_time_to_check_rank(PeriodDays, SpecialTimeOfDay) ->
    {_, DiffDays} = calc_days(),
    ?INFO_LOG("car_gold_rank_reward_check --> ~p~n", [{DiffDays, PeriodDays}]),
    if
        DiffDays >= PeriodDays ->
            NowSeconds = util:now_seconds(),
            NotifySecond = util:hour_to_second(SpecialTimeOfDay),
            ?INFO_LOG("car_gold_rank_reward_check --> ~p~n", [{NowSeconds, NotifySecond}]),
            NowSeconds >= NotifySecond;
        true ->
            false
    end.

update_state()->
    State = case game_earn_gold_rank_detail_config_db:get(car) of
        {ok, [DetailConfig]} ->
            #game_earn_gold_rank_detail_config {
                period = PeriodDays,
                special_time_of_day = SpecialTimeOfDay
            } = DetailConfig,
            {Start, _} = calc_days(),
            #state {
                this_period_start_time = Start,
                period = PeriodDays,
                special_time_of_day = SpecialTimeOfDay
            };
        _ ->
            ?ERROR_LOG("not found any config for car_rank_reward_mod.~n"),
            #state {
                this_period_start_time = 0,
                period = 0,
                special_time_of_day = 0
            }
    end,
    %?INFO_LOG("00000000000000000===~p~n", [{State}]),
    ets:insert(?ETS_RANK_MOD_TIME_CACHE, #ets_data{
        key = ?CAR_RANK_REWARD_MOD_STATE_CACHE_KEY, value = State
    }),
    State.