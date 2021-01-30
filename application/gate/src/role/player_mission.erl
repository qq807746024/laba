%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 二月 2017 13:51
%%%-------------------------------------------------------------------
-module(player_mission).
-author("Administrator").

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/mission_pb.hrl").

-define(NEWBIE_MISSION, 1).  %%  新手任务
-define(DAILY_MISSION, 2).  %%  日常任务
-define(WEEKLY_MISSION, 3).  %% 每周任务
-define(TIMING_MISSION, 4). %%  定时任务
-define(MONTHLY_MISSION, 5). %% 每月任务


-define(MISSION_STATUS_INCOMPLETE, 0).  %%  日常状态=》未完成
-define(MISSION_STATUS_COMPLETE, 1).  %%  日常状态=》完成
-define(MISSION_STATUS_DRAW, 2).  %%  日常状态=》已领取
-define(MISSION_STATUS_NULL, 99).  %%  日常状态=》忽略，不下发


%% API
-export([
  change_head/1,
  change_name/1,
  make_friend/1,
  niu_room_earn/2,
  niu_room_play/2,
  niu_room_leader/2,

  recharge/1,
  hundred_wars_play/1,
  hundred_niu_bet/1,
  hundred_wars_leader_win/1,
  hundred_wars_win/1,
  any_game_play/1,
  any_game_leader/1,
  any_game_earn/1,
  testtype_game_earn/1,
  testtype_game_play/1,
  fruit_carnival_play/1,
  fruit_normal_play/1,
  fruit_carnival_earn/1,
  car_earn/1,
  hundred_niu_set_chips_reward/1,
  daily_first_fudai_reward/1,
  daily_5_yuan_redpack_prize/1,
  daily_1_yuan_redpack_prize/1,
  send_draw_mission_back/3,
  fudai_get/1,
  laba_pool_reward_times/1,
  hundred_wars_leader/2,
  share_times/1,
  online_time/1,
  hundred_niu_testtype_earn/1,
  normal_fruit_testtype_earn/1,
  super_fruit_testtype_earn/1,
  car_testtype_earn/1,
  stickiness_redpack_earn/3,
  bet_stickiness_cost/3,
  bet_lock_cost/3,
  airlaba_testtype_earn/1
]).

-export([
  handle_event/1,
  login_initialize/0,
  send_player_login/0,
  draw/1,
  handle_time/2,
  gm_test/2
  %get_ets_player_mission_base/0
]).
%%----------------------
%%get_ets_player_mission_base() ->
%%  case ets:lookup(?ETS_MISSION_BASE_CONFIG, 1) of
%%    [] ->
%%      undefined;
%%    [Info] ->
%%      %?INFO_LOG("infoinfoinfo~p~n",[Info]),
%%      MissionbaseList = Info#ets_mission_base.mision_base_list,
%%      {ok, MissionbaseList}
%%  end.

%%-------------------------------------------------------
%% 修改头像
change_head(Count) ->
  send_mission_update_event({?MISSION_TYPE_CHANGE_HEAD, Count}).

%%修改名字
change_name(Count) ->
  send_mission_update_event({?MISSION_TYPE_CHANGE_NAME, Count}).

%%结识朋友
make_friend(Count) ->
  send_mission_update_event({?MISSION_TYPE_FRIEND, Count}).

%%充值
recharge(Count) ->
  send_mission_update_event({{?MISSION_TYPE_RECHARGE, Count}, [500007]}).

%%牛牛赚钱
niu_room_earn(Count, Lv) ->
  send_mission_update_event({?MISSION_TYPE_NIU_ROOM_EARN, Count, 0}),
  send_mission_update_event({?MISSION_TYPE_NIU_ROOM_EARN, Count, Lv}).


niu_room_play(Count, 10) ->
%%	send_mission_update_event({?MISSION_TYPE_NIU_ROOM_PLAY, Count, 0}),
  send_mission_update_event({{?MISSION_TYPE_NIU_ROOM_PLAY, Count, 10}, [500005]});

%%牛牛玩
niu_room_play(Count, Lv) ->
%%	send_mission_update_event({?MISSION_TYPE_NIU_ROOM_PLAY, Count, 0}),
  send_mission_update_event({{?MISSION_TYPE_NIU_ROOM_PLAY, Count, Lv}, [500004]}).

%%牛牛坐庄
niu_room_leader(Count, Lv) ->
  send_mission_update_event({?MISSION_TYPE_NIU_ROOM_LEADER, Count, 0}),
  send_mission_update_event({?MISSION_TYPE_NIU_ROOM_LEADER, Count, Lv}).

%%在百人大战玩
hundred_wars_play(Count) ->
  send_mission_update_event({{?MISSION_TYPE_HUNDRED_WARS_PLAY, Count}, [500008]}).

% 百人下注
hundred_niu_bet(Count) ->
  send_mission_update_event({{?MISSION_TYPE_HUNDRED_NIU_BET, Count}, [710005]}).

%%百人大战房间坐庄赢
hundred_wars_leader_win(Count) ->
  send_mission_update_event({{?MISSION_TYPE_HUNDRED_WARS_LEADER, Count}, [500003]}).

%%百人大战房间坐庄
hundred_wars_leader(Count, _TestType) ->
  MissionList = [510017, 520012],
  send_mission_update_event({{?MISSION_TYPE_HUNDRED_LEADER, Count}, MissionList}).

%%百人大战房间赢钱
hundred_wars_win(Count) ->
  send_mission_update_event({{?MISSION_TYPE_HUNDRED_WARS_WIN, Count}, [510020]}).
%%	send_mission_update_event({?MISSION_TYPE_HUNDRED_WARS_WIN_TIMES, 1}).

%%任意场玩
any_game_play(Count) ->
  MissionList = [510004],
  send_mission_update_event({{?MISSION_TYPE_ANY_GAME_PLAY, Count}, MissionList}).

% 娱乐场玩
testtype_game_play(Count) ->
  player_7_day_carnival_util:update_7_day_carnival_mission(1, Count),
  MissionList = [],
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_PLAY, Count}, MissionList}).

