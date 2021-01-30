%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 三月 2017 11:13
%%%-------------------------------------------------------------------
-module(player_niu_room_chest).
-author("Administrator").

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/chest_pb.hrl").

-define(FUDAI_TIMES,10).
-define(NORMAL_TIMES,5).
-define(LIMIT_GOLD,50000).
-define(LABA_LIMIT_GOLD,50000).
-define(SUPER_LABA_LIMIT_GOLD,50000).
-define(PLAYER_HUNDRED_ROOM_CHEST_INFO,player_hundred_room_chest_info).
-define(PLAYER_LABA_CHEST_INFO,player_laba_chest_info).
-define(PLAYER_SUPER_LABA_CHEST_INFO,player_super_laba_chest_info).

-define(GAME_TYPE_1,1). %牛牛
-define(GAME_TYPE_2,2). %百人
-define(GAME_TYPE_3,3). %拉霸
-define(GAME_TYPE_4,4). %超级拉霸

%% API
-export([
	draw/2,

	change_times/1,
	change_process/1,
	change_laba_process/1,
	change_super_laba_process/1,

	refresh_player_niu_room_chest/0,
	refresh_player_hundred_room_chest/0,
	refresh_player_laba_chest/0,

	send_enter_room_msg/1,
	enter_hundred_room_msg/0,
	enter_laba_room_msg/1,

	handle_timer/2,
	is_buy_fudai/1,
	init_info/1,
	gm_test/2
]).

init_info(PlayerId)->
	init_player_niu_room_chest(PlayerId),
	init_player_hundred_room_chest(PlayerId),
	init_player_laba_chest(PlayerId),
	init_player_super_laba_chest(PlayerId),
	ok.

send_enter_room_msg(RoomLevel) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			PlayerId = PlayerInfo#player_info.id,
			{ok, [PlayerChest]} = player_niu_room_chest_db:get(PlayerId),
			if
				PlayerChest#player_niu_room_chest.room_lv == RoomLevel ->
					UseTimes = PlayerChest#player_niu_room_chest.free_diamond_times,
					Times = PlayerChest#player_niu_room_chest.times;
				true ->
					Times = 0,
					NewPlayerChest = PlayerChest#player_niu_room_chest{times = 0},
					UseTimes = NewPlayerChest#player_niu_room_chest.free_diamond_times,
					player_niu_room_chest_db:write(NewPlayerChest)
			end,
			send_niu_room_chest_info_update(Times,?GAME_TYPE_1),
			send_sc_niu_room_chest_times_update(UseTimes,?GAME_TYPE_1)
	end.

