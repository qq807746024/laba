%%%-------------------------------------------------------------------
%%% @author 硕爷
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 四月 2017 0:24
%%%-------------------------------------------------------------------
-module(player_game_task_util).

-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/mission_pb.hrl").


-define(DIC_PLAYER_GAME_TASK, dic_player_game_task).
-define(HUNDRED_GAME_TASK_NEWBIE_MISSION_INIT_ID, 800001).
-define(HUNDRED_GAME_TASK_NEWBIE_MISSION_ID_MAX, 800006).

-define(FRUIT_GAME_TASK_NEWBIE_MISSION_INIT_ID, 900001).
-define(FRUIT_GAME_TASK_NEWBIE_MISSION_ID_MAX, 900006).

-define(HUNDRED_TASK_TYPE_61, 61).
-define(HUNDRED_TASK_TYPE_62, 62).
-define(HUNDRED_TASK_TYPE_63, 63).
-define(HUNDRED_TASK_TYPE_64, 64).
-define(HUNDRED_TASK_TYPE_65, 65).
-define(HUNDRED_TASK_TYPE_66, 66).
-define(HUNDRED_TASK_TYPE_67, 67).
-define(HUNDRED_TASK_TYPE_68, 68).
-define(HUNDRED_TASK_TYPE_69, 69).
-define(HUNDRED_TASK_TYPE_70, 70).

-define(LABA_TASK_TYPE_51, 51).
-define(LABA_TASK_TYPE_52, 52).
-define(LABA_TASK_TYPE_53, 53).
-define(LABA_TASK_TYPE_54, 54).

-define(BOX_POS_LIST, [{1,3}, {2,5}, {3,7}]).        %% 宝箱任务次数

-define(DAILY_MISSION_NUM, 10).        %% 每日任务数量
%% API
-export([
	init/1,
	handle_timer/2,
	send_enter_room_msg/1,
	cs_game_task_draw_req/2,
	cs_game_task_box_draw_req/2,
	update_game_task_process_by_hundred/2,
	update_game_task_process_by_laba/5,
	get_newbie_hundred_mission_id_list/0,
	get_first_mission_id/1,
	change_newbie_mission/0,
	cs_game_task_box_draw_req1/2
]).


update_dic_player_task(NewPlayertask) ->
	put(?DIC_PLAYER_GAME_TASK, NewPlayertask).

get_dic_player_task() ->
	get(?DIC_PLAYER_GAME_TASK).

save_player_task_info(NewPlayertask) ->
	DBFun =
		fun() ->
			player_game_task_info_db:t_write(NewPlayertask)
		end,
	DBSuccessFun =
		fun() ->
			update_dic_player_task(NewPlayertask)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			ok;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

init(PlayerId) ->
	case player_game_task_info_db:get(PlayerId) of
		{ok, [PlayerTask]} ->
%%			NewPlayerTask = check_old(PlayerTask),
%%			if
%%				NewPlayerTask == PlayerTask ->
%%					update_dic_player_task(PlayerTask);
%%				true ->
%%					save_player_task_info(NewPlayerTask)
%%			end;
			update_dic_player_task(PlayerTask);
		_ ->
%%			PlayerInfo = player_util:get_dic_player_info(),
			PlayerTask =
				#player_game_task_info{
					player_id = PlayerId,
%%					hundred_today_mission_id = ?HUNDRED_GAME_TASK_NEWBIE_MISSION_INIT_ID,
%%					hundred_today_mission_condition = get_mission_condition(1, ?HUNDRED_GAME_TASK_NEWBIE_MISSION_INIT_ID),
%%					hundred_today_all_mission_id_list = get_newbie_hundred_mission_id_list(),
					fruit_today_mission_id = ?FRUIT_GAME_TASK_NEWBIE_MISSION_INIT_ID,
					fruit_today_mission_condition = get_mission_condition(2, ?FRUIT_GAME_TASK_NEWBIE_MISSION_INIT_ID),
%%					update_init_mission_date = erlang:date(),
					update_vip_level = get_mission_lv(2, ?FRUIT_GAME_TASK_NEWBIE_MISSION_INIT_ID)
				},
			%NewPlayerTask = check_old(PlayerTask),
			save_player_task_info(PlayerTask)
	end.

get_mission_condition(GameType, MissionId) ->
	case GameType of
		1 ->
			case hundred_game_task_config_db:get_base(MissionId) of
				{ok, [Base]} ->
					Base#hundred_game_task_config.achieve_conditicon;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					[]
			end;
		_ ->
			case laba_game_task_config_db:get_base(MissionId) of
				{ok, [Base]} ->
					Base#laba_game_task_config.achieve_conditicon;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					[]
			end
	end.