%%任意场坐庄赢
any_game_leader(Count) ->
  send_mission_update_event({?MISSION_TYPE_ANY_GAME_LEADER, Count}).

%%任意场赚金
any_game_earn(Count) ->
  player_golden_bull_util:update_mission(Count),
  MissionList = [520001, 520002, 520003, 520004, 520010],
  send_mission_update_event({{?MISSION_TYPE_ANY_GAME_EARN, Count}, MissionList}).

%% 娱乐场赚金（一样也会触发任意场任务，由逻辑上控制调用）
testtype_game_earn(Count) ->
  player_pay_activity_util:update_process(Count), % 红包任务更新
  % 七日-娱乐场赚金
  player_7_day_carnival_util:update_7_day_carnival_mission(2,Count),
  player_7_day_carnival_util:update_7_day_carnival_mission(4,Count),
  player_7_day_carnival_util:update_7_day_carnival_mission(5,Count),
  player_7_day_carnival_util:update_7_day_carnival_mission(7,Count),
  % 510050, 510051, 510052, 510053, 510054, 510055, 510056 -- 这是原来的每日赚金红包任务，现在屏蔽，变成粘性红包
  % 增加同步到月任务 2020-11-10
  MissionList = [
	  540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
	  540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
	  540021,540022,
	  510023,510024,510025,510026,510027,510028,510029,510030,510031,510032,510033,510034,510035],
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, MissionList}).

% 在水果玩
fruit_normal_play(Count) ->
  MissionList = [],
  send_mission_update_event({{?MISSION_TYPE_FRUIT_NORMAL_PLAY, Count}, MissionList}).

%%在水果狂欢玩牌
fruit_carnival_play(Count) ->
  send_mission_update_event({{?MISSION_TYPE_FRUIT_CARNIVAL_PLAY, Count}, [500009]}).

%%水果狂欢赚钱
fruit_carnival_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_FRUIT_CARNIVAL_EARN, Count}, [510021]}).

%% 豪车赚钱
car_earn(Count) ->
  send_mission_update_event({?MISSION_TYPE_CAR_EARN, Count}).

%% 百人牛牛每日压注奖励
hundred_niu_set_chips_reward(_Count) ->
  skip.
%%	send_mission_update_event({?MISSION_TYPE_DAILY_SET_CHIPS_REWARD_1, Count}).

%%每日福袋
daily_first_fudai_reward(Count) ->
  send_mission_update_event({{?MISSION_TYPE_DAILY_FUDAI, Count}, [510019, 510022]}).

%%每日兑换5元红包
daily_5_yuan_redpack_prize(Count) ->
  send_mission_update_event({{?MISSION_TYPE_5_YUAN_REDPACK_PRIZE, Count}, [510005]}).

%兑换1元红包
daily_1_yuan_redpack_prize(Count) ->
  MissionList = [],
  send_mission_update_event({{?MISSION_TYPE_1_YUAN_REDPACK_PRIZE, Count}, MissionList}).

fudai_get(Count) ->
  send_mission_update_event({{?MISSION_TYPE_BUY_FUDAI, Count}, [520007]}).

laba_pool_reward_times(Count) ->
  send_mission_update_event({{?MISSION_TYPE_LABA_POOL_REWARD_TIMES, Count}, [520011]}).

share_times(Count) ->
  send_mission_update_event({{?MISSION_TYPE_SHARE_TIMES, Count}, [520013]}).

online_time(Count) ->
  send_mission_update_event({{?MISSION_TYPE_ONLINE_TIME, Count}, [520008]}).

hundred_niu_testtype_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, [
    540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
    540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
    540021,540022,
    12510023,12510024,12510025,12510026,12510027,12510028,12510029,12510030,12510031,12510032,12510033,12510034,12510035]}),
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_HUNDRED_NIU_EARN_REDPACK, Count}, [
    543201,543202,543203,543204,543205,543206,543207,543208,543209,543210,
    543211,543212,543213,543214,543215,543216,543217,543218,543219,543220,
    543221,543222
  ]}).

normal_fruit_testtype_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, [
	540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
	540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
	540021,540022,
    22510023,22510024,22510025,22510026,22510027,22510028,22510029,22510030,22510031,22510032,22510033,22510034,22510035]}).

super_fruit_testtype_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, [
    540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
    540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
    540021,540022,
    32510023,32510024,32510025,32510026,32510027,32510028,32510029,32510030,32510031,32510032,32510033,32510034,32510035]}).

% 娱乐场豪车赚金
car_testtype_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, [
    540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
    540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
    540021,540022
  ]}),
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_CAR_EARN_REDPACK, Count}, [
    544201,544202,544203,544204,544205,544206,544207,544208,544209,544210,
    544211,544212,544213,544214,544215,544216,544217,544218,544219,544220,
    544221,544222
  ]}).

stickiness_redpack_earn(RoomType, TestType, Count) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      role_processor_mod:cast(self(), {'player_stickiness_redpack_update', RoomType, TestType, Count})
  end.

bet_stickiness_cost(RoomType, TestType, Count) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      role_processor_mod:cast(self(), {'player_bet_stickiness_update', RoomType, TestType, Count})
  end.

bet_lock_cost(RoomType, TestType, Count) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      role_processor_mod:cast(self(), {'player_bet_lock_update', RoomType, TestType, Count})
  end.

send_mission_update_event(Event) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      role_processor_mod:cast(self(), {'player_mission_update', Event})
  end.

airlaba_testtype_earn(Count) ->
  send_mission_update_event({{?MISSION_TYPE_TESTTYPE_GAME_EARN, Count}, [
    540001,540002,540003,540004,540005,540006,540007,540008,540009,540010,
    540011,540012,540013,540014,540015,540016,540017,540018,540019,540020,
    540021,540022]}).

%%--------------------------------------------------------------------------

