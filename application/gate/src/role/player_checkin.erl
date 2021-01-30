%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 二月 2017 14:53
%%%-------------------------------------------------------------------
-module(player_checkin).
-author("Administrator").

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(MAX_CHECKIN_DAY, 7). %%签到最大日期
-define(WEEK_SECOND, 3600 * 24 * 7). %%一周的秒数
-define(CHECKIN_CARD_BASE_ID, 100002). %%补签卡base_id

%% API
-export([
  init_player_checkin_info/1,
  send_init_msg/0,
  handle_time/2,

  cs_daily_checkin/1,
  send_daily_checkin_back/4,
  cs_make_up_for_checkin/1,
  gm_test/2
]).
%%初始化
init_player_checkin_info(PlayerId) ->
  case player_checkin_info_db:get(PlayerId) of
    {ok, [PlayerCheckinInfo]} ->
      %?INFO_LOG("checktime~p~n",[PlayerCheckinInfo]),
      NewPlayerCheckinInfo = check_time(PlayerCheckinInfo),
      if
        NewPlayerCheckinInfo == PlayerCheckinInfo ->
          skip;
        true ->
          save_player_checkin_info(NewPlayerCheckinInfo)
      end;
    _ ->
      StartTime = util:get_today_start_second(),
      PlayerCheckinInfo = #player_checkin_info{
        player_id = PlayerId,
        check_list = [],
        %checkin_card = 0,
        refresh_check_time = StartTime,
        last_check_time = 946656000,
        can_checkin_day = 1
      },
      NewPlayerCheckinInfo = check_time(PlayerCheckinInfo),
      save_player_checkin_info(NewPlayerCheckinInfo)
  end.

save_player_checkin_info(Info) ->
  DBFun =
    fun() ->
      player_checkin_info_db:t_write(Info)
    end,
  DBSuccessFun =
    fun() ->
      void
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      ok;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
      error
  end.