get_mission_lv(GameType, MissionId) ->
	case GameType of
		1 ->
			case hundred_game_task_config_db:get_base(MissionId) of
				{ok, [Base]} ->
					Base#hundred_game_task_config.account_level;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					9
			end;
		_ ->
			case laba_game_task_config_db:get_base(MissionId) of
				{ok, [Base]} ->
					Base#laba_game_task_config.account_level;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					9
			end
	end.

check_old(PlayerTask) ->
	NowDate = erlang:date(),
	UpdateMissionDate = PlayerTask#player_game_task_info.update_init_mission_date,
	if
		NowDate == UpdateMissionDate ->
			PlayerTask;
		true ->
			PlayerTask1 =
				case in_newbie_mission(PlayerTask#player_game_task_info.hundred_today_mission_id,
					PlayerTask#player_game_task_info.hundred_today_mission_complete_flag) of
					true ->
						PlayerTask;
					_ ->
						fresh_misison_data(1, PlayerTask, NowDate)
				end,
			PlayerTask2 =
				case in_newbie_mission(PlayerTask1#player_game_task_info.fruit_today_mission_id,
					PlayerTask1#player_game_task_info.fruit_today_mission_complete_flag) of
					true ->
						PlayerTask1;
					_ ->
						fresh_misison_data(2, PlayerTask1, NowDate)
				end,
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerTask2#player_game_task_info{update_init_mission_date = NowDate, update_vip_level = PlayerInfo#player_info.vip_level}
	end.

%% 检查是否在新手任务中
in_newbie_mission(NowMissionId, OverFlag) ->
	(NowMissionId >= ?HUNDRED_GAME_TASK_NEWBIE_MISSION_INIT_ID andalso
	NowMissionId < ?HUNDRED_GAME_TASK_NEWBIE_MISSION_ID_MAX) orelse (
		NowMissionId >= ?FRUIT_GAME_TASK_NEWBIE_MISSION_INIT_ID andalso
			NowMissionId < ?FRUIT_GAME_TASK_NEWBIE_MISSION_ID_MAX
	) orelse (OverFlag == false andalso
		NowMissionId == ?HUNDRED_GAME_TASK_NEWBIE_MISSION_ID_MAX) orelse (
		OverFlag == false andalso
			NowMissionId == ?FRUIT_GAME_TASK_NEWBIE_MISSION_ID_MAX
	).

fresh_misison_data(GameType, PlayerTask, NowDate) ->
	case GameType of
		1 ->
			%% 获取随机列表
			RandMissionIdList = get_rand_hundred_mission_id_list(),
			[FirstMission|_] = RandMissionIdList,
			PlayerTask#player_game_task_info{
				update_init_mission_date = NowDate,
				hundred_today_mission_id = FirstMission, %% 当前任务id
				hundred_today_mission_process = 0,  %% 该任务完成进度
				hundred_today_mission_process_over = false,  %% 该任务完成进度
				hundred_today_mission_achieve_num = 0,  %% 今日任务完成数量
				hundred_today_mission_complete_flag = false,  %% 所有任务完成=true
				hundred_today_mission_condition = get_mission_condition(1, FirstMission),  %% 任务完成条件
				hundred_box_draw_info = [],  %% 宝箱领奖情况 1，2，3
				hundred_today_all_mission_id_list = RandMissionIdList
			};
		_ ->
			MissionId = get_first_mission_id(GameType),
			PlayerTask#player_game_task_info{
				update_init_mission_date = NowDate,
				fruit_today_mission_id = MissionId, %% 当前任务id
				fruit_today_mission_process = 0,  %% 该任务完成进度
				fruit_today_mission_process_over = false,  %% 该任务完成进度
				fruit_today_mission_achieve_num = 0,  %% 今日任务完成数量
				fruit_today_mission_complete_flag = false,  %% 所有任务完成=true
				fruit_today_mission_condition = get_mission_condition(2, MissionId),
				fruit_box_draw_info = []
			}
	end.

