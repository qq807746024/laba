%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 二月 2017 11:19
%%%-------------------------------------------------------------------
-module(player_shop).
-author("Administrator").

-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/shop_pb.hrl").

-define(SHOP_BUY_RANDOMREWARD_ANN_MIN, 20000). % 商城购买随机金币通告最小值


-define(CAN_REFRESH_FLAG, 1).  %%可以刷新购买次数
-define(PAY_ACTIVITY_STALL_1, 401).  %%一本万利充值档位
-define(PAY_ACTIVITY_STALL_2, 402).  %%
-define(PAY_ACTIVITY_STALL_3, 403).  %%
-define(PAY_ACTIVITY_STALL_4, 404).  %%
-define(PAY_ACTIVITY_STALL_5, 405).  %%
-define(PAY_ACTIVITY_STALL_6, 406).  %%


%% API
-export([
	get_ets_shop_item_info/0,
	init_player_shop/1,
	handle_time/2,
	send_player_shop_item_info/0,
	cs_buy/2,
	send_buy_back/5,
	test/0
]).
%%-----------------

get_ets_shop_item_info() ->
	ets:tab2list(?ETS_SHOP_ITEM).

init_player_shop(PlayerId) ->
	case player_buy_info_db:get(PlayerId) of
		{ok, [PlayerBuyInfo]} ->
			NowSec = util:now_seconds(),
			%?INFO_LOG("111~p~n",[PlayerBuyInfo]),
			NewPlayerBuyInfo = check_time(PlayerBuyInfo, NowSec),
			if
				NewPlayerBuyInfo == PlayerBuyInfo ->
					skip;
				true ->
					player_buy_info_db:write(NewPlayerBuyInfo)
			end;
		_ ->
			NewPlayerBuyInfo = #player_buy_info{
				player_id = PlayerId,
				limit_item = []
			},
			player_buy_info_db:write(NewPlayerBuyInfo)
	end.


send_player_shop_item_info() ->
	ItemList = get_ets_shop_item_info(),
	PlayerInfo = player_util:get_dic_player_info(),
	{ok, [PlayerBuyInfo]} = player_buy_info_db:get(PlayerInfo#player_info.id),
	PbItemList = pack_shop_item(ItemList, PlayerBuyInfo),
	Msg =
		#sc_shop_all_item_base_config{
			item_list = PbItemList
		},
	%player_util:log_by_player_id(1000242, "shop_msg~p~n",[Msg]),
	GatePid = player_util:get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg).

pack_shop_item(List, PlayerBuyInfo) ->
	ListOut =
		lists:map(fun(E) ->
			#base_shop_item{
				id = Id,
				shop_type = ShopType,
				item_id = ItemId,
				item_num = ItemNum,
				item_extra_num = ExtraNum,
				cost_list = CostList1,
				discount = Discount,
				special_flag = SpecialFlag,
				start_time = StartTime1,
				end_time = EndTime1,
				limit_condition = LimitCondition,
				vip_limit = VipLimit,
				tex = Icon,
				name = Name,
				sort = Sort
			} = E,
			{StartTime, EndTime} = get_start_and_end_time(StartTime1, EndTime1),
			CostList = pack_cost_list(CostList1),
			LimitCondition1 = pack_LimitCondition(LimitCondition),
			LeftTimes = get_left_times(Id, LimitCondition, PlayerBuyInfo),
			#pb_shop_item{
				id = Id,
				shop_type = ShopType,
				item_id = ItemId,
				item_num = ItemNum,
				item_extra_num = ExtraNum,
				cost_list = CostList,
				discount = Discount,
				special_flag = SpecialFlag,
				start_time = StartTime,
				end_time = EndTime,
				limit_times = LimitCondition1,
				vip_limit = VipLimit,
				left_times = LeftTimes,
				icon = Icon,
				name = Name,
				sort = Sort
			} end, List),
	ListOut.

