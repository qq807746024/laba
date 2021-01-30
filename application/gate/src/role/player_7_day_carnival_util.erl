%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 三月 2018 14:58
%%%-------------------------------------------------------------------
-module(player_7_day_carnival_util).
-author("Administrator").

-define(PLAYER_7_DAY_CARNIVAL, player_7_day_carnival). % 7日狂欢
-define(STATE_0,0). %未完成
-define(STATE_1,1). %已完成
-define(STATE_2,2). %已领取


%% API
-export([
  draw/0,
  init_7_day_carnival_info/1,
  update_7_day_carnival_mission/2,
  update_7_day_carnival_mission_offline/3,
  send_init_msg/0
]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/share_pb.hrl").

get_7_day_carnival_info() ->
  get(?PLAYER_7_DAY_CARNIVAL).

update_7_day_carnival_info(Val) ->
  put(?PLAYER_7_DAY_CARNIVAL, Val).

save_7_day_carnival_info(NewInfo)->
  DBFun =
    fun() ->
      player_seven_days_carnival_info_db:t_write(NewInfo)
    end,
  DBSuccessFun =
    fun() ->
      update_7_day_carnival_info(NewInfo)
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      true;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}]),
      false
  end.

save_7_day_carnival_info(NewInfo,MsgFlag)->
  DBFun =
    fun() ->
      player_seven_days_carnival_info_db:t_write(NewInfo)
    end,
  DBSuccessFun =
    fun() ->
      if
        MsgFlag ->
          update_7_day_carnival_info(NewInfo);
        true ->
          skip
      end
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      true;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}]),
      false
  end.

init_7_day_carnival_info(PlayerId)->
  case player_chnid_info_db:get(PlayerId) of
    {ok,[Info]}->
      MyChnid = Info#player_chnid_info.chnid,
      if
        MyChnid > ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM ->
          % 从最近 3 期开始查
          ChnidBase = max(MyChnid rem ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM + ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM, 
            MyChnid - 3 * ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM),
          ChnidTuple1List = lists:reverse(lists:foldl(fun(Chnid, Acc) ->
            case ets:lookup(?ETS_ACTIVITY_CHNID_CONFIG,Chnid) of
              [ChnidTuple3|_] ->
                Acc ++ [ChnidTuple3];
              _ ->
                Acc
            end
          end, [], lists:seq(ChnidBase, MyChnid, ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM)));
          %?INFO_LOG("my chnid ~p~n", [{ChnidBase, ChnidTuple1List}]);
        true ->
          case ets:lookup(?ETS_ACTIVITY_CHNID_CONFIG,MyChnid) of
            [ChnidTuple3|_] ->
              ChnidTuple1List = [ChnidTuple3];
            _ ->
              ChnidTuple1List = []
          end
      end,
      case ChnidTuple1List of
        [ChnidTuple1|_]->
          case ets:lookup(?ETS_ACTIVITY_CHNID_CONFIG,time) of
            [TimeTuple2|_]->
              if
                ChnidTuple1#ets_data.value == 1->
                  init_7_day_carnival_info1(PlayerId),
                  %?INFO_LOG("init_7_day_carnival_info~p~n",[ChnidTuple1]),
                  player_share_lucky_wheel_util:init_share_lucky_wheel_info(PlayerId);
                true ->
                  PlayerInfo = player_util:get_dic_player_info(),
                  %?INFO_LOG("init_7_day_carnival_info~p~n",[TimeTuple2]),
                  if
                    PlayerInfo#player_info.create_time >= TimeTuple2#ets_data.value ->
                      init_7_day_carnival_info1(PlayerId),
                      player_share_lucky_wheel_util:init_share_lucky_wheel_info(PlayerId);
                    true ->
                      skip
                  end
              end;
            _->
              skip
          end;
        _->
          skip
      end;
    _->
      skip
  end.

