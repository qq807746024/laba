%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 四月 2017 15:28
%%%-------------------------------------------------------------------
-module(player_pack_task).
-author("wodong_0013").

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/activity_pb.hrl").

-define(DIC_PACK_TASK, dic_pack_task).

%% API
-export([
	init/1,
	send_enter_msg/1,
	cs_redpack_task_draw_req/3,
	get_dict_pack_task/0,
	clear_task/0,
	update_player_task_data/2
]).

update_dict_pack_task(Task) ->
	put(?DIC_PACK_TASK, Task).

get_dict_pack_task() ->
	get(?DIC_PACK_TASK).


init(PlayerId) ->
	case player_pack_task_info_db:get(PlayerId) of
		{ok, [PlayerTask]} ->
			update_dict_pack_task(PlayerTask);
		_ ->
			PlayerTask = #player_pack_task_info{
				player_id = PlayerId,
				task_info_list = lists:map(fun(EId) -> #pb_redpack_task_draw_info{
					game_type = EId,
					gold_num = 0,
					draw_list = []
				} end, [1, 2])
			},
			player_pack_task_info_db:write(PlayerTask),
			update_dict_pack_task(PlayerTask)
	end.


send_enter_msg(GameType) ->
	%?INFO_LOG("GameType --- ~p~n",[GameType]),
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			case check_game_type_ok(GameType) of
				true ->
					PlayerTask = get_dict_pack_task(),

					tcp_client:send_data(player_util:get_dic_gate_pid(), pack_task_draw_list_update_msg('enter', PlayerTask#player_pack_task_info.task_info_list, GameType));

				%tcp_client:send_data(player_util:get_dic_gate_pid(), Msg);
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}])
			end
	end.

pack_task_draw_list_update_msg(Type, TaskInfo, GameType) ->
	case Type of
		'enter' ->
			TaskInfo1 =
				lists:filter(fun(EPbInfo) ->
					EPbInfo#pb_redpack_task_draw_info.game_type == GameType
				end, TaskInfo),
			#sc_redpack_task_draw_list_update{
				upd_type = 1,
				list = TaskInfo1
			};
		_ ->
			TaskInfo1 =
				lists:map(fun(EPb) ->
					EPb#pb_redpack_task_draw_info{
						draw_list = []
					} end, TaskInfo),
			#sc_redpack_task_draw_list_update{
				upd_type = 2,
				list = TaskInfo1
			}
	end.