enter_hundred_room_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			PlayerChest = get_player_hundred_room_chest(),
%%			?INFO_LOG("PlayerChest~p~n",[PlayerChest]),
			Count = PlayerChest#player_hundred_room_chest.count,
			send_niu_room_chest_info_update(Count,?GAME_TYPE_2),
			send_sc_niu_room_chest_times_update(PlayerChest#player_hundred_room_chest.free_diamond_times,?GAME_TYPE_2)
	end.

enter_laba_room_msg(Type) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			if
				Type == 1 ->
					PlayerChest = get_player_laba_chest(),
					Count = PlayerChest#player_laba_chest.count,
					send_niu_room_chest_info_update(Count,?GAME_TYPE_3),
					send_sc_niu_room_chest_times_update(PlayerChest#player_laba_chest.free_diamond_times,?GAME_TYPE_3);
				true -> %% TODO ??
					PlayerChest = get_player_super_laba_chest(),
					Count = PlayerChest#player_super_laba_chest.count,
					send_niu_room_chest_info_update(Count,?GAME_TYPE_4),
					send_sc_niu_room_chest_times_update(PlayerChest#player_super_laba_chest.free_diamond_times,?GAME_TYPE_4)
			end
	end.


gm_test(Type, Key) ->
	if
		Type == 1 ->
			change_times(Key);
		Type == 2 ->
			draw(Key,1);
		Type == 3 ->
			refresh_player_niu_room_chest();
		Type == 4 ->
			PlayerInfo = player_util:get_dic_player_info(),
			?INFO_LOG("chest_info~p~n",[{player_niu_room_chest_db:get(PlayerInfo#player_info.id),get_player_hundred_room_chest(),get_player_laba_chest(),get_player_super_laba_chest()}]);
		true->
			ok
	end.

%%初始化
init_player_niu_room_chest(PlayerId) ->
	case player_niu_room_chest_db:get(PlayerId) of
		{ok, [PlayerChest]} ->
			NowSec = util:now_seconds(),
		case util:is_same_date(NowSec,PlayerChest#player_niu_room_chest.refresh_time) of
			true ->
				ok;
			false ->
				NewPlayerChest = PlayerChest#player_niu_room_chest{
					free_diamond_times = 0,
					refresh_time = NowSec
				},
				save_player_niu_room_chest(NewPlayerChest)
		end;
		_ ->
			PlayerChest = #player_niu_room_chest{
				player_id = PlayerId,
				room_lv = 0,
				times = 0
			},
			save_player_niu_room_chest(PlayerChest)
	end.

save_player_niu_room_chest(PlayerChest) ->
	DBFun =
		fun() ->
			player_niu_room_chest_db:t_write(PlayerChest)
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

%%增加对局次数
change_times(RoomLv) ->
	PlayerInfo = player_util:get_dic_player_info(),
	case player_niu_room_chest_db:get(PlayerInfo#player_info.id) of
		{ok, [PlayerChest]} ->
			{ok, [NiuRoomChestConfig]} = niu_room_chest_config_db:get(1),
			OldTimes = PlayerChest#player_niu_room_chest.times,
			if
				OldTimes == NiuRoomChestConfig#niu_room_chest_config.condition ->
					skip;
				true ->
					NewPlayerChest = PlayerChest#player_niu_room_chest{
						room_lv = RoomLv,
						times = OldTimes + 1
					},
					DBFun =
						fun() ->
							player_niu_room_chest_db:t_write(NewPlayerChest)
						end,
					DBSuccessFun =
						fun() ->
							send_niu_room_chest_info_update(OldTimes + 1,?GAME_TYPE_1)
						end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun(),
							ok;
						{aborted, Reason} ->
							?ERROR_LOG("niu room chest change time run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							error
					end
			end;
		_ ->
			?INFO_LOG("change_niu_room_chest_times_fail")
	end.

draw(Type,GameType)->
	case GameType of
		?GAME_TYPE_1->
			draw_niu(Type);
		?GAME_TYPE_2->
			draw_hundred(Type);
		?GAME_TYPE_3->
			draw_laba(Type);
		?GAME_TYPE_4->
			draw_super_laba(Type);
		_->
			skip
	end.

%% 领取对局宝箱
draw_niu(Type) ->
	case pre_draw(Type) of
		{true, AccDict} ->
			Rewards = dict:fetch(rewards, AccDict),
			ForPbReward = dict:fetch(pb_reward, AccDict),
			PlayerChest = dict:fetch(player_niu_room_chest, AccDict),
      RewardNum = dict:fetch(reward_num,AccDict),
			RewardLog =
				if
					Type == 1->
						?REWARD_TYPE_NIU_ROOM_CHEST;
					Type == 2 ->
						?REWARD_TYPE_NIU_ROOM_CHEST_TYPE_2;
					Type == 3 ->
						?REWARD_TYPE_NIU_ROOM_CHEST_TYPE_3;
					true ->
						?REWARD_TYPE_NIU_ROOM_CHEST
				end,
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward(Rewards, RewardLog),
			DBFun2 =
			if
				Type == 2  ->
					NewTimes = PlayerChest#player_niu_room_chest.free_diamond_times + 1,
					NewPlayerChest = PlayerChest#player_niu_room_chest{
						times = 0,
						room_lv = 0,
						free_diamond_times = NewTimes
					},
					fun() ->
						player_niu_room_chest_db:t_write(NewPlayerChest)
					end;
				true ->
					NewPlayerChest = PlayerChest#player_niu_room_chest{
						times = 0,
						room_lv = 0
					},
					fun() -> player_niu_room_chest_db:t_write(NewPlayerChest) end
			end,

			SuccessFun2 = fun()->
				if
					RewardLog == ?REWARD_TYPE_NIU_ROOM_CHEST_TYPE_2 orelse RewardLog == ?REWARD_TYPE_NIU_ROOM_CHEST_TYPE_3->
						skip;
						%role_processor_mod:cast(self(),{'update_7_day_carnival_mission',2,abs(RewardNum)});
					true ->
						skip
				end end,

			DBFun =
				fun() ->
					DBFun1(),
					DBFun2()
				end,
			DBSuccessFun =
				fun() ->
					SuccessFun1(),
					SuccessFun2(),
					send_sc_niu_room_chest_times_update(NewPlayerChest#player_niu_room_chest.free_diamond_times,?GAME_TYPE_1)
				end,
      PlayerInfo = player_util:get_dic_player_info(),
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					send_niu_room_chest_info_update(0,?GAME_TYPE_1),
          if
            Type =/= 1->
              announcement_server:niu_room_chest(PlayerInfo#player_info.player_name,PlayerChest#player_niu_room_chest.room_lv,RewardNum);
            true->
              skip
          end,
					send_draw_niu_room_chest(0, "", item_use:get_pb_reward_info([ForPbReward]),?GAME_TYPE_1);
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_draw_niu_room_chest(1, "数据库错误", [],?GAME_TYPE_1)
			end;
		{false, Err} ->
			send_draw_niu_room_chest(1, Err, [],?GAME_TYPE_1)
	end.

pre_draw(Type) ->
	Requires = [
		chceck_db_info,
		check_times,
		check_rewards
	],
	AccDict = dict:new(),
	draw_requires(Type, AccDict, Requires).

draw_requires(_Type, AccDict, []) ->
	{true, AccDict};

draw_requires(Type, AccDict, [chceck_db_info | T]) ->
	PlayerInfo = player_util:get_dic_player_info(),
	case player_niu_room_chest_db:get(PlayerInfo#player_info.id) of
		{ok, [PlayerChest]} ->
			case niu_room_chest_config_db:get(1) of
				{ok, [NiuRoomChestConfig]} ->
					AccDict1 = dict:store(player_niu_room_chest, PlayerChest, AccDict),
					AccDict2 = dict:store(niu_room_chest_config, NiuRoomChestConfig, AccDict1),
					draw_requires(Type, AccDict2, T);
				_ ->
					{false, "查询对局宝箱配置信息错误"}
			end;
		_ ->
			{false, "查询玩家对局宝箱信息错误"}
	end;

draw_requires(Type, AccDict, [check_times | T]) ->
	PlayerChest = dict:fetch(player_niu_room_chest, AccDict),
	NiuRoomChestConfig = dict:fetch(niu_room_chest_config, AccDict),
	Condition = NiuRoomChestConfig#niu_room_chest_config.condition,
	Times = PlayerChest#player_niu_room_chest.times,

	if
		Times >= Condition ->
			draw_requires(Type, AccDict, T);
		true ->
			{false, "对局次数不足"}
	end;

draw_requires(Type, AccDict, [check_rewards | T]) ->
%%	PlayerChest = dict:fetch(player_niu_room_chest,AccDict),
	NiuRoomChestConfig = dict:fetch(niu_room_chest_config, AccDict),
	PlayerInfo = player_util:get_dic_player_info(),
	MinGold = NiuRoomChestConfig#niu_room_chest_config.min_gold,
	{RewardNum, CostNum, RewardId} = get_free_get_by_type(NiuRoomChestConfig, Type),
	if
		CostNum == 0 ->  %免费
			Cost = {?ITEM_ID_GOLD, 0},
			Reward = {RewardId, RewardNum},
			Rewards = [Cost, Reward],
			AccDict1 = dict:store(rewards, Rewards, AccDict),
			AccDict2 = dict:store(pb_reward, Reward, AccDict1),
			AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
			draw_requires(Type, AccDict3, T);
		true ->
			if
				PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
					Cost = {?ITEM_ID_GOLD, -CostNum},
					Reward = {RewardId, RewardNum},
					Rewards = [Cost, Reward],
					AccDict1 = dict:store(rewards, Rewards, AccDict),
					AccDict2 = dict:store(pb_reward, Reward, AccDict1),
					AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
					draw_requires(Type, AccDict3, T);
				true ->
					{false, "金币不足"}
			end
	end;
%%	if
%%		Type == 2 ->
%%			Times = PlayerChest#player_niu_room_chest.free_diamond_times,
%%			IsBuy = is_buy_fudai(PlayerInfo#player_info.id),
%%			CanGetDia =
%%			if
%%				IsBuy ->
%%					if
%%						Times >= ?FUDAI_TIMES ->
%%							false;
%%						true ->
%%							true
%%					end;
%%				true ->
%%					if
%%						Times >= ?NORMAL_TIMES ->
%%							false;
%%						true ->
%%							true
%%					end
%%			end,
%%			if
%%				CanGetDia ->
%%					if
%%						CostNum == 0 ->  %免费
%%							Cost = {?ITEM_ID_GOLD, 0},
%%							Reward = {RewardId, RewardNum},
%%							Rewards = [Cost, Reward],
%%							AccDict1 = dict:store(rewards, Rewards, AccDict),
%%							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
%%							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
%%							draw_requires(Type, AccDict3, T);
%%						true ->
%%							if
%%								PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
%%									Cost = {?ITEM_ID_GOLD, -CostNum},
%%									Reward = {RewardId, RewardNum},
%%									Rewards = [Cost, Reward],
%%									AccDict1 = dict:store(rewards, Rewards, AccDict),
%%									AccDict2 = dict:store(pb_reward, Reward, AccDict1),
%%									AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
%%									draw_requires(Type, AccDict3, T);
%%								true ->
%%									{false, "金币不足"}
%%							end
%%					end;
%%				true ->
%%					{false, "领取次数不足"}
%%			end;
%%		true ->
%%			if
%%				CostNum == 0 ->  %免费
%%					Cost = {?ITEM_ID_GOLD, 0},
%%					Reward = {RewardId, RewardNum},
%%					Rewards = [Cost, Reward],
%%					AccDict1 = dict:store(rewards, Rewards, AccDict),
%%					AccDict2 = dict:store(pb_reward, Reward, AccDict1),
%%					AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
%%					draw_requires(Type, AccDict3, T);
%%				true ->
%%					if
%%						PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
%%							Cost = {?ITEM_ID_GOLD, -CostNum},
%%							Reward = {RewardId, RewardNum},
%%							Rewards = [Cost, Reward],
%%							AccDict1 = dict:store(rewards, Rewards, AccDict),
%%							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
%%							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
%%							draw_requires(Type, AccDict3, T);
%%						true ->
%%							{false, "金币不足"}
%%					end
%%			end
%%	end;


draw_requires(Type, AccDict, [_ | T]) ->
	draw_requires(Type, AccDict, T).

send_draw_niu_room_chest(Result, Err, PBReward,GameType) ->
	Msg = #sc_niu_room_chest_draw_reply{
		result = Result,
		err = Err,
		rewards = PBReward,
		game_type = GameType
	},
%%	?INFO_LOG("sc_niu_room_chest_draw_reply~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

send_niu_room_chest_info_update(Times,GameType) ->
	Msg = #sc_niu_room_chest_info_update{
		times  = Times,
		game_type  = GameType
	},
%%	?INFO_LOG("sc_niu_room_chest_info_update~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

send_sc_niu_room_chest_times_update(Times,GameType) ->
	Msg = #sc_niu_room_chest_times_update{
		times_niu = Times,
		times_hundred = 0,
		times_laba = 0,
		update_type = GameType
	},
%%	?INFO_LOG("sc_niu_room_chest_times_update~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

%%宝箱奖励
get_free_get_by_type(NiuRoomChestConfig, Type) ->
	if
		Type == 1 ->
			[Num, CostNum] = NiuRoomChestConfig#niu_room_chest_config.free_get,
			{Num, CostNum, ?ITEM_ID_GOLD};
		Type == 2 ->
			[Num, CostNum] = NiuRoomChestConfig#niu_room_chest_config.free_get2,
			{Num, CostNum, ?ITEM_ID_DIAMOND};
		Type == 3 ->
			[Num, CostNum] = NiuRoomChestConfig#niu_room_chest_config.free_get3,
			{Num, CostNum, ?ITEM_ID_DIAMOND};
		true ->
			{0, 0, ?ITEM_ID_GOLD}
	end.

%%刷新玩家对局数据
refresh_player_niu_room_chest() ->
	PlayerInfo = player_util:get_dic_player_info(),
	case player_niu_room_chest_db:get(PlayerInfo#player_info.id) of
		{ok, [PlayerChest]} ->
			refresh_player_niu_room_chest1(PlayerChest);
		_ ->
			skip
	end.

refresh_player_niu_room_chest1(PlayerChest) ->
	NewPlayerChest = PlayerChest#player_niu_room_chest{
		room_lv = 0,
		times = 0
	},
	DBFun =
		fun() ->
			player_niu_room_chest_db:t_write(NewPlayerChest)
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

handle_timer(OldTime,NewTime)->
	case util:is_same_date(OldTime,NewTime) of
		true ->
			skip;
		false ->
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerId = PlayerInfo#player_info.id,
			{ok, [PlayerChest]} = player_niu_room_chest_db:get(PlayerId),
			NewPlayerChest = PlayerChest#player_niu_room_chest{
				free_diamond_times = 0,
				refresh_time = NewTime
			},
			save_player_niu_room_chest(NewPlayerChest),
			PlayerHChest = get_player_hundred_room_chest(),
			NewPlayerHChest = PlayerHChest#player_hundred_room_chest{
				free_diamond_times = 0,
				refresh_time = NewTime
			},
			save_player_hundred_room_chest(NewPlayerHChest),
			PlayerLChest = get_player_laba_chest(),
			NewPlayerLChest = PlayerLChest#player_laba_chest{
				free_diamond_times = 0,
				refresh_time = NewTime
			},
			save_player_laba_chest(NewPlayerLChest)
	end.

is_buy_fudai(PlayerId)->
	IsBuy =
	try
			case gen_server:call(diamond_fudai_mod:get_mod_pid(),{'is_fudai_buy',PlayerId}) of
				Flag when is_boolean(Flag) -> %{OldBuyList,OldTimesList}
					Flag;
				_->
					false
			end
	catch
	    E:R  ->
				?ERROR_LOG("is_buy_fudai! info = ~p~n, stack = ~p~n", [{E, R}, erlang:get_stacktrace()]),
				false
	end,
	IsBuy.

%% 初始化百人对局宝箱
init_player_hundred_room_chest(PlayerId) ->
	case player_hundred_room_chest_db:get(PlayerId) of
		{ok, [PlayerChest]} ->
			NowSec = util:now_seconds(),
			case util:is_same_date(NowSec,PlayerChest#player_hundred_room_chest.refresh_time) of
				true ->
					update_player_hundred_room_chest(PlayerChest);
				false ->
					NewPlayerChest = PlayerChest#player_hundred_room_chest{
						free_diamond_times = 0,
						refresh_time = NowSec
					},
					save_player_hundred_room_chest(NewPlayerChest)
			end;
		_ ->
			PlayerChest = #player_hundred_room_chest{
				player_id = PlayerId,
				count = 0,
				free_diamond_times = 0, %% 领取免费钻石次数
				refresh_time = 1451577600
			},
			save_player_hundred_room_chest(PlayerChest)
	end.

save_player_hundred_room_chest(PlayerChest) ->
	DBFun =
		fun() ->
			player_hundred_room_chest_db:t_write(PlayerChest)
		end,
	DBSuccessFun =
		fun() ->
			update_player_hundred_room_chest(PlayerChest)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			ok;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

get_player_hundred_room_chest()->
	get(?PLAYER_HUNDRED_ROOM_CHEST_INFO).

update_player_hundred_room_chest(Val)->
	put(?PLAYER_HUNDRED_ROOM_CHEST_INFO,Val).

%%增加进度
change_process(Count) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			PlayerChest = get_player_hundred_room_chest(),
%%			?INFO_LOG("change_process~p~n",[PlayerChest]),
			if
				PlayerChest#player_hundred_room_chest.count >= ?LIMIT_GOLD ->
					skip;
				true ->
					OldCount = PlayerChest#player_hundred_room_chest.count,
					NewPlayerChest = PlayerChest#player_hundred_room_chest{
						count = OldCount + Count
					},
					DBFun =
						fun() ->
							player_hundred_room_chest_db:t_write(NewPlayerChest)
						end,
					DBSuccessFun =
						fun() ->
							update_player_hundred_room_chest(NewPlayerChest),
							send_niu_room_chest_info_update(OldCount + Count,?GAME_TYPE_2)
						end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("niu room chest change time run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							error
					end
			end
	end.

%% 领取对局宝箱
draw_hundred(Type) ->
	case pre_draw_hundred(Type) of
		{true, AccDict} ->
			Rewards = dict:fetch(rewards, AccDict),
			ForPbReward = dict:fetch(pb_reward, AccDict),
			PlayerChest = dict:fetch(player_hundred_room_chest, AccDict),
			RewardNum = dict:fetch(reward_num,AccDict),
			RewardLog =
				if
					Type == 1->
						?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_1;
					Type == 2 ->
						?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_2;
					Type == 3 ->
						?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_3;
					true ->
						?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_1
				end,
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward(Rewards, RewardLog),
			DBFun2 =
				if
					Type == 2  ->
						NewTimes = PlayerChest#player_hundred_room_chest.free_diamond_times + 1,
						NewPlayerChest = PlayerChest#player_hundred_room_chest{
							count = 0,
							free_diamond_times = NewTimes
						},
						fun() ->
							player_hundred_room_chest_db:t_write(NewPlayerChest)
						end;
					true ->
						NewPlayerChest = PlayerChest#player_hundred_room_chest{
							count = 0
						},
						fun() -> player_hundred_room_chest_db:t_write(NewPlayerChest) end
				end,

			SuccessFun2 = fun()->
				if
					RewardLog == ?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_2 orelse RewardLog == ?REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_3->
						%role_processor_mod:cast(self(),{'update_7_day_carnival_mission',2,abs(RewardNum)}),
						send_sc_niu_room_chest_times_update(NewPlayerChest#player_hundred_room_chest.free_diamond_times,?GAME_TYPE_2);
					true ->
						skip
				end end,

			DBFun =
				fun() ->
					DBFun1(),
					DBFun2()
				end,
			DBSuccessFun =
				fun() ->
					SuccessFun1(),
					SuccessFun2(),
					update_player_hundred_room_chest(NewPlayerChest)
				end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					send_niu_room_chest_info_update(0,?GAME_TYPE_2),
					send_draw_niu_room_chest(0, "", item_use:get_pb_reward_info([ForPbReward]),?GAME_TYPE_2);
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_draw_niu_room_chest(1, "数据库错误", [],?GAME_TYPE_2)
			end;
		{false, Err} ->
			send_draw_niu_room_chest(1, Err, [],?GAME_TYPE_2)
	end.

pre_draw_hundred(Type) ->
	Requires = [
		chceck_db_info,
		check_times,
		check_rewards
	],
	AccDict = dict:new(),
	draw_hundred_requires(Type, AccDict, Requires).

draw_hundred_requires(_Type, AccDict, []) ->
	{true, AccDict};

draw_hundred_requires(Type, AccDict, [chceck_db_info | T]) ->
	PlayerChest = get_player_hundred_room_chest(),
	case niu_room_chest_config_db:get(2) of
		{ok, [HRoomChestConfig]} ->
			AccDict1 = dict:store(player_hundred_room_chest, PlayerChest, AccDict),
			AccDict2 = dict:store(hundred_room_chest_config, HRoomChestConfig, AccDict1),
			draw_hundred_requires(Type, AccDict2, T);
		_ ->
			{false, "查询对局宝箱配置信息错误"}
	end;

draw_hundred_requires(Type, AccDict, [check_times | T]) ->
	PlayerChest = dict:fetch(player_hundred_room_chest, AccDict),
	HRoomChestConfig = dict:fetch(hundred_room_chest_config, AccDict),
	Condition = HRoomChestConfig#niu_room_chest_config.condition,
	Count = PlayerChest#player_hundred_room_chest.count,
	if
		Count >= Condition ->
			draw_hundred_requires(Type, AccDict, T);
		true ->
			{false, "累计赢金不足"}
	end;

draw_hundred_requires(Type, AccDict, [check_rewards | T]) ->
	PlayerChest = dict:fetch(player_hundred_room_chest,AccDict),
	NHRoomChestConfig = dict:fetch(hundred_room_chest_config, AccDict),
	PlayerInfo = player_util:get_dic_player_info(),
	MinGold = NHRoomChestConfig#niu_room_chest_config.min_gold,
	{RewardNum, CostNum, RewardId} = get_free_get_by_type(NHRoomChestConfig, Type),
	if
		Type == 2 ->
			Times = PlayerChest#player_hundred_room_chest.free_diamond_times,
			IsBuy = is_buy_fudai(PlayerInfo#player_info.id),
			CanGetDia =
				if
					IsBuy ->
						if
							Times >= ?FUDAI_TIMES ->
								false;
							true ->
								true
						end;
					true ->
						if
							Times >= ?NORMAL_TIMES ->
								false;
							true ->
								true
						end
				end,
			if
				CanGetDia ->
					if
						CostNum == 0 ->  %免费
							Cost = {?ITEM_ID_GOLD, 0},
							Reward = {RewardId, RewardNum},
							Rewards = [Cost, Reward],
							AccDict1 = dict:store(rewards, Rewards, AccDict),
							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
							draw_hundred_requires(Type, AccDict3, T);
						true ->
							if
								PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
									Cost = {?ITEM_ID_GOLD, -CostNum},
									Reward = {RewardId, RewardNum},
									Rewards = [Cost, Reward],
									AccDict1 = dict:store(rewards, Rewards, AccDict),
									AccDict2 = dict:store(pb_reward, Reward, AccDict1),
									AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
									draw_hundred_requires(Type, AccDict3, T);
								true ->
									{false, "金币不足"}
							end
					end;
				true ->
					{false, "领取次数不足"}
			end;
		true ->
			if
				CostNum == 0 ->  %免费
					Cost = {?ITEM_ID_GOLD, 0},
					Reward = {RewardId, RewardNum},
					Rewards = [Cost, Reward],
					AccDict1 = dict:store(rewards, Rewards, AccDict),
					AccDict2 = dict:store(pb_reward, Reward, AccDict1),
					AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
					draw_hundred_requires(Type, AccDict3, T);
				true ->
					if
						PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
							Cost = {?ITEM_ID_GOLD, -CostNum},
							Reward = {RewardId, RewardNum},
							Rewards = [Cost, Reward],
							AccDict1 = dict:store(rewards, Rewards, AccDict),
							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
							draw_hundred_requires(Type, AccDict3, T);
						true ->
							{false, "金币不足"}
					end
			end
	end;

draw_hundred_requires(Type, AccDict, [_ | T]) ->
	draw_hundred_requires(Type, AccDict, T).

%%刷新玩家百人赢金数据
refresh_player_hundred_room_chest() ->
	PlayerChest = get_player_hundred_room_chest(),
	refresh_player_hundred_room_chest1(PlayerChest).

refresh_player_hundred_room_chest1(PlayerChest) ->
	NewPlayerChest = PlayerChest#player_niu_room_chest{
		room_lv = 0,
		times = 0
	},
	save_player_hundred_room_chest(NewPlayerChest).


%% 初始化百人对局宝箱
init_player_laba_chest(PlayerId) ->
	case player_laba_chest_db:get(PlayerId) of
		{ok, [PlayerChest]} ->
			NowSec = util:now_seconds(),
			case util:is_same_date(NowSec,PlayerChest#player_laba_chest.refresh_time) of
				true ->
					update_player_laba_chest(PlayerChest);
				false ->
					NewPlayerChest = PlayerChest#player_laba_chest{
						free_diamond_times = 0,
						refresh_time = NowSec
					},
					save_player_laba_chest(NewPlayerChest)
			end;
		_ ->
			PlayerChest = #player_laba_chest{
				player_id = PlayerId,
				count = 0
			},
			save_player_laba_chest(PlayerChest)
	end.

save_player_laba_chest(PlayerChest) ->
	DBFun =
		fun() ->
			player_laba_chest_db:t_write(PlayerChest)
		end,
	DBSuccessFun =
		fun() ->
			update_player_laba_chest(PlayerChest)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			ok;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

get_player_laba_chest()->
	get(?PLAYER_LABA_CHEST_INFO).

update_player_laba_chest(Val)->
	put(?PLAYER_LABA_CHEST_INFO,Val).


%%增加进度
change_laba_process(Count) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->

			PlayerChest = get_player_laba_chest(),
			if
				PlayerChest#player_laba_chest.count >= ?LABA_LIMIT_GOLD ->
					skip;
				true ->
					OldCount = PlayerChest#player_laba_chest.count,
					NewPlayerChest = PlayerChest#player_laba_chest{
						count = OldCount + Count
					},
					DBFun =
						fun() ->
							player_laba_chest_db:t_write(NewPlayerChest)
						end,
					DBSuccessFun =
						fun() ->
							update_player_laba_chest(NewPlayerChest),
							send_niu_room_chest_info_update(OldCount + Count,?GAME_TYPE_3)
						end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("niu room chest change time run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							error
					end
			end
	end.

change_super_laba_process(Count) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->

			PlayerChest = get_player_super_laba_chest(),
			if
				PlayerChest#player_super_laba_chest.count >= ?SUPER_LABA_LIMIT_GOLD ->
					skip;
				true ->
					OldCount = PlayerChest#player_super_laba_chest.count,
					NewPlayerChest = PlayerChest#player_super_laba_chest{
						count = OldCount + Count
					},
					DBFun =
						fun() ->
							player_super_laba_chest_db:t_write(NewPlayerChest)
						end,
					DBSuccessFun =
						fun() ->
							update_player_super_laba_chest(NewPlayerChest),
							send_niu_room_chest_info_update(OldCount + Count,?GAME_TYPE_4)
						end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("niu room chest change time run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							error
					end
			end
	end.

%% 领取拉霸对局宝箱
draw_laba(Type) ->
	case pre_draw_laba(Type) of
		{true, AccDict} ->
			Rewards = dict:fetch(rewards, AccDict),
			ForPbReward = dict:fetch(pb_reward, AccDict),
			PlayerChest = dict:fetch(player_laba_chest, AccDict),
			RewardNum = dict:fetch(reward_num,AccDict),
			RewardLog =
				if
					Type == 1->
						?REWARD_TYPE_LABA_CHEST_TYPE_1;
					Type == 2 ->
						?REWARD_TYPE_LABA_CHEST_TYPE_2;
					Type == 3 ->
						?REWARD_TYPE_LABA_CHEST_TYPE_3;
					true ->
						?REWARD_TYPE_LABA_CHEST_TYPE_1
				end,
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward(Rewards, RewardLog),
			DBFun2 =
				if
					Type == 2  ->
						NewTimes = PlayerChest#player_laba_chest.free_diamond_times + 1,
						NewPlayerChest = PlayerChest#player_laba_chest{
							count = 0,
							free_diamond_times = NewTimes
						},
						fun() ->
							player_hundred_room_chest_db:t_write(NewPlayerChest)
						end;
					true ->
						NewPlayerChest = PlayerChest#player_laba_chest{
							count = 0
						},
						fun() -> player_laba_chest_db:t_write(NewPlayerChest) end
				end,

			SuccessFun2 =
			fun() ->
				if
					RewardLog == ?REWARD_TYPE_LABA_CHEST_TYPE_2 orelse RewardLog == ?REWARD_TYPE_LABA_CHEST_TYPE_3->
						%role_processor_mod:cast(self(),{'update_7_day_carnival_mission',2,abs(RewardNum)}),
						send_sc_niu_room_chest_times_update(NewPlayerChest#player_laba_chest.free_diamond_times,?GAME_TYPE_3);
					true ->
						skip
				end end,

			DBFun =
				fun() ->
					DBFun1(),
					DBFun2()
				end,
			DBSuccessFun =
				fun() ->
					SuccessFun1(),
					SuccessFun2(),
					update_player_laba_chest(NewPlayerChest)
				end,

			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					send_niu_room_chest_info_update(0,?GAME_TYPE_3),
					send_draw_niu_room_chest(0, "", item_use:get_pb_reward_info([ForPbReward]),?GAME_TYPE_3);
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_draw_niu_room_chest(1, "数据库错误", [],?GAME_TYPE_3)
			end;
		{false, Err} ->
			send_draw_niu_room_chest(1, Err, [],?GAME_TYPE_3)
	end.

pre_draw_laba(Type) ->
	Requires = [
		chceck_db_info,
		check_times,
		check_rewards
	],
	AccDict = dict:new(),
	draw_laba_requires(Type, AccDict, Requires).

draw_laba_requires(_Type, AccDict, []) ->
	{true, AccDict};

draw_laba_requires(Type, AccDict, [chceck_db_info | T]) ->
	PlayerChest = get_player_laba_chest(),
	case niu_room_chest_config_db:get(3) of
		{ok, [LRoomChestConfig]} ->
			AccDict1 = dict:store(player_laba_chest, PlayerChest, AccDict),
			AccDict2 = dict:store(laba_chest_config, LRoomChestConfig, AccDict1),
			draw_laba_requires(Type, AccDict2, T);
		_ ->
			{false, "查询对局宝箱配置信息错误"}
	end;

draw_laba_requires(Type, AccDict, [check_times | T]) ->
	PlayerChest = dict:fetch(player_laba_chest, AccDict),
	HRoomChestConfig = dict:fetch(laba_chest_config, AccDict),
	Condition = HRoomChestConfig#niu_room_chest_config.condition,
	Count = PlayerChest#player_laba_chest.count,
	if
		Count >= Condition ->
			draw_laba_requires(Type, AccDict, T);
		true ->
			{false, "累计赢金不足"}
	end;

draw_laba_requires(Type, AccDict, [check_rewards | T]) ->
	PlayerChest = dict:fetch(player_laba_chest,AccDict),
	LRoomChestConfig = dict:fetch(laba_chest_config, AccDict),
	PlayerInfo = player_util:get_dic_player_info(),
	FreeDiamondTimes = PlayerChest#player_laba_chest.free_diamond_times,
	get_laba_reward(LRoomChestConfig,Type,FreeDiamondTimes,PlayerInfo,AccDict,T);

draw_laba_requires(Type, AccDict, [_ | T]) ->
	draw_laba_requires(Type, AccDict, T).

%%刷新玩家
refresh_player_laba_chest() ->
	PlayerChest = get_player_laba_chest(),
	refresh_player_laba_chest1(PlayerChest).

refresh_player_laba_chest1(PlayerChest) ->
	NewPlayerChest = PlayerChest#player_laba_chest{
		count = 0
	},
	save_player_laba_chest(NewPlayerChest).

%% 初始化超级拉霸
init_player_super_laba_chest(PlayerId) ->
	case player_super_laba_chest_db:get(PlayerId) of
		{ok, [PlayerChest]} ->
			NowSec = util:now_seconds(),
			case util:is_same_date(NowSec,PlayerChest#player_super_laba_chest.refresh_time) of
				true ->
					update_player_super_laba_chest(PlayerChest);
				false ->
					NewPlayerChest = PlayerChest#player_super_laba_chest{
						free_diamond_times = 0,
						refresh_time = NowSec
					},
					save_player_super_laba_chest(NewPlayerChest)
			end;
		_ ->
			PlayerChest = #player_super_laba_chest{
				player_id = PlayerId,
				count = 0
			},
			save_player_super_laba_chest(PlayerChest)
	end.