init_7_day_carnival_info1(PlayerId)->
  case player_seven_days_carnival_info_db:get(PlayerId) of
    {ok,[Info]}->
      update_7_day_carnival_info(Info);
    _->
      {ok,[Config]} = share_task_redpack_config_db:get(560001),
      Info = #player_seven_days_carnival_info{
        player_id = PlayerId,
        now_task_id = Config#share_task_redpack_config.key,
        process = 0,
        status = ?STATE_0,
        condition = Config#share_task_redpack_config.condition,
        draw_list = [],
        draw_time = 1514736000
      },
      save_7_day_carnival_info(Info)
  end.

send_init_msg()->
  CarnivalInfo = get_7_day_carnival_info(),
  if
    CarnivalInfo == undefined ->
      skip;
    true ->
      %if
        %CarnivalInfo#player_seven_days_carnival_info.now_task_id == 560004 ->
        %  Count = player_share_lucky_wheel_util:get_share_times(),
        %  update_7_day_carnival_mission(4,Count);
        %CarnivalInfo#player_seven_days_carnival_info.now_task_id == 560006 ->
        %  Count = max(0,player_share_lucky_wheel_util:get_share_times() - 1),
        %  update_7_day_carnival_mission(6,Count);
        %true ->
        %  skip
      %end,
      send_init_msg_status_2()
  end.

