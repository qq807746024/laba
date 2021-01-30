%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 三月 2017 18:29
%%%-------------------------------------------------------------------
-module(player_laba_util).
-author("wodong_0013").

-include("common.hrl").
-include("laba.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/laba_pb.hrl").

-include("./player_laba_util.hrl").

-define(IS_IN_BLACK_ROOM, is_in_black_room).
-define(BLACK_ROOM_SET_POS, 11).

%% API
-export([
	init/1,
	get_laba_dic/0,
	cs_laba_enter_room_req/3,
	cs_laba_leave_room_req/2,
	check_have_leave_room/0,

	cs_laba_spin_req/4,
	cs_win_player_list/1,

	check_not_in_room/0,
	check_in_hundred_room/0,
	gm_test/9,
	rate_set/3,
	rate_list/3,
	gm_set_laba_config/4,
	gm_test_laba_testtype1_one_player/8,
	gm_test_laba_testtype1/6
]).

init(PlayerId) ->
	init_blackroom(PlayerId),
	init_laba_info(PlayerId),
	init_super_laba_info(PlayerId),
	init_player_laba_win_gold(PlayerId).

init_laba_info(PlayerId)->
	case player_laba_info_db:get(PlayerId) of
		{ok, [PlayerLaba]} ->
			update_laba_dic(PlayerLaba);
		_ ->
			NewData = #player_laba_info{
				player_id = PlayerId,
				line_num = ?INIT_LABA_LINE_NUM,
				line_set_chips_pos = ?INIT_LABA_LINE_SET_CHIPS,
				free_num = 0,
				lucky_reward_times = 1,
				bet_times = 1
			},
			save_player_laba_info(NewData)
	end.

init_blackroom(PlayerId) ->
	BlackPlayerIds = player_util:get_server_const(?CONST_CONFIG_KEY_LABA_BLACK_ROOM),
	IsBalckId = lists:any(fun (Id) ->
		Id =:= PlayerId
	end, BlackPlayerIds),
	if
		IsBalckId ->
			put(?IS_IN_BLACK_ROOM, true),
			?INFO_LOG("=====> user ~p is in blackroom~n", [PlayerId]);
		true ->
			put(?IS_IN_BLACK_ROOM, false),
			skip
	end.

update_laba_dic(PlayerLaba) ->
	put(?LABA_DATA_DICT, PlayerLaba).

get_laba_dic() ->
	get(?LABA_DATA_DICT).

save_player_laba_info(PlayerLaba) ->
	DBFun =
		fun() ->
			player_laba_info_db:t_write(PlayerLaba)
		end,
	DBSuccessFun =
		fun() ->
			update_laba_dic(PlayerLaba)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
	end.

%% --- 超级水果初始化 ------
init_super_laba_info(PlayerId)->
	case player_super_laba_info_db:get(PlayerId) of
		{ok, [PlayerLaba]} ->
			update_super_laba_dic(PlayerLaba);
		_ ->
			NewData = #player_super_laba_info{
				player_id = PlayerId,
				line_num = 15,
				line_set_chips_pos = ?INIT_LABA_LINE_SET_CHIPS,
				free_num = 0
			},
			save_player_super_laba_info(NewData)
	end.

update_super_laba_dic(PlayerLaba) ->
	put(?SUPERLABA_DATA_DICT, PlayerLaba).

get_super_laba_dic() ->
	get(?SUPERLABA_DATA_DICT).

save_player_super_laba_info(PlayerLaba) ->
	DBFun =
		fun() ->
			player_super_laba_info_db:t_write(PlayerLaba)
		end,
	DBSuccessFun =
		fun() ->
			update_super_laba_dic(PlayerLaba)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}])
	end.

%% -----------------

%% --- 初始化 玩家 所有水果赢金 -------
init_player_laba_win_gold(PlayerId)->
	case player_laba_win_gold_db:get(PlayerId) of
		{ok,[Info]}->
			update_player_laba_win_gold(Info);
		_->
			Info =#player_laba_win_gold{
				player_id = PlayerId,
				laba_win = 0,
				super_laba_win = 0
			},
			save_player_laba_win_gold(Info)
	end.

update_player_laba_win_gold(Val) ->
	put(?PLAYER_LABA_WIN_GOLD, Val).

get_player_laba_win_gold() ->
	get(?PLAYER_LABA_WIN_GOLD).

save_player_laba_win_gold(Info)->
	DBFun =
		fun() ->
			player_laba_win_gold_db:t_write(Info)
		end,
	DBSuccessFun =
		fun() ->
			update_player_laba_win_gold(Info)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}])
	end.

cs_laba_enter_room_req(Type, TestType, IsAirLabaMod) ->
	case check_not_in_room() of
		true ->
			case check_enter_condtion() of
				true ->
					if
						Type == undefined orelse Type == 0 ->
							sys_notice_mod:send_notice("功能暂未开放"),
							{false, undefined};
						Type == ?TYPE_LABA ->
							{true, enter_laba(TestType, IsAirLabaMod, TestType)};
						true ->
							Flag = player_activity_util:check_activity_time(1),
							if
								Flag ->
									{true, enter_super_laba(TestType, IsAirLabaMod, TestType)};
								true ->
									sys_notice_mod:send_notice("不在活动时间内"),
									{false, undefined}
							end
					end;
				_ ->
					sys_notice_mod:send_notice("不满足进入条件"),
					{false, undefined}
			end;
		_ ->
			sys_notice_mod:send_notice("您还在游戏房间中"),
			{false, undefined}
	end.

enter_laba(TestType, IsAirLabaMod, TestType)->
	PlayerLaba = get_laba_dic(),
	PlayerId = PlayerLaba#player_laba_info.player_id,
	NewPlayerLaba = PlayerLaba#player_laba_info{
		in_room = true
	},
	save_player_laba_info(NewPlayerLaba),
	EtsData = #ets_laba_player_info{
		player_id = PlayerId,
		is_robot = false,
		is_in_airlaba = IsAirLabaMod,
		test_type = TestType
	},
	ets:insert(?ETS_LABA_PLAYER_INFO, EtsData),

	PlayerLabaInfo = get_laba_dic(),
	{STime,ETime} = player_activity_util:get_activity_time(1),
	Msg = #sc_laba_enter_room_reply{
		line_num = PlayerLabaInfo#player_laba_info.line_num,
		line_set_chips = PlayerLabaInfo#player_laba_info.line_set_chips_pos,
		last_free_times = PlayerLabaInfo#player_laba_info.free_num,
		type = ?TYPE_LABA,
		start_time = STime,
		end_time = ETime
	},
	GateId = player_util:get_dic_gate_pid(),
	if
		IsAirLabaMod ->
			%?INFO_LOG("88888 ===> 88888 send stickiness infoes...."),
			player_bet_stickiness_redpack:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_AIRLABA, TestType),
			player_bet_lock:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_AIRLABA, TestType),
			laba_mod:cast_to_notice_player_airlaba_pool_num(GateId);
		true ->
			tcp_client:send_data(GateId, Msg),
			player_bet_stickiness_redpack:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_LABA, TestType),
			player_bet_lock:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_LABA, TestType),
			laba_mod:cast_to_notice_player_pool_num(GateId)
	end,
	%% player_game_task_util:send_enter_room_msg(2),
	player_pack_task:send_enter_msg(2),
	do_add_room_member(),

	put(?NOW_ROOM_LEVEL, 30),
	PlayerInfo = player_util:get_dic_player_info(),
	player_niu_room_chest:enter_laba_room_msg(?TYPE_LABA),

	if
		IsAirLabaMod ->
			LogRoomType = ?HTTP_LOG_ROOM_TYPE_AIRLABA;
		true ->
			LogRoomType = ?HTTP_LOG_ROOM_TYPE_FRUIT
	end,
	http_static_util:post_enter_room(PlayerInfo, LogRoomType, TestType),
	Msg.

enter_super_laba(TestType, IsAirLabaMod, TestType)->
	PlayerLaba = get_super_laba_dic(),
	PlayerId = PlayerLaba#player_super_laba_info.player_id,
	NewPlayerLaba = PlayerLaba#player_super_laba_info{
		in_room = true
	},
	save_player_super_laba_info(NewPlayerLaba),
	EtsData = #ets_laba_player_info{
		player_id = PlayerId,
		is_robot = false,
		is_in_airlaba = IsAirLabaMod,
		test_type = TestType
	},
	ets:insert(?ETS_SUPER_LABA_PLAYER_INFO, EtsData),

	{STime,ETime} = player_activity_util:get_activity_time(1),
	Msg = #sc_laba_enter_room_reply{
		line_num = NewPlayerLaba#player_super_laba_info.line_num,
		line_set_chips = NewPlayerLaba#player_super_laba_info.line_set_chips_pos,
		last_free_times = NewPlayerLaba#player_super_laba_info.free_num,
		type = ?TYPE_SUPER_LABA,
		start_time = STime,
		end_time = ETime
	},
	GateId = player_util:get_dic_gate_pid(),
	if
		IsAirLabaMod ->
			skip;
		true ->
			tcp_client:send_data(GateId, Msg),
			player_bet_stickiness_redpack:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_SUPER_LABA, TestType),
			player_bet_lock:send_current_info(
				player_util:get_dic_player_info(), GateId, ?STICKINESS_REDPACK_EARN_SUPER_LABA, TestType),
			laba_mod:cast_to_notice_player_pool_num_super_laba(GateId)
	end,

	put(?NOW_ROOM_LEVEL, 31),
	PlayerInfo = player_util:get_dic_player_info(),
	player_niu_room_chest:enter_laba_room_msg(?TYPE_SUPER_LABA),
	if
		IsAirLabaMod ->
			LogRoomType = ?HTTP_LOG_ROOM_TYPE_SUPER_AIRLABA;
		true ->
			LogRoomType = ?HTTP_LOG_ROOM_TYPE_SUPER_LABA
	end,
	http_static_util:post_enter_room(PlayerInfo, LogRoomType, TestType),
	Msg.

%% 检测是否可进入房间
check_enter_condtion() ->
	true.


%% 添加房间伙伴
do_add_room_member() ->
	ok.