cs_redpack_task_draw_req(GameType, TaskId, EnterType) ->
	PlayerTask = get_dict_pack_task(),
	case check_game_type_ok(GameType) of
		false ->
			send_redpack_task_draw_reply(1, "Game类型错误", [], 0, 0, EnterType);
		_ ->
			MissionInfo = lists:keyfind(GameType, #pb_redpack_task_draw_info.game_type, PlayerTask#player_pack_task_info.task_info_list),
			case lists:member(TaskId, MissionInfo#pb_redpack_task_draw_info.draw_list) of
				true ->
					send_redpack_task_draw_reply(1, "已领过该奖励", [], 0, 0, EnterType);
				_ ->
					case check_gold_num_enough(GameType, TaskId, MissionInfo#pb_redpack_task_draw_info.gold_num) of
						{true, RewardNum} ->
							do_draw_ok(MissionInfo, TaskId, PlayerTask, RewardNum, EnterType);
						_ ->
							send_redpack_task_draw_reply(1, "条件未满足", [], 0, 0, EnterType)
					end
			end
	end.

check_game_type_ok(GameType) ->
	GameType > 0 andalso GameType < 3.

check_gold_num_enough(GameType, TaskId, NowGold) ->
	case redpack_task_reward_config_db:get_base({GameType, TaskId}) of
		{ok, [Base]} ->
			NeedGold = Base#redpack_task_reward_config.need_gold,
			{NeedGold =< NowGold, Base#redpack_task_reward_config.reward_pack_num};
		_ ->
			false
	end.


do_draw_ok(MissionInfo, TaskId, PlayerTask, RewardNum, EnterType) ->
	GameType = MissionInfo#pb_redpack_task_draw_info.game_type,
	OldList = PlayerTask#player_pack_task_info.task_info_list,
	NewMissionInfo = MissionInfo#pb_redpack_task_draw_info{
		draw_list = [TaskId | MissionInfo#pb_redpack_task_draw_info.draw_list]
	},
	NewPlayerTask = PlayerTask#player_pack_task_info{
		task_info_list = lists:keystore(GameType, #pb_redpack_task_draw_info.game_type,
			OldList, NewMissionInfo)
	},

	{_NewPlayerInfo, DBReward, SuccessReward, PbReward} = item_use:transc_items_reward(
		[{?ITEM_ID_GOLD, RewardNum}], ?REWARD_TYPE_RED_PACK_TASK),
	DBFun = fun() ->
		player_pack_task_info_db:t_write(NewPlayerTask),
		DBReward()
	end,
	DBSuccess = fun() ->
		update_dict_pack_task(NewPlayerTask),
		SuccessReward(),
		send_redpack_task_draw_reply(0, "", PbReward, GameType, TaskId, EnterType)
	end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccess();
		{aborted, Reason} ->
			send_redpack_task_draw_reply(1, "数据库错误", [], 0, 0, EnterType),
			?ERROR_LOG("Error ~p~n", [{Reason, ?MODULE, ?LINE}])
	end.


send_redpack_task_draw_reply(Result, Err, RewardPb, GameType, TaskId, EnterType) ->
	Msg =
		case EnterType of
			'game' ->
				#sc_redpack_task_draw_reply{
					result = Result,
					err = Err,
					reward = RewardPb,
					game_type = GameType,
					task_id = TaskId
				};
			_ ->
				#sc_activity_draw_reply{
					result = Result,
					err = Err,
					reward_list = RewardPb,
					activity_id = GameType,
					sub_id = TaskId
				}
		end,

	%io:format("redpack ~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


update_player_task_data(GameType, AddGold) ->
	PlayerTask = get_dict_pack_task(),
	OldTaskInfoList = PlayerTask#player_pack_task_info.task_info_list,
	TaskInfo = lists:keyfind(GameType, #pb_redpack_task_draw_info.game_type, OldTaskInfoList),
	NewTaskInfo = TaskInfo#pb_redpack_task_draw_info{
		gold_num = TaskInfo#pb_redpack_task_draw_info.gold_num + AddGold
	},
	NewTaskInfoList = lists:keystore(GameType, #pb_redpack_task_draw_info.game_type, OldTaskInfoList, NewTaskInfo),
	NewPlayerTask = PlayerTask#player_pack_task_info{
		task_info_list = NewTaskInfoList
	},
	update_dict_pack_task(NewPlayerTask),
	player_pack_task_info_db:write(NewPlayerTask),
	tcp_client:send_data(player_util:get_dic_gate_pid(), pack_task_draw_list_update_msg('upd', [NewTaskInfo], GameType)).

clear_task()->
	PlayerTask = get_dict_pack_task(),
	NewPlayerTask = #player_pack_task_info{
		player_id = PlayerTask#player_pack_task_info.player_id,
		task_info_list = lists:map(fun(EId) -> #pb_redpack_task_draw_info{
			game_type = EId,
			gold_num = 0,
			draw_list = []
		} end, [1, 2])
	},
	DBFun = fun() ->
		player_pack_task_info_db:t_write(NewPlayerTask)
					end,
	DBSuccess = fun() ->
		update_dict_pack_task(NewPlayerTask)
							end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccess();
		{aborted, Reason} ->
			?ERROR_LOG("Error ~p~n", [{Reason, ?MODULE, ?LINE}])
	end.