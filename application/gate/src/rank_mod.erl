%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 16:00
%%%-------------------------------------------------------------------
-module(rank_mod).
-author("wodong_0013").
-behaviour(gen_server).
%% API

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, 
  test_send_daily_earn_gold_reward/0, test_send_and_clean_daily_earn_gold_reward/0,
  post_send_and_clean_car_rank/1, post_send_and_clean_hundred_niu_rank/1, post_send_and_clean_airlaba_rank/1, sync_airlaba_rank/0]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(REFRESH_TIMER_SEC, 300).                  % 300s
-define(QUERY_RANK_NUM_LIMIT_IN_NORMAL, 20).      % 排名查询限制
-define(QUERY_RANK_NUM_LIMIT_IN_FRUIT, 30).       % 水果排名查询限制


-define(RANK_TABLE_NAME, t_rank).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start_link/1,
  get_mod_pid/0,
  update_rank/3,
  send_rank/3
]).

-record(state, {
  rank_gold = [], rank_profit = [], rank_diamond = [], rank_fruit = [], rank_redpack = [],
  rank_car = [], rank_hundred_niu = [], rank_airlaba_bet = [], time = 0}).

get_mod_pid() ->
  misc:get_mod_pid(?MODULE).

send_rank(TypeId, GatePid, PlayerId) ->
  Value =
    case TypeId of
      ?RANK_TYPE_FRUIT -> get_rank_value(PlayerId, fruit);
      ?RANK_TYPE_CAR -> get_rank_value(PlayerId, car);
      ?RANK_TYPE_HUNDRED_NIU -> get_rank_value(PlayerId, hundred_niu);
      ?RANK_TYPE_AIRLABA_BET -> get_rank_value(PlayerId, airlaba_bet);
      _ -> 0
    end,
  gen_server:cast(get_mod_pid(), {send_rank, TypeId, GatePid, Value}).

test_send_daily_earn_gold_reward() ->
 gen_server:cast(get_mod_pid(), {'send_daily_earn_gold_reward_test'}).

test_send_and_clean_daily_earn_gold_reward() ->
 gen_server:cast(get_mod_pid(), {'send_and_clean_daily_earn_gold_reward_test'}).

post_send_and_clean_car_rank(PoolDivideNum) ->
  gen_server:cast(get_mod_pid(), {'post_send_and_clean_car_rank', PoolDivideNum}).

post_send_and_clean_hundred_niu_rank(PoolDivideNum) ->
  gen_server:cast(get_mod_pid(), {'post_send_and_clean_hundred_niu_rank', PoolDivideNum}).

post_send_and_clean_airlaba_rank(PoolDivideNum) ->
  gen_server:cast(get_mod_pid(), {'post_send_and_clean_airlaba_rank', PoolDivideNum}).


start_link(ModProcessName) ->
  gen_server:start_link(?MODULE, [ModProcessName], []).

init([ModProcessName]) ->
  process_flag(trap_exit, true),
  util_process:register_local(ModProcessName, self()),

  statistic_server:check_exist_table(?RANK_TABLE_NAME, rank),

  DailySeconds = util:get_today_start_second() + ?DAY_SECOND - util:now_seconds() + 1,
  erlang:send_after(DailySeconds*1000, self(), timer_daily),

  {ok, refresh_get_state()}.

handle_call(Request, From, State) ->
  ?ERROR_LOG("~p unkonw call:~p ", [?MODULE, {Request, From}]),
  {reply, ok, State}.