cs_laba_leave_room_req(Type, IsAirLabaMod) ->
	if
		Type == ?TYPE_LABA ->
			PlayerLaba = get_laba_dic(),
			RetMsg = case PlayerLaba#player_laba_info.in_room of
				true ->
					PlayerId = PlayerLaba#player_laba_info.player_id,
					ets:delete(?ETS_LABA_PLAYER_INFO, PlayerId),
					Msg = #sc_laba_leave_room_reply{
						result = 0
					},
					NewPlayerLaba = PlayerLaba#player_laba_info{
						in_room = false
					},
					save_player_laba_info(NewPlayerLaba),
					if
						IsAirLabaMod ->
							skip;
						true ->
							tcp_client:send_data(player_util:get_dic_gate_pid(), Msg)
					end,
					PlayerInfo = player_util:get_dic_player_info(),
					http_static_util:post_leave_room(PlayerInfo, ?HTTP_LOG_ROOM_TYPE_FRUIT),
					put(?NOW_ROOM_LEVEL, 0),
					Msg;
				_ ->
					undefined
			end;
		true ->
			PlayerLaba = get_super_laba_dic(),
			RetMsg = case PlayerLaba#player_super_laba_info.in_room of
				true ->
					PlayerId = PlayerLaba#player_super_laba_info.player_id,
					ets:delete(?ETS_SUPER_LABA_PLAYER_INFO, PlayerId),
					Msg = #sc_laba_leave_room_reply{
						result = 0
					},
					NewPlayerLaba = PlayerLaba#player_super_laba_info{
						in_room = false
					},
					save_player_super_laba_info(NewPlayerLaba),
					if
						IsAirLabaMod ->
							skip;
						true ->
							tcp_client:send_data(player_util:get_dic_gate_pid(), Msg)
					end,
					PlayerInfo = player_util:get_dic_player_info(),
					http_static_util:post_leave_room(PlayerInfo, ?HTTP_LOG_ROOM_TYPE_SUPER_LABA),
					put(?NOW_ROOM_LEVEL, 0),
					Msg;
				_ ->
					undefined
			end
	end,
	RetMsg.


%% 通知ob玩家删除观察者
%% notice_out_from_laba_room(_ObPlayerId, _DeletePlayerId) ->
%% 	ok.