save_player_super_laba_chest(PlayerChest) ->
	DBFun =
		fun() ->
			player_super_laba_chest_db:t_write(PlayerChest)
		end,
	DBSuccessFun =
		fun() ->
			update_player_super_laba_chest(PlayerChest)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			ok;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

get_player_super_laba_chest()->
	get(?PLAYER_SUPER_LABA_CHEST_INFO).

update_player_super_laba_chest(Val)->
	put(?PLAYER_SUPER_LABA_CHEST_INFO,Val).

draw_super_laba(Type) ->
	case pre_draw_super_laba(Type) of
		{true, AccDict} ->
			Rewards = dict:fetch(rewards, AccDict),
			ForPbReward = dict:fetch(pb_reward, AccDict),
			PlayerChest = dict:fetch(player_laba_chest, AccDict),
			RewardNum = dict:fetch(reward_num,AccDict),
			RewardLog =
				if
					Type == 1->
						?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_1;
					Type == 2 ->
						?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_2;
					Type == 3 ->
						?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_3;
					true ->
						?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_1
				end,
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward(Rewards, RewardLog),
			DBFun2 =
				if
					Type == 2  ->
						NewTimes = PlayerChest#player_super_laba_chest.free_diamond_times + 1,
						NewPlayerChest = PlayerChest#player_super_laba_chest{
							count = 0,
							free_diamond_times = NewTimes
						},
						fun() ->
							player_hundred_room_chest_db:t_write(NewPlayerChest)
						end;
					true ->
						NewPlayerChest = PlayerChest#player_super_laba_chest{
							count = 0
						},
						fun() -> player_super_laba_chest_db:t_write(NewPlayerChest) end
				end,

			SuccessFun2 =
				fun() ->
					if
						RewardLog == ?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_2 orelse RewardLog == ?REWARD_TYPE_SUPER_LABA_CHEST_TYPE_3->
							%role_processor_mod:cast(self(),{'update_7_day_carnival_mission',2,abs(RewardNum)}),
							send_sc_niu_room_chest_times_update(NewPlayerChest#player_super_laba_chest.free_diamond_times,?GAME_TYPE_4);
						true ->
							skip
					end end,

			DBFun =
				fun() ->
					DBFun1(),
					DBFun2()
				end,
			DBSuccessFun =
				fun() ->
					SuccessFun1(),
					SuccessFun2(),
					update_player_super_laba_chest(NewPlayerChest)
				end,

			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					send_niu_room_chest_info_update(0,?GAME_TYPE_4),
					send_draw_niu_room_chest(0, "", item_use:get_pb_reward_info([ForPbReward]),?GAME_TYPE_4);
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_draw_niu_room_chest(1, "数据库错误", [],?GAME_TYPE_4)
			end;
		{false, Err} ->
			send_draw_niu_room_chest(1, Err, [],?GAME_TYPE_4)
	end.

pre_draw_super_laba(Type) ->
	Requires = [
		chceck_db_info,
		check_times,
		check_rewards
	],
	AccDict = dict:new(),
	draw_super_laba_requires(Type, AccDict, Requires).

draw_super_laba_requires(_Type, AccDict, []) ->
	{true, AccDict};

draw_super_laba_requires(Type, AccDict, [chceck_db_info | T]) ->
	PlayerChest = get_player_super_laba_chest(),
	case niu_room_chest_config_db:get(4) of
		{ok, [LRoomChestConfig]} ->
			AccDict1 = dict:store(player_laba_chest, PlayerChest, AccDict),
			AccDict2 = dict:store(laba_chest_config, LRoomChestConfig, AccDict1),
			draw_super_laba_requires(Type, AccDict2, T);
		_ ->
			{false, "查询对局宝箱配置信息错误"}
	end;

draw_super_laba_requires(Type, AccDict, [check_times | T]) ->
	PlayerChest = dict:fetch(player_laba_chest, AccDict),
	LRoomChestConfig = dict:fetch(laba_chest_config, AccDict),
	Condition = LRoomChestConfig#niu_room_chest_config.condition,
	Count = PlayerChest#player_super_laba_chest.count,
	if
		Count >= Condition ->
			draw_super_laba_requires(Type, AccDict, T);
		true ->
			{false, "累计赢金不足"}
	end;

draw_super_laba_requires(Type, AccDict, [check_rewards | T]) ->
	PlayerChest = dict:fetch(player_laba_chest,AccDict),
	LRoomChestConfig = dict:fetch(laba_chest_config, AccDict),
	PlayerInfo = player_util:get_dic_player_info(),
	FreeDiamondTimes = PlayerChest#player_super_laba_chest.free_diamond_times,
	get_laba_reward(LRoomChestConfig,Type,FreeDiamondTimes,PlayerInfo,AccDict,T);

draw_super_laba_requires(Type, AccDict, [_ | T]) ->
	draw_super_laba_requires(Type, AccDict, T).

get_laba_reward(LRoomChestConfig,Type,FreeDiamondTimes,PlayerInfo,AccDict,T)->
	MinGold =LRoomChestConfig#niu_room_chest_config.min_gold,
	{RewardNum, CostNum, RewardId} = get_free_get_by_type(LRoomChestConfig, Type),
	if
		Type == 2 ->
			Times = FreeDiamondTimes,
			IsBuy = is_buy_fudai(PlayerInfo#player_info.id),
			CanGetDia =
				if
					IsBuy ->
						if
							Times >= ?FUDAI_TIMES ->
								false;
							true ->
								true
						end;
					true ->
						if
							Times >= ?NORMAL_TIMES ->
								false;
							true ->
								true
						end
				end,
			if
				CanGetDia ->
					if
						CostNum == 0 ->  %免费
							Cost = {?ITEM_ID_GOLD, 0},
							Reward = {RewardId, RewardNum},
							Rewards = [Cost, Reward],
							AccDict1 = dict:store(rewards, Rewards, AccDict),
							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
							draw_super_laba_requires(Type, AccDict3, T);
						true ->
							if
								PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
									Cost = {?ITEM_ID_GOLD, -CostNum},
									Reward = {RewardId, RewardNum},
									Rewards = [Cost, Reward],
									AccDict1 = dict:store(rewards, Rewards, AccDict),
									AccDict2 = dict:store(pb_reward, Reward, AccDict1),
									AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
									draw_super_laba_requires(Type, AccDict3, T);
								true ->
									{false, "金币不足"}
							end
					end;
				true ->
					{false, "领取次数不足"}
			end;
		true ->
			if
				CostNum == 0 ->  %免费
					Cost = {?ITEM_ID_GOLD, 0},
					Reward = {RewardId, RewardNum},
					Rewards = [Cost, Reward],
					AccDict1 = dict:store(rewards, Rewards, AccDict),
					AccDict2 = dict:store(pb_reward, Reward, AccDict1),
					AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
					draw_super_laba_requires(Type, AccDict3, T);
				true ->
					if
						PlayerInfo#player_info.gold >= (MinGold + CostNum) ->
							Cost = {?ITEM_ID_GOLD, -CostNum},
							Reward = {RewardId, RewardNum},
							Rewards = [Cost, Reward],
							AccDict1 = dict:store(rewards, Rewards, AccDict),
							AccDict2 = dict:store(pb_reward, Reward, AccDict1),
							AccDict3 = dict:store(reward_num,RewardNum,AccDict2),
							draw_super_laba_requires(Type, AccDict3, T);
						true ->
							{false, "金币不足"}
					end
			end
	end.