%%发送初始化信息
send_init_msg() ->
  PlayerInfo = player_util:get_dic_player_info(),
  %?INFO_LOG("111~p~n",[PlayerInfo#player_info.id]),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      PlayerCheckinInfo = get_player_checkin_info(),
      CheckList = PlayerCheckinInfo#player_checkin_info.check_list,
      CheckinBaseInfoList = checkin_base_config_db:get(),
      PbCheckinInfo = get_pb_checkin_info(CheckinBaseInfoList, CheckList),
      NowSec = util:now_seconds(),
      Flag = util:is_same_date(PlayerCheckinInfo#player_checkin_info.last_check_time, NowSec),

      if
        PlayerInfo#player_info.vip_level == 0 ->
          IsDraw = false;
        true ->
          {ok, PlayerVipList} = player_vip_daily_reward_db:get(PlayerInfo#player_info.id),
          if
            PlayerVipList == [] ->
              IsDraw = false;
            true ->
              [PlayerVip | _] = PlayerVipList,
              IsDraw = util:is_same_date(NowSec, PlayerVip#player_vip_daily_reward.daily_reward_draw_time)
          end

      end,
      send_daily_checkin_info_update(PbCheckinInfo, PlayerCheckinInfo#player_checkin_info.can_checkin_day, Flag, IsDraw)
  end.

send_daily_checkin_info_update(List, Day, Flag, IsDraw) ->
  Msg = #sc_daily_checkin_info_update{
    list = List,
    %% 以下临时帮你加的.......
    all_checkin_day = Day,
    is_checkin_today = Flag,
    vip_is_draw = IsDraw
  },
  %?INFO_LOG("info_update~p~n",[Msg]),
  GatePid = player_util:get_dic_gate_pid(),
  tcp_client:send_data(GatePid, Msg).

%%生成#pb_checkin_info消息
get_pb_checkin_info(CheckinBaseInfoList, CheckList) ->
  lists:map(fun(E) ->
    Rewards = pack_reward_list(E#checkin_base_config.rewards),
    #pb_checkin_info{
      day = E#checkin_base_config.condition,
      rewards = item_use:get_pb_reward_info(Rewards),
      is_draw = lists:member(E#checkin_base_config.condition, CheckList)
    } end, CheckinBaseInfoList).

%%签到
cs_daily_checkin(Day) ->
	%?INFO_LOG("1 Day ~p~n",[Day]),
  case pre_daily_checkin(Day) of
    {true, AccDict} ->
      PlayerCheckinInfo = dict:fetch(player_checkin_info, AccDict),
      Rewards = dict:fetch(reward, AccDict),
      NowSec = util:now_seconds(),
      CheckList = PlayerCheckinInfo#player_checkin_info.check_list,
      NewCheckList = [Day | CheckList],
      NewPlayerCheckinInfo = PlayerCheckinInfo#player_checkin_info{
        check_list = NewCheckList,
        last_check_time = NowSec
      },

      {_NewPlayerInfo, DBFun1, SuccessFun1, _} =
        item_use:transc_items_reward(Rewards, ?REWARD_TYPE_CHECKIN),

      PbRewards = item_use:get_pb_reward_info(Rewards),
      DBFun = fun() ->
        DBFun1(),
        player_checkin_info_db:t_write(NewPlayerCheckinInfo)
              end,
      DBSccussFun = fun() ->
        SuccessFun1(),
        send_daily_checkin_back(0, "", PbRewards, Day)
                    end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSccussFun();
        {aborted, Reason} ->
          ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
          send_daily_checkin_back(1, "数据库错误", [], 0)
      end;
    {false, Err} ->
      send_daily_checkin_back(1, Err, [], 0)
  end.

pre_daily_checkin(Day) ->
  Requires = [
    check_day,
    check_reward
  ],
  AccDict = dict:from_list([
  ]),
  daily_checkin_requires(Day, AccDict, Requires).

daily_checkin_requires(_Day, AccDict, []) ->
  {true, AccDict};

daily_checkin_requires(Day, AccDict, [check_day | T]) ->

  PlayerCheckinInfo = get_player_checkin_info(),
  CheckList = PlayerCheckinInfo#player_checkin_info.check_list,
  LastCheckTime = PlayerCheckinInfo#player_checkin_info.last_check_time,
  NowSec = util:now_seconds(),

  Flag1 = lists:member(Day, CheckList),                %%检测Day是过去的日期
  Flag2 = (length(CheckList) + 1) == Day,              %%保证签到是下一个日期
  Flag3 = util:is_same_date(LastCheckTime, NowSec),    %%保证一天签到一次
  Flag4 = Day > ?MAX_CHECKIN_DAY andalso Day > PlayerCheckinInfo#player_checkin_info.can_checkin_day, %%检测签到日期在七日内
  if
    Flag1 ->
      {false, "已签到"};
    (not Flag2) orelse Flag4 ->
      {false, "签到日期错误"};
    Flag3 ->
      {false, "今日已签到"};
    true ->
      AccDict1 = dict:store(player_checkin_info, PlayerCheckinInfo, AccDict),
      daily_checkin_requires(Day, AccDict1, T)
  end;

daily_checkin_requires(Day, AccDict, [check_reward | T]) ->
  Key = Day + 100,
  case checkin_base_config_db:get(Key) of
    {ok, [CheckinBaesInfo]} ->
      RewardInfo = CheckinBaesInfo#checkin_base_config.rewards,
      Rewards = pack_reward_list(RewardInfo),
      AccDict1 = dict:store(reward, Rewards, AccDict),
      daily_checkin_requires(Day, AccDict1, T);
    _ ->
      {false, "查询签到配置表错误"}
  end;

daily_checkin_requires(Day, AccDict, [_ | T]) ->
  daily_checkin_requires(Day, AccDict, T).

%%签到返回
send_daily_checkin_back(Result, Err, RewardList, Day) ->
  Msg = #sc_daily_checkin_reply{
    result = Result,
    err = Err,
    rewards = RewardList,
    flag = Day
  },
  %?INFO_LOG("checkin_back~p~n", [Msg]),
  GatePid = player_util:get_dic_gate_pid(),
  tcp_client:send_data(GatePid, Msg).

%%获取玩家签到数据
get_player_checkin_info() ->
  PlayerInfo = player_util:get_dic_player_info(),
  case player_checkin_info_db:get(PlayerInfo#player_info.id) of
    {ok, [PlayerCheckinInfo]} ->
      PlayerCheckinInfo;
    _ ->
      #player_checkin_info{
        player_id = PlayerInfo#player_info.id,
        check_list = [],
        refresh_check_time = util:now_seconds(),
        last_check_time = 0,
        can_checkin_day = util:get_week_day()
      }
  end.
%%零点检测
handle_time(OldSec, NewSec) ->
  PlayerCheckinInfo = get_player_checkin_info(),
  NewPlayerCheckinInfo = check_time1(OldSec, NewSec, PlayerCheckinInfo),
  if
    NewPlayerCheckinInfo == PlayerCheckinInfo ->
      skip;
    true ->
      save_player_checkin_info(NewPlayerCheckinInfo),
      send_init_msg()
  end.

%% 时间检测
check_time(PlayerCheckinInfo) ->
  LastCheckinTime = PlayerCheckinInfo#player_checkin_info.last_check_time,
  NowSec = util:now_seconds(),
  check_time1(LastCheckinTime, NowSec, PlayerCheckinInfo).

check_time1(OldSec, NewSec, PlayerCheckinInfo) ->
  case util:is_same_date(OldSec, NewSec) of
    true ->
      %同天不改变
      PlayerCheckinInfo;
    false ->
      RefreshTime = PlayerCheckinInfo#player_checkin_info.refresh_check_time,
      CanCheckDay = calc_can_checkin_day(RefreshTime, NewSec),
      case util:is_same_week(RefreshTime,NewSec) of
        %同周改变可签到总天数（未补签）
        true ->

          PlayerCheckinInfo#player_checkin_info{
            can_checkin_day = CanCheckDay
          };
        %不同周刷新数据
        false ->
          %{Date, _} = util:seconds_to_datetime(NewSec),
          %NewFreshTime = util:datetime_to_seconds({Date, {0, 0, 0}}),
          PlayerCheckinInfo#player_checkin_info{
            check_list = [],
            refresh_check_time = NewSec,
            can_checkin_day = CanCheckDay
          }
      end
  end.


gm_test(Type, Day) ->
  if
    Type == 1 ->
      cs_daily_checkin(Day);
    Type == 2 ->
      cs_make_up_for_checkin(Day);
    Type == 4 ->
      player_checkin_info_db:clean(),
      player_vip_daily_reward_db:clean();
    Type == 5 ->
      PlayerInfo = player_util:get_dic_player_info(),
      {ok, [Info]} = player_checkin_info_db:get(PlayerInfo#player_info.id),
      %Time = Info#player_checkin_info.refresh_check_time,
      NewInfo = Info#player_checkin_info{
        check_list = [],
        refresh_check_time = util:now_seconds(),
        last_check_time = 946656000,
        can_checkin_day = util:get_week_day()
      },
      player_checkin_info_db:write(NewInfo);
    true ->
      ok
  end.

pack_reward_list(RewardInfo) ->
  [_, Id, Num] = RewardInfo,
  [{Id, Num}].
%% 补签
cs_make_up_for_checkin(Day) ->
  PlayerInfo = player_util:get_dic_player_info(),
  case player_checkin_info_db:get(PlayerInfo#player_info.id) of
    {ok, [PlayerCheckinInfo]} ->
      CanCheckinDay = PlayerCheckinInfo#player_checkin_info.can_checkin_day,
      CheckList = PlayerCheckinInfo#player_checkin_info.check_list,
      CardCost = [{?CHECKIN_CARD_BASE_ID,-1}],
      CheckinCardCheck = item_use:check_item_enough(CardCost),


      Flag1 = Day > CanCheckinDay,          %%保证是可签到日期
      Flag2 = lists:member(Day, CheckList), %%检测已签到
      CheckFlag =
        if
          Flag1 ->
            {false, "签到日期错误"};
          Flag2 ->
            {false, "已签到"};
          not CheckinCardCheck  ->
            {false, "补签劵不足"};
          true ->
            [Day | CheckList]
        end,
      case CheckFlag of
        {false, Err} ->
          send_daily_checkin_back(1, Err, [], 0);
        NewCheckList ->
          Key = Day + 100,
          {ok, [CheckinBaesInfo]} = checkin_base_config_db:get(Key),
          RewardInfo = CheckinBaesInfo#checkin_base_config.rewards,
          Reward = pack_reward_list(RewardInfo),
          NewPlayerCheckinInfo = PlayerCheckinInfo#player_checkin_info{
            check_list = NewCheckList
          },
          {_NewPlayerInfo, DBFun1, SuccessFun1, PbRewards} =
            item_use:transc_items_reward(Reward++CardCost, ?REWARD_TYPE_CHECKIN),

          DBFun = fun() ->
            DBFun1(),
			player_checkin_info_db:t_write(NewPlayerCheckinInfo)
                  end,
          DBSccussFun = fun() ->
            SuccessFun1(),
            send_daily_checkin_back(0, "", PbRewards, Day) end,
          case dal:run_transaction_rpc(DBFun) of
            {atomic, _} ->
              DBSccussFun();
            {aborted, Reason} ->
              ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
              send_daily_checkin_back(1, "数据库错误", [], 0)
          end
      end
  end.

calc_can_checkin_day(_RefreshTime, NewSec) ->
  util:get_week_day(NewSec).