%% 根据vip等级获得任务id
get_first_mission_id(Type) ->
	PlayerInfo = player_util:get_dic_player_info(),
	VipLevel = PlayerInfo#player_info.vip_level,
	case Type of
		1 ->
			get_first_mission_id_by_type(hundred_game_task_config_db, #hundred_game_task_config.key, VipLevel);
		_ ->
			get_first_mission_id_by_type(laba_game_task_config_db, #laba_game_task_config.key, VipLevel)
	end.

get_first_mission_id_by_type(DBName, RecordKey, VipLevel) ->
	case DBName:load_by_account_level(VipLevel) of
		{ok, List} ->
			[FirstConfig | _] = lists:keysort(RecordKey, List),
			element(2, FirstConfig);
		_ ->
			?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
			0
	end.


handle_timer(OldSec, NowSec) ->
	case util:is_same_date(OldSec, NowSec) of
		true ->
			skip;
		_ ->
			PlayerTast = get_dic_player_task(),
			NewPlayerTask = check_old(PlayerTast),
			save_player_task_info(NewPlayerTask),
			check_send_room_msg()
	end.


%% 检查是否在房间内
check_send_room_msg() ->
	skip.
	% PlayerHundredRoom = player_niu_room_util:get_player_room_info(),
	% PlayerLaba = player_laba_util:get_laba_dic(),
	% case PlayerHundredRoom#player_niu_room_info.room_id of
	% 	0 ->
	% 		skip;
	% 	_ ->
	% 		send_enter_room_msg(1)
	% end,
	% case PlayerLaba#player_laba_info.in_room of
	% 	false ->
	% 		skip;
	% 	_ ->
	% 		send_enter_room_msg(2)
	% end.

%% 进入房间时发送任务更新消息
send_enter_room_msg(RoomType) ->
	PlayerTast = get_dic_player_task(),
	EndTime = util:datetime_to_seconds({erlang:date(), {0,0,0}}) + ?DAY_SECOND,
	PlayerInfo = player_util:get_dic_player_info(),

	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
%%			?INFO_LOG("PlayerTast~p~n",[PlayerTast]),
			case RoomType of
				1 ->
					Type = 1,
					#player_game_task_info{
						hundred_today_mission_id = NowMissionId, %% 当前任务id
						hundred_today_mission_process = NowProcess,  %% 该任务完成进度
						hundred_today_mission_process_over = MissionOverFlag,  %% 该任务完成进度
						hundred_today_mission_achieve_num = AchieveNum,  %% 今日任务完成数量
						hundred_today_mission_complete_flag = CompleteFlag,  %% 所有任务完成=true
						hundred_box_draw_info = DrawList,
						update_vip_level = VipLevel
					} = PlayerTast;
				_ ->
					Type = 2,
					#player_game_task_info{
						fruit_today_mission_id = NowMissionId, %% 当前任务id
						fruit_today_mission_process = NowProcess,  %% 该任务完成进度
						fruit_today_mission_process_over = MissionOverFlag,  %% 该任务完成进度
						fruit_today_mission_achieve_num = AchieveNum,  %% 今日任务完成数量
						fruit_today_mission_complete_flag = CompleteFlag,  %% 所有任务完成=true
						fruit_box_draw_info = DrawList,
						update_vip_level = VipLevel
					} = PlayerTast
			end,
			%% 发生消息
			MsgMission = pack_game_task_msg(Type, NowMissionId, NowProcess, MissionOverFlag, CompleteFlag, AchieveNum, DrawList, EndTime, VipLevel),
			%player_util:log_by_player_id(1000901, "~p~n", [MsgMission]),
			tcp_client:send_data(player_util:get_dic_gate_pid(), MsgMission)
	end.

pack_game_task_msg(Type, NowMissionId, NowProcess, MissionOverFlag, CompleteFlag, AchieveNum, _DrawList, EndTime, VipLevel) ->
	MissionState =
		case MissionOverFlag of
			true ->
				case CompleteFlag of
					true ->
						2;
					_ ->
						1
				end;
			_ ->
				0
		end,
%%	BoxStart =
%%		case in_newbie_mission(NowMissionId, false) of
%%			true ->
%%				0;
%%			_ ->
%%				1
%%		end,
%%	BoxStateList =
%%		lists:foldl(fun({EPos, ETimes}, Acc) ->
%%			case lists:member(EPos, DrawList) of
%%				true ->
%%					Acc ++ [2];
%%				_ ->
%%					if
%%						ETimes =< AchieveNum ->
%%							Acc ++ [1];
%%						true ->
%%							Acc ++ [0]
%%					end
%%			end end, [], ?BOX_POS_LIST),
	PbInfo = #pb_game_task_info{
		taskid = NowMissionId,
		process = NowProcess,
		status = MissionState,
		boxstart = 1,
		boxprocess = AchieveNum,
		boxstatus = [2,2,2],
		remaindtime = EndTime,
		tast_type = Type,
		vip_level = VipLevel
	},
	#sc_game_task_info_update{
		tast_info = [PbInfo]
	}.