%%修改头像
update_mission_status({?MISSION_TYPE_CHANGE_HEAD, ChangeCount}, PlayerMission, [1, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%修改名字
update_mission_status({?MISSION_TYPE_CHANGE_NAME, ChangeCount}, PlayerMission, [2, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%结识朋友
update_mission_status({?MISSION_TYPE_FRIEND, ChangeCount}, PlayerMission, [12, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%充值
update_mission_status({?MISSION_TYPE_RECHARGE, ChangeCount}, PlayerMission, [9, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%牛牛赚钱
update_mission_status({?MISSION_TYPE_NIU_ROOM_EARN, ChangeCount, Lv}, PlayerMission, [3, 2, Lv, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%牛牛玩
update_mission_status({?MISSION_TYPE_NIU_ROOM_PLAY, ChangeCount, Lv}, PlayerMission, [4, 2, Lv, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%牛牛坐庄
update_mission_status({?MISSION_TYPE_NIU_ROOM_LEADER, ChangeCount, Lv}, PlayerMission, [7, 2, Lv, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];


%%在百人大战玩牌
update_mission_status({?MISSION_TYPE_HUNDRED_WARS_PLAY, ChangeCount}, PlayerMission, [4, 1, 0, Count], UpdateMissionList) ->
%%	?INFO_LOG("update_mission_status~p~n",[{ChangeCount,PlayerMission,Count}]),
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%百人大战房间坐庄
update_mission_status({?MISSION_TYPE_HUNDRED_WARS_LEADER, Num}, PlayerMission, [7, 1, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

update_mission_status({?MISSION_TYPE_HUNDRED_LEADER, Num}, PlayerMission, [6, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      Status =
        case NewCount >= Count of
          true -> 1;
          false -> 0
        end,
      [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList]
  end;

%%百人大战房间赢钱
update_mission_status({?MISSION_TYPE_HUNDRED_WARS_WIN, Num}, PlayerMission, [3, 1, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%% 百人下注
update_mission_status({?MISSION_TYPE_HUNDRED_NIU_BET, Num}, PlayerMission, [16, 1, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%百人大战房间赢钱
update_mission_status({?MISSION_TYPE_HUNDRED_WARS_WIN_TIMES, Num}, PlayerMission, [5, 1, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%任意场玩
update_mission_status({?MISSION_TYPE_ANY_GAME_PLAY, Num}, PlayerMission, [4, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,

  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

% 娱乐场玩
update_mission_status({?MISSION_TYPE_TESTTYPE_GAME_PLAY, Num}, PlayerMission, [4, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

% 娱乐场豪车赚金
update_mission_status({?MISSION_TYPE_TESTTYPE_CAR_EARN_REDPACK, Num}, PlayerMission, [3, 4, 11, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

% 娱乐场百人赚金
update_mission_status({?MISSION_TYPE_TESTTYPE_HUNDRED_NIU_EARN_REDPACK, Num}, PlayerMission, [3, 3, 11, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%任意场坐庄赢
update_mission_status({?MISSION_TYPE_ANY_GAME_LEADER, Num}, PlayerMission, [7, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%任意场赚金
update_mission_status({?MISSION_TYPE_ANY_GAME_EARN, Num}, PlayerMission, [3, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%娱乐场场赚金 
% -- 金币
update_mission_status({?MISSION_TYPE_TESTTYPE_GAME_EARN, Num}, PlayerMission, [3, 0, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];
% -- 红包
update_mission_status({?MISSION_TYPE_TESTTYPE_GAME_EARN, Num}, PlayerMission, [3, 0, 7, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];
% -- 月任务
update_mission_status({?MISSION_TYPE_TESTTYPE_GAME_EARN, Num}, PlayerMission, [3, 0, 11, Count], UpdateMissionList) ->
  HasThisMission = lists:any(fun (Elem) ->
    Elem =:= PlayerMission#player_mission.mission_id
  end, get(accept_mission_id_set)),
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    not HasThisMission ->
      UpdateMissionList;
    true ->
      NewCount = PlayerMission#player_mission.record + Num,
      Status = case NewCount >= Count of
        true -> 1;
        false -> 0
      end,
      [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList]
  end;

% 玩普通水果
%%在水果狂欢玩牌
update_mission_status({?MISSION_TYPE_FRUIT_NORMAL_PLAY, ChangeCount}, PlayerMission, [4, 3, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%在水果狂欢玩牌
update_mission_status({?MISSION_TYPE_FRUIT_CARNIVAL_PLAY, ChangeCount}, PlayerMission, [4, 3, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + ChangeCount,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%%水果狂欢赚钱
update_mission_status({?MISSION_TYPE_FRUIT_CARNIVAL_EARN, Num}, PlayerMission, [3, 3, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

%% 豪车赚钱
update_mission_status({?MISSION_TYPE_CAR_EARN, Num}, PlayerMission, [3, 4, 0, Count], UpdateMissionList) ->
  NewCount = PlayerMission#player_mission.record + Num,
  Status =
    case NewCount >= Count of
      true -> 1;
      false -> 0
    end,
  [PlayerMission#player_mission{record = NewCount, status = Status} | UpdateMissionList];

% 百人大战每日首次压注100000金币
update_mission_status({?MISSION_TYPE_DAILY_SET_CHIPS_REWARD_1, Num}, PlayerMission, [14, 0, 0, Count], UpdateMissionList) ->
  Status =
    case Num >= Count of
      true -> 1;
      false -> PlayerMission#player_mission.status
    end,
  [PlayerMission#player_mission{record = Num, status = Status} | UpdateMissionList];

% 钻石福袋每日购
update_mission_status({?MISSION_TYPE_DAILY_FUDAI, Num}, PlayerMission, [15, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      Status =
        case Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_5_YUAN_REDPACK_PRIZE, Num}, PlayerMission, [16, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      Status =
        case Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_1_YUAN_REDPACK_PRIZE, Num}, PlayerMission, [17, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      Status =
        case Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_BUY_FUDAI, Num}, PlayerMission, [18, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      OldNum = PlayerMission#player_mission.record,
      Status =
        case OldNum + Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = OldNum + Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_LABA_POOL_REWARD_TIMES, Num}, PlayerMission, [19, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      OldNum = PlayerMission#player_mission.record,
      Status =
        case OldNum + Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = OldNum + Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_SHARE_TIMES, Num}, PlayerMission, [21, 0, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      OldNum = PlayerMission#player_mission.record,
      Status =
        case OldNum + Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = OldNum + Num, status = Status} | UpdateMissionList]
  end;

update_mission_status({?MISSION_TYPE_ONLINE_TIME, Num}, PlayerMission, [20, 0, Count], UpdateMissionList) ->
  if
    PlayerMission#player_mission.status /= ?MISSION_STATUS_INCOMPLETE ->
      UpdateMissionList;
    true ->
      OldNum = PlayerMission#player_mission.record,
      Status =
        case OldNum + Num >= Count of
          true -> 1;
          false -> PlayerMission#player_mission.status
        end,
      [PlayerMission#player_mission{record = OldNum + Num, status = Status} | UpdateMissionList]
  end;

update_mission_status(_Event, _PlayerMission, _MissionAchieveCondition, UpdateMissionList) ->
  UpdateMissionList.

%%-----------------------------------------------------

handle_event({Event, AcceptMissionIDSet}) ->
  PlayerInfo = player_util:get_dic_player_info(),
%%	?INFO_LOG("Event~p~n",[{Event,PlayerInfo#player_info.id,PlayerInfo#player_info.is_robot}]),
  PlayerID = PlayerInfo#player_info.id,
  %% 用于判断红包重置任务的激活
  NowDiamond = PlayerInfo#player_info.diamond,

%%	AcceptMissionIDSet = get(accept_mission_id_set),
  UpdateMissionList =
    lists:foldl(fun(MissionID, UpdateMissionListAcc) ->
      case {player_mission_db:get({PlayerID, MissionID}), get_player_mission_base(MissionID)} of
        {{ok, [PlayerMission]}, {ok, [PlayerMissionBase]}} when PlayerMission#player_mission.status =/= ?MISSION_STATUS_NULL ->
          case is_redpack_mission_type(PlayerMission#player_mission.mission_id) of
            true ->
              case triger_redpack_reset_mission(NowDiamond) of
                true ->
                  update_mission_status(Event, PlayerMission, PlayerMissionBase#player_mission_base.achieve_condition, UpdateMissionListAcc);
                _ ->
                  UpdateMissionListAcc
              end;
            _ ->
              update_mission_status(Event, PlayerMission, PlayerMissionBase#player_mission_base.achieve_condition, UpdateMissionListAcc)
          end;
        _ ->
          UpdateMissionListAcc
      end
                end,
      [],
      AcceptMissionIDSet),
  ?INFO_LOG("UpdateMissionList~p~n", [UpdateMissionList]),
  DBFun =
    fun() ->
      util:map(fun(Mission) ->
        player_mission_db:t_write(Mission)
      end, UpdateMissionList)
    end,
  DBSuccessFun =
    fun() ->
      case player_util:get_dic_gate_pid() of
        GateProc when GateProc =/= undefined ->
          util:map(fun(Mission) ->
            case packet_mission(Mission) of
              [] ->
                skip;
              PacketMission ->
                %?INFO_LOG("handle_sccuss~p~n",[PacketMission]),
                tcp_client:send_data(GateProc, #sc_mission_update{mission_ = PacketMission})
            end
          end,
            UpdateMissionList);
        _ ->
          void
      end,
      CheckList = lists:filter(fun(EMission) ->
        is_redpack_mission_type(EMission#player_mission.mission_id) end, UpdateMissionList),
      case CheckList of
        [] ->
          skip;
        _ ->
          do_check_all_redpack_mission_over(PlayerID)
      end
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun();
    {aborted, Reason} ->
      ?ERROR_LOG("成就系统处理事件失败【~p】!~n", [{Reason, PlayerID}])
  end.


login_initialize() ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      Now = calendar:local_time(),
      PlayerMissionBaseList = get_player_mission_base([]),

      {AcceptMissionIDSet, DrawMissionIDSet} =
        lists:foldl(fun(PlayerMissionBase, {AcceptMissionIDSetAcc, DrawMissionIDSetAcc}) ->
          initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSetAcc, DrawMissionIDSetAcc)
        end, {[], []}, PlayerMissionBaseList),
      PlayerID = PlayerInfo#player_info.id,
      %% 过滤已接受新手任务

      NewMissionIDSet = lists:filter(fun(MissionID) ->
          case player_mission_db:get({PlayerID, MissionID}) of
            {ok, []} -> true;
            {ok, [OldMission]} ->
              Flag1 = is_daily_mission_type(MissionID),
              Flag2 = is_weekly_mission_type(MissionID),
              Flag3 = is_timing_mission_type(MissionID),
              Flag5 = is_redpack_mission_type(MissionID),
              FlagMonthly = is_monthly_mission_type(MissionID),
              if
                Flag1 orelse Flag5 ->
                  %% 非今天接收的每日任务都需重置
                  {OldDate, _} = OldMission#player_mission.accept_time,
                  {NowDate, _} = Now,
                  OldDate =/= NowDate;
                Flag2 ->
                  %% 非一周的每周任务要重置
                  Sec1 = util:datetime_to_seconds(Now),
                  Sec2 = util:datetime_to_seconds(OldMission#player_mission.accept_time),
                  Flag4 = util:is_same_week(Sec1, Sec2),
                  not Flag4;
                FlagMonthly ->
                  not util:is_same_month_by_datetime(Now, OldMission#player_mission.accept_time);
                Flag3 ->
                  true;
                Flag5 ->
                  true;
                true ->
                  false
              end;
            _ ->
              false
          end
      end, AcceptMissionIDSet),
      NewMissionsSets = lists:foldl(fun(MissionID, Acc0) ->
        PlayerMission = create_mission(PlayerID, MissionID, Now),
        [PlayerMission | Acc0]
      end, [], NewMissionIDSet),

      Transition =
        fun() ->
          lists:foldl(fun(Mission, Acc0) ->
            player_mission_db:t_write(Mission),
            Acc0
          end,
          ok,
          NewMissionsSets)
        end,
      {atomic, _} = dal:run_transaction_rpc(Transition),
      put(draw_mission_id_set, DrawMissionIDSet),
      put(accept_mission_id_set, AcceptMissionIDSet)
  end.

create_mission(PlayerID, MissionID, AcceptTime) ->
  {ok, [PlayerMissionBase]} = get_player_mission_base(MissionID),

  case PlayerMissionBase#player_mission_base.condition of
    [] ->
      RecordNum = 0,
      AchieveTime = AcceptTime,
      Status = ?MISSION_STATUS_INCOMPLETE;
    [AchieveCondition | _] ->
      case AchieveCondition of
        {time, AchieveHour, _EndHour} ->  %% 小时时间类型的任务，默认完成，时间到了即可领取
          RecordNum = 0,
          {{Y, M, D}, {_, _, _}} = AcceptTime,
          AchieveTime = {{Y, M, D}, {AchieveHour, 0, 0}},
          %%EndTime = {{Y, M, D}, {EndHour, 0, 0}},
          Status = ?MISSION_STATUS_INCOMPLETE;
        _ ->
          RecordNum = 0,
          AchieveTime = AcceptTime,
          Status = ?MISSION_STATUS_INCOMPLETE
      end
  end,
  PlayerMission = #player_mission{
    key = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    status = Status,
    record = RecordNum,
    accept_time = AcceptTime,
    achieve_time = AchieveTime
  },
  PlayerMission.

send_player_login() ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      PlayerID = PlayerInfo#player_info.id,
      AcceptMissionIDSet = get(accept_mission_id_set),
      DrawMissionIDSet = get(draw_mission_id_set),
      Missions = lists:foldl(fun(MissionID, Acc0) ->
        case player_mission_db:get({PlayerID, MissionID}) of
          {ok, [PlayerMission]} ->
            [packet_mission(PlayerMission) | Acc0];
          _ ->
            Acc0
        end end, [], AcceptMissionIDSet),
      DrawMissions = lists:map(fun(E) ->
        #pb_mission{
          id = E,
          state = ?MISSION_STATUS_DRAW,
          count = 0
        } end, DrawMissionIDSet),
      AllMissions = lists:append(Missions, DrawMissions),
      ScMission = #sc_mission{missions = AllMissions},
      GateProc = player_util:get_dic_gate_pid(),
      tcp_client:send_data(GateProc, ScMission)
  end.


%% --- 初始化玩家任务 ---
%%新手
initialize_mission(PlayerInfo, _Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when 
    PlayerMissionBase#player_mission_base.id >= 500000 andalso PlayerMissionBase#player_mission_base.id < 510000 ->
  case player_mission_history_db:get({PlayerInfo#player_info.id, PlayerMissionBase#player_mission_base.id}) of
    {ok, []} ->
      {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet};
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;
%%每日
initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when
    (PlayerMissionBase#player_mission_base.id >= 510000 andalso PlayerMissionBase#player_mission_base.id < 520000)
    orelse
    (PlayerMissionBase#player_mission_base.id >= 12510000 andalso PlayerMissionBase#player_mission_base.id < 12520000) 
    orelse
    (PlayerMissionBase#player_mission_base.id >= 22510000 andalso PlayerMissionBase#player_mission_base.id < 22520000)
    orelse
    (PlayerMissionBase#player_mission_base.id >= 32510000 andalso PlayerMissionBase#player_mission_base.id < 32520000) ->
  PlayerID = PlayerInfo#player_info.id,
  {Date, _} = Now,
  case player_mission_history_db:get({PlayerID, PlayerMissionBase#player_mission_base.id, Date}) of
    {ok, []} ->
      {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet};
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;

%%每周
initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when 
    PlayerMissionBase#player_mission_base.id >= 520000 andalso PlayerMissionBase#player_mission_base.id < 530000 ->
  Date = get_week_num(Now),
  %?INFO_LOG("Date ~p~n", [Date]),
  case player_mission_history_db:get({PlayerInfo#player_info.id, PlayerMissionBase#player_mission_base.id, Date}) of
    {ok, []} ->
      {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet};
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;
%%定时
initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when 
    PlayerMissionBase#player_mission_base.id >= 530000 andalso PlayerMissionBase#player_mission_base.id < 540000 ->
  {Date, _} = Now,
  case player_mission_history_db:get({PlayerInfo#player_info.id, PlayerMissionBase#player_mission_base.id, Date}) of
    {ok, []} ->
      AcceptTime = calendar:local_time(),
      {{Y, M, D}, {_, _, _}} = AcceptTime,
      [{_, AchieveHour, EndHour}] = PlayerMissionBase#player_mission_base.condition,
      AchieveTime = {{Y, M, D}, {AchieveHour, 0, 0}},
      EndTime = {{Y, M, D}, {EndHour, 0, 0}},
      case get_status_by_now_time(AchieveTime, EndTime, AcceptTime) of
        ?MISSION_STATUS_NULL ->
          {AcceptMissionIDSet, DrawMissionIDSet};
        _ ->
          {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet}
      end;
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;
%%每月
initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when 
    PlayerMissionBase#player_mission_base.id >= 540000 andalso PlayerMissionBase#player_mission_base.id < 550000 ->
  {{Year, Month, _}, _} = Now,
  case player_mission_history_db:get({PlayerInfo#player_info.id, PlayerMissionBase#player_mission_base.id, {Year, Month}}) of
    {ok, []} ->
      {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet};
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;

%%每日
initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) when 
    PlayerMissionBase#player_mission_base.id >= 710000 andalso PlayerMissionBase#player_mission_base.id < 720000 ->
  PlayerID = PlayerInfo#player_info.id,
  {Date, _} = Now,
  case player_mission_history_db:get({PlayerID, PlayerMissionBase#player_mission_base.id, Date}) of
    {ok, []} ->
      {[PlayerMissionBase#player_mission_base.id | AcceptMissionIDSet], DrawMissionIDSet};
    {ok, [_]} ->
      {AcceptMissionIDSet, [PlayerMissionBase#player_mission_base.id | DrawMissionIDSet]}
  end;

initialize_mission(_PlayerInfo, _Now, _PlayerMissionBase, AcceptMissionIDSet, DrawMissionIDSet) ->
  {AcceptMissionIDSet, DrawMissionIDSet}.

%%  获取任务奖励
draw(MissionID) ->
  case pre_draw(MissionID) of
    {true, AccDict} ->
      Now = calendar:local_time(),
      Mission = dict:fetch(mission, AccDict),
      MissionBase = dict:fetch(mission_base, AccDict),
      Rewards = dict:fetch(rewards, AccDict),
      {HandleMissionHistoryDbFun, HandleMissionHistoryDBSuccessFun} = handle_mission_history(Now, Mission, MissionBase),
      {_NewPlayerInfo, DBFun1, SuccessFun1, PbRewads} = item_use:transc_items_reward(Rewards, ?REWARD_TYPE_MISSION),
      DBFun = fun() ->
        DBFun1(),
        HandleMissionHistoryDbFun()
      end,

      [{RewardItemId, RewardNum} | _] = Rewards,
      PlayerInfo = player_util:get_dic_player_info(),
      DBSuccessFun = fun() ->
        SuccessFun1(),
        HandleMissionHistoryDBSuccessFun(),
        send_draw_mission_back(0, "", PbRewads),
        http_static_util:post_task_log(PlayerInfo, MissionID, RewardItemId, RewardNum, util:now_seconds())
      end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSuccessFun(),
          %% update_mission_data(Now),
          PBMission = #pb_mission{
            id = MissionID,
            state = 2,
            count = 0
          },
          announcement_server:mission_accomplished(PlayerInfo#player_info.player_name, MissionID),
          tcp_client:send_data(player_util:get_dic_gate_pid(), #sc_mission_update{mission_ = PBMission});
        {aborted, Reason} ->
          send_draw_mission_back(1, "数据库错误", []),
          ?ERROR_LOG("领取任务奖励失败【~p】!~n", [{Reason, Mission#player_mission.player_id}])
      end;
    {false, Err} ->
      send_draw_mission_back(1, Err, [])
  end.

send_draw_mission_back(Result, Err, Rewards) ->
  Msg = #sc_draw_mission_result_reply{
    result = Result,
    err_msg = Err,
    reward_info_s = Rewards
  },
  %?INFO_LOG("send_draw_back~p~n", [Msg]),
  Gate = player_util:get_dic_gate_pid(),
  tcp_client:send_data(Gate, Msg).

pre_draw(MissionID) ->
  Requires = [
    check_mission_id_is_accept,
    check_mission_is_achieve,
    check_mission_base_exist,
    check_mission_rewards
  ],
  AccDict = dict:from_list([

  ]),
  pre_draw_check(MissionID, AccDict, Requires).

pre_draw_check(_MissionID, AccDict, []) ->
  {true, AccDict};
pre_draw_check(MissionID, AccDict, [check_mission_id_is_accept | T]) ->
  AcceptMissionIDSet = get(accept_mission_id_set),
  case lists:member(MissionID, AcceptMissionIDSet) of
    false ->
      {false, "任务ID未在列表中"};
    true ->
      pre_draw_check(MissionID, AccDict, T)
  end;
pre_draw_check(MissionID, AccDict, [check_mission_is_achieve | T]) ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  case player_mission_db:get({PlayerID, MissionID}) of
    {ok, [PlayerMission]} ->
      case PlayerMission#player_mission.status == 1 of
        true ->
          pre_draw_check(MissionID, dict:store(mission, PlayerMission, AccDict), T);
        false ->
          case is_timing_mission_type(MissionID) of
            true ->
              %%判断定时任务
              {ok, [MissionBase]} = get_player_mission_base(MissionID),
              Now = calendar:local_time(),
              {Date, _} = Now,
              [{time, Start, End} | _] = MissionBase#player_mission_base.condition,
              if
                {Date, {Start, 0, 0}} =< Now andalso Now =< {Date, {End, 0, 0}} ->
                  pre_draw_check(MissionID, dict:store(mission, PlayerMission, AccDict), T);
                true ->
                  {false, "任务未完成"}
              end;
            false ->
              {false, "任务未完成"}
          end
      end;
    _ ->
      ?INFO_LOG("pre_draw_check error___________ ~p~n", [{PlayerID, MissionID}]),
      {false, "无法领取"}
  end;


pre_draw_check(MissionID, AccDict, [check_mission_base_exist | T]) ->
  case get_player_mission_base(MissionID) of
    {ok, [MissionBase]} ->
      AccDict2 = dict:store(mission_base, MissionBase, AccDict),
      pre_draw_check(MissionID, AccDict2, T);
    {ok, []} ->
      {false, "数据库中的任务基本数据不存在!"};
    _ ->
      {false, "访问任务基本数据出错"}
  end;
pre_draw_check(MissionID, AccDict, [check_mission_rewards | T]) ->
  MissionBase = dict:fetch(mission_base, AccDict),
  Rewards = get_base_reward(MissionBase),
  CheckList = lists:foldl(fun(E, Acc) ->
    {Id, Num} = E,
    if
      Id > 0 andalso Num > 0 ->
        [E | Acc];
      true ->
        Acc
    end end, [], Rewards),
  case CheckList of
    [] ->
      {false, "奖励物品错误"};
    RewardList ->
      AccDict1 = dict:store(rewards, RewardList, AccDict),
      pre_draw_check(MissionID, AccDict1, T)
  end;

pre_draw_check(MissionID, AccDict, [_ | T]) ->
  pre_draw_check(MissionID, AccDict, T).

handle_mission_history(Now, Mission, MissionBase) when 
    MissionBase#player_mission_base.id >= 500000 andalso MissionBase#player_mission_base.id < 510000 ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,

  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now       %%  获取奖励时间
  },
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
          end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set))),
    put(draw_mission_id_set, [MissionID | get(draw_mission_id_set)])
  end,
  {DbFun, DbSuccessFun};

handle_mission_history(Now, Mission, MissionBase) when 
    (MissionBase#player_mission_base.id >= 510000 andalso MissionBase#player_mission_base.id < 520000)
    orelse
    (MissionBase#player_mission_base.id >= 12510000 andalso MissionBase#player_mission_base.id < 12520000) 
    orelse
    (MissionBase#player_mission_base.id >= 22510000 andalso MissionBase#player_mission_base.id < 22520000)
    orelse
    (MissionBase#player_mission_base.id >= 32510000 andalso MissionBase#player_mission_base.id < 32520000) ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,
  {Date, _} = Now,
  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID, Date},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now       %%  获取奖励时间
  },
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
          end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set)))
  end,
  {DbFun, DbSuccessFun};

handle_mission_history(Now, Mission, MissionBase) when 
    MissionBase#player_mission_base.id >= 520000 andalso MissionBase#player_mission_base.id < 530000 ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,
  WeekNum = get_week_num(Now),

  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID, WeekNum},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now                         %%  获取奖励时间
  },
  
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
  end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set)))
  end,
  {DbFun, DbSuccessFun};


handle_mission_history(Now, Mission, MissionBase) when 
    MissionBase#player_mission_base.id >= 530000 andalso MissionBase#player_mission_base.id < 540000 ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,
  {Date, _} = Now,

  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID, Date},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now                         %%  获取奖励时间
  },
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
  end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set)))
  end,
  {DbFun, DbSuccessFun};

handle_mission_history(Now, Mission, MissionBase) when 
    MissionBase#player_mission_base.id >= 540000 andalso MissionBase#player_mission_base.id < 550000 ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,
  {{Year, Month, _}, _} = Now,

  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID, {Year, Month}},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now                         %%  获取奖励时间
  },
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
  end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set)))
  end,
  {DbFun, DbSuccessFun};

handle_mission_history(Now, Mission, MissionBase) when 
    MissionBase#player_mission_base.id >= 710000 andalso MissionBase#player_mission_base.id < 720000 ->
  PlayerInfo = player_util:get_dic_player_info(),
  PlayerID = PlayerInfo#player_info.id,
  MissionID = MissionBase#player_mission_base.id,
  {Date, _} = Now,
  PlayerMissionHistory = #player_mission_history{
    key = {PlayerID, MissionID, Date},
    key2 = {PlayerID, MissionID},
    player_id = PlayerID,
    mission_id = MissionID,
    accept_time = Mission#player_mission.accept_time,
    achieve_time = calendar:local_time(),   %%  到达时间
    draw_time = Now       %%  获取奖励时间
  },
  DbFun = fun() ->
    player_mission_history_db:t_write(PlayerMissionHistory),
    player_mission_db:delete({PlayerID, MissionID})
          end,

  DbSuccessFun = fun() ->
    send_delete_mission(MissionID),
    put(accept_mission_id_set, lists:delete(MissionID, get(accept_mission_id_set)))
  end,
  {DbFun, DbSuccessFun}.

update_mission_data(Now) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      case get_player_mission_base([]) of
        PlayerMissionBaseList when is_list(PlayerMissionBaseList) ->
          PlayerInfo = player_util:get_dic_player_info(),
          PlayerID = PlayerInfo#player_info.id,
          {AcceptMissionIDSet, _DrawMissionIDSet} =
            lists:foldl(fun(PlayerMissionBase, {AcceptMissionIDSetAcc, DrawMissionIDSetAcc}) ->
              initialize_mission(PlayerInfo, Now, PlayerMissionBase, AcceptMissionIDSetAcc, DrawMissionIDSetAcc)
            end, {[], []}, PlayerMissionBaseList),
          NewMissionIDSet = lists:filter(fun(MissionID) ->
            case player_mission_db:get({PlayerID, MissionID}) of
              {ok, []} ->
                true;
              {ok, [OldMission]} ->
                Flag1 = is_daily_mission_type(MissionID),
                Flag2 = is_weekly_mission_type(MissionID),
                Flag3 = is_timing_mission_type(MissionID),
                Flag5 = is_redpack_mission_type(MissionID),
                FlagMonthly = is_monthly_mission_type(MissionID),
                if
                  Flag1 orelse Flag5 ->
                    %% 非今天接收的每日任务都需重置
                    {OldDate, _} = OldMission#player_mission.accept_time,
                    {NowDate, _} = Now,
                    OldDate =/= NowDate;
                  Flag2 ->
                    %% 非一周的每周任务要重置
                    Sec1 = util:datetime_to_seconds(Now),
                    Sec2 = util:datetime_to_seconds(OldMission#player_mission.accept_time),
                    Flag4 = util:is_same_week(Sec1, Sec2),
                    not Flag4;
                  FlagMonthly ->
                    not util:is_same_month_by_datetime(Now, OldMission#player_mission.accept_time);
                  Flag3 ->
                    true;
                  true ->
                    false
                end
            end end, AcceptMissionIDSet),
          NewMissionSet = lists:foldl(fun(MissionID, NewMissionSetAcc) ->
            [create_mission(PlayerID, MissionID, Now) | NewMissionSetAcc]
          end, [], NewMissionIDSet),
          Transition = fun() ->
            lists:foldl(fun(Mission, Acc0) ->
              player_mission_db:t_write(Mission),
              Acc0
            end, ok, NewMissionSet)
          end,
          {atomic, _} = dal:run_transaction_rpc(Transition),
          case player_util:get_dic_gate_pid() of
            GateProc when GateProc =/= undefined ->
              lists:foldl(fun(MissionID, Acc0) ->
                case lists:member(MissionID, Acc0) of
                  false ->
                    {ok, [PlayerMission]} = player_mission_db:get({PlayerID, MissionID}),
                    case packet_mission(PlayerMission) of
                      [] ->
                        skip;
                      PacketMission ->
                        % ?INFO_LOG("PacketMission~p~n",[PacketMission]),
                        tcp_client:send_data(GateProc, #sc_mission_add{mission_ = PacketMission})
                    end,
                    Acc0;
                  true ->
                    Acc0
                end
                          end, get(accept_mission_id_set), AcceptMissionIDSet);
            _ ->
              void
          end,
          IdListOut =
            lists:foldl(fun(MissionID, Acc0) ->
              Flag = lists:member(MissionID, Acc0),
              if
                Flag ->
                  Acc0;
                true ->
                  [MissionID | Acc0]
              end end, get(accept_mission_id_set), AcceptMissionIDSet),
          put(accept_mission_id_set, IdListOut);
        _ ->
          ?INFO_LOG("get_ets_mission_base_fail"),
          skip
      end
  end.


%is_newbie_mission_type(MissionId) ->
%  if
%    MissionId >= 500000 andalso MissionId < 510000 ->
%      true;
%    true ->
%      false
%  end.

is_daily_mission_type(MissionId) ->
  if
    (MissionId >= 510000 andalso MissionId < 520000)
    orelse
    (MissionId >= 12510000 andalso MissionId < 12520000) 
    orelse
    (MissionId >= 22510000 andalso MissionId < 22520000)
    orelse
    (MissionId >= 32510000 andalso MissionId < 32520000) ->
      true;
    true ->
      false
  end.

is_weekly_mission_type(MissionId) ->
  if
    MissionId >= 520000 andalso MissionId < 530000 ->
      true;
    true ->
      false
  end.

is_timing_mission_type(MissionId) ->
  if
    MissionId >= 530000 andalso MissionId < 540000 ->
      true;
    true ->
      false
  end.

is_monthly_mission_type(MissionId) ->
  if
    MissionId >= 540000 andalso MissionId < 550000 ->
      true;
    true ->
      false
  end.

is_redpack_mission_type(MissionId) ->
  if
    MissionId >= 710000 andalso MissionId < 720000 ->
      true;
    true ->
      false
  end.

get_status_by_now_time(AchieveTime, EndTime, AcceptTime) ->
  AchiveSec = calendar:datetime_to_gregorian_seconds(AchieveTime),  %%start
  AcceptSec = calendar:datetime_to_gregorian_seconds(AcceptTime),   %%now
  EndSec = calendar:datetime_to_gregorian_seconds(EndTime),         %%end
  if
    AchiveSec =< AcceptSec andalso EndSec >= AcceptSec ->
      ?MISSION_STATUS_COMPLETE;
    AchiveSec > AcceptSec ->
      ?MISSION_STATUS_INCOMPLETE;
    true ->
      ?MISSION_STATUS_INCOMPLETE
  end.

get_week_num(Date) ->
  %?INFO_LOG("Date~p~n", [Date]),
  {{Year, _, _}, _} = Date,
  WeekNum = util:week_of_year2(),
  {Year, WeekNum}.

packet_mission(PlayerMission) ->
  #pb_mission{
    id = PlayerMission#player_mission.mission_id,
    state = PlayerMission#player_mission.status,
    count = trunc(PlayerMission#player_mission.record)
  }.
send_delete_mission(MissionID) ->
  case player_util:get_dic_gate_pid() of
    GateProc when GateProc =/= undefined ->
      ScMissionDel = #sc_mission_del{id = MissionID},
      %?INFO_LOG("send_delet~p~n", [ScMissionDel]),
      tcp_client:send_data(GateProc, ScMissionDel);
    _ ->
      void
  end,
  ok.

handle_time(OldSeconds, NewSeconds) ->
  case util:is_same_date_spe(0, OldSeconds, NewSeconds) of
    true ->
      skip;
    false ->
      Now = calendar:local_time(),
      update_mission_data(Now),
      send_player_login()
  end.

get_base_reward(MissionBase) ->
  RewardId1 = MissionBase#player_mission_base.reward_id1,
  RewardNum1 = MissionBase#player_mission_base.reward_num1,
  RewardId2 = MissionBase#player_mission_base.reward_id2,
  RewardNum2 = MissionBase#player_mission_base.reward_num2,
  [{RewardId1, RewardNum1}, {RewardId2, RewardNum2}].

%% 判断红包任务是否都完成
do_check_all_redpack_mission_over(PlayerID) ->
  skip.
  % case player_redpack_room_util:check_can_add_reset_times() of
  %   true ->
  %     MissionIdList = [710005],
  %     CheckList =
  %       lists:filter(fun(E) ->
  %         case player_mission_db:get({PlayerID, E}) of
  %           {ok, [Mission]} ->
  %             Mission#player_mission.status =/= ?MISSION_STATUS_COMPLETE;
  %           _ ->
  %             true
  %         end end, MissionIdList),
  %     case CheckList of
  %       [] ->
  %         player_redpack_room_util:add_left_reset_times();
  %       _ ->
  %         skip
  %     end;
  %   _ ->
  %     skip
  % end.

triger_redpack_reset_mission(Diamond) ->
  false.
  % Diamond < player_redpack_room_util:get_config('game_limit').

get_player_mission_base([]) ->
  ets:tab2list(?ETS_MISSION_BASE);

get_player_mission_base(Id) ->
  case ets:lookup(?ETS_MISSION_BASE, Id) of
    [BaseConfig] ->
      {ok, [BaseConfig]};
    _ ->
      player_mission_base_db:get(Id)
  end.


gm_test(Type, Id) ->
  if
    Type == 1 ->
      niu_room_earn(5000, Id);
    Type == 2 ->
      draw(Id);
    Type == 3 ->
      if
        Id == 1 ->

          A = get(accept_mission_id_set),
          ?INFO_LOG("aaaaa~p~n", [A]);
        true ->
          A = get(draw_mission_id_set),
          ?INFO_LOG("aaaaa~p~n", [A])
      end;
    Type == 4 ->
      Now = calendar:local_time(),
      update_mission_data(Now);
    Type == 6 ->
      NowSec = util:now_seconds(),
      handle_time(1488629288, NowSec);
    Type == 7 ->
      hundred_wars_leader_win(1);
    Type == 8 ->
      any_game_earn(Id);
    Type == 9 ->

      A = self(),
      ?INFO_LOG("aaaaa~p~n", [A]);
    Type == 10 ->
      %ok;
      send_player_login();
    true ->
      skip
  end.