get_left_times(Id, LimitCondition, PlayerBuyInfo) ->
	LimitItems = PlayerBuyInfo#player_buy_info.limit_item,
	Tuple = lists:keyfind(Id, 1, LimitItems),
	if
		LimitCondition == [] ->
			if
				Id == ?SHOP_ITEM_ID_DIAMOND_FUDAI_DAILY ->
					Flag1 = player_niu_room_chest:is_buy_fudai(PlayerBuyInfo#player_buy_info.player_id),
					Num =
					if
						Flag1->
							1;
						true ->
							0
					end,
					99 - Num;
%%					case lists:keyfind(?SHOP_ITEM_ID_DIAMOND_FUDAI, 1, LimitItems) of
%%						{?SHOP_ITEM_ID_DIAMOND_FUDAI,Num,_,_} ->
%%							99 - Num;
%%						_->
%%							99
%%					end;
				true ->
					99
			end;
		Tuple == false ->
			[{Times, _} | _] = LimitCondition,
			Times;
		true ->
			{Id, BuyTimes, _, _} = Tuple,
			[{Times, _} | _] = LimitCondition,
			Times - BuyTimes
	end.


pack_LimitCondition(LimitCondition) ->
	if
		LimitCondition == [] ->
			99;
		true ->
			[{Num, _} | _] = LimitCondition,
			Num
	end.
pack_cost_list(CostList) ->
	[CostType, CostNum | _] = CostList,
	[#pb_cost_type_and_num{
		cost_type = CostType,
		cost_num = CostNum
	}].