%% 更新任务进度 百人: 4门押注钱数,赢钱数, 4位置牌型
update_game_task_process_by_hundred([], _IsMaster) ->
	skip;
update_game_task_process_by_hundred(GameTaskData, IsMaster) ->
	#game_task_data{
		reward_num = WinNum,
		set_chips = SetChipsList,
		card_type_list = CardTypeList,
		rate_list = RateList
	} = GameTaskData,
	PlayerTask = get_dic_player_task(),
	#player_game_task_info{
		hundred_today_mission_id = NowMissionId,
		hundred_today_mission_process = NowCount,  %% 该任务完成进度
		hundred_today_mission_process_over = MissionOverFlag,  %% 该任务完成进度
		hundred_today_mission_achieve_num = NowAchieveNum,  %% 今日任务完成数量
		hundred_today_mission_condition = Condition  %% 任务完成条件
	} = PlayerTask,

	%player_util:log_by_player_id(1001713, "RateList, SetChipsList, CardTypeList, WinNum MissionOverFlag~p~n", [{RateList, SetChipsList, CardTypeList, WinNum, MissionOverFlag}]),
	case MissionOverFlag of
		true ->
			skip;
		_ ->
			[TaskType, NeedTimes, Parma1, Parma2] = Condition,
			%player_util:log_by_player_id(1001713, "Condition~p~n", [Condition]),
			AddTimeFlag =
				case TaskType of
					?HUNDRED_TASK_TYPE_61 ->
						get_pos_set_chips(SetChipsList, Parma1) >= Parma2;
					?HUNDRED_TASK_TYPE_62 ->
						get_pos_set_chips(SetChipsList, Parma1) >= Parma2 andalso get_pos_rate(RateList, Parma1) > 0;
					?HUNDRED_TASK_TYPE_63 ->
						get_pos_set_chips(SetChipsList, Parma1) >= Parma2 andalso get_pos_rate(RateList, Parma1) < 0;
					?HUNDRED_TASK_TYPE_64 ->
						check_set_card_type(SetChipsList, CardTypeList, Parma2, Parma1);
					?HUNDRED_TASK_TYPE_65 ->
						check_all_pos_set(SetChipsList, Parma2);
					?HUNDRED_TASK_TYPE_66 ->
						lists:foldl(fun({_, Num}, Acc) -> Acc+Num end, 0, SetChipsList);
					?HUNDRED_TASK_TYPE_67 ->
						WinNum >= Parma2;
					?HUNDRED_TASK_TYPE_68 ->
						IsMaster;
					?HUNDRED_TASK_TYPE_69 ->
						IsMaster andalso WinNum > 0;
					?HUNDRED_TASK_TYPE_70 ->
						if
							IsMaster andalso WinNum > 0 ->
								WinNum;
							true ->
								0
						end;
					_ ->
						?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
						false
				end,
			NewNowCount =
				case TaskType of
					?HUNDRED_TASK_TYPE_66 ->
						NeedTimes1 = Parma2,
						AddTimeFlag+NowCount;
					?HUNDRED_TASK_TYPE_70 ->
						NeedTimes1 = Parma2,
						AddTimeFlag+NowCount;
					_ ->
						NeedTimes1 = NeedTimes,
						case AddTimeFlag of
							true ->
								NowCount+1;
							_ ->
								NowCount
						end
				end,
			NewNowCount1 = min(NewNowCount, NeedTimes1),
			if
				NewNowCount1 == NeedTimes1 ->
					case in_newbie_mission(NowMissionId, MissionOverFlag) of
						true ->
							NewAchieveNum = 0;
						_ ->
							NewAchieveNum = NowAchieveNum + 1
					end,
					MissionOver = true;
				true ->
					NewAchieveNum = NowAchieveNum,
					MissionOver = false
			end,
			NewPlayerTask = PlayerTask#player_game_task_info{
				hundred_today_mission_process = NewNowCount1,  %% 该任务完成进度
				hundred_today_mission_process_over = MissionOver,  %% 该任务完成进度
				hundred_today_mission_achieve_num = NewAchieveNum %% 今日任务完成数量
			},
			if
				NewPlayerTask == PlayerTask ->
					skip;
				true ->
					save_player_task_info(NewPlayerTask),
					send_enter_room_msg(1)
			end
	end.


