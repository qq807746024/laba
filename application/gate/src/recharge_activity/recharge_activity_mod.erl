%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 十月 2017 10:16
%%%-------------------------------------------------------------------
-module(recharge_activity_mod).
-author("Administrator").

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(BASE_GOLD_NUM, 1000). %% 每元增加奖池的金币数
-define(RECHARGE_NEED_NUM,50).
%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start_link/1,
  get_mod_pid/0,
  send_rank_update/2,
  send_recharge_info/2
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

start_link(ModProcessName) ->
  gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
  misc:get_mod_pid(?MODULE).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
  Result :: {ok, State}
  | {ok, State, Timeout}
  | {ok, State, hibernate}
  | {stop, Reason :: term()}
  | ignore,
  State :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([ModProcessName]) ->
  process_flag(trap_exit, true),
  util_process:register_local(ModProcessName, self()),
  init_pool(),
  init_ets(),
  erlang:send_after(60 * 1000, self(), {'refresh_rank', util:now_seconds()}),
  State = #state{},
  {ok, State}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
  Result :: {reply, Reply, NewState}
  | {reply, Reply, NewState, Timeout}
  | {reply, Reply, NewState, hibernate}
  | {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason, Reply, NewState}
  | {stop, Reason, NewState},
  Reply :: term(),
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity,
  Reason :: term().