%% 摇奖
%% 1:香蕉,2:西瓜,3:柠檬,4:葡萄,5:幸运草,6:铃铛,7:樱桃,8:纱票,9:WILD钻石,10:BONUS橙子,11:7
cs_laba_spin_req(LineNum, LineSetChipsPos,Type,TestType) ->
	case pre_spin(LineNum, LineSetChipsPos,Type,TestType) of
		{true, AccDict} ->
			LineNum1 = dict:fetch(line_num, AccDict),
			NewLineSetChipsPos = dict:fetch(line_set_chips_pos, AccDict),
			LineSetChips = dict:fetch(line_set_chips, AccDict),
			TotalKeyList = dict:fetch(fruit_list, AccDict),
			NewFreeNum = dict:fetch(new_free_num, AccDict),
			CostNum = dict:fetch(cost_num, AccDict),
      		LuckyRewardFlag = dict:fetch(luck_reward_flag, AccDict),
			WinGoldInfo = get_player_laba_win_gold(),

			{RewardNum, AddPoolNum, AddRankNum, WinPoolRate, LineRewardInfo, FreeTimes, AddToStorageNum,RewardAllTuple}
				= calc_settlement(TotalKeyList, LineNum1, LineSetChips,CostNum, Type, TestType),

			if
				Type == ?TYPE_LABA->
					PlayerLabaInfo = get_laba_dic(),
					LuckyRewardTimes = if
						LuckyRewardFlag ->
							0;
						true ->
							PlayerLabaInfo#player_laba_info.lucky_reward_times
						end,
					AllFreeNum = NewFreeNum + FreeTimes,
					NewLabaInfo = PlayerLabaInfo#player_laba_info{
						line_set_chips_pos = NewLineSetChipsPos,
						line_num = LineNum1,
						free_num = AllFreeNum,
						lucky_reward_times = LuckyRewardTimes,
						bet_times = PlayerLabaInfo#player_laba_info.bet_times + 1
					},
          			RewardlogType = ?REWARD_TYPE_LABA,
					WriteLabaInfo = fun() ->player_laba_info_db:t_write(NewLabaInfo) end,
					UpdateLabaInfo = fun() ->update_laba_dic(NewLabaInfo) end,
          			RankFun = fun() -> void end;
				true ->
					PlayerLabaInfo = get_super_laba_dic(),
					AllFreeNum = NewFreeNum + FreeTimes,
					NewLabaInfo = PlayerLabaInfo#player_super_laba_info{
						line_set_chips_pos = NewLineSetChipsPos,
						line_num = LineNum1,
						free_num = AllFreeNum
					},
          			RewardlogType = ?REWARD_TYPE_SUPER_LABA,
					WriteLabaInfo = fun() ->player_super_laba_info_db:t_write(NewLabaInfo) end,
					UpdateLabaInfo = fun() ->update_super_laba_dic(NewLabaInfo) end,
          			RankFun = fun() ->player_rank_util:rank_change(PlayerLabaInfo#player_super_laba_info.player_id, ?RANK_TYPE_FRUIT, abs(CostNum)) end
			end,
			AddFreeFlag =
				case FreeTimes of
					5 ->
						1;
					10 ->
						2;
					15 ->
						3;
					_ ->
						0
				end,
			%% 检测赢奖池
			%?INFO_LOG("WinPoolRate ~p~n",[WinPoolRate]),
			if
				WinPoolRate > 0 ->
					if
						Type == ?TYPE_LABA->
							{ok, WinPoolGoldNum} = gen_server:call(laba_mod:get_mod_pid(), {'call_dis_pool_num', {AddPoolNum, AddRankNum}, WinPoolRate, player_util:get_dic_player_info()});
						true ->
							{ok, WinPoolGoldNum} = gen_server:call(laba_mod:get_mod_pid(), {'call_dis_pool_num_super_laba', {AddPoolNum, AddRankNum}, WinPoolRate, player_util:get_dic_player_info()})
					end,
					%?INFO_LOG("WinPoolGoldNum ~p~n",[WinPoolGoldNum]),
					if
						WinPoolGoldNum > 0 ->
							WinPoolFlag = 1;
						true ->
							WinPoolFlag = 0
					end;
				true ->
					WinPoolFlag = 0,
					WinPoolGoldNum = 0,
					check_add_pool_num({AddPoolNum, AddRankNum},Type)
			end,

			%% if
			%%	AddToStorageNum > 0 ->
			%%		depot_manager_mod:add_to_depot(AddToStorageNum);
			%%	true ->
			%%		skip
			%%	end,

			ShowTotalReward = RewardNum + WinPoolGoldNum,
			TotalReward = RewardNum + WinPoolGoldNum - AddPoolNum - AddToStorageNum,
			TotalEarnReward = TotalReward + CostNum,
			{NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward([{?ITEM_ID_GOLD, TotalEarnReward}], RewardlogType),
			if
				0 =/= AddFreeFlag ->
					?INFO_LOG("laba user ~p add free ~p~n", [NewPlayerInfo#player_info.id, AddFreeFlag]);
				true ->
					skip
			end,

			if
				Type == ?TYPE_LABA ->
					player_mission:bet_stickiness_cost(?STICKINESS_REDPACK_EARN_LABA, TestType, -CostNum),
					player_mission:bet_lock_cost(?STICKINESS_REDPACK_EARN_LABA, TestType, -CostNum),
					player_statistics_util:cast_cost(laba, -CostNum, TestType),
					NewWinGoldInfo = WinGoldInfo#player_laba_win_gold{
						laba_win = WinGoldInfo#player_laba_win_gold.laba_win + TotalEarnReward
					};
				true ->
					player_mission:bet_stickiness_cost(?STICKINESS_REDPACK_EARN_SUPER_LABA, TestType, -CostNum),
					player_mission:bet_lock_cost(?STICKINESS_REDPACK_EARN_SUPER_LABA, TestType, -CostNum),
					player_statistics_util:cast_cost(super_laba, -CostNum, TestType),
					NewWinGoldInfo = WinGoldInfo#player_laba_win_gold{
						super_laba_win = WinGoldInfo#player_laba_win_gold.super_laba_win + TotalEarnReward
					}
			end,


			if
				TotalReward > 0 ->
					if
						TotalEarnReward > 0 ->
							PackTaskFun = fun() ->
								player_pack_task:update_player_task_data(2, TotalEarnReward)
							end,
							MissionFun = fun() ->
								if
									Type == ?TYPE_SUPER_LABA ->
										player_mission:fruit_carnival_earn(TotalEarnReward);
									true ->
										skip
								end
							end;
						true ->
							PackTaskFun = fun() ->
								skip
							end,
							MissionFun = fun() ->
								skip
							end
					end,
					AnnouncementFun =
						if
							TotalReward > ?MIN_LABA_ANNOUNCEMNET_GOLD andalso Type == ?TYPE_LABA->
								fun() ->
									announcement_server:laba_win(NewPlayerInfo#player_info.player_name, TotalReward, TestType)
								end;
							TotalReward > ?MIN_LABA_ANNOUNCEMNET_GOLD andalso Type == ?TYPE_SUPER_LABA ->
								fun() ->
									announcement_server:super_laba_win(NewPlayerInfo#player_info.player_name, TotalReward, TestType)
								end;
							true ->
								fun() -> skip end
						end;
				true ->
					MissionFun = fun() -> skip end,
					AnnouncementFun = fun() -> skip end,
					PackTaskFun = fun() -> skip end
			end,
			DBFun = fun() ->
				DBFun1(),
				WriteLabaInfo(),
				player_laba_win_gold_db:t_write(NewWinGoldInfo)
			end,
			SuccessFun = fun() ->
				SuccessFun1(),
				UpdateLabaInfo(),
				RankFun(),
				update_player_laba_win_gold(NewWinGoldInfo),
				send_spin_back_msg(ShowTotalReward, TotalKeyList, LineRewardInfo, AllFreeNum, WinPoolFlag, AddFreeFlag),
				%?INFO_LOG("LineRewardInfo ~p~n",[LineRewardInfo]),
				if
					Type == ?TYPE_SUPER_LABA ->
						player_mission:fruit_carnival_play(1);
					true ->
						skip
				end,
				if
					NewPlayerInfo#player_info.is_robot ->
						skip;
					TotalEarnReward > 0 ->
						%% player_game_task_util:update_game_task_process_by_laba(LineNum1, LineSetChips,
						%% 	LineRewardInfo, TotalReward + CostNum , FreeTimes),
						player_rank_util:rank_change(NewPlayerInfo#player_info.id, ?RANK_TYPE_WIN_GOLD, TotalEarnReward),
						player_mission:any_game_earn(TotalEarnReward),
						if 
							TestType == ?TEST_TYPE_ENTERTAINMENT ->
								if
									Type == ?TYPE_LABA ->
										player_mission:normal_fruit_testtype_earn(TotalEarnReward);
									true ->
										player_mission:super_fruit_testtype_earn(TotalEarnReward)
								end,
								player_mission:testtype_game_earn(TotalEarnReward);
							true ->
								skip
						end,
						if
							Type == ?TYPE_LABA ->
								player_statistics_util:cast_earn(laba, TotalEarnReward, TestType),
								player_mission:stickiness_redpack_earn(?STICKINESS_REDPACK_EARN_LABA, TestType, TotalEarnReward);
							true ->
								player_statistics_util:cast_earn(super_laba, TotalEarnReward, TestType),
								player_mission:stickiness_redpack_earn(?STICKINESS_REDPACK_EARN_SUPER_LABA, TestType, TotalEarnReward)
						end,
						if
							Type == ?TYPE_LABA ->
								player_niu_room_chest:change_laba_process(TotalEarnReward);
							true ->
								player_niu_room_chest:change_super_laba_process(TotalEarnReward)
						end,
						player_winning_record:save_winning_record_info(['_'], TotalEarnReward, 0);
					true ->
						%% player_game_task_util:update_game_task_process_by_laba(LineNum1, LineSetChips,
						%% 	LineRewardInfo, 0 , FreeTimes),
						player_winning_record:save_winning_record_info(['_'], 0, 0)
				end,
				if
					WinPoolGoldNum > 0  ->
						player_mission:laba_pool_reward_times(1);
					true ->
						skip
				end,
				PackTaskFun(),
				MissionFun(),
				AnnouncementFun(),
				if
					2 =:= TestType ->
						player_mission:testtype_game_play(1);
					true ->
						skip
				end,
				player_mission:any_game_play(1),
				ReMark = lists:concat([LineNum, ",",LineSetChipsPos,",",RewardAllTuple]),
				http_static_util:post_fruit_log(NewPlayerInfo, RewardNum, abs(CostNum), WinPoolGoldNum,AddPoolNum,AddToStorageNum, ReMark,Type,TestType, util:now_seconds())
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					SuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
			end;
		{false, Err} ->
			sys_notice_mod:send_notice(Err)
	end.

check_add_pool_num({AddPoolNum, AddRankNum},Type) ->
	if
		(AddPoolNum > 0 orelse AddRankNum > 0) andalso Type == ?TYPE_LABA->
			gen_server:cast(laba_mod:get_mod_pid(), {'cast_add_pool_num', {AddPoolNum, AddRankNum}});
		(AddPoolNum > 0 orelse AddRankNum > 0) andalso Type == ?TYPE_SUPER_LABA->
			gen_server:cast(laba_mod:get_mod_pid(), {'cast_add_pool_num_super_laba', {AddPoolNum, AddRankNum}});
		true ->
			skip
	end.

send_spin_back_msg(RewardNum, TotalKeyList, LineRewardInfo, NewFreenum, WinPoolFlag, AddFreeNm) ->
	Msg = #sc_laba_spin_reply{
		total_reward_num = integer_to_list(RewardNum),
		fruit_list = lists:map(fun({EId, Type}) ->
			#pb_laba_fruit_info{pos_id = EId, fruit_type = Type} end, TotalKeyList),
		reward_list = lists:map(fun({LineId, Num, _}) ->
			#pb_laba_line_reward{line_id = LineId, same_num = Num} end, LineRewardInfo),
		new_last_free_times = NewFreenum,
		pool = WinPoolFlag,
		free = AddFreeNm
	},
	%?INFO_LOG("sc_laba_spin_reply ~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


calc_settlement(TotalKeyList, LineNum, LineSetChips, CostNum, Type, TestType) ->
	{UseLineConfig, _} = lists:split(LineNum, ?LINE_CONFIG_15),
	%% 连线奖励
	{TotalLineInfo, TotalRewardNum, TotalWinPoolRate,RewardTupleOut} =
		lists:foldl(fun(EConfig, {Acc, RewardNumAcc, PoolRateAcc,RewardTupleAcc}) ->
			{LineId, Pos1, Pos2, Pos3, Pos4, Pos5} = EConfig,
			{SameNum, RewardTuple, WinPoolRate1, FruitType} = calc_laba_line_reward([Pos1, Pos2, Pos3, Pos4, Pos5], TotalKeyList, LineSetChips,Type),
			if
				RewardTuple == 0 ->
					{Acc, RewardNumAcc, PoolRateAcc + WinPoolRate1,RewardTupleAcc};
				true ->
					WinPoolRate2 =
					if
						WinPoolRate1 >= PoolRateAcc  ->
							WinPoolRate1;
						true ->
							PoolRateAcc
					end,

					{[{LineId, SameNum, FruitType} | Acc], RewardNumAcc + RewardTuple * LineSetChips, WinPoolRate2,RewardTupleAcc+RewardTuple}
			end
		end, {[], 0, 0,0}, UseLineConfig),
	%% 免费摇奖检测
	AllBonesCol =
		lists:foldl(fun({Col_id, Pos2, Pos3}, ColListAcc) ->
			{_, EFruitType1} = lists:keyfind(Col_id, 1, TotalKeyList),
			{_, EFruitType2} = lists:keyfind(Pos2, 1, TotalKeyList),
			{_, EFruitType3} = lists:keyfind(Pos3, 1, TotalKeyList),

			if
				EFruitType1 == ?S_FRUIT_BONUS orelse EFruitType2 == ?S_FRUIT_BONUS orelse
					EFruitType3 == ?S_FRUIT_BONUS ->
					[Col_id | ColListAcc];
				true ->
					ColListAcc
			end
		end, [], ?COL_LIST_CONFIG),
	AddFreeTimes = check_free_times_add(AllBonesCol),
	%% 检测是否获得奖池
	if
		Type == ?TYPE_LABA ->
			[Config1] = ets:lookup(?ETS_LABA_CONST_LIST, 2),
			[Config2] = ets:lookup(?ETS_LABA_CONST_LIST, 1),
			%% 2020-11-10 增加判断红包试玩场不收税
			if
				TestType == 1->
					{FaxRateP, FaxRateR} = {0, 0};
				true ->
				{FaxRateP, FaxRateR} = Config1#laba_const_config.param
			end,
			SystemTax = Config2#laba_const_config.param;
		true ->
			[Config1] = ets:lookup(?ETS_LABA_CONST_LIST, 5),
			[Config2] = ets:lookup(?ETS_LABA_CONST_LIST, 4),
			{FaxRateP, FaxRateR} = Config1#laba_const_config.param,
			SystemTax = Config2#laba_const_config.param
	end,
	FaxRatePool = FaxRateP / 100,
	FaxRateRank = FaxRateR / 100,
	TotalRate = (SystemTax + FaxRateP + FaxRateR) / 100,
	TotalEarnNum = TotalRewardNum + CostNum,
	if
		TotalEarnNum > 0 ->
			AddToPoolNum = trunc(TotalEarnNum * FaxRatePool),
			AddToRankNum = trunc(TotalEarnNum * FaxRateRank),
			TotalFee = trunc(TotalEarnNum * TotalRate);
		true ->
			AddToPoolNum = 0,
			AddToRankNum = 0,
			TotalFee = 0
	end,
	AddToStorageNum = TotalFee - AddToPoolNum,
	{TotalRewardNum, AddToPoolNum, AddToRankNum, TotalWinPoolRate, TotalLineInfo, AddFreeTimes, AddToStorageNum, RewardTupleOut}.

check_not_have_1_or_5(AllBonesCol) ->
	(not lists:member(1, AllBonesCol)) orelse (not lists:member(5, AllBonesCol)).


do_export_rand_key([{Key, RandNum} | T], Rand) ->
	if
		T == [] ->
			Key;
		RandNum >= Rand ->
			Key;
		true ->
			do_export_rand_key(T, Rand)
	end.

pre_spin(LineNum, LineSetChips,Type,TestType) -> %% TODO ?? 房间判断
	if
		Type == ?TYPE_LABA ->
			Requires = [
				check_level_condition,
				check_in_room,
				check_free_times,
				check_cost,
				check_fruit_reward
			];
		true ->
			Requires = [
				check_level_condition,
				check_in_room,
				check_free_times_super_laba,
				check_cost_super_laba,
				check_fruit_reward
			]
	end,
	AccDict = dict:from_list([{line_num, LineNum}, {line_set_chips_pos, LineSetChips},
		{is_use_free, false} , {type,Type}, {test_type, TestType}]),
	spin_require(AccDict, Requires).

spin_require(AccDict, []) ->
	{true, AccDict};

spin_require(AccDict, [check_level_condition | T]) ->
	case check_enter_condtion() of
		true ->
			spin_require(AccDict, T);
		_ ->
			{false, "Lv.2才可进入"}
	end;

spin_require(AccDict, [check_in_room | T]) ->
	case check_not_in_room() of
		true ->
			spin_require(AccDict, T);
		_ ->
			{false, "您还在游戏房间中"}
	end;

spin_require(AccDict, [check_free_times | T]) ->
	PlayerLabaInfo = get_laba_dic(),
	if
		PlayerLabaInfo#player_laba_info.free_num > 0 ->
			AccDict2 = dict:store(new_free_num, PlayerLabaInfo#player_laba_info.free_num - 1, AccDict),
			OldLineNum = PlayerLabaInfo#player_laba_info.line_num,
			OldLineSetChips = PlayerLabaInfo#player_laba_info.line_set_chips_pos,
			AccDict3 = dict:store(line_num, OldLineNum, AccDict2),
			AccDict4 = dict:store(line_set_chips_pos, OldLineSetChips, AccDict3),
			AccDict5 = dict:store(line_set_chips, lists:nth(OldLineSetChips, ?SET_CHIPS_LIST), AccDict4),
			AccDict6 = dict:store(cost_num, 0, AccDict5),
			AccDict7 = dict:store(is_use_free, true, AccDict6),
			AccDict8 = dict:store(lucky_reward_times, 0, AccDict7),
			spin_require(AccDict8, [check_fruit_reward]);
		true ->
			AccDict2 = dict:store(new_free_num, 0, AccDict),
			AccDict3 = dict:store(lucky_reward_times, PlayerLabaInfo#player_laba_info.lucky_reward_times, AccDict2),
      		spin_require(AccDict3, T)
	end;

spin_require(AccDict, [check_free_times_super_laba | T]) ->
	PlayerLabaInfo = get_super_laba_dic(),
	if
		PlayerLabaInfo#player_super_laba_info.free_num > 0 ->
			AccDict2 = dict:store(new_free_num, PlayerLabaInfo#player_super_laba_info.free_num - 1, AccDict),
			OldLineNum = PlayerLabaInfo#player_super_laba_info.line_num,
			OldLineSetChips = PlayerLabaInfo#player_super_laba_info.line_set_chips_pos,
			AccDict3 = dict:store(line_num, OldLineNum, AccDict2),
			AccDict4 = dict:store(line_set_chips_pos, OldLineSetChips, AccDict3),
			AccDict5 = dict:store(line_set_chips, lists:nth(OldLineSetChips, ?SET_CHIPS_LIST_SUPER_LABA), AccDict4),
			AccDict6 = dict:store(cost_num, 0, AccDict5),
			AccDict7 = dict:store(is_use_free, true, AccDict6),
			AccDict8 = dict:store(lucky_reward_times, 0, AccDict7),
			spin_require(AccDict8, [check_fruit_reward]);
		true ->
			AccDict2 = dict:store(new_free_num, 0, AccDict),
			AccDict3 = dict:store(lucky_reward_times, 0, AccDict2),
      		spin_require(AccDict3, T)
	end;

spin_require(AccDict, [check_cost | T]) ->
	LineNum = dict:fetch(line_num, AccDict),
	LineSetChipsPos = dict:fetch(line_set_chips_pos, AccDict),
	if
		LineNum < 1 orelse LineNum > 9 ->
			{false, "条数错误"};
		true ->
			Length = length(?SET_CHIPS_LIST),
			if
				LineSetChipsPos >= 1 andalso LineSetChipsPos =< Length ->
					LineSetChips = lists:nth(LineSetChipsPos, ?SET_CHIPS_LIST),
					TotalNum = LineNum * LineSetChips,
					PlayerInfo = player_util:get_dic_player_info(),
					if
						PlayerInfo#player_info.gold >= TotalNum ->
							AccDict1 = dict:store(line_set_chips, LineSetChips, AccDict),
							AccDict2 = dict:store(cost_num, -TotalNum, AccDict1),
							spin_require(AccDict2, T);
						true ->
							{false, "玩家钱不够"}
					end;
				true ->
					{false, "押注金额错误"}
			end
	end;

spin_require(AccDict, [check_cost_super_laba | T]) ->
	LineNum = dict:fetch(line_num, AccDict),
	LineSetChipsPos = dict:fetch(line_set_chips_pos, AccDict),
	if
		LineNum < 1 orelse LineNum > 15 ->
			{false, "条数错误"};
		true ->
			Length = length(?SET_CHIPS_LIST_SUPER_LABA),
			if
				LineSetChipsPos >= 1 andalso LineSetChipsPos =< Length ->
					LineSetChips = lists:nth(LineSetChipsPos, ?SET_CHIPS_LIST_SUPER_LABA),
					TotalNum = LineNum * LineSetChips,
					PlayerInfo = player_util:get_dic_player_info(),
					if
						PlayerInfo#player_info.gold >= TotalNum ->
							AccDict1 = dict:store(line_set_chips, LineSetChips, AccDict),
							AccDict2 = dict:store(cost_num, -TotalNum, AccDict1),
							spin_require(AccDict2, T);
						true ->
							{false, "玩家钱不够"}
					end;
				true ->
					{false, "押注金额错误"}
			end
	end;


spin_require(AccDict, [check_fruit_reward | T]) ->
	<<A:32, B:32, C:32>> = crypto:strong_rand_bytes(12),
	put(random_seed, {A, B, C}),
	IsUseFree = dict:fetch(is_use_free, AccDict),
	LineNum = dict:fetch(line_num, AccDict),
	SetNum = dict:fetch(line_set_chips, AccDict),
	LineSetChipsPos = dict:fetch(line_set_chips_pos, AccDict),
	Type = dict:fetch(type, AccDict),

	%% 当使用免费再奖励免费时和5连钻时重摇
	% 初始重摇倍数
	InitRate =
		case IsUseFree of
			true ->
				player_util:get_server_const(?CONST_CONFIG_KEY_FRUIT_FREE_RESET_RATE);
			_ ->
				MaxReward = player_util:get_server_const(?CONST_CONFIG_KEY_FRUIT_MAX_REWARD),
				MaxReward div SetNum
		end,
	PlayerInfo = player_util:get_dic_player_info(),
	LuckRewardTimes = dict:fetch(lucky_reward_times, AccDict),
	%% 压注大于等于50000，次数不为零，普通水果才能触发
	IsLuckyReward = (SetNum >= 50000 andalso LuckRewardTimes > 0 andalso Type /= ?TYPE_SUPER_LABA),
	TestType = dict:fetch(test_type, AccDict),
	PoolConfig = case laba_mod:get_laba_pool_config(TestType, Type) of
		[PoolConfig1] ->
			PoolConfig1;
		_ ->
			undefined
	end,

	BetIndex = case Type of
		?TYPE_LABA ->
			BetIndexLaba = get_pos(SetNum),
			PlayerLabaInfo = get_laba_dic(),
			WelfareConfig = priv_get_fruit_fresher_welfare_config(Type, BetIndexLaba, PlayerLabaInfo#player_laba_info.bet_times),
			BetIndexLaba;
		_ ->
			WelfareConfig = undefined,
			get_pos_super_laba(SetNum)
	end,
	case WelfareConfig of
		undefined ->
			IsWelfare = false,
			InitMaxRate = InitRate,
			InitMinRate = undefined;
		_ ->
			case WelfareConfig#fruit_fresher_welfare_config.reward_range of
				[MinRate, MaxRate] ->
					IsWelfare = true,
					InitMaxRate = MaxRate,
					InitMinRate = MinRate;
				_ ->
					IsWelfare = false,
					InitMaxRate = InitRate,
					InitMinRate = undefined
			end
	end,

	{TotalKeyList, LuckRewardFlag} = check_reroll(IsWelfare, IsUseFree, 50, BetIndex, LineNum, InitMaxRate, PlayerInfo#player_info.recharge_money, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, InitMinRate),
	case length(TotalKeyList) == 15 of
		true ->
			AccDict2 = dict:store(fruit_list, TotalKeyList, AccDict),
			AccDict3 = dict:store(luck_reward_flag, LuckRewardFlag, AccDict2),
			spin_require(AccDict3, T);
		_ ->
			?INFO_LOG("==============> ~p~n", [{TotalKeyList}]),
			{false, "分布错误"}
	end;

spin_require(AccDict, [_ | T]) ->
	spin_require(AccDict, T).

check_have_leave_room() ->
	cs_laba_leave_room_req(?TYPE_LABA, false),
	cs_laba_leave_room_req(?TYPE_SUPER_LABA, false).

%% 检测是否在五人场 and 百人场是否有押注
check_not_in_room() ->
	true.
	% NiuRoomInfo = player_niu_room_util:get_player_room_info(),
	% NiuRoomId = NiuRoomInfo#player_niu_room_info.room_id,
	% if
	% 	NiuRoomId > 0 ->
	% 		false;
	% 	true ->
	% 		not check_in_hundred_room()
	% end.

check_in_hundred_room() ->
	HundredRoomInfo = 0,%player_hundred_niu_util:get_player_room_info(),
	HundredRoomId = HundredRoomInfo#player_niu_room_info.room_id,
	if
		HundredRoomId > 0 ->
			EtsName = hundred_niu_processor:get_hundred_player_ets_name(HundredRoomId),
			case ets:lookup(EtsName, HundredRoomInfo#player_niu_room_info.player_id) of
				[EtsData] ->
					#ets_hundred_niu_player_info{
						set_1_flag = Set_1,
						set_2_flag = Set_2,
						set_3_flag = Set_3,
						set_4_flag = Set_4
					} = EtsData,
					lists:all(fun(E) -> E end, [Set_1, Set_2, Set_3, Set_4]);
				_ ->
					?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
					false
			end;
		true ->
			false
	end.

%% 计算线奖励
calc_laba_line_reward(PosList, TotalKeyList, LineSetChips,Type) ->
	FruitTypeList = lists:map(fun(EPos) ->
		{_, FruitType} = lists:keyfind(EPos, 1, TotalKeyList),
		FruitType end, PosList),
	[FirstFruit | Last] = FruitTypeList,

	{FirstFruit1, TotalSameNum} = calc_laba_same_num(FirstFruit, Last, 1),
	Rate = calc_7_num_rate(FruitTypeList, LineSetChips,Type),
	if
		TotalKeyList >= 2 andalso Type == ?TYPE_LABA->
			[FruitConfig] = ets:lookup(?ETS_LABA_FRUIT_CONFIG, FirstFruit1),
			{TotalSameNum, get_laba_odds(TotalSameNum, FruitConfig), Rate, FirstFruit1};
		TotalKeyList >= 2 andalso Type == ?TYPE_SUPER_LABA->
			[FruitConfig] = ets:lookup(?ETS_SUPER_LABA_FRUIT_CONFIG, FirstFruit1),
			{TotalSameNum, get_super_laba_odds(TotalSameNum, FruitConfig), Rate, FirstFruit1};
		true ->
			{0, 0, 0, 0}
	end.

calc_7_num_rate(FruitTypeList, LineSetChips,?TYPE_LABA) ->
	%?INFO_LOG("calc_7_num_rate ~p~n",[LineSetChips]),
	Key = get_pos(LineSetChips),
	Config = case line_num_config_db:get(Key) of
		{ok,[Config1]}->
			Config1;
		_->
			undefined
	end,
	if
		Config == undefined ->
			0;
		true ->
			SevenCount = calc_laba_seven_num(FruitTypeList),
			if
				SevenCount >= 5 ->
					Config#line_num_config.rate3/100;
				SevenCount >= 4 ->
					Config#line_num_config.rate2/100;
				SevenCount >= 3 ->
					Config#line_num_config.rate1/100;
				true ->
					0
			end
	end;

calc_7_num_rate(FruitTypeList, LineSetChips,_) ->

	%% ?INFO_LOG("calc_7_num_rate~p~n",[LineSetChips]),
	Key = get_pos_super_laba(LineSetChips),
	Config =
		case super_line_config_db:get(Key) of
			{ok,[Config1]}->
				Config1;
			_->
				undefined
		end,

	%% ?INFO_LOG("Config~p~n",[Config]),

	if
		Config == undefined ->
			0;
		true ->
			SevenCount = calc_laba_seven_num(FruitTypeList),
			if
				SevenCount >= 5 ->
					Config#super_line_config.rate3/100;
				SevenCount >= 4 ->
					Config#super_line_config.rate2/100;
				SevenCount >= 3 ->
					Config#super_line_config.rate1/100;
				true ->
					0
			end
	end.

calc_laba_seven_num(FruitTypeList) ->
	[First | T] = FruitTypeList,
	case First of
		?S_FRUIT_777 ->
			calc_777_num(T, 1);
		_ ->
			0
	end.

calc_777_num([], Count) ->
	Count;
calc_777_num([?S_FRUIT_777 | T], Count) ->
	calc_777_num(T, Count + 1);
calc_777_num([_ | _T], Count) ->
	Count.

%% 9:WILD钻石,10:BONUS橙子,11:7
calc_laba_same_num(?S_FRUIT_WILD, [This | T], Count) when This == ?S_FRUIT_WILD ->
	calc_laba_same_num(?S_FRUIT_WILD, T, Count + 1);

calc_laba_same_num(?S_FRUIT_WILD, [This | _T], Count) when This == ?S_FRUIT_BONUS ->
	{?S_FRUIT_WILD, Count};
calc_laba_same_num(?S_FRUIT_WILD, [This | _T], Count) when This == ?S_FRUIT_777 ->
	{?S_FRUIT_WILD, Count};
calc_laba_same_num(?S_FRUIT_WILD, [This | T], Count) ->
	calc_laba_same_num(This, T, Count + 1);

calc_laba_same_num(FirstFruit, [], Count) ->
	{FirstFruit, Count};

calc_laba_same_num(FirstFruit, [?S_FRUIT_WILD | T], Count) ->
	if
		FirstFruit == ?S_FRUIT_BONUS orelse FirstFruit == ?S_FRUIT_777 ->
			{FirstFruit, Count};
		true ->
			calc_laba_same_num(FirstFruit, T, Count + 1)
	end;

calc_laba_same_num(FirstFruit, [FirstFruit | T], Count) ->
	calc_laba_same_num(FirstFruit, T, Count + 1);

calc_laba_same_num(FirstFruit, [_ | _T], Count) ->
	{FirstFruit, Count}.

get_laba_odds(TotalSameNum, FruitConfig) ->
	OddList = [
		{2, FruitConfig#laba_fruit_config.two_odds},
		{3, FruitConfig#laba_fruit_config.three_odds},
		{4, FruitConfig#laba_fruit_config.four_odds},
		{5, FruitConfig#laba_fruit_config.five_odds}
	],
	case lists:keyfind(TotalSameNum, 1, OddList) of
		false ->
			0;
		{_, Odds} ->
			Odds
	end.

get_super_laba_odds(TotalSameNum, FruitConfig)->
	OddList = [
		{2, FruitConfig#super_fruit_config.two_odds},
		{3, FruitConfig#super_fruit_config.three_odds},
		{4, FruitConfig#super_fruit_config.four_odds},
		{5, FruitConfig#super_fruit_config.five_odds}
	],
	case lists:keyfind(TotalSameNum, 1, OddList) of
		false ->
			0;
		{_, Odds} ->
			Odds
	end.

check_reroll(IsWelfare, IsUseFree, 0, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, _MinWinRate) ->
	?INFO_LOG(" LABA check_reroll OverFlow  ~p~n", [{IsWelfare, IsUseFree, 0, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig}]),
	TotalKeyList = roll_all_by_setnum(SetNum, Type, TestType, IsUseFree),
	{NewTotalKeyList, _} = lists:foldl(fun (Index, {CurKeyList, FruitPool}) ->
		Fruit = lists:nth(util:rand(1, length(FruitPool)), FruitPool),
		NewFruitPool = lists:delete(Fruit, FruitPool),
		NewKeyList = lists:keyreplace(Index, 1, CurKeyList, {Index, Fruit}),
		{NewKeyList, NewFruitPool}
	end, {TotalKeyList, [1,2,3,4,5,6,7,8, ?S_FRUIT_BONUS, ?S_FRUIT_777]}, [1,2,6,7,11,12]),
	RewardRate = calc_reward_pre(NewTotalKeyList, LineNum, SetNum, Type),
	check_reroll_by_pool_enough(PoolConfig, SetNum, LineNum, RewardRate, IsUseFree, true),
	{NewTotalKeyList, false};
check_reroll(IsWelfare, IsUseFree, Count, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate) ->
	TotalKeyList = roll_all_by_setnum(SetNum, Type, TestType, IsUseFree),
	%% 是否有中奖池
	WinPoolFlag = get_pool_reward_rate(TotalKeyList, LineNum, Type, SetNum),
	%% 超级水果彩池过低不会中奖
	Flag3 = reroll_by_spe_pool(Type,WinPoolFlag),
	%% 免费摇奖结果不会出现更多免费次数
	Flag1 = check_reroll_by_reward_free(TotalKeyList, IsUseFree),
	%% 彩池辅助控制
	Flag4 = check_pool_win_control(WinPoolFlag, Type, IsLuckyReward),
	%?INFO_LOG("check_reroll_args~p",[{WinPoolFlag,Flag3,Flag1,Flag4}]),

	if
		Flag3 ->
			check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
		is_list(Flag4) ->
			{Flag4, true};
		Flag4 ->
			check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
		Flag1 ->
			Flag2 = check_reroll_by_5_wild(TotalKeyList, Type),
			RewardRate = calc_reward_pre(TotalKeyList, LineNum, SetNum, Type),
			[RewardLimitConfig] = ets:lookup(?ETS_LABA_CONST_LIST, 3),
			FlagLimit = SetNum * RewardRate >= RewardLimitConfig#laba_const_config.param,
			if
				FlagLimit ->
					check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, min(MaxRewardRate, RewardRate), RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
				Flag2 ->
					case check_reroll_by_no_reward(TotalKeyList, LineNum, MaxRewardRate, SetNum, Type, RewardRate) of
						{false, NeedMaxRate} ->
							check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, NeedMaxRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
						_ ->
							IsInFresherProtect = (undefined =/= MinWinRate andalso not IsWelfare),
							if
								IsWelfare andalso (RewardRate > MaxRewardRate orelse MinWinRate > RewardRate) ->
									check_reroll(IsWelfare, IsUseFree, Count, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
								IsInFresherProtect andalso (RewardRate > MaxRewardRate orelse MinWinRate > RewardRate) ->
									check_reroll(IsWelfare, IsUseFree, Count, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
								true ->
									PlayerInfo = player_util:get_dic_player_info(),
									Result = if
										0 =:= RewardRate ->
											{IsFresherProtectReroll, ConfMinRate, ConfMaxRate} = player_laba_util_reroll:check_reroll_by_laba_fresher_protect(BetIndex, LineNum, Type),
											NewMinWinRate = trunc(ConfMinRate * LineNum),
											NewMaxWinRate = trunc(ConfMaxRate * LineNum),
											case IsFresherProtectReroll of
												true ->
													%?INFO_LOG("start protect user ~p, rate: ~p, at ~p~n", [PlayerInfo#player_info.id, {NewMinWinRate, NewMaxWinRate}, {BetIndex, LineNum, Type}]),
													check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, NewMaxWinRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, NewMinWinRate);
												_ ->
													going_check
											end;
										true ->
											player_laba_util_reroll:reset_laba_fresher_protect_stat(Type),
											going_check
									end,
									case Result of
										going_check ->
											IsPoolEnough = check_reroll_by_pool_enough(PoolConfig, SetNum, LineNum, RewardRate, IsUseFree, false),
											if
												not IsPoolEnough ->
													check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, min(MaxRewardRate, RewardRate), RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate);
												true ->
													if
														IsInFresherProtect ->
															?INFO_LOG("protect user ~p, rate: ~p at ~p~n", [PlayerInfo#player_info.id, RewardRate, {BetIndex, LineNum, Type}]),
															skip;
														IsWelfare ->
															?INFO_LOG("welfare user ~p, rate: ~p at ~p~n", [PlayerInfo#player_info.id, RewardRate, {BetIndex, LineNum, Type}]),
															skip;
														true ->
															skip
													end,
													{TotalKeyList, false}
											end;
										_ ->
											if
												IsInFresherProtect ->
													?INFO_LOG("protect user ~p, rate: ~p", [PlayerInfo#player_info.id, RewardRate]);
												true ->
													skip
											end,
											Result
									end
							end
					end;
				true ->
					check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate)
			end;
		true ->
			check_reroll(IsWelfare, IsUseFree, Count - 1, BetIndex, LineNum, MaxRewardRate, RechargeMoney, SetNum, LineSetChipsPos, Type, TestType, IsLuckyReward, PoolConfig, MinWinRate)
	end.

%% 60概率重摇-30%盈利
%% 45概率重摇-25%盈利
check_reroll_by_no_reward(_TotalKeyList, LineNum, MaxRewardRate,_LineSetChips,_Type,RewardRate) ->
	if
		RewardRate > 0 ->
			if
				RewardRate > MaxRewardRate ->
					{false, MaxRewardRate};
				RewardRate >= 77777 ->
					RandBig = util:rand(1, 100),
					if
						RandBig =< 18 ->
							{false, MaxRewardRate};
						true ->
							{true, RewardRate}
					end;
				true ->
					{true, RewardRate}
			end;
		true ->
			case check_line_rate_1(LineNum) of
				{true, DoAgainRate} ->
					case DoAgainRate > 0 of
						true ->
							{false, DoAgainRate};
						_ ->
							{true, RewardRate}
					end;
					%change_key_list(TotalKeyList, DoAgainRate, false);
				_ ->
					{true, RewardRate}
			end
	end.

check_line_rate_1(_LineNum) ->
	false.
%%	case laba_re_roll_config_db:get_base(LineNum) of
%%		{ok, [Base]} ->
%%			Rate1 = Base#laba_re_roll_config.do_again,
%%			Rand1 = util:rand(1, 100),
%%			%Rand1 = 0,
%%			if
%%				Rate1 > Rand1 ->
%%					{true, Base#laba_re_roll_config.max_gold};
%%				true ->
%%					false
%%			end;
%%		_ ->
%%			?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE}]),
%%			false
%%	end.

check_pool_win_control(PoolWinFlag, Type, IsLuckyReward) -> %%
  WinGoldInfo = get_player_laba_win_gold(),
  WinGold =
    if
      Type == ?TYPE_LABA ->
        WinGoldInfo#player_laba_win_gold.laba_win;
      true ->
        WinGoldInfo#player_laba_win_gold.super_laba_win
    end,
  %?INFO_LOG("WinGold~p",[WinGold]),
  check_pool_win_control(PoolWinFlag, Type, IsLuckyReward, WinGold).

check_pool_win_control(PoolWinFlag, _Type, _IsLuckyReward, WinGold) when WinGold > 0 -> %% 赢钱多中奖，触发彩池重摇
  if
    PoolWinFlag ->
      List1 = ets:tab2list(?ETS_LABA_POOL_REWARD_CONFIG_LIST),
      List = lists:filter(fun(E) -> E#laba_pool_reward_config.type == 1 end, List1),
      NeedConfiglist = lists:filter(fun(E) -> E#laba_pool_reward_config.limit =< WinGold end, List),
      case lists:sort(NeedConfiglist) of
        [] ->
          false;
        SortList ->
          Config = lists:last(SortList),
          Rand = util:rand(1, 100000),
          %?INFO_LOG("NeedConfiglist~p",[{Rand,Config,NeedConfiglist}]),
          if
            Rand < Config#laba_pool_reward_config.rate ->
              true;
            true ->
              false
          end
      end;
    true ->
      false
  end;

check_pool_win_control(PoolWinFlag, Type, IsLuckyReward, WinGold) -> %% 输钱太多触发概率中奖（超级水果除外）
	if
		Type == ?TYPE_SUPER_LABA ->
			false;
		PoolWinFlag ->
			false;
		IsLuckyReward ->
			List1 = ets:tab2list(?ETS_LABA_POOL_REWARD_CONFIG_LIST),
			List = lists:filter(fun(E) ->
				E#laba_pool_reward_config.type == 2
			end, List1),
			NeedConfiglist = lists:filter(fun(E) ->
				-1 * E#laba_pool_reward_config.limit =< WinGold
			end, List),
			case lists:sort(NeedConfiglist) of
				[] ->
					false;
				[Config|_]->
					%% Rand = util:rand(1, 100000),
					Rand = 40,
					%?INFO_LOG("NeedConfiglist~p",[{Rand,Config,NeedConfiglist}]),
					if
						Rand < Config#laba_pool_reward_config.rate ->
							?FIX_WIN_POOL_LIST;
						true ->
							false
					end
			end;
		true ->
			false
	end.

priv_get_rate_etsname_by_setnum(SetNum, Type, TestType) ->
	case Type of
		?TYPE_LABA ->
			SetPos = get_pos(SetNum),
			case TestType of
				?TEST_TYPE_TRY_PLAY ->
					lists:nth(SetPos, ?LABA_RATE_EST_MAPLIST);
				_ ->
					lists:nth(SetPos, ?LABA_TESTTYPE2_RATE_EST_MAPLIST)
			end;
		?TYPE_SUPER_LABA ->
			SetPos = get_pos_super_laba(SetNum),
			case TestType of
				?TEST_TYPE_TRY_PLAY ->
					lists:nth(SetPos, ?SUPER_LABA_RATE_EST_MAPLIST);
				_ ->
					lists:nth(SetPos, ?SUPER_LABA_TESTTYPE2_RATE_EST_MAPLIST)
			end;
		_ ->
			?ERROR_LOG("Unknown type ~p for roll_all_by_setnum ~n", [Type]),
			SetPos = get_pos(SetNum),
			lists:nth(SetPos, ?LABA_RATE_EST_MAPLIST)
	end.

roll_all_by_setnum(SetNum, Type, TestType, IsUseFree) ->
	IsBlackRoom = get(?IS_IN_BLACK_ROOM),
	if
		IsBlackRoom ->
			%% 小黑屋概率统一在试玩 laba 配置第 11 注
			EtsName = lists:nth(?BLACK_ROOM_SET_POS, ?LABA_RATE_EST_MAPLIST);
		true ->
			EtsName = priv_get_rate_etsname_by_setnum(SetNum, Type, TestType)
	end,
	%% 除5的余数相同的位置，元素概率相同
	lists:foldl(fun(E, Acc2) ->
		EtsKey = case E rem 5 of
			0 ->
				5;
			Ekey ->
				Ekey
		end,
		[EData] = ets:lookup(EtsName, EtsKey),
		{RateList, Rand} = case false andalso IsUseFree of
			true ->
				% {RateList1, _} = EData#ets_data.value,
				% {NewRandList, _, TotalRate, _} = lists:foldl(fun ({FType, FRate}, {List, Sub, Acc, LastFRate}) ->
				% 	DiffRate = FRate - LastFRate,
				% 	Next = if
				% 		?S_FRUIT_BONUS =:= FType ->
				% 			{List, Sub + DiffRate, Acc, FRate};
				% 		true ->
				% 			CurRate = FRate - Sub,
				% 			{List ++ [{FType, CurRate}], Sub, Acc + CurRate, FRate}
				% 	end,

				% 	Next
				% end, {[], 0, 0, 0}, RateList1),
				% Rand1 = util:rand(1, TotalRate),

				% {NewRandList, Rand1};
				{RateList1, TotalRate} = EData#ets_data.value,
				Rand1 = util:rand(1, TotalRate),
				{RateList1, Rand1};
			_ ->
				{RateList1, TotalRate} = EData#ets_data.value,
				Rand1 = util:rand(1, TotalRate),
				{RateList1, Rand1}
		end,
		[{E, do_export_rand_key(RateList, Rand)} | Acc2]
	end, [], lists:seq(1, 15)).

check_reroll_by_reward_free(TotalKeyList, IsUseFree) ->
	if
		not IsUseFree ->
			true;
		true ->
			AllBonesCol =
				lists:foldl(fun({Col_id, Pos2, Pos3}, ColListAcc) ->
					{_, EFruitType1} = lists:keyfind(Col_id, 1, TotalKeyList),
					{_, EFruitType2} = lists:keyfind(Pos2, 1, TotalKeyList),
					{_, EFruitType3} = lists:keyfind(Pos3, 1, TotalKeyList),
					if
						EFruitType1 == ?S_FRUIT_BONUS orelse EFruitType2 == ?S_FRUIT_BONUS orelse
							EFruitType3 == ?S_FRUIT_BONUS ->
							[Col_id | ColListAcc];
						true ->
							ColListAcc
					end
				end, [], ?COL_LIST_CONFIG),
			FreeTimes = check_free_times_add(AllBonesCol),
			case FreeTimes of
				0 ->
					true;
				_ ->
					false
			end
	end.

check_reroll_by_5_wild(TotalKeyList,Type) ->
	check_reroll_by_5_wild2(TotalKeyList, ?LINE_CONFIG_15).

check_reroll_by_5_wild2(_TotalKeyList, []) ->
	true;
check_reroll_by_5_wild2(TotalKeyList, [{_, Pos1, Pos2, Pos3, Pos4, Pos5} | T]) ->
	FruitTypeList = lists:map(fun(EPos) ->
		{_, FruitType} = lists:keyfind(EPos, 1, TotalKeyList),
		FruitType end, [Pos1, Pos2, Pos3, Pos4, Pos5]),
	case lists:usort(FruitTypeList) of
		[Type] ->
			if
				Type =/= ?S_FRUIT_WILD ->
					check_reroll_by_5_wild2(TotalKeyList, T);
				true ->
					false
			end;
		_ ->
			check_reroll_by_5_wild2(TotalKeyList, T)
	end.

check_free_times_add(AllBonesCol) ->
	BonesLength = length(AllBonesCol),
	case BonesLength of
		5 ->
			15;
		4 ->
			case check_not_have_1_or_5(AllBonesCol) of
				true ->
					10;
				_ ->
					case lists:member(3, AllBonesCol) of
						true ->
							5;
						_ ->
							0
					end
			end;
		3 ->
			CheckList = lists:sort(AllBonesCol),
			[Col1, Col2, Col3] = CheckList,
			if
				Col1 + 1 == Col2 andalso Col2 + 1 == Col3 ->
					5;
				true ->
					0
			end;
		_ ->
			0
	end.

calc_reward_pre(TotalKeyList, LineNum,LineSetChips,Type) ->
	{UseLineConfig, _} = lists:split(LineNum, ?LINE_CONFIG_15),
	%% 连线奖励
	lists:foldl(fun(EConfig, RewardNumAcc) ->
		{_LineId, Pos1, Pos2, Pos3, Pos4, Pos5} = EConfig,
		{_SameNum, RewardTuple, _WinPoolRate1, _FruitType} = calc_laba_line_reward([Pos1, Pos2, Pos3, Pos4, Pos5], TotalKeyList, LineSetChips,Type),
		if
			RewardTuple == 0 ->
				RewardNumAcc;
			true ->
				RewardNumAcc + RewardTuple
		end
	end, 0, UseLineConfig).

get_pos(LineSetChips)->
	if
		1 =:= ?SUPERFRUIT ->
			case LineSetChips of
				500 ->
					1;
				1000 ->
					2;
				2500 ->
					3;
				5000 ->
					4;
				10000 ->
					5;
				25000 ->
					6;
				50000 ->
					7;
				100000 ->
					8;
				250000 ->
					9;
				500000 ->
					10
			end;
		true ->
			case LineSetChips of
				100 ->
					1;
				500 ->
					2;
				2500 ->
					3;
				5000->
					4;
				25000 ->
					5;
				50000 ->
					6;
				250000 ->
					7;
				500000->
					8
			end
	end.

get_pos_super_laba(LineSetChips)->
	if
		1 =:= ?SUPERFRUIT ->
			case LineSetChips of
				500 ->
					1;
				1000 ->
					2;
				2500 ->
					3;
				5000 ->
					4;
				10000 ->
					5;
				25000 ->
					6;
				50000 ->
					7;
				100000 ->
					8;
				250000 ->
					9;
				500000 ->
					10
			end;
		true ->
			case LineSetChips of
				500 ->
					1;
				2500 ->
					2;
				5000->
					3;
				25000 ->
					4;
				50000 ->
					5;
				250000 ->
					6;
				500000->
					7
			end
	end.

gm_test(Type,LineNum,LineSetNum,LabaType,TestType, Num, IsProtect, MinRate, MaxRate)->
	if
		Type == 1  ->
			{Out1,Out2,Out3,_,OutProtect} = lists:foldl(fun(_E,{Acc,Acc2,Acc3,AllFallAcc,ProtectAcc}) ->
				{Tuple,FreeTime,IsWinPool,NowAllFallNum, ProtectNum} = test_1(LineNum,LineSetNum,LabaType,TestType,IsProtect,AllFallAcc,ProtectAcc,MinRate,MaxRate),
				NewAcc = case lists:keyfind(Tuple,1,Acc) of
					false ->
						lists:keystore(Tuple,1,Acc,{Tuple,1});
					{Tuple,Old}->
						lists:keystore(Tuple,1,Acc,{Tuple,Old+1})
				end,
				NewAcc2 = case lists:keyfind(FreeTime,1,Acc2) of
					false ->
						lists:keystore(FreeTime,1,Acc2,{FreeTime,1});
					{FreeTime,Old2}->
						lists:keystore(FreeTime,1,Acc2,{FreeTime,Old2+1})
				end,
				NewAcc3 = case IsWinPool of
					true ->
						Acc3 + 1;
					_ ->
						Acc3
				end,
				{NewAcc,NewAcc2,NewAcc3,NowAllFallNum,ProtectNum}
			end,{[],[],0,0,0},lists:seq(1,Num)),
			Total = lists:foldl(fun (Elem, Acc) ->
				{B, C} = Elem,
				Acc + (B * C)
			end, 0, Out1),
			?INFO_LOG("laba_check ~p~n",[{Total, Total / (LineNum * Num),OutProtect,Out3,Out2,lists:sort(Out1)}]),
			ok;
		Type == 2 ->
			Out = roll_all_by_setnum(LineSetNum, LabaType, TestType, false),
			?INFO_LOG("laba_list~p~n", [Out]);
		true ->
			ok
	end.

gm_test_laba_testtype1(LabaType, TestType, PlayerNum, InitMoney, LineNum, Clip) ->
	lists:foldl(fun (_, _) ->
		Pid = spawn(player_laba_util, gm_test_laba_testtype1_one_player, [InitMoney, 0, 0, LineNum, Clip, LabaType, TestType, continue])
	end,{}, lists:seq(1, PlayerNum)).

gm_test_laba_testtype1_one_player(PlayerNowNum, PlayerNowClips, PlayerNowTimes, LineNum, LineSetChips, LabaType, TestType, stop) ->
	test_result_manager_mod:hand_laba_testtype1_finish(PlayerNowNum, PlayerNowClips, PlayerNowTimes);
gm_test_laba_testtype1_one_player(PlayerNowNum, PlayerNowClips, PlayerNowTimes, LineNum, LineSetChips, LabaType, TestType, continue) ->
	{PlayerCurrentNum, PlayerCurrentClips, Continue} = gm_test_laba_testtype1_one_player(PlayerNowNum, PlayerNowClips, LineNum, LineSetChips, LabaType, TestType),
	if
		Continue ->
			gm_test_laba_testtype1_one_player(PlayerCurrentNum, PlayerCurrentClips, PlayerNowTimes + 1, LineNum, LineSetChips, LabaType, TestType, continue);
		true ->
			gm_test_laba_testtype1_one_player(PlayerCurrentNum, PlayerCurrentClips, PlayerNowTimes, LineNum, LineSetChips, LabaType, TestType, stop)
	end.

gm_test_laba_testtype1_one_player(PlayerNowNum, PlayerNowClips, LineNum, LineSetChips, LabaType, TestType) ->
	NeedNum = LineNum * LineSetChips,
	Continue = PlayerNowNum >= NeedNum,
	if
		Continue ->
			EarnNum = gm_test_laba_testtype1_one_player_once(LineNum, LineSetChips, LabaType, TestType, false),
			PlayerCurrentNum = PlayerNowNum - NeedNum + EarnNum,
			PlayerCurrentClips = PlayerNowClips + NeedNum;
		true ->
			PlayerCurrentNum = PlayerNowNum,
			PlayerCurrentClips = PlayerNowClips
	end,
	%?INFO_LOG("------- gm_test_laba_testtype1_one_player ------- ~p~n", [{PlayerCurrentNum, PlayerCurrentClips, Continue, PlayerNowNum, PlayerNowClips}]),
	{PlayerCurrentNum, PlayerCurrentClips, Continue}.

gm_test_laba_testtype1_one_player_roll(LineNum, LineSetChips, LabaType, TestType) ->
	<<A:32, B:32, C:32>> = crypto:strong_rand_bytes(12),
	put(random_seed, {A, B, C}),
	[PoolConfig] = laba_mod:get_laba_pool_config(1, LabaType),
	TotalKeyList = roll_all_by_setnum(LineSetChips, LabaType, TestType, false),
	{UseLineConfig, _} = lists:split(LineNum, ?LINE_CONFIG_15),
	RewardRate = calc_reward_pre(TotalKeyList, LineNum, LineSetChips, LabaType),
	IsPoolEnough = check_reroll_by_pool_enough(PoolConfig, LineSetChips, LineNum, RewardRate, false, false),
	if
		IsPoolEnough ->
			{_TotalLineInfo, TotalRewardNum, _TotalWinPoolRate,_RewardTupleOut} = lists:foldl(fun(EConfig, {Acc, RewardNumAcc, PoolRateAcc,RewardTupleAcc}) ->
				{LineId, Pos1, Pos2, Pos3, Pos4, Pos5} = EConfig,
				{SameNum, RewardTuple, WinPoolRate1, FruitType} = calc_laba_line_reward([Pos1, Pos2, Pos3, Pos4, Pos5], TotalKeyList, LineSetChips,LabaType),
				if
					RewardTuple == 0 ->
						{Acc, RewardNumAcc, PoolRateAcc + WinPoolRate1,RewardTupleAcc};
					true ->
						{[{LineId, SameNum, FruitType} | Acc], RewardNumAcc + RewardTuple * LineSetChips, PoolRateAcc + WinPoolRate1,RewardTupleAcc+RewardTuple}
				end
			end, {[], 0, 0, 0}, UseLineConfig),
			{TotalKeyList, TotalRewardNum};
		true ->
			gm_test_laba_testtype1_one_player_roll(LineNum, LineSetChips, LabaType, TestType)
	end.

gm_test_laba_testtype1_one_player_once(LineNum, LineSetChips, LabaType, TestType, IsInFreeMod) ->
	{TotalKeyList, TotalRewardNum} = gm_test_laba_testtype1_one_player_roll(LineNum, LineSetChips, LabaType, TestType),
	if
		not IsInFreeMod ->
			AllBonesCol = lists:foldl(fun({Col_id, Pos2, Pos3}, ColListAcc) ->
					{_, EFruitType1} = lists:keyfind(Col_id, 1, TotalKeyList),
					{_, EFruitType2} = lists:keyfind(Pos2, 1, TotalKeyList),
					{_, EFruitType3} = lists:keyfind(Pos3, 1, TotalKeyList),

					if
						EFruitType1 == ?S_FRUIT_BONUS orelse EFruitType2 == ?S_FRUIT_BONUS orelse
							EFruitType3 == ?S_FRUIT_BONUS ->
							[Col_id | ColListAcc];
						true ->
							ColListAcc
					end
			end, [], ?COL_LIST_CONFIG),
			AddFreeTimes = check_free_times_add(AllBonesCol),
			if
				AddFreeTimes >= 1 ->
					FinalTotalRewardNum = lists:foldl(fun (_E, Acc) ->
						Acc + gm_test_laba_testtype1_one_player_once(LineNum, LineSetChips, LabaType, TestType, true)
					end, TotalRewardNum, lists:seq(1, AddFreeTimes));
				true ->
					FinalTotalRewardNum = TotalRewardNum
			end;
		true ->
			FinalTotalRewardNum = TotalRewardNum
	end,
	FinalTotalRewardNum.

test_1(LineNum,LineSetChips,Type, TestType, IsProtect, AllFallNum, ProtectNum, MinRate, MaxRate)->
	<<A:32, B:32, C:32>> = crypto:strong_rand_bytes(12),
	put(random_seed, {A, B, C}),
	TotalKeyList = roll_all_by_setnum(LineSetChips, Type, TestType, false),
	{UseLineConfig, _} = lists:split(LineNum, ?LINE_CONFIG_15),
	%% 连线奖励
	{_TotalLineInfo, TotalRewardNum, TotalWinPoolRate,RewardTupleOut} =
		lists:foldl(fun(EConfig, {Acc, RewardNumAcc, PoolRateAcc,RewardTupleAcc}) ->
			{LineId, Pos1, Pos2, Pos3, Pos4, Pos5} = EConfig,
			{SameNum, RewardTuple, WinPoolRate1, FruitType} = calc_laba_line_reward([Pos1, Pos2, Pos3, Pos4, Pos5], TotalKeyList, LineSetChips,Type),
			if
				RewardTuple == 0 ->
					{Acc, RewardNumAcc, PoolRateAcc + WinPoolRate1,RewardTupleAcc};
				true ->
					{[{LineId, SameNum, FruitType} | Acc], RewardNumAcc + RewardTuple * LineSetChips, PoolRateAcc + WinPoolRate1,RewardTupleAcc+RewardTuple}
			end
	end, {[],0,0,0}, UseLineConfig),
	if
		0 =:= TotalRewardNum ->
			NewAllFallNum = AllFallNum + 1;
		true ->
			NewAllFallNum = 0
	end,
	if
		NewAllFallNum >= 4 andalso IsProtect ->
			test_1(LineNum,LineSetChips,Type,TestType, IsProtect, NewAllFallNum, ProtectNum, MinRate, MaxRate);
		true ->
			Status = if
				AllFallNum >= 4 andalso IsProtect ->
					if
						trunc(TotalRewardNum / (LineNum * LineSetChips)) > MaxRate ->
							NewProtectNum = ProtectNum,
							need_reroll;
						trunc(TotalRewardNum / (LineNum * LineSetChips)) < MinRate ->
							NewProtectNum = ProtectNum,
							need_reroll;
						true ->
							?INFO_LOG("--Protect--~n"),
							NewProtectNum = ProtectNum + 1,
							skip
					end;
				true ->
					NewProtectNum = ProtectNum,
					skip
			end, 
			case Status of
				need_reroll ->
					test_1(LineNum,LineSetChips,Type, TestType, IsProtect, NewAllFallNum, ProtectNum, MinRate, MaxRate);
				_ ->
					%% 免费摇奖检测
					AllBonesCol =
						lists:foldl(fun({Col_id, Pos2, Pos3}, ColListAcc) ->
							{_, EFruitType1} = lists:keyfind(Col_id, 1, TotalKeyList),
							{_, EFruitType2} = lists:keyfind(Pos2, 1, TotalKeyList),
							{_, EFruitType3} = lists:keyfind(Pos3, 1, TotalKeyList),

							if
								EFruitType1 == ?S_FRUIT_BONUS orelse EFruitType2 == ?S_FRUIT_BONUS orelse
									EFruitType3 == ?S_FRUIT_BONUS ->
									[Col_id | ColListAcc];
								true ->
									ColListAcc
							end
					end, [], ?COL_LIST_CONFIG),
					AddFreeTimes = check_free_times_add(AllBonesCol),
					{RewardTupleOut,AddFreeTimes,TotalWinPoolRate > 0,NewAllFallNum,NewProtectNum}
			end
	end.


cs_win_player_list(Type)->
	List =
	if
		Type  == ?TYPE_LABA->
			ets:tab2list(?ETS_LAST_WIN_POOL_PLAYER);
		true ->
			ets:tab2list(?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER)
	end,
	PbList = lists:map(fun(E) -> E#ets_data.value end,List),
	Msg = #sc_win_player_list{
		win_players = PbList
	},
	%% ?INFO_LOG("cs_win_player_list~p~n",[{Type,Msg}]),
	tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).


%% 元素权重原始数据
get_all_fruit_list(Type, Flag) ->
	List =
		case Type of
			?TYPE_LABA ->
				laba_fruit_rate_config_db:get_base();
			_ ->
				slaba_fruit_rate_config_db:get_base()
		end,
	%?INFO_LOG("get_all_fruit_list ~p~n", [{List, Type, Flag}]),
	if %% 大小注
		Flag ->
			lists:map(fun({_, Key, Small, _Big}) ->
				{Key, Small} end, List);
		true ->
			lists:map(fun({_, Key, _Small, Big}) ->
				{Key, Big} end, List)
	end.

%% 生成元素概率ets
rate_set(Type, Flag, EtsName) ->
	AllFruitList = get_all_fruit_list(Type, Flag),
	%?INFO_LOG("----> ~p~n", [{AllFruitList}]),
	lists:foreach(fun(EPos) ->
		{Acc, AccSum} = lists:mapfoldl(fun({Ekey, ERec}, Sum) ->
			Rate = lists:nth(EPos, ERec),
			{{Ekey, Rate + Sum}, Rate + Sum}
		end, 0, AllFruitList),
		ets:insert(EtsName, #ets_data{key = EPos, value = {Acc, AccSum}})
	end, lists:seq(1, 5)).

rate_set(EtsName, AllFruitList) ->
	%% AllFruitList = get_all_fruit_list(Type, Flag),
	lists:map(fun(EPos) ->
		{Acc, AccSum} = lists:mapfoldl(fun({Ekey, ERec}, Sum) ->
			Rate = lists:nth(EPos, ERec),
			{{Ekey, Rate + Sum}, Rate + Sum} 
		end, 0, AllFruitList),
		EtsData = #ets_data{key = EPos, value = {Acc, AccSum}},
		ets:insert(EtsName, EtsData), EtsData 
	end, lists:seq(1, 5)).

rate_list(Type, TestType, SetNum) ->
  EtsName = priv_get_rate_etsname_by_setnum(SetNum, Type, TestType),
  lists:foldl(fun(E, Acc2) ->
    EtsKey =
      case E rem 5 of
        0 ->
          5;
        Ekey ->
          Ekey
      end,
    [EData] = ets:lookup(EtsName, EtsKey),
    {RateList, TotalRate} = EData#ets_data.value,
    Rand = util:rand(1, TotalRate),
    [{E, do_export_rand_key(RateList, Rand)} | Acc2] end, [], lists:seq(1, 15)).

gm_set_laba_config(Type, TestType, Index, SetData) ->
	case Type of
		?TYPE_LABA ->
			?INFO_LOG("gm_set_laba_config-->1111 ~p~n", [{SetData}]),
			{List,_} = deal_set_data_laba_rate(SetData),
			case TestType of
				?TEST_TYPE_TRY_PLAY ->
					EtsName = lists:nth(Index, ?LABA_RATE_EST_MAPLIST);
				_ ->
					EtsName = lists:nth(Index, ?LABA_TESTTYPE2_RATE_EST_MAPLIST)
			end,
			?INFO_LOG("gm_set_laba_config-->2222 ~p~n", [{List}]),
			SaveData = rate_set(EtsName, List),
			?INFO_LOG("gm_set_laba_config-->1 ~p~n", [{List,TestType,SaveData}]),
			laba_fruit_activate_config_db:write(#laba_fruit_activate_config{key = {laba, TestType, Index},value = SaveData});
		?TYPE_SUPER_LABA ->
			{List,_} = deal_set_data_laba_rate(SetData),
			case TestType of
				?TEST_TYPE_TRY_PLAY ->
					EtsName = lists:nth(Index, ?SUPER_LABA_RATE_EST_MAPLIST);
				_ ->
					EtsName = lists:nth(Index, ?SUPER_LABA_TESTTYPE2_RATE_EST_MAPLIST)
			end,
			SaveData = rate_set(EtsName, List),
			?INFO_LOG("gm_set_laba_config-->2 ~p~n", [{List,TestType,SaveData}]),
			laba_fruit_activate_config_db:write(#laba_fruit_activate_config{key = {super_laba, TestType, Index},value = SaveData});
		3 ->
			OutList =
			lists:map(fun({_, Elemet})->
				{_, KeyBin} = lists:nth(1, Elemet),
				Key = binary_to_integer(KeyBin),
				{_, TypeBin} = lists:nth(2, Elemet),
				WinType = binary_to_integer(TypeBin),
				{_, Param1Bin} = lists:nth(3, Elemet),
				Param1 = binary_to_integer(Param1Bin),
				{_, Param2Bin} = lists:nth(4, Elemet),
				Param2 = binary_to_integer(Param2Bin),
				{laba_pool_reward_config, Key,WinType, Param1, Param2}
			end, SetData),

			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_POOL_REWARD_CONFIG_LIST,E) end,OutList),
			laba_fruit_activate_config_db:write(#laba_fruit_activate_config{key = 5,value = OutList});
		4 ->
			%% SetData1 = lists:map(fun({_, EList1}) -> EList1 end, SetData),
			OutList =
				lists:map(fun({_,Elemet}) ->
					{_, KeyBin} = lists:nth(1, Elemet),
					Key = binary_to_integer(KeyBin),
					if
						2 =:= Key orelse 5 =:= Key ->
							{_, ParamBin} = lists:nth(3, Elemet),
							ParamList = binary_to_list(ParamBin),
							ParamL1 = lists:nth(1, ParamList) - 48, % '0'
							ParamL2 = lists:nth(3, ParamList) - 48,
							Param2 = {ParamL1, ParamL2};
						true ->
							{_, Param1Bin} = lists:nth(3, Elemet),
							Param2 = binary_to_integer(Param1Bin)
					end,
					{laba_const_config, Key, Param2}
				end, SetData),
			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_CONST_LIST,E) end,OutList),
			laba_fruit_activate_config_db:write(#laba_fruit_activate_config{key = 6,value = OutList});
    _ ->
      	false
  end.

deal_set_data_laba_rate(SetData)->
	SetData1 = lists:map(fun({_, EList1}) -> EList1 end, SetData),
	OutList = lists:map(fun(Elemet) ->
		{_, KeyBin} = lists:nth(1, Elemet),
		Key1 = binary_to_integer(KeyBin),
		{_, SmallBin} = lists:nth(2, Elemet),
		Small1 = binary_to_list(SmallBin),
		StrSmallList = string:tokens(Small1, ","),
		Small2 = lists:map(fun(E) -> list_to_integer(E) end, StrSmallList),

		{_, BigBin} = lists:nth(3, Elemet),
		Big1 = binary_to_list(BigBin),
		StrBig = string:tokens(Big1, ","),
		Big2 = lists:map(fun(E) -> list_to_integer(E) end, StrBig),

		{laba_rate_config, Key1, Small2, Big2}
	end, SetData1),
	SList = lists:map(fun({_, Key, Small, _Big}) ->
		{Key, Small} end, OutList),
	BList = lists:map(fun({_, Key, _Small, Big}) ->
		{Key, Big} end, OutList),
	{SList,BList}.

get_pool_reward_rate(TotalKeyList, LineNum, Type, LineSetChips) ->
	{UseLineConfig, _} = lists:split(LineNum, ?LINE_CONFIG_15),
	AllPoolRate = lists:foldl(fun(EConfig, RewardNumAcc) ->
		{_LineId, Pos1, Pos2, Pos3, Pos4, Pos5} = EConfig,

		FruitTypeList = lists:map(fun(EPos) ->
			{_, FruitType} = lists:keyfind(EPos, 1, TotalKeyList),
			FruitType end, [Pos1, Pos2, Pos3, Pos4, Pos5]),
		Rate = calc_7_num_rate(FruitTypeList, LineSetChips, Type),
		if
			Rate == 0 ->
				RewardNumAcc;
			true ->
				RewardNumAcc + Rate
		end
	end, 0, UseLineConfig),
	%?INFO_LOG("AllPoolRate ~p~n",[AllPoolRate]),
	AllPoolRate > 0.

reroll_by_spe_pool(_,false)->
  false;
reroll_by_spe_pool(?TYPE_LABA,_)->
  false;
reroll_by_spe_pool(_,_)->
  {ok, WinPoolGoldNum} = gen_server:call(laba_mod:get_mod_pid(), 'call_super_pool_num'),
  {ok, [ConfigData]} = laba_pool_reroll_config_db:get({super_laba, 1}),
  ?INFO_LOG("WinPoolGoldNum~p",[{WinPoolGoldNum,ConfigData#laba_pool_reroll_config.multiple}]),
  if
    WinPoolGoldNum =< ConfigData#laba_pool_reroll_config.multiple ->
      Rand = util:rand(1, 100),
      ?INFO_LOG("reroll_by_spe_pool~p",[{WinPoolGoldNum,Rand,ConfigData#laba_pool_reroll_config.do_again}]),
      if
        Rand < ConfigData#laba_pool_reroll_config.do_again ->
          true;
        true ->
          false
      end;
    true ->
      false
  end.

%这个要在重摇最后调用，因为这里会修改水池
check_reroll_by_pool_enough(PoolConfig, SetNum, LineNum, RewardRate, IsUseFree, IsForceUpdate) ->
	%?INFO_LOG("check_reroll_by_pool_enough.......~p~n", [{SetNum, LineNum, RewardRate, IsUseFree, IsForceUpdate}]),
	case PoolConfig of
		undefined ->
			true;
		_ ->
			{GameType, TestType} = PoolConfig#fruit_pool_config.key,
			{BRNum, BRDeno} = PoolConfig#fruit_pool_config.bet_retrieve,
			{ERNum, ERDeno} = PoolConfig#fruit_pool_config.earn_retrieve,
			if
				IsUseFree ->
					TotalSetNum = 0;
				true ->
					TotalSetNum = SetNum * LineNum
			end,
			TmpRewardNum = SetNum * RewardRate,
			TmpPoolAddNum = trunc(TotalSetNum - TotalSetNum * BRNum / BRDeno),
			case GameType of
				laba ->
					BetIndex = get_pos(SetNum),
					{ok, IsEnough} = laba_mod:is_fruit_pool_enough_then_update(BetIndex, TmpPoolAddNum, TotalSetNum, TmpRewardNum, ERNum div ERDeno, TestType, IsForceUpdate);
				super_laba ->
					BetIndex = get_pos_super_laba(SetNum),
					{ok, IsEnough} = laba_mod:is_super_fruit_pool_enough_then_update(BetIndex, TmpPoolAddNum, TotalSetNum, TmpRewardNum, ERNum div ERDeno, TestType, IsForceUpdate);
				_ ->
					IsEnough = true
			end,
			IsEnough
	end.

priv_get_fruit_fresher_welfare_config(Type, BetIndex, BetTimes) ->
	case Type of
		?TYPE_LABA ->
			case ets:lookup(?ETS_FRUIT_FRESHER_WELFARE_CONFIG, {laba, BetIndex, BetTimes}) of
				[Config] ->
					Config;
				_ ->
					undefined
			end;
		_ ->
			case ets:lookup(?ETS_SUPER_FRUIT_FRESHER_WELFARE_CONFIG, {super_laba, BetIndex, BetTimes}) of
				[Config] ->
					Config;
				_ ->
					undefined
			end
	end.