%% 更新任务进度 拉霸: 连线数量 单注下注 连线情况 获得金币 +免费摇奖次数
update_game_task_process_by_laba(LineNum, SetChipsNum, LineInfoList, RewardGold, AddFreeTimes) ->
	PlayerTask = get_dic_player_task(),
	PlayerInfo = player_util:get_dic_player_info(),
	#player_game_task_info{
		fruit_today_mission_id = NowMissionId,
		fruit_today_mission_process = NowCount,  %% 该任务完成进度
		fruit_today_mission_process_over = MissionOverFlag,  %% 该任务完成进度
		fruit_today_mission_achieve_num = NowAchieveNum,  %% 今日任务完成数量
		fruit_today_mission_condition = Condition,  %% 任务完成条件
		update_vip_level = VipLimit
	} = PlayerTask,
	if
		PlayerInfo#player_info.vip_level < VipLimit andalso VipLimit /= 99 ->
			skip;
		true ->
			case MissionOverFlag of
				true ->
					skip;
				_ ->
					[TaskType, NeedTimes, Parma1, Parma2] = Condition,
					AddTimeFlag =
						case TaskType of
							?LABA_TASK_TYPE_51 ->
								LineNum >= Parma1 andalso SetChipsNum >= Parma2;
							?LABA_TASK_TYPE_52 ->
								get_line_info_list_banana(LineInfoList, Parma1) andalso SetChipsNum >= Parma2;
							?LABA_TASK_TYPE_53 ->
								RewardGold >= Parma1;
							?LABA_TASK_TYPE_54 ->
								AddFreeTimes > 0 andalso SetChipsNum >= Parma2;
							_ ->
								?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
								false
						end,

					NewNowCount =
						if
							AddTimeFlag ->
								NowCount + 1;
							true ->
								NowCount
						end,
					NewNowCount1 = min(NewNowCount, NeedTimes),
					if
						NewNowCount1 == NeedTimes ->
							case in_newbie_mission(NowMissionId, MissionOverFlag) of
								true ->
									%?INFO_LOG("in_newbie_mission ~p~n",[true]),
									NewAchieveNum = 0;
								_ ->
									NewAchieveNum = 0
							end,
							MissionOver = true;
						true ->
							NewAchieveNum = NowAchieveNum,
							MissionOver = false
					end,
					%?INFO_LOG("NewAchieveNum ~p~n",[NewAchieveNum]),
					NewPlayerTask = PlayerTask#player_game_task_info{
						fruit_today_mission_process = NewNowCount1,  %% 该任务完成进度
						fruit_today_mission_process_over = MissionOver,  %% 该任务完成进度
						fruit_today_mission_achieve_num = NewAchieveNum %% 今日任务完成数量
					},
					if
						NewPlayerTask == PlayerTask ->
							skip;
						true ->
							save_player_task_info(NewPlayerTask),
							send_enter_room_msg(2)
					end
			end
	end.

get_line_info_list_banana(List, CheckNum) ->
	CheckList =
		lists:filter(fun({_LineId, SameNum, Type}) ->
			Type == 1 andalso SameNum >= CheckNum
		end, List),
	CheckList =/= [].


check_set_card_type(SetChipsList, CardTypeList, MinSet, CardType) ->
	SetPosList =
		lists:filter(fun({_, ESetNum}) ->
			ESetNum >= MinSet end, SetChipsList),
	CheckList =
		lists:filter(fun({EPos, _}) ->
			{_, ECardType} = lists:keyfind(EPos, 1, CardTypeList),
			ECardType == CardType end, SetPosList),
	CheckList =/= [].
%%
%% get_min_set_chips(SetChipsList) ->
%% 	case lists:keysort(2, SetChipsList) of
%% 		[] ->
%% 			0;
%% 		[{_, Data} | _] ->
%% 			Data
%% 	end.