handle_cast(Msg, State) ->
  try
    do_cast(Msg, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
      {noreply, State}
  end.

handle_info(Info, State) ->
  try
    do_info(Info, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p", [{Error, Reason, Info}, erlang:get_stacktrace()]),
      {noreply, State}
  end.

terminate(_Reason, _State) ->
  ?ERROR_LOG("~p terminated ", [?MODULE]),
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_info(timer_daily, State) ->
  DailySeconds = util:get_today_start_second() + ?DAY_SECOND - util:now_seconds() + 1,
  erlang:send_after(DailySeconds*1000, self(), timer_daily),

  %% 每日处理
  send_and_clean_daily_earn_gold_rank(State#state.rank_profit),
  clear_rank_value(diamond),

  %% 每周处理
  case util:get_week_day() of
    1 ->
      laba_mod:send_super_laba_rank_reward(State#state.rank_fruit),
      clear_rank_value(fruit);
    _ ->
      skip
  end,
  {noreply, refresh_get_state()};

do_info(Info, State) ->
  ?ERROR_LOG("~p unkonw info:~p ", [?MODULE, Info]),
  {noreply, State}.


do_cast({'send_daily_earn_gold_reward_test'}, State) ->
  daily_rank_reward_mod:send_daily_earn_gold_reward(State#state.rank_profit),
  {noreply, State};

do_cast({'send_and_clean_daily_earn_gold_reward_test'}, State) ->
  send_and_clean_daily_earn_gold_rank(State#state.rank_profit),
  {noreply, State};

do_cast({'post_send_and_clean_car_rank', PoolDivideNum}, State) ->
  car_rank_reward_mod:send_reward(State#state.rank_car, PoolDivideNum),
  clear_rank_value(car),
  {noreply, refresh_get_state()};

do_cast({'post_send_and_clean_hundred_niu_rank', PoolDivideNum}, State) ->
  hundred_niu_rank_reward_mod:send_reward(State#state.rank_hundred_niu, PoolDivideNum),
  clear_rank_value(hundred_niu),
  {noreply, refresh_get_state()};

do_cast({'post_send_and_clean_airlaba_rank', PoolDivideNum}, State) ->
  airlaba_bet_rank_reward_mod:send_reward(State#state.rank_airlaba_bet, PoolDivideNum),
  clear_rank_value(airlaba_bet),
  {noreply, refresh_get_state()};

do_cast({'sync_airlaba_rank'}, State) ->
  AirlabaRank = State#state.rank_airlaba_bet,
  PackElem = fun (Rec) ->
    case Rec of
      undefined ->
        {obj, []};
      _ ->
        {obj, [
          {player_id, Rec#pb_rank_info.player_uuid},
          {rank, Rec#pb_rank_info.rank},
          {player_name, Rec#pb_rank_info.player_name},
          {player_vip, Rec#pb_rank_info.player_vip},
          {player_icon, Rec#pb_rank_info.player_icon},
          {sex, Rec#pb_rank_info.sex},
          {win_gold, Rec#pb_rank_info.win_gold_num}
        ]}
      end
  end,
  RankData = lists:foldl(fun (Elem, Acc) ->
    Acc ++ [PackElem(Elem)]
  end, [], AirlabaRank),
  ServerId = config_app:get_server_id(),
  Json = rfc4627:encode({obj, [{data, RankData}, {server_id, ServerId}]}),
  http_send_mod:do_cast_http_post_fun(post_airlaba_rank, [Json]),
  {noreply, State};

do_cast({send_rank, TypeId, GatePid, Value}, State) ->
  NewState = check_get_state(State),
  RankList =
    case TypeId of
      ?RANK_TYPE_GOLD -> NewState#state.rank_gold;
      ?RANK_TYPE_WIN_GOLD -> NewState#state.rank_profit;
      ?RANK_TYPE_DIAMOND -> NewState#state.rank_diamond;
      ?RANK_TYPE_FRUIT -> NewState#state.rank_fruit;
      ?RANK_TYPE_REDPACK -> NewState#state.rank_redpack;
      ?RANK_TYPE_CAR -> NewState#state.rank_car;
      ?RANK_TYPE_HUNDRED_NIU -> NewState#state.rank_hundred_niu;
      ?RANK_TYPE_AIRLABA_BET -> NewState#state.rank_airlaba_bet;
      _Other -> []
    end,
  {StartTime, EndTime} = case TypeId of
    ?RANK_TYPE_WIN_GOLD ->
      daily_rank_reward_mod:get_start_and_end_days();
    ?RANK_TYPE_CAR ->
      car_rank_reward_mod:get_start_and_end_days();
    ?RANK_TYPE_HUNDRED_NIU ->
      hundred_niu_rank_reward_mod:get_start_and_end_days();
    ?RANK_TYPE_AIRLABA_BET ->
      airlaba_bet_rank_reward_mod:get_start_and_end_days();
    _ -> 
      TodayStartTime = util:get_today_start_second(),
      TodayEndTime = TodayStartTime + 86399,
      {TodayStartTime, TodayEndTime}
  end,
  Msg = #sc_rank_qurey_reply{
    rank_type = TypeId,
    my_rank = 0,
    my_recharge_money = Value,
    rank_info_list = RankList,
    start_time = max(StartTime, 0),
    end_time = max(0, min(EndTime, 4294967295)) % 防止 uint32 溢出
  },
  tcp_client:send_data(GatePid, Msg),
  {noreply, NewState};

do_cast({'player_base_info_change', PlayerInfo}, State) ->
  {ok, EncRoldId} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
  Func =
    fun(L) ->
      case lists:keyfind(EncRoldId, 3, L) of
        false ->
          L;
        Rec when is_record(Rec, pb_rank_info) ->
          NewRec = Rec#pb_rank_info{
            player_name = PlayerInfo#player_info.player_name,
            player_vip = PlayerInfo#player_info.vip_level,
            player_icon = PlayerInfo#player_info.icon,
            sex = PlayerInfo#player_info.sex
          },
          lists:keyreplace(EncRoldId, 3, L, NewRec)
      end
    end,
  {noreply, State#state{
    rank_gold = Func(State#state.rank_gold),
    rank_profit = Func(State#state.rank_profit),
    rank_diamond = Func(State#state.rank_diamond),
    rank_fruit = Func(State#state.rank_fruit),
    rank_redpack = Func(State#state.rank_redpack),
    rank_car = Func(State#state.rank_car),
    rank_hundred_niu = Func(State#state.rank_hundred_niu),
    rank_airlaba_bet = Func(State#state.rank_airlaba_bet)}
  };

do_cast(Request, State) ->
  ?ERROR_LOG("~p unkonw cast:~p ", [?MODULE, Request]),
  {noreply, State}.

%%%%%%%% exteranal functions %%%%%%%%%%
update_rank(?RANK_TYPE_GOLD, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `gold`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `gold` = ~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_WIN_GOLD, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `profit`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `profit` = `profit`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_DIAMOND, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `diamond`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `diamond` = `diamond`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_FRUIT, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `fruit`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `fruit` = `fruit`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_REDPACK, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `redpack`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `redpack` = ~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_CAR, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `car`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `car` = `car`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_HUNDRED_NIU, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `hundred_niu`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `hundred_niu` = `hundred_niu`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(?RANK_TYPE_AIRLABA_BET, PlayerId, Value) ->
  Sql = io_lib:format("INSERT INTO `t_rank` (`player_id`, `airlaba_bet`, `updtime`) VALUES (~p, ~p, now()) ON DUPLICATE KEY UPDATE `airlaba_bet` = `airlaba_bet`+~p, updtime = NOW()", [PlayerId, Value, Value]),
  mysql:fetch(p3, Sql),
  ok;
update_rank(TypeId, _PlayerId, _Value) ->
  ?ERROR_LOG("~p[~p] update_rank unknow TypeId:~p ", [?MODULE, ?LINE, TypeId]),
  error.

%%%%%%%% interanal functions %%%%%%%%%%
check_get_state(State) ->
  NowSeconds = util:now_seconds(),
  case NowSeconds - State#state.time > ?REFRESH_TIMER_SEC of
    true -> refresh_get_state();
    false -> State
  end.

refresh_get_state()->
  Func =
    fun([PlayerId, Type, Value], L) ->
      case player_info_db:get_base(PlayerId) of
        {ok, [PlayerInfo]} ->
          {V1, V2, V3, V4} =
            case Type of
              <<"gold">> -> {Value, 0, 0, 0};
              <<"profit">> -> {0, Value, 0, 0};
              <<"diamond">> -> {0, 0, Value, 0};
              <<"fruit">> -> {Value, 0, 0, 0};
              <<"car">> -> {0, Value, 0, 0};
              <<"hundred_niu">> -> {0, Value, 0, 0};
              <<"airlaba_bet">> -> {0, Value, 0, 0};
              <<"redpack">> -> {0, 0, 0, Value}
            end,
          {ok, EncRoldId} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
          [#pb_rank_info{
            rank = length(L) + 1,
            player_uuid = EncRoldId,
            player_name = PlayerInfo#player_info.player_name,
            player_icon = PlayerInfo#player_info.icon,
            player_vip = PlayerInfo#player_info.vip_level,
            gold_num = V1,
            win_gold_num = V2,
            cash_num = V3,
            sex = PlayerInfo#player_info.sex,
            hundred_win = 0,
            account = PlayerInfo#player_info.account,
            redpack = V4
          } | L];
        _ ->
          ?ERROR_LOG("unknow playerid:~p", [PlayerId]),
          L
      end
    end,
  #state{
    rank_gold = lists:foldl(Func, [], get_rank_list(gold)),
    rank_profit = lists:foldl(Func, [], get_rank_list(profit)),
    rank_diamond = lists:foldl(Func, [], get_rank_list(diamond)),
    rank_fruit = lists:foldl(Func, [], get_rank_list(fruit)),
    rank_redpack = lists:foldl(Func, [], get_rank_list(redpack)),
    rank_car = lists:foldl(Func, [], get_rank_list(car)),
    rank_hundred_niu = lists:foldl(Func, [], get_rank_list(hundred_niu)),
    rank_airlaba_bet = lists:foldl(Func, [], get_rank_list(airlaba_bet)),
    time = util:now_seconds()}.

get_rank_list(Type) ->
  Limit =
    case Type of
      fruit -> ?QUERY_RANK_NUM_LIMIT_IN_FRUIT;
      _ -> ?QUERY_RANK_NUM_LIMIT_IN_NORMAL
    end,
  Sql = io_lib:format("select `player_id`, '~p' as `type`, `~p` from `t_rank` where `~p` > 0 order by `~p` desc limit ~p", [Type,Type,Type, Type, Limit]),
  case mysql:fetch(p3, Sql) of
    {data,{mysql_result,_, DataList, 0,[]}} ->
      DataList;
    Error ->
      ?ERROR_LOG("Error:~p", [Error]),
      []
  end.

get_rank_value(PlayerId, Type)->
  Sql = io_lib:format("select `~p` from `t_rank` where `player_id` = '~p'", [Type, PlayerId]),
  case mysql:fetch(p3, Sql) of
    {data,{mysql_result,_, [[Value]], 0,[]}} ->
      Value;
    Error ->
      ?ERROR_LOG("Error:~p", [Error]),
      0
  end.

clear_rank_value(Type)->
  Sql = io_lib:format("update `t_rank` set `~p` = 0", [Type]),
  case mysql:fetch(p3, Sql) of
    {updated, {mysql_result,[],[],N,[]}}->
      ?INFO_LOG("[~s] clear rank ~p, record count:~p", [util:now_to_local_string(), Type, N]),
      ok;
    Error ->
      ?ERROR_LOG("Error:~p", [Error]),
      error
  end.

send_and_clean_daily_earn_gold_rank(Rank) ->
  daily_rank_reward_mod:send_daily_earn_gold_reward(Rank),
  CleanProfitRank = daily_rank_reward_mod:is_time_to_clean_rank(),
  if 
    true =:= CleanProfitRank ->
      clear_rank_value(profit);
    true ->
      skip
  end.

sync_airlaba_rank() ->
  gen_server:cast(get_mod_pid(), {'sync_airlaba_rank'}).