cs_buy(Id, EnterType) ->
	case pre_buy(Id, EnterType) of
		{true, AccDict} ->
			Cost = dict:fetch(cost, AccDict),
			Reward = dict:fetch(reward, AccDict),
			Record = dict:fetch(buy_record, AccDict),
			LeftTime = dict:fetch(left_times, AccDict),
			%?INFO_LOG("cs_buy~p~p~n",[Cost,Reward]),
			Playerinfo = player_util:get_dic_player_info(),
			NewPlayerBuyInfo = insert_player_buy_record(Record),

			IsBuy = player_niu_room_chest:is_buy_fudai(Playerinfo#player_info.id),

			DailyFirstFudaiReward =
				if
					not IsBuy andalso Id == ?SHOP_ITEM_ID_DIAMOND_FUDAI_DAILY ->
						[{?ITEM_ID_DIAMOND,8},{?ITEM_ID_GOLD,5000}];
					true ->
						[]
				end,
			FirstBuyReward =
				if
					?SHOP_ITEM_ID_FIRST_RECHARGE_BAG == Id ->
						player_util:get_server_const(?CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD);
					?SHOP_ITEM_ID_FIRST_RECHARGE_BAG_2 == Id ->
						player_util:get_server_const(?CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD_2);
					?SHOP_ITEM_ID_FIRST_RECHARGE_BAG_3 == Id ->
						player_util:get_server_const(?CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD_3);
					true ->
						[]
				end,

			{NewPlayerInfo, DBFun1, SuccessFun, PbRewardInfo} =
				item_use:transc_items_reward(
					Cost ++ [Reward] ++ DailyFirstFudaiReward ++ FirstBuyReward, 
					?REWARD_TYPE_SHOP),
			{OtherDBFun, OtherSuccess} =
				case Id of
					?SHOP_ITEM_ID_MONTH_CARD ->
						player_id_month_card:add_monthly_days(calendar:local_time());
					?SHOP_ITEM_ID_WEEK_CARD ->
						player_id_period_card:add_period_days(calendar:local_time(), ?PERIOD_CARD_TYPE_WEEK);
					?SHOP_ITEM_ID_DIAMOND_FUDAI ->
						{fun() ->void end, fun() -> void end};
					?SHOP_ITEM_ID_DIAMOND_FUDAI_DAILY ->
						{fun() ->void end, fun() -> do_cast_fudai_mod(Playerinfo#player_info.id) end};
					?PAY_ACTIVITY_STALL_1 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?PAY_ACTIVITY_STALL_2 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?PAY_ACTIVITY_STALL_3 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?PAY_ACTIVITY_STALL_4 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?PAY_ACTIVITY_STALL_5 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?PAY_ACTIVITY_STALL_6 ->
						{fun() ->void end, fun() -> player_pay_activity_util:task_open() end};
					?SHOP_ITEM_ID_SALARY ->
						{SalaryReward, SalaryDBFunOri, SalaryDBSuccFunOri} = player_daily_salary:draw(),
						{_, DBFunDailySalary, SuccessFunDailySalary, PbRewardInfoDailySalary} =
							item_use:transc_items_reward_with_playerInfo(NewPlayerInfo, SalaryReward, ?REWARD_TYPE_DAILY_SALARY),
						{fun() ->
							SalaryDBFunOri(),
							DBFunDailySalary()
						end, fun() ->
							SalaryDBSuccFunOri(),
							SuccessFunDailySalary(),
							send_buy_back(0, "", PbRewardInfoDailySalary, 0, 0)
						end};
					?SHOP_ITEM_ID_1YUAN_RANDOM_REWARD ->
						[Gold] = util_random:get_random_rewards(player_util:get_server_const(?CONST_CONFIG_KEY_1YUAN_RANDOM_REWARD)),
						RandomReward = [{?ITEM_ID_GOLD, Gold}],
						{_, DBFunRandomReward, SuccessFunRandomRewardOri, PbRewardInfoRandomReward} =
							item_use:transc_items_reward_with_playerInfo(NewPlayerInfo, RandomReward, ?REWARD_TYPE_SHOP_RANDOM_REWARD),
						SuccessFunRandomReward = fun () ->
							SuccessFunRandomRewardOri(),
							send_buy_back(0, "", PbRewardInfoRandomReward, 0, 0),
							if
								Gold >= ?SHOP_BUY_RANDOMREWARD_ANN_MIN ->
									announcement_server:shop_buy_random_reward(Playerinfo#player_info.player_name, Gold);
								true ->
									skip
							end
						end,
						{DBFunRandomReward, SuccessFunRandomReward};
					_ ->
						{fun() ->skip end, fun() ->skip end}
				end,
			RecordDBFun =
				case Record of
					[] ->
						fun() ->skip end;
					_ ->
						fun() -> player_buy_info_db:t_write(NewPlayerBuyInfo) end
				end,
			DBFun = fun() ->
				DBFun1(),
				RecordDBFun(),
				OtherDBFun()
			end,
			DBSuccessFun = fun() ->
				SuccessFun(),
				OtherSuccess(),
				send_buy_back(0, "", PbRewardInfo, LeftTime, Id),
				announcement_server:pay_for_gold(Playerinfo#player_info.player_name, Id)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_buy_back(1, "数据库错误", [], 0, Id)
			end,
			ok;
		{false, Err} ->
			send_buy_back(1, Err, [], 0, Id)
	end.

pre_buy(Id, EnterType) ->
	Requires = [
		check_item_id,
		check_vip,
		check_buy_time,
		check_buy_limit,
		check_cost
	],
	AccDict = dict:from_list([
		{id, Id},
		{enter_type, EnterType}
	]),
	buy_requires(AccDict, Requires).

buy_requires(AccDict, []) ->
	{true, AccDict};

buy_requires(AccDict, [check_item_id | T]) ->
	Id = dict:fetch(id, AccDict),
	ShopItemList = get_ets_shop_item_info(),
	ItemList =
		lists:filter(fun(E) ->
			E#base_shop_item.id == Id end, ShopItemList),
	if
		ItemList == [] ->
			{false, "购买的商品不存在"};
		true ->
			[Item | _] = ItemList,
			AccDict1 = dict:store(shop_item, Item, AccDict),
			buy_requires(AccDict1, T)
	end;

buy_requires(AccDict, [check_vip | T]) ->
	ShopItem = dict:fetch(shop_item, AccDict),
	VipLimit = ShopItem#base_shop_item.vip_limit,
	PlayerInfo = player_util:get_dic_player_info(),
	VipLv = PlayerInfo#player_info.vip_level,
	if
		VipLv >= VipLimit ->
			buy_requires(AccDict, T);
		true ->
			{false, "vip等级不足"}
	end;

buy_requires(AccDict, [check_buy_time | T]) ->
	ShopItem = dict:fetch(shop_item, AccDict),
	{StartTime, EndTime} =
		get_start_and_end_time(ShopItem#base_shop_item.start_time, ShopItem#base_shop_item.end_time),
	NowSec = util:now_seconds(),

	if
		StartTime == 0 andalso EndTime == 0 ->
			buy_requires(AccDict, T);
		NowSec >= StartTime andalso NowSec =< EndTime ->
			buy_requires(AccDict, T);
		true ->
			{false, "商品不在出售时间内"}
	end;
buy_requires(AccDict, [check_buy_limit | T]) ->
	ShopItem = dict:fetch(shop_item, AccDict),
	LimitCondition = ShopItem#base_shop_item.limit_condition,
	LimitItemBuyRecords = get_player_buy_info(),
	case LimitCondition of
		[{Num, RefreshFlag} | _] ->
			case deal_limit_condition({Num, RefreshFlag}, LimitItemBuyRecords, ShopItem#base_shop_item.id) of
				{false, Err} ->
					{false, Err};
				{NewBuyRecord, LeftTimes} ->
					if
						?SHOP_ITEM_ID_SALARY =:= ShopItem#base_shop_item.id ->
							SalaryOk = player_daily_salary:can_draw();
						true ->
							SalaryOk = true
					end,
					if
						not SalaryOk ->
							{false, "你昨日没有工资，或者已领取"};
						true ->
							AccDict1 = dict:store(buy_record, NewBuyRecord, AccDict),
							AccDict2 = dict:store(left_times, LeftTimes, AccDict1),
							buy_requires(AccDict2, T)
					end
			end;
		[] ->
			if
				ShopItem#base_shop_item.id == ?SHOP_ITEM_ID_DIAMOND_FUDAI_DAILY ->
					AccDict1 = dict:store(buy_record, [], AccDict),
					AccDict2 = dict:store(left_times, 98, AccDict1),
					buy_requires(AccDict2, T);
				true ->
					AccDict1 = dict:store(buy_record, [], AccDict),
					AccDict2 = dict:store(left_times, 99, AccDict1),
					buy_requires(AccDict2, T)
			end;
		_ ->
			{false, "次数不足"}
	end;

buy_requires(AccDict, [check_cost | T]) ->
	ShopItem = dict:fetch(shop_item, AccDict),
	EnterType = dict:fetch(enter_type, AccDict),
	%?INFO_LOG("shop_item~p~n",[ShopItem]),
	PlayerInfo = player_util:get_dic_player_info(),
	{CostId, CostNum} = get_cost_num(ShopItem),
	case EnterType of
		'client' ->
			if
				CostId == ?ITEM_ID_GOLD ->
					Gold = PlayerInfo#player_info.gold,
					if
						Gold >= CostNum ->
							Cost = [{?ITEM_ID_GOLD, -CostNum}],
							Reward = get_reward(ShopItem),
							AccDict1 = dict:store(cost, Cost, AccDict),
							AccDict2 = dict:store(reward, Reward, AccDict1),
							buy_requires(AccDict2, T);
						true ->
							{false, "金币不足"}
					end;
				CostId == ?ITEM_ID_DIAMOND ->
					Diamond = PlayerInfo#player_info.diamond,
					if
						Diamond >= CostNum ->
							Cost = [{?ITEM_ID_DIAMOND, -CostNum}],
							Reward = get_reward(ShopItem),
							AccDict1 = dict:store(cost, Cost, AccDict),
							AccDict2 = dict:store(reward, Reward, AccDict1),
							buy_requires(AccDict2, T);
						true ->
							{false, "钻石不足"}
					end;
				CostId == ?ITEM_ID_CASH ->
					Cash = PlayerInfo#player_info.cash,
					if
						Cash >= CostNum ->
							Cost = [{?ITEM_ID_CASH, -CostNum}],
							Reward = get_reward(ShopItem),
							AccDict1 = dict:store(cost, Cost, AccDict),
							AccDict2 = dict:store(reward, Reward, AccDict1),
							buy_requires(AccDict2, T);
						true ->
							{false, "钞票不足"}
					end;
				true ->
					{false, "货币类型错误1"}
			end;
		_ ->
			if
				CostId == 999 ->
					Cost = [],
					Reward = get_reward(ShopItem),
					AccDict1 = dict:store(cost, Cost, AccDict),
					AccDict2 = dict:store(reward, Reward, AccDict1),
					buy_requires(AccDict2, T);
				true ->
					{false, "货币类型错误2"}
			end
	end;

buy_requires(AccDict, [_ | T]) ->
	buy_requires(AccDict, T).

send_buy_back(Result, Err, Rewards, LeftTimes, Id) ->
	Msg = #sc_shop_buy_reply{
		result = Result,
		err_msg = Err,
		rewards = Rewards,
		left_times = LeftTimes,
		id = Id
	},
	%?INFO_LOG("sc_shop_buy_reply~p~n",[Msg]),
	GatePid = player_util:get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg).

deal_limit_condition({Num, RefreshFlag}, LimitItemBuyRecord, Id) ->
	NowSec = util:now_seconds(),
	case lists:keyfind(Id, 1, LimitItemBuyRecord) of
		{Id, BuyNum, _, _} ->
			if
				BuyNum < Num ->
					{{Id, BuyNum + 1, RefreshFlag, NowSec}, Num - BuyNum - 1};
				true ->
					{false, "购买次数不足"}
			end;
		false ->
			{{Id, 1, RefreshFlag, NowSec}, Num - 1}
	end.

%%获取商品上架时间
get_start_and_end_time(StartTime1, EndTime1) ->
	if
		StartTime1 == 0 orelse EndTime1 == 0 ->
			{0, 0};
		true ->
			StartTime = util:datetime_to_seconds(StartTime1),
			EndTime = util:datetime_to_seconds(EndTime1),
			{StartTime, EndTime}
	end.


%%获取物品出售价格（根据消耗货币类型）
get_cost_num(ShopItem) ->
	Discount = ShopItem#base_shop_item.discount,
	CostList = ShopItem#base_shop_item.cost_list,
	[CostId, CostNum] = CostList,

	{CostId, round(CostNum * Discount / 100)}.

get_player_buy_info() ->
	PlayerInfo = player_util:get_dic_player_info(),
	{ok, [PlayerBuyInfo]} = player_buy_info_db:get(PlayerInfo#player_info.id),
	PlayerBuyInfo#player_buy_info.limit_item.

insert_player_buy_record(Record) ->
	PlayerInfo = player_util:get_dic_player_info(),
	{ok, [PlayerBuyInfo]} = player_buy_info_db:get(PlayerInfo#player_info.id),
	if
		Record == [] ->
			PlayerBuyInfo;
		true ->
			{Key, _, _, _} = Record,
			case Key of
				?SHOP_ITEM_ID_DIAMOND_FUDAI ->
					LimitRecords = PlayerBuyInfo#player_buy_info.limit_item;
				_ ->
					LimitRecords = PlayerBuyInfo#player_buy_info.limit_item
			end,

			NewLimitRecords = lists:keystore(Key, 1, LimitRecords, Record),
			PlayerBuyInfo#player_buy_info{
				limit_item = NewLimitRecords
			}
	end.

check_time(PlayerBuyInfo, NewSec) ->
	if
		PlayerBuyInfo == [] ->
			PlayerBuyInfo;
		true ->
			LimitItemRecord = PlayerBuyInfo#player_buy_info.limit_item,

			NewLimitItemRecord =
				lists:foldl(fun(E, Acc) ->
					{Key, Num, Refresn, Time} = E,
					if
						Refresn == ?CAN_REFRESH_FLAG ->
							Flag = util:is_same_date(Time, NewSec),
							if
								Flag ->
									[{Key, Num, Refresn, Time} | Acc];
								true ->
									[{Key, 0, Refresn, NewSec} | Acc]
							end;
						true ->
							[{Key, Num, Refresn, Time} | Acc]
					end end, [], LimitItemRecord),
			PlayerBuyInfo#player_buy_info{
				limit_item = NewLimitItemRecord
			}
	end.

handle_time(OldSec, NewSec) ->
	case util:is_same_date(OldSec, NewSec) of
		true ->
			skip;
		false ->
			PlayerInfo = player_util:get_dic_player_info(),
			{ok, [PlayerBuyInfo]} = player_buy_info_db:get(PlayerInfo#player_info.id),
			NewPlayerBuyInfo = check_time(PlayerBuyInfo, NewSec),
			if
				PlayerBuyInfo == NewPlayerBuyInfo ->
					skip;
				true ->
					DBFun =
						fun() ->
							player_buy_info_db:t_write(NewPlayerBuyInfo)
						end,
					DBSuccessFun =
						fun() ->
							send_player_shop_item_info()
						end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							error
					end
			end
	end.

get_reward(ShopItem) ->
	Id = ShopItem#base_shop_item.item_id,
	Num = ShopItem#base_shop_item.item_num,
	ExtraNum = ShopItem#base_shop_item.item_extra_num,
	AllNum = Num + ExtraNum,
	{Id, AllNum}.

do_cast_fudai_mod(BuyPlayerId) ->
	%ok.
	gen_server:cast(diamond_fudai_mod:get_mod_pid(), {'buy_fudai', BuyPlayerId}).

test() ->
	PlayerInfo = player_util:get_dic_player_info(),
	{ok, [PlayerBuyInfo]} = player_buy_info_db:get(PlayerInfo#player_info.id),
	LimitItemRecord = PlayerBuyInfo#player_buy_info.limit_item,

	NewSec = util:now_seconds(),
	NewLimitItemRecord =
		lists:foldl(fun(E, Acc) ->
			{Key, Num, Refresn, Time} = E,
			if
				Refresn == ?CAN_REFRESH_FLAG ->
					[{Key, 0, Refresn, NewSec} | Acc];
				true ->
					[{Key, Num, Refresn, Time} | Acc]
			end end, [], LimitItemRecord),

	NewPlayerBuyInfo = 	PlayerBuyInfo#player_buy_info{
		limit_item = NewLimitItemRecord
	},
	player_buy_info_db:write(NewPlayerBuyInfo),
	send_player_shop_item_info().