%% 任务领奖
cs_game_task_draw_req(GameType, TaskId) ->
	PlayerGameTask = get_dic_player_task(),
	{NowMissionId, OverFlag, CompleteFlag, _DBName} =
		case GameType of
			1 ->
				{PlayerGameTask#player_game_task_info.hundred_today_mission_id,
					PlayerGameTask#player_game_task_info.hundred_today_mission_process_over,
					PlayerGameTask#player_game_task_info.hundred_today_mission_complete_flag,
					hundred_game_task_config_db};

			_ ->
				{PlayerGameTask#player_game_task_info.fruit_today_mission_id,
					PlayerGameTask#player_game_task_info.fruit_today_mission_process_over,
					PlayerGameTask#player_game_task_info.fruit_today_mission_complete_flag,
					laba_game_task_config_db}
		end,
	{Success, Err} =
		case OverFlag of
			false ->
				{false, "任务未完成"};
			_ ->
				case TaskId == NowMissionId of
					true ->
						case CompleteFlag of
							true ->
								{false, "已领"};
							_ ->
								{true, ""}
						end;
					_ ->
						{false, "任务id错误"}
				end
		end,
	case Success of
		true ->
			{NewCompleteFlag, MissionProcessOver, NextMissionId, Reward, NewHundredTodayMissionList,VipLevel} =
				get_mission_draw_info(NowMissionId, PlayerGameTask, GameType),
			{_PlayerInfo, DBReward, SuccessReward, PbReward} = item_use:transc_items_reward(Reward, get_reward_log_type('task', GameType)),
			NewPlayerGameTask =
				case GameType of
					1 ->
						case NewHundredTodayMissionList of
							false ->
								UseHundredMissionList = PlayerGameTask#player_game_task_info.hundred_today_all_mission_id_list;
							_ ->
								UseHundredMissionList = NewHundredTodayMissionList
						end,
						PlayerGameTask#player_game_task_info{
							hundred_today_mission_id = NextMissionId, %% 当前任务id
							hundred_today_mission_process = 0,  %% 该任务完成进度
							hundred_today_mission_process_over = MissionProcessOver,  %% 该任务完成进度
							%hundred_today_mission_achieve_num = PlayerGameTask#player_game_task_info.hundred_today_mission_achieve_num + 1,  %% 今日任务完成数量
							hundred_today_mission_complete_flag = NewCompleteFlag,  %% 所有任务完成=true
							hundred_today_mission_condition = get_mission_condition(1, NextMissionId),
							hundred_today_all_mission_id_list = UseHundredMissionList
						};
					_ ->
						PlayerGameTask#player_game_task_info{
							fruit_today_mission_id = NextMissionId, %% 当前任务id
							fruit_today_mission_process = 0,  %% 该任务完成进度
							fruit_today_mission_process_over = MissionProcessOver,  %% 该任务完成进度
							%fruit_today_mission_achieve_num = PlayerGameTask#player_game_task_info.fruit_today_mission_achieve_num + 1,  %% 今日任务完成数量
							fruit_today_mission_complete_flag = NewCompleteFlag,  %% 所有任务完成=true
							fruit_today_mission_condition = get_mission_condition(2, NextMissionId),
							update_vip_level = VipLevel
						}
				end,
			DBFun = fun() ->
				DBReward(),
				player_game_task_info_db:t_write(NewPlayerGameTask)
			end,
			DBSuccess = fun() ->
				SuccessReward(),
				update_dic_player_task(NewPlayerGameTask),
				send_game_task_draw_reply(0, "", PbReward),
				send_enter_room_msg(GameType)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccess();
				{aborted, Reason} ->
					send_game_task_draw_reply(1, "DBError", []),
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
			end;
		_ ->
			send_game_task_draw_reply(1, Err, [])
	end.

% {NewCompleteFlag, MissionProcessOver, NextMissionId, Reward}
get_mission_draw_info(NowMissionId, PlayerGameTask, GameType) ->
	case GameType of
		1 ->
			case hundred_game_task_config_db:get_base(NowMissionId) of
				{ok, [Base]} ->
					RewardId = Base#hundred_game_task_config.item1_id,
					RewardNum = Base#hundred_game_task_config.item1_num,
					VipLevel = Base#hundred_game_task_config.account_level,
					TodayMissionList = PlayerGameTask#player_game_task_info.hundred_today_all_mission_id_list,
					TotalMissionNum = length(TodayMissionList),
					ZipList = lists:zip(TodayMissionList, lists:seq(1, TotalMissionNum)),
					case lists:keyfind(NowMissionId, 1, ZipList) of
						false ->
							?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
							NextMissionId = 0;
						{_, NowPos} ->
							if
								NowPos == TotalMissionNum ->
									NextMissionId = 0;
								true ->
									case lists:keyfind(NowPos+1, 2, ZipList) of
										false ->
											?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
											NextMissionId = 0;
										{NextMissionId, _} ->
											NextMissionId
									end
							end
					end;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					VipLevel = 9,
					RewardId = 0,
					RewardNum = 0,
					NextMissionId = 0
			end;
		_ ->
			case laba_game_task_config_db:get_base(NowMissionId) of
				{ok, [Base]} ->
					NextMissionId = Base#laba_game_task_config.post_id,
					VipLevel =
					case laba_game_task_config_db:get_base(NextMissionId) of
						{ok,[NextConfig]} ->
							NextConfig#laba_game_task_config.account_level;
						_->
							0
					end,

					RewardId = Base#laba_game_task_config.item1_id,
					RewardNum = Base#laba_game_task_config.item1_num;
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					VipLevel = 9,
					RewardId = 0,
					RewardNum = 0,
					NextMissionId = 0
			end
	end,
	if
		NextMissionId == 0 ->
			case in_newbie_mission(NowMissionId, false) of
				true ->
					case GameType of
						1 ->
							RandMissionIdList = get_rand_hundred_mission_id_list(),
							[FirstMission|_] = RandMissionIdList,
							NewCompleteFlag = false,
							MissionProcessOver = false,
							UseNextMissionId = FirstMission,
							NewHundredTodayMissionList = RandMissionIdList;
						_ ->
							NewCompleteFlag = false,
							MissionProcessOver = false,
							UseNextMissionId = get_first_mission_id(GameType),
							NewHundredTodayMissionList = false
					end;
				_ ->
					NewCompleteFlag = true,
					MissionProcessOver = true,
					UseNextMissionId = NowMissionId,
					NewHundredTodayMissionList = false
			end;
		true ->
			NewCompleteFlag = false,
			MissionProcessOver = false,
			UseNextMissionId = NextMissionId,
			NewHundredTodayMissionList = false
	end,
