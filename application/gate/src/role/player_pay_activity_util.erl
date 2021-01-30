%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 四月 2018 16:52
%%%-------------------------------------------------------------------
-module(player_pay_activity_util).
-author("Administrator").

-define(PLAYER_PAY_ACTIVITY_INFO,player_pay_activity_info).
-define(STATE_0,0). %未完成
-define(STATE_1,1). %已完成
-define(STATE_2,2). %已领取
-define(LAST_TASK_ID,405). % 最后一档
-define(FIRST_TASK_ID,401). % 最后一档

%% API
-export([
  init_player_pay_activity_info/1,
  send_init_msg/0,
  cs_task_pay_award_request/1,
  cs_task_pay_info_request/0,
  task_open/0,
  update_process/1
]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/activity_pb.hrl").


update_player_pay_activity_info(Info)->
  put(?PLAYER_PAY_ACTIVITY_INFO,Info).

get_player_pay_activity_info()->
  get(?PLAYER_PAY_ACTIVITY_INFO).

init_player_pay_activity_info(PlayerId)->
  init_player_pay_activity_info2(PlayerId).

check_chnid_open(PlayerId)->
  case player_chnid_info_db:get(PlayerId) of
    {ok,[Info]}->
      MyChnid = Info#player_chnid_info.chnid,
      case ets:lookup(?ETS_ACTIVITY_GOLD_CHNID_CONFIG,MyChnid) of
        [ChnidTuple1|_]->
          case ets:lookup(?ETS_ACTIVITY_GOLD_CHNID_CONFIG,time) of
            [TimeTuple2|_]->
              if
                ChnidTuple1#ets_data.value == 1->
                  true;
                true ->
                  PlayerInfo = player_util:get_dic_player_info(),
                  if
                    PlayerInfo#player_info.create_time >= TimeTuple2#ets_data.value ->
                      true;
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

init_player_pay_activity_info2(PlayerId)->
  case player_pay_activity_info_db:get(PlayerId) of
    {ok,[Info]}->
      case check_chnid_open(PlayerId) of
        true ->
         update_player_pay_activity_info(Info);
        _->
          if
            Info#player_pay_activity_info.open == 0 ->
              skip;
            true ->
              List = act_golding_config_db:get(),
              OldConfigList = lists:filter(fun(E)-> E#act_golding_config.task_id == Info#player_pay_activity_info.task_id end,List),
              if
                length(OldConfigList) == length(Info#player_pay_activity_info.status) ->
                  skip;
                true ->
                  update_player_pay_activity_info(Info)
              end
          end
      end;
    _->
      case check_chnid_open(PlayerId) of
        true ->
          Info = #player_pay_activity_info{
            player_id = PlayerId,
            task_id = ?FIRST_TASK_ID,  %% 任务id
            process =0,  %% 进度
            status = [],  %% 完成状态
            open = 0   %% 是否开启
          },
          save_player_pay_activity_info(Info);
        _->
          skip
      end
  end.

save_player_pay_activity_info(Info)->
  DBFun =
    fun() ->
      player_pay_activity_info_db:t_write(Info)
    end,
  DBSuccessFun =
    fun() ->
      update_player_pay_activity_info(Info)
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      true;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}]),
      false
  end.

cs_task_pay_info_request()->
  send_init_msg().

send_init_msg()->
  PayActivityInfo = get_player_pay_activity_info(),
  if
    PayActivityInfo == undefined ->
      skip;
    true ->
      Msg = #sc_task_pay_info_response{
        task_id = PayActivityInfo#player_pay_activity_info.task_id,
        process = integer_to_list(PayActivityInfo#player_pay_activity_info.process),
        status = PayActivityInfo#player_pay_activity_info.status,
        open = PayActivityInfo#player_pay_activity_info.open
      },
%%      ?INFO_LOG("sc_task_pay_info_response~p~n",[Msg]),
      tcp_client:send_data(player_util:get_dic_gate_pid(),Msg)
  end.

cs_task_pay_award_request(Index)->
  PayActivityInfo = get_player_pay_activity_info(),
  if
    PayActivityInfo == undefined ->
      skip;
    true ->
      case act_golding_config_db:get(Index) of
        []->
          send_sc_task_pay_award_response(1,"查询配置表错误",[]);
        {ok,[Config]}->
%%          ?INFO_LOG("Config~p~n",[{Config,PayActivityInfo#player_pay_activity_info.process}]),
          Status = PayActivityInfo#player_pay_activity_info.status,
          Flag = lists:member(Index,Status),
          if
            Flag ->
              send_sc_task_pay_award_response(1,"已领取",[]);
            PayActivityInfo#player_pay_activity_info.process >=  Config#act_golding_config.total_gold->
              [_,RewardId,RewardNum] = Config#act_golding_config.reward,
              Rewards = [{RewardId,RewardNum}],
              {_PlayerInfo, DBReward, SuccessReward, PbReward} =
                item_use:transc_items_reward(Rewards, ?REWARD_TYPE_PAY_ACTIVITY_REWARD),

              NewPayActivityInfo = upadate_mission(PayActivityInfo,Index),
              PlayerInfo = player_util:get_dic_player_info(),

              DBFun = fun()->
                DBReward(),
                player_pay_activity_info_db:t_write(NewPayActivityInfo)
                      end,
              case dal:run_transaction_rpc(DBFun) of
                {atomic, _} ->
                  SuccessReward(),
                  update_player_pay_activity_info(NewPayActivityInfo),
                  send_sc_task_pay_award_response(0,"",PbReward),
                  send_init_msg(),
                  http_static_util:post_task_log(PlayerInfo, Index, RewardId, RewardNum, util:now_seconds());
                {aborted, Reason} ->
                  ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
                  send_sc_task_pay_award_response(1,"数据库错误",[])
              end;
            true ->
              send_sc_task_pay_award_response(1,"任务未完成",[])
          end
      end
  end.

send_sc_task_pay_award_response(Result,Err,PbReward)->
  Msg = #sc_task_pay_award_response{
    result = Result,
    err = Err,
    reward_list = PbReward
  },
  tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

upadate_mission(PayActivityInfo,Index)->
  OldStutes = PayActivityInfo#player_pay_activity_info.status,
  case check_chnid_open(PayActivityInfo#player_pay_activity_info.player_id) of
    true ->
      List = act_golding_config_db:get(),
      OldConfigList = lists:filter(fun(E)-> E#act_golding_config.task_id == PayActivityInfo#player_pay_activity_info.task_id end,List),
      if
        (length(OldStutes) + 1) == length(OldConfigList)->
          if
            PayActivityInfo#player_pay_activity_info.task_id == ?LAST_TASK_ID ->
              PayActivityInfo#player_pay_activity_info{
                task_id = ?LAST_TASK_ID,
                process =0,
                status = [],
                open = 0
              };
            true ->
              PayActivityInfo#player_pay_activity_info{
                task_id = PayActivityInfo#player_pay_activity_info.task_id + 1,
                process =0,
                status = [],
                open = 0
              }
          end;
        true ->
          PayActivityInfo#player_pay_activity_info{
            status = [Index|OldStutes]
          }
      end;
    _->
      PayActivityInfo#player_pay_activity_info{
        status = [Index|OldStutes]
      }
  end.

update_process(Count)->
  PayActivityInfo = get_player_pay_activity_info(),
  if
    PayActivityInfo == undefined ->
      skip;
    PayActivityInfo#player_pay_activity_info.open == 0 ->
      skip;
    true ->
      Limit = get_count_limit(PayActivityInfo#player_pay_activity_info.task_id),
      if
        PayActivityInfo#player_pay_activity_info.process >= Limit ->
          skip;
        true ->
          NewPayActivityInfo = PayActivityInfo#player_pay_activity_info{
            process = PayActivityInfo#player_pay_activity_info.process + Count
          },
          save_player_pay_activity_info(NewPayActivityInfo)
      end
  end.

task_open()->
  PayActivityInfo = get_player_pay_activity_info(),
  if
    PayActivityInfo == undefined ->
      skip;
    true ->
      NewPayActivityInfo = PayActivityInfo#player_pay_activity_info{
        process = 0,  %% 进度
        status = [],  %% 完成状态
        open = 1   %% 是否开启
      },
      save_player_pay_activity_info(NewPayActivityInfo),
      send_init_msg()
  end.


%% TODO 这个应该从配置中读取吧
get_count_limit(TaskId)->
  case TaskId of
    401 ->
      15000000;
    402 ->
      60000000;
    403 ->
      250000000;
    404 ->
      1000000000;
    405 ->
      2800000000
  end.