send_init_msg_status_2()->
  CarnivalInfo = get_7_day_carnival_info(),
  DrawList = CarnivalInfo#player_seven_days_carnival_info.draw_list,
  IsDraw1 = lists:member(CarnivalInfo#player_seven_days_carnival_info.now_task_id,DrawList),
  IsDraw =
    if
      IsDraw1 ->
        1;
      true ->
        0
    end,
  player_share_lucky_wheel_util:send_init_msg(),
  send_sc_task_seven_info_response(CarnivalInfo#player_seven_days_carnival_info.now_task_id,CarnivalInfo#player_seven_days_carnival_info.process,
    CarnivalInfo#player_seven_days_carnival_info.status,IsDraw).
%%check_time(Info)->
%%  Nowsec = util:now_seconds(),
%%  Flag = util:is_same_date(Nowsec,Info#player_seven_days_carnival_info.draw_time),
%%  if
%%    not Flag andalso Info#player_seven_days_carnival_info.status == ?STATE_2 ->
%%      %% 更新任务
%%      NewInfo = next_misson(Info);
%%    true ->
%%      Info
%%  end.

%%next_misson(Info)->
%%  NowTaskId = Info#player_seven_days_carnival_info.now_task_id,
%%  {ok,[MissionConfig]} = share_task_redpack_config_db:get(NowTaskId),
%%  NextId = MissionConfig#share_task_redpack_config.post_id,
%%  case share_task_redpack_config_db:get(NextId) of
%%    {ok,[NextMissionConfig]}->
%%      NewInfo = Info#player_seven_days_carnival_info{
%%        now_task_id = NextMissionConfig#share_task_redpack_config.key,
%%        process = 0,
%%        status = ?STATE_0,
%%        condition = NextMissionConfig#share_task_redpack_config.condition
%%      },
%%      NewInfo;
%%    _->
%%      Info
%%  end.

draw()->
  CarnivalInfo = get_7_day_carnival_info(),
  NowSec = util:now_seconds(),
  Flag = util:is_same_date(NowSec,CarnivalInfo#player_seven_days_carnival_info.draw_time),

  if
    Flag ->
      send_sc_task_seven_award_response(1,"请明天再来领取奖励",[]);
    CarnivalInfo#player_seven_days_carnival_info.status == ?STATE_1 ->

      {ok,[Config]} = share_task_redpack_config_db:get(CarnivalInfo#player_seven_days_carnival_info.now_task_id),

      Rewards = get_carnival_reward(Config),
      {_PlayerInfo, DBReward, SuccessReward, PbReward} =
        item_use:transc_items_reward(Rewards, ?REWARD_TYPE_7_DAY_CARNIVAL),

      % 更新任务
      NewCarnivalInfo = update_mission_info(CarnivalInfo,Config),

      DBFun1 = fun() ->
        player_seven_days_carnival_info_db:t_write(NewCarnivalInfo) end,
      DBFun = fun() ->
        DBReward(),
        DBFun1()
              end,
      DBSuccess = fun()->
        SuccessReward(),
        update_7_day_carnival_info(NewCarnivalInfo),
        send_http_post_seventask(CarnivalInfo#player_seven_days_carnival_info.now_task_id)
      end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSuccess(),
          send_sc_task_seven_award_response(0,"",PbReward),
          send_init_msg();
        {aborted, Reason} ->
          ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
          send_sc_task_seven_award_response(1,"数据库错误",[])
      end;
    CarnivalInfo#player_seven_days_carnival_info.status == ?STATE_2 ->
      send_sc_task_seven_award_response(1,"已领取",[]);
    true ->
      send_sc_task_seven_award_response(1,"未完成",[])
  end.

send_sc_task_seven_award_response(Result,Err,PbReward)->
  Msg = #sc_task_seven_award_response{
    result = Result,
    err = Err,
    rewards = PbReward
  },
  tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

update_7_day_carnival_mission(MissionType,Count)->
  CarnivalInfo = get_7_day_carnival_info(),
  %?INFO_LOG("update_7_day_carnival_mission ~p~n.", [{MissionType, Count, CarnivalInfo}]),
  if
    CarnivalInfo == undefined ->
      skip;
    true ->
      update_7_day_carnival_mission_state_2(CarnivalInfo,MissionType,Count,true)
  end.

send_sc_task_seven_info_response(TaskId,Process,Status,IsDraw)->
  Msg = #sc_task_seven_info_response{
    task_id = TaskId,
    process = Process,
    status = Status,
    award = IsDraw
  },
  tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

update_7_day_carnival_mission_offline(PlayerId,MissionType,Count)->

  case player_seven_days_carnival_info_db:get(PlayerId) of
    {ok,[CarnivalInfo]} ->
      update_7_day_carnival_mission_state_2(CarnivalInfo,MissionType,Count,false);
    _->
      skip
  end.

update_7_day_carnival_mission_state_2(CarnivalInfo,MissionType,Count,MsgFlag)->
  MissionId = get_mission_id_by_mission_type(MissionType),
  if
    CarnivalInfo == undefined  ->
      skip;
    MissionId /=  CarnivalInfo#player_seven_days_carnival_info.now_task_id->
      if
        true ->
          skip;
        false ->
          % TODO 这是老的七日狂欢分享的，七日狂欢已经是一个被写蹦的模块，各种硬编码，配置已经鸡肋
          if
            MissionType == 4 ->
              if
                MsgFlag ->
                  update_7_day_carnival_mission(6,Count);
                true ->
                  update_7_day_carnival_mission_offline(CarnivalInfo#player_seven_days_carnival_info.player_id,6,Count)
              end;
            true ->
              skip
          end
      end;
    CarnivalInfo#player_seven_days_carnival_info.status == ?STATE_1 orelse CarnivalInfo#player_seven_days_carnival_info.status == ?STATE_2 ->
      skip;
    true ->
      NewProcess = CarnivalInfo#player_seven_days_carnival_info.process + Count,
      [_E1,_E2,_E3,E4] = CarnivalInfo#player_seven_days_carnival_info.condition,
      Cond = case E4 of
        [Val] ->
          Val;
        _ ->
          E4
      end,
      if
        NewProcess >= Cond->
          NewStatus = ?STATE_1;
        true ->
          NewStatus = CarnivalInfo#player_seven_days_carnival_info.status
      end,
      %?INFO_LOG("update_7_day_carnival_mission_state_2 ~p~n", [{E4, Cond, NewProcess, NewStatus, CarnivalInfo#player_seven_days_carnival_info.player_id}]),
      NewCarnivalInfo = CarnivalInfo#player_seven_days_carnival_info{
        process = NewProcess,
        status = NewStatus
      },
      Flag =save_7_day_carnival_info(NewCarnivalInfo,MsgFlag),
      if
        Flag ->
          DrawList = NewCarnivalInfo#player_seven_days_carnival_info.draw_list,
          IsDraw1 = lists:member(NewCarnivalInfo#player_seven_days_carnival_info.now_task_id,DrawList),
          IsDraw =
            if
              IsDraw1 ->
                1;
              true ->
                0
            end,
          if
            MsgFlag ->
              send_sc_task_seven_info_response(NewCarnivalInfo#player_seven_days_carnival_info.now_task_id,NewCarnivalInfo#player_seven_days_carnival_info.process,
                NewCarnivalInfo#player_seven_days_carnival_info.status,IsDraw);
            true ->
              skip
          end;
        true ->
          skip
      end
  end.


get_carnival_reward(Config)->
  if
    Config#share_task_redpack_config.item2_id == 0 ->
      [{Config#share_task_redpack_config.item1_id,Config#share_task_redpack_config.item1_num}];
    true ->
      [{Config#share_task_redpack_config.item1_id,Config#share_task_redpack_config.item1_num},
        {Config#share_task_redpack_config.item2_id,Config#share_task_redpack_config.item2_num}]
  end.

update_mission_info(CarnivalInfo,Config)->
  PostId = Config#share_task_redpack_config.post_id,
  if
    PostId == 0 ->
      CarnivalInfo#player_seven_days_carnival_info{
        status = ?STATE_2,
        draw_list = [CarnivalInfo#player_seven_days_carnival_info.now_task_id|CarnivalInfo#player_seven_days_carnival_info.draw_list],
        draw_time = util:now_seconds()
      };
    true ->
      {ok,[PostConfig]} = share_task_redpack_config_db:get(PostId),
      {Process,Status} =
      if
        false andalso PostId == 560004 ->
          Count = player_share_lucky_wheel_util:get_share_times(),
          [_,_,_,NeedCount1] = PostConfig#share_task_redpack_config.condition,
          if
            Count >= NeedCount1 ->
              {1,?STATE_1};
            true ->
              {0,?STATE_0}
          end;
        false andalso PostId == 560006 ->
          Count = player_share_lucky_wheel_util:get_share_times(),
          [_,_,_,NeedCount2] = PostConfig#share_task_redpack_config.condition,
          if
            Count - 1 >= NeedCount2 ->
              {1,?STATE_1};
            true ->
              {0,?STATE_0}
          end;
        true ->
          {0,?STATE_0}
      end,
      CarnivalInfo#player_seven_days_carnival_info{
        now_task_id = PostId,
        process = Process,
        status = Status,
        condition = PostConfig#share_task_redpack_config.condition,
        draw_list = [CarnivalInfo#player_seven_days_carnival_info.now_task_id|CarnivalInfo#player_seven_days_carnival_info.draw_list],
        draw_time = util:now_seconds()
      }
  end.

get_mission_id_by_mission_type(MissionType)->
  case MissionType of
    1 ->
      560001;
    2 ->
      560002;
    3 ->
      560003;
    4 ->
      560004;
    5 ->
      560005;
    6 ->
      560006;
    7->
      560007
  end.

get_day_by_mission_id(MissionId)->
  case MissionId of
    560001 ->
      1;
    560002 ->
      2;
    560003 ->
      3;
    560004 ->
      4;
    560005 ->
      5;
    560006 ->
      6;
    560007->
      7
  end.

send_http_post_seventask(NowTaskId)->
  PlayerInfo = player_util:get_dic_player_info(),
  ShareCharId = get_obj_share_id(),
  http_static_util:post_seventask(PlayerInfo,get_day_by_mission_id(NowTaskId),NowTaskId,ShareCharId).

get_obj_share_id()->
%%  PlayerShareInfo = get_player_share_info(),
  PlayerInfo = player_util:get_dic_player_info(),
  case player_share_binding_info_db:get(PlayerInfo#player_info.id) of
    {ok,[Info]}->
      Info#player_share_binding_info.share_player_id;
    _->
      0
  end.