%% ====================================================================
handle_call(Request, From, State) ->
  try
    do_call(Request, From, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("recharge_activity_mod call Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Request}, erlang:get_stacktrace()]),
      {reply, ok, State}
  end.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
  Result :: {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason :: term(), NewState},
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Msg, State) ->
  try
    do_cast(Msg, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("recharge_activity_mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
      {noreply, State}
  end.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
  Result :: {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason :: term(), NewState},
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(Info, State) ->
  try
    do_info(Info, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("recharge_activity_mod info Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Info}, erlang:get_stacktrace()]),
      {noreply, State}
  end.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
  Reason :: normal
  | shutdown
  | {shutdown, term()}
  | term().
%% ====================================================================
terminate(_Reason, _State) ->
  ?ERROR_LOG("~p terminated ~n", [?MODULE]),
  ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
  Result :: {ok, NewState :: term()} | {error, Reason :: term()},
  OldVsn :: Vsn | {down, Vsn},
  Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

do_call({'get_recharge_pool'}, _From, State) ->
%%  ?INFO_LOG("get(recharge_gold_pool)~p~n",[get(recharge_gold_pool)]),
  Num =
    case RechargeGold = get(recharge_gold_pool) of
      undefined ->
        0;
      _ ->
        RechargeGold#recharge_activity_info.gold
    end,
  {reply, {ok, Num}, State};

do_call(Request, From, State) ->
  ?ERROR_LOG("recharge_activity_mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
  {reply, ok, State}.

%% 玩家属性变化
do_cast({'player_data_change', PlayerId, NewData}, State) ->
  if
    NewData < 10 ->
      skip;
    true ->
      case player_recharge_activity_rank_info_db:get(PlayerId) of
        {ok, [OldPlayerRankInfo]} ->
%%          ?INFO_LOG("OldPlayerRankInfo1~p~n",[OldPlayerRankInfo]),
          RankKey = get_rank_key(OldPlayerRankInfo),
          ets:delete(?ETS_RANK_RECHARGE_ACTIVITY, RankKey),
          NowTime = util:now_long_seconds(),
          NewPlayerRankInfo = get_new_player_info(?ETS_RANK_RECHARGE_ACTIVITY, NewData, NowTime, OldPlayerRankInfo),
          NewRechargeInfo = add_recharge_activity_pool(NewData),
          DbFun = fun() ->
            player_recharge_activity_rank_info_db:t_write(NewPlayerRankInfo),
            recharge_activity_info_db:t_write(NewRechargeInfo),
            put(recharge_gold_pool, NewRechargeInfo)
                  end,
          {atomic, _} = dal:run_transaction_rpc(DbFun),
          {ok, [NewPlayerRankInfo1]} = player_recharge_activity_rank_info_db:get(NewPlayerRankInfo#player_recharge_activity_rank_info.player_id),
          add_rank(?ETS_RANK_RECHARGE_ACTIVITY, NewPlayerRankInfo1,true);
        _ ->
          {ok, [PlayerInfo]} = player_info_db:get_base(PlayerId),
          OldPlayerRankInfo = #player_recharge_activity_rank_info{
            player_id = PlayerId,
            name = PlayerInfo#player_info.player_name,
            icon = PlayerInfo#player_info.icon,
            vip = PlayerInfo#player_info.vip_level,
            sex = PlayerInfo#player_info.sex
          },
%%          ?INFO_LOG("PlayerInfo~p~n",[{PlayerInfo#player_info.icon,PlayerInfo#player_info.vip_level,PlayerInfo#player_info.sex}]),
%%          ?INFO_LOG("OldPlayerRankInfo2~p~n",[OldPlayerRankInfo]),
          PlayerRankInfo = get_new_player_info(?ETS_RANK_RECHARGE_ACTIVITY, NewData, util:now_long_seconds(), OldPlayerRankInfo),
          NewRechargeInfo = add_recharge_activity_pool(NewData),
          DbFun = fun() ->
            player_recharge_activity_rank_info_db:t_write(PlayerRankInfo),
            recharge_activity_info_db:t_write(NewRechargeInfo),
            put(recharge_gold_pool, NewRechargeInfo)
                  end,
          {atomic, _} = dal:run_transaction_rpc(DbFun),
          add_player_rank(PlayerRankInfo#player_recharge_activity_rank_info.player_id,true)
      end
  end,
  {noreply, State};

do_cast({'player_base_info_change', PlayerInfo}, State) ->
  case PlayerInfo#player_info.is_robot of
    true ->
      skip;
    _ ->
      case player_recharge_activity_rank_info_db:get(PlayerInfo#player_info.id) of
        {ok,[PlayerRankInfo]} ->
          NewPlayerRankInfo = PlayerRankInfo#player_recharge_activity_rank_info{
            name = PlayerInfo#player_info.player_name,
            vip = PlayerInfo#player_info.vip_level,
            icon = PlayerInfo#player_info.icon,
            sex = PlayerInfo#player_info.sex
          },
          DbFun = fun() -> player_recharge_activity_rank_info_db:t_write(NewPlayerRankInfo) end,
          {atomic, _} = dal:run_transaction_rpc(DbFun),
          add_player_rank(PlayerInfo#player_info.id,true);
        _ ->
          ?ERROR_LOG("recharge_activity_mod player_base_info_change rank_info not exist! info = ~p~n", [{?MODULE}])
      end
  end,
  {noreply, State};

do_cast(Msg, State) ->
  ?ERROR_LOG("recharge_activity_mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
  {noreply, State}.

do_info({'refresh_rank', OldSecond}, State) ->
  NowSecond = util:now_seconds(),
  erlang:send_after(60 * 1000, self(), {'refresh_rank', NowSecond}),
  case util:is_same_date(OldSecond, NowSecond) of
    true ->
      skip;
    _ ->
      %% 当天是周一就处理
      case util:get_week_day(NowSecond) of
        1 ->
          do_refresh_rank();
        _ ->
          skip
      end
  end,
  {noreply, State};

do_info(Info, State) ->
  ?ERROR_LOG("recharge_activity_mod info bad match! info = ~p~n", [{?MODULE, Info}]),
  {noreply, State}.

%%%% 计算刷新时间
%%calc_refresh_time() ->
%%  StartSecond = util:get_today_start_second(),
%%  NextRefreshTime = StartSecond + ?DAY_SECOND,
%%  NextRefreshTime.

% 初始化ets
init_ets() ->
  ets:delete_all_objects(?ETS_RANK_RECHARGE_ACTIVITY),
  PlayerRankInfoList = player_recharge_activity_rank_info_db:get(),
  util:map(fun(EPlayerRankInfo) ->
    add_player_rank(EPlayerRankInfo#player_recharge_activity_rank_info.player_id,false)
           end,
    PlayerRankInfoList),
  ok.

%% 添加玩家信息到排行榜
add_player_rank(PlayerId,Flag) ->
  {ok, [PlayerRankInfo]} = player_recharge_activity_rank_info_db:get(PlayerId),
  add_rank(?ETS_RANK_RECHARGE_ACTIVITY, PlayerRankInfo,Flag).

add_rank(EtsRankType, PlayerRankInfo,Flag) -> %% TODO 添加上榜条件
  if
    PlayerRankInfo#player_recharge_activity_rank_info.recharge == 0 ->
      skip;
    true ->
      RankKey = get_rank_key(PlayerRankInfo),
      RankNum =
        case PrevKey = ets:next(EtsRankType, RankKey) of
          '$end_of_table' ->
            1;
          _ ->
            [PrevEtsPlayerRank] = ets:lookup(EtsRankType, PrevKey),
            PrevEtsPlayerRank#ets_rank_player_info.rank + 1
        end,
      EtsPlayerRank =
        #ets_rank_player_info{
          key = RankKey,
          player_id = PlayerRankInfo#player_recharge_activity_rank_info.player_id,
          name = PlayerRankInfo#player_recharge_activity_rank_info.name,
          icon = PlayerRankInfo#player_recharge_activity_rank_info.icon,
          vip = PlayerRankInfo#player_recharge_activity_rank_info.vip,
          diamond_num = PlayerRankInfo#player_recharge_activity_rank_info.recharge,
          rank = RankNum,
          sex = PlayerRankInfo#player_recharge_activity_rank_info.sex,
          account = PlayerRankInfo#player_recharge_activity_rank_info.account
        },
      ets:insert(EtsRankType, EtsPlayerRank)
  end,
  if
    Flag ->
      case role_manager:get_roleprocessor(PlayerRankInfo#player_recharge_activity_rank_info.player_id) of
        {ok,Pid} ->
          role_processor_mod:cast(Pid,{'cs_rank_query_req',6});
        _->
          skip
      end;
    true ->
      skip
  end.

get_rank_key(PlayerRankInfo) ->
  {PlayerRankInfo#player_recharge_activity_rank_info.recharge,
    PlayerRankInfo#player_recharge_activity_rank_info.fresh_time_1,
    PlayerRankInfo#player_recharge_activity_rank_info.player_id}.

get_new_player_info(EtsName, NewData, NowTime, OldPlayerRankInfo) ->
  NewPlayerRankInfo =
    case EtsName of
      ?ETS_RANK_RECHARGE_ACTIVITY ->
        OldPlayerRankInfo#player_recharge_activity_rank_info{
          recharge = OldPlayerRankInfo#player_recharge_activity_rank_info.recharge + NewData,
          fresh_time_1 = 9999999999999 - NowTime
        };
      _ ->
        ?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
        OldPlayerRankInfo
    end,
  NewPlayerRankInfo.

do_refresh_rank() ->
  RechargeRankList = get_true_rank(?RECHARGE_NEED_NUM),  %% 获得前n名玩家
  NewRechargeRankList = combine_rank_list(RechargeRankList),
%%	?INFO_LOG("NewLastWeekRankList ~p~n",[NewLastWeekRankList]),
  do_reward_board(NewRechargeRankList),
  %% 清0排行榜
  clean_two_board(),
  ok.

get_true_rank(Num) ->
  RechargeRankList1 = ets:tab2list(?ETS_RANK_RECHARGE_ACTIVITY),
  RechargeRankList = lists:keysort(#ets_rank_player_info.key, RechargeRankList1),
  {UseRechargeRank, _} = lists:split(min(Num, length(RechargeRankList)), lists:reverse(RechargeRankList)),
  UseTotalWinRank2 = lists:map(fun({EData, Rank}) ->
    EData#ets_rank_player_info{rank = Rank} end, lists:zip(UseRechargeRank, lists:seq(1, length(UseRechargeRank)))),
  UseTotalWinRank2.

combine_rank_list(RechargeRankList) ->
  AllGoldNum =
    case recharge_activity_info_db:get(1) of
      {ok, [Info]} ->
        Info#recharge_activity_info.gold;
      _ ->
        0
    end,

  RankRewardConfig = get_recharge_rank_reward_list(),
  lists:foldl(fun(E, Acc) ->
    ERechargeRankData =
      case lists:keyfind(E, #ets_rank_player_info.rank, RechargeRankList) of
        false ->
          [];
        Data1 ->
          Data1
      end,
    UseRewardNum =
      case lists:keyfind(E, 1, RankRewardConfig) of
        false ->
          0;
        {_, Config} ->
          trunc(Config * AllGoldNum) div 100
      end,
    [{E, UseRewardNum, ERechargeRankData} | Acc] end, [], lists:seq(1, ?RECHARGE_NEED_NUM)).

get_recharge_rank_reward_list() ->
  List = recharge_activity_reward_config_db:get(),
  lists:map(fun(E) ->
    {E#recharge_activity_reward_config.rank, E#recharge_activity_reward_config.precent} end, List).

do_reward_board(NewRechargeRankList) ->
  lists:foreach(fun({Rank, RewardNum, ERechargeRankData}) ->
    Reward = [{?ITEM_ID_GOLD, RewardNum}],
    case ERechargeRankData of
      [] ->
        skip;
      _ ->
        Content2 = io_lib:format("恭喜您在上一周的[[ff69ef]金币彩池活动[-]]中名列第[[5bf6de]~p[-]],获得[[5bf6de]~p[-]]金币的排名奖励。", [Rank, RewardNum]),
        player_mail:send_system_mail(ERechargeRankData#ets_rank_player_info.player_id,
          1, ?MAIL_TYPE_RECHARGE_ACTIVITY_RANK_REWARD, "金币彩池奖励", Content2, Reward)
    end
                end, NewRechargeRankList).

clean_two_board() ->
  PlayerRankInfoList = player_recharge_activity_rank_info_db:get(),
  ets:delete_all_objects(?ETS_RANK_RECHARGE_ACTIVITY),
  case recharge_activity_info_db:get(1) of
    {ok,[PoolInfo]}->
      NewPoolInfo = PoolInfo#recharge_activity_info{
        gold = 0,
        last_time = util:now_seconds()
      },
      DBFun1 = fun() -> recharge_activity_info_db:t_write(NewPoolInfo) end,
      {atomic, _} = dal:run_transaction_rpc(DBFun1);
    _->
      skip
  end,
  init_pool(),
  lists:foreach(fun(EPlayerRankInfo) ->
    NewEPlayerRankInfo = EPlayerRankInfo#player_recharge_activity_rank_info{
      recharge = 0,
      fresh_time_1 = 0  %% 刷新数据时间1
    },
    DBFun = fun() -> player_recharge_activity_rank_info_db:t_write(NewEPlayerRankInfo) end,
    {atomic, _} = dal:run_transaction_rpc(DBFun),
    add_rank(?ETS_RANK_RECHARGE_ACTIVITY, NewEPlayerRankInfo,true)
                end,
    PlayerRankInfoList).

send_rank_update(GatePid, PlayerId) ->
  LastKey = ets:last(?ETS_RANK_RECHARGE_ACTIVITY),

  {Pool, MyRechargeMoney, StartTime, EndTime} = send_recharge_info(GatePid, PlayerId),

  ConfigList = recharge_activity_reward_config_db:get(),
  {PbRankInfoList, PlayerRankInfo} = get_rank(?RECHARGE_NEED_NUM, PlayerId, [], [], 1, LastKey, ConfigList),
  Rank =
    if
      PlayerRankInfo == [] ->
        0;
      true ->
        PlayerRankInfo#pb_rank_info.rank
    end,
%%  ?INFO_LOG("PbRankInfoList~p~n",[PbRankInfoList]),
  send_sc_rank_update(GatePid, 6, Rank, PbRankInfoList, Pool, MyRechargeMoney, StartTime, EndTime).

get_rank(NeedNum, PlayerId, PbRankInfoList, PbMyRankInfo, CurrentRank, CurrentKey, List) ->
  if
    CurrentRank =< NeedNum ->
      case ets:lookup(?ETS_RANK_RECHARGE_ACTIVITY, CurrentKey) of
        [EtsRankInfo] ->
          if
            EtsRankInfo#ets_rank_player_info.rank /= CurrentRank ->
              NewEtsRankInfo = EtsRankInfo#ets_rank_player_info{rank = CurrentRank};
            true ->
              NewEtsRankInfo = EtsRankInfo
          end,
          {_, _, CurrentPlayerId} = CurrentKey,
          PbPlayerInfo = pack_pb_rank_info(NewEtsRankInfo, List),
          if
            PlayerId == CurrentPlayerId ->
              NewPbMyRankInfo = PbPlayerInfo;
            true ->
              NewPbMyRankInfo = PbMyRankInfo
          end,
          PrevKey = ets:prev(?ETS_RANK_RECHARGE_ACTIVITY, CurrentKey),
          NewPbRankInfoList = [PbPlayerInfo | PbRankInfoList];
        _ ->
          Data1 = #pb_rank_info{
            rank = CurrentRank,
            player_uuid = "",
            player_name = "--",
            player_icon = "",
            player_vip = 0,
            sex = 0,
            account = "",
            win_gold_num = get_reward_precent_by_rank(List, CurrentRank),
            cash_num = 0
          },
          NewPbMyRankInfo = PbMyRankInfo,
          PrevKey = CurrentKey,
          NewPbRankInfoList = [Data1 | PbRankInfoList]
      end,
      get_rank(NeedNum, PlayerId, NewPbRankInfoList, NewPbMyRankInfo, CurrentRank + 1, PrevKey, List);
    true ->
      {PbRankInfoList, PbMyRankInfo}
  end.

add_recharge_activity_pool(NewData) ->
  case recharge_activity_info_db:get(1) of
    {ok, [Info]} ->
      NewInfo = Info#recharge_activity_info{
        gold = NewData * ?BASE_GOLD_NUM + Info#recharge_activity_info.gold,
        last_time = util:now_seconds()
      },
      NewInfo;
    _ ->
      Info = #recharge_activity_info{
        key = 1,
        gold = NewData * ?BASE_GOLD_NUM,
        last_time = util:now_seconds()},
      Info
  end.

pack_pb_rank_info(NewEtsRankInfo, List) ->
  {ok, PlayerUuid} = id_transform_util:role_id_to_proto(NewEtsRankInfo#ets_rank_player_info.player_id),
  Data1 = #pb_rank_info{
    rank = NewEtsRankInfo#ets_rank_player_info.rank,
    player_uuid = PlayerUuid,
    player_name = NewEtsRankInfo#ets_rank_player_info.name,
    player_icon = NewEtsRankInfo#ets_rank_player_info.icon,
    player_vip = NewEtsRankInfo#ets_rank_player_info.vip,
    sex = NewEtsRankInfo#ets_rank_player_info.sex,
    account = NewEtsRankInfo#ets_rank_player_info.account,
    win_gold_num = get_reward_precent_by_rank(List, NewEtsRankInfo#ets_rank_player_info.rank),
    cash_num = NewEtsRankInfo#ets_rank_player_info.diamond_num
  },
  Data1.

send_sc_rank_update(GatePid, RankType, MyRank, RankList, Pool, MyRechargeMoney, StartTime, EndTime) ->
  Msg = #sc_rank_qurey_reply{
    rank_type = RankType,
    my_rank = MyRank,
    rank_info_list = RankList,
    pool = Pool,
    my_recharge_money = MyRechargeMoney,
    start_time = StartTime,
    end_time = EndTime
  },
  %?INFO_LOG("sc_rank_qurey_reply ~p~n",[Msg]),
  tcp_client:send_data(GatePid, Msg).

get_reward_precent_by_rank(List, Rank) ->
  case lists:keyfind(Rank, #recharge_activity_reward_config.rank, List) of
    false ->
      0;
    Info ->
      trunc(Info#recharge_activity_reward_config.precent * 100)
  end.

send_recharge_info(_GatePid, PlayerId) ->
  {ok, Pool} = gen_server:call(recharge_activity_mod:get_mod_pid(), {'get_recharge_pool'}),
%%  ?INFO_LOG("RechargeGold~p~n", [Pool]),
  MyRechargeMoney =
    case player_recharge_activity_rank_info_db:get(PlayerId) of
      {ok, [MyRechargeInfo]} ->
        MyRechargeInfo#player_recharge_activity_rank_info.recharge;
      _ ->
        0
    end,

  NowSec = util:now_seconds(),
  WeekDay = util:get_week_day(NowSec),
  StartTime = NowSec - ?DAY_SECOND * (WeekDay - 1),
  EndTime = NowSec + ?DAY_SECOND * (7 - WeekDay),
  {Pool, MyRechargeMoney, StartTime, EndTime}.

init_pool()->
  case recharge_activity_info_db:get(1) of
    {ok, [Info]} ->
      put(recharge_gold_pool,Info);
    _->
      Info = #recharge_activity_info{
        key = 1,
        gold = 0,
        last_time =util:now_seconds()
      },
      put(recharge_gold_pool,Info)
  end.