%%	?INFO_LOG("VipLevel~p~n",[VipLevel]),
	{NewCompleteFlag, MissionProcessOver, UseNextMissionId, [{RewardId, RewardNum}], NewHundredTodayMissionList,VipLevel}.


send_game_task_draw_reply(Result, Err, PbReward) ->
	Msg = #sc_game_task_draw_reply{
		result = Result,
		err = Err,
		reward = PbReward
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


%% 任务宝箱领奖
cs_game_task_box_draw_req(_GameType, _TimesId)->
	skip.

cs_game_task_box_draw_req1(GameType, TimesId) ->
	PlayerGameTask = get_dic_player_task(),
	{NowMissionId, AchieveNum, DrawList} =
		case GameType of
			1 ->
				{PlayerGameTask#player_game_task_info.hundred_today_mission_id,
					PlayerGameTask#player_game_task_info.hundred_today_mission_achieve_num,
					PlayerGameTask#player_game_task_info.hundred_box_draw_info};
			_ ->
				{PlayerGameTask#player_game_task_info.fruit_today_mission_id,
					PlayerGameTask#player_game_task_info.fruit_today_mission_achieve_num,
					PlayerGameTask#player_game_task_info.fruit_box_draw_info}
		end,

	{Success, Err} =
		case lists:keyfind(TimesId, 1, ?BOX_POS_LIST) of
			{_, NeedTimes} ->
				case lists:member(TimesId, DrawList) of
					true ->
						{false, "已领"};
					_ ->
						if
							NeedTimes =< AchieveNum ->
								case in_newbie_mission(NowMissionId, PlayerGameTask#player_game_task_info.hundred_today_mission_complete_flag) of
									true ->
										{false, "新手任务中"};
									_ ->
										{true, ""}
								end;
							true ->
								{false, "条件未达到"}
						end
				end;
			_ ->
				{false, "id错误"}
		end,
	case {Success, Err} of
		{false, _} ->
			send_task_box_draw_reply(1, Err, []);
		{true, _} ->
			NewPlayerGameTask =
				case GameType of
					1 ->
						NewList = PlayerGameTask#player_game_task_info.hundred_box_draw_info ++ [TimesId],
						PlayerGameTask#player_game_task_info{
							hundred_box_draw_info = NewList
						};
					_ ->
						NewList = PlayerGameTask#player_game_task_info.fruit_box_draw_info ++ [TimesId],
						PlayerGameTask#player_game_task_info{
							fruit_box_draw_info = NewList
						}
				end,
			Reward = get_box_reward_by_level(GameType, PlayerGameTask#player_game_task_info.update_vip_level, TimesId),
			{_PlayerInfo, DBReward, SuccessReward, PbReward} = item_use:transc_items_reward(Reward, get_reward_log_type('box', GameType)),
			DBFun = fun() ->
				DBReward(),
				player_game_task_info_db:t_write(NewPlayerGameTask)
			end,
			DBSuccess = fun() ->
				SuccessReward(),
				update_dic_player_task(NewPlayerGameTask),
				send_task_box_draw_reply(0, "", PbReward),
				send_game_task_box_update(GameType, NewList, AchieveNum)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccess();
				{aborted, Reason} ->
					send_task_box_draw_reply(1, "DBError", []),
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
			end
	end.

send_task_box_draw_reply(Result, Err, PbReward) ->
	Msg = #sc_game_task_box_draw_reply{
		result = Result,
		err = Err,
		reward = PbReward
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

send_game_task_box_update(GameType, List, AchieveNum) ->
	UseList =
		lists:foldl(fun({E1, E2}, Acc) ->
			if
				E2 =< AchieveNum ->
					case lists:member(E1, List) of
						true ->
							Acc ++ [2];
						_ ->
							Acc ++ [1]
					end;
				true ->
					Acc ++ [0]
			end end, [], [{1,3}, {2,5}, {3,7}]),
	Msg = #sc_game_task_box_info_update{
		game_type = GameType,
		box_flag_list = UseList
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_box_reward_by_level(GameType, VipLevel, TimesId) ->
	case game_task_box_config_db:get_base({GameType, VipLevel}) of
		{ok, [Base]} ->
			case TimesId of
				1 ->
					[{?ITEM_ID_GOLD, Base#game_task_box_config.reward_gold1}];
				2 ->
					[{?ITEM_ID_GOLD, Base#game_task_box_config.reward_gold2}];
				3 ->
					[{?ITEM_ID_GOLD, Base#game_task_box_config.reward_gold3}];
				_ ->
					?INFO_LOG("error ~p~n",[{?MODULE, ?LINE}]),
					[]
			end;
		_ ->
			[]
	end.


get_reward_log_type(DrawType, GameType) ->
	case {DrawType, GameType} of
		{'task', 1} ->
			?REWARD_TYPE_GAME_TAST_NIU_MISSION;
		{'task', _} ->
			?REWARD_TYPE_GAME_TASK_LABA_MISSION;
		{'box', 1} ->
			?REWARD_TYPE_GAME_TAST_NIU_BOX;
		{'box', _} ->
			?REWARD_TYPE_GAME_TASK_LABA_BOX;
		_ ->
			0
	end.

get_pos_set_chips(SetChipsList, Pos) ->
	%?INFO_LOG("SetChipsList ~p~n", [SetChipsList]),
	case lists:keyfind(Pos, 1, SetChipsList) of
		false ->
			0;
		{_, SetNum} ->
			SetNum
	end.

get_pos_rate(RateList, Pos) ->
	lists:nth(Pos, RateList).

check_all_pos_set(SetChipsList, Parma2) ->
	CheckList = lists:filter(fun({_Pos, Num}) -> Num >= Parma2 end, SetChipsList),
	length(CheckList) == 4.

get_rand_hundred_mission_id_list() ->
	TotalList = hundred_game_task_config_db:get_base(),
	PlayerInfo = player_util:get_dic_player_info(),
	VipLevel = PlayerInfo#player_info.vip_level,
	UseList = lists:foldl(fun(E, Acc) ->
		if
			E#hundred_game_task_config.account_level == VipLevel ->
				[E#hundred_game_task_config.key|Acc];
			true ->
				Acc
		end end, [], TotalList),
	%?INFO_LOG("VipLevel UseList~p~n",[{VipLevel, UseList}]),
	{TotalMissionList, _} = lists:split(?DAILY_MISSION_NUM, util_random:random_order_list(UseList)),

	TotalMissionList.

get_newbie_hundred_mission_id_list() ->
	TotalList = hundred_game_task_config_db:get_base(),
	UseList = lists:foldl(fun(E, Acc) ->
		if
			E#hundred_game_task_config.account_level == 99 ->
				[E#hundred_game_task_config.key|Acc];
			true ->
				Acc
		end end, [], TotalList),
	lists:sort(UseList).

change_newbie_mission() ->
	PlayerTask = get_dic_player_task(),
	case PlayerTask#player_game_task_info.hundred_today_all_mission_id_list of
		[] ->
			?INFO_LOG("OKOK"),
			NewPlayerTask = PlayerTask#player_game_task_info{
				hundred_today_mission_process = 0,  %% 该任务完成进度
				hundred_today_mission_process_over = false,  %% 该任务完成进度
				hundred_today_mission_achieve_num = 0,  %% 今日任务完成数量
				hundred_today_mission_complete_flag = false,  %% 所有任务完成=true

				hundred_today_mission_id = 800001,
				hundred_today_all_mission_id_list = [800001,800002,800003,800004,800005],
				hundred_today_mission_condition = [61,1,1,1000]
			},
			save_player_task_info(NewPlayerTask);
		_ ->
			skip
	end.