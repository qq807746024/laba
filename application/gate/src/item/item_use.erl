%% 物品使用

-module(item_use).

-export([
	get_pb_reward_info/1,	%% 获取奖励的显示结构

	imme_items_reward/2,	%% 立即发奖励 奖励列表(可包括消耗, 返回奖励pb(不包含扣除) )
	transc_items_reward/2, 	%% 获取发奖励事务(可包括消耗, 返回 NewPlayerInfo, DB, DBSuccess, 奖励pb(不包含扣除) )
	transc_items_reward_with_playerInfo/3,
	send_reward_mail/4,	%% 发奖励邮件 (playerid, 奖励,title, content)

	rewards_item_id_correct/1,
	compare_check/2,
	deduct_item_enough/3,
	check_item_enough/1,
	check_robot_gold_add/2,

	get_player_item_num/1,		%% 获取数量
	update_robot_level/0,
	do_transc_items_rank_and_log_sync/3
]).

-ifdef(TEST).
-compile(export_all).
-endif.

-include("common.hrl").
-include("role_processor.hrl").

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/item_pb.hrl").

get_pb_reward_info(RewardList) ->
	lists:foldl(fun({BaseId, Count}, Acc) ->
		if
			Count =< 0 ->
				Acc;
			true ->
				Add = #pb_reward_info{
					base_id = BaseId,
					count = Count
				},
				[Add|Acc]
		end end, [], RewardList).

%% 注意勿在使用该方法后更新玩家数据 容易出错
%% 有修改player_info的话用transc_items_reward
imme_items_reward(RewardList, RewardLogType) ->
	case transc_items_reward(RewardList, RewardLogType) of
		{NewPlayerInfo, DBFun, SuccessFun, _PbRewardList} ->
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _}	->
					SuccessFun();
				{aborted, Reason}	->
					?ERROR_LOG("imme_items_reward transc_items_reward FAIL!!! ~p~n", [{?MODULE, Reason}]),
					?INFO_LOG("imme_items_reward transc_items_reward FAIL!!! ~p~n", [player_util:get_dic_player_info()])
			end,
			{true, NewPlayerInfo};
		_ ->
			{false, undefined}
	end.

%% 获取a u d 相关数据库操作 %%%%%
get_trans_by_add_item(BagItem, PlayerId, AddItemRec) ->
	lists:foldl(fun({AddBaseId, Num}, {BagItemAcc, DBFunAcc, RecList}) ->
		Rec = item_util:create_item_info(PlayerId, AddBaseId, Num),
		DBFun = fun() ->
			player_items_db:t_write_player_items(Rec)
		end,
		NewBagItemAcc = dict:store(AddBaseId, Rec, BagItemAcc),
		{NewBagItemAcc, [DBFun | DBFunAcc], [Rec|RecList]}
	end, {BagItem, [], []}, AddItemRec).
get_trans_by_upd_item(BagItem, _PlayerId, UpdItemRec) ->
	lists:foldl(fun({UpdBaseId, Num}, {BagItemAcc, DBFunAcc, RecList}) ->
		OldRec = dict:fetch(UpdBaseId, BagItem),
		Rec = OldRec#player_items{
			count = Num
		},
		DBFun = fun() ->
			player_items_db:t_write_player_items(Rec)
		end,
		NewBagItemAcc = dict:store(UpdBaseId, Rec, BagItemAcc),
		{NewBagItemAcc, [DBFun | DBFunAcc], [Rec|RecList]}
	end, {BagItem, [], []}, UpdItemRec).
get_trans_by_del_item(BagItem, _PlayerId, DeleteRec) ->
	lists:foldl(fun({DelBaseId, TypeId}, {BagItemAcc, DBFunAcc, RecList}) ->
		DBFun = fun() ->
			player_items_db:t_delete_player_items(DelBaseId)
		end,
		NewBagItemAcc = dict:erase(TypeId, BagItemAcc),
		{NewBagItemAcc, [DBFun | DBFunAcc], [DelBaseId|RecList]}
	end, {BagItem, [], []}, DeleteRec).
%% 获取a u d 相关数据库操作 %%%%%

transc_items_reward_with_playerInfo(PlayerInfo, RewardList, RewardLogType) ->
	{Reward1, Deduct1} = combine_rewards(RewardList),
	Check1 = (Reward1 == [] andalso Deduct1 == []),
	Check2 = (rewards_item_id_correct(Reward1) andalso rewards_item_id_correct(Deduct1)),
	if
		Check1 ->
			{PlayerInfo, fun()-> skip end, fun() ->skip end, []};
		Check2 ->
			BagItem = item_util:get_dic_player_bag_dict(),
			OldRedPackNum = get_player_item_num(?ITEM_ID_RED_PACK),
			%?INFO_LOG("---------------------------------  ~p~n", [OldRedPackNum]),
			case deduct_item_enough(PlayerInfo, BagItem, Deduct1) of
				true->
					{NewPlayerInfo, AddItemRec, UpdateRec, DeleteRec} = amount_player_dict_items(PlayerInfo, BagItem, Reward1, Deduct1),
					{NewPlayerInfo2, UpdatePlayerInfoDBFun, UpdatePlayerInfoDBSuccessFun} = player_util:update_player_info_level_and_save(PlayerInfo, NewPlayerInfo),
					PlayerId = PlayerInfo#player_info.id,
					{NewBagItem1, DBFunAcc1, AddRecList} = get_trans_by_add_item(BagItem, PlayerId, AddItemRec),
					{NewBagItem2, DBFunAcc2, UpdRecList} = get_trans_by_upd_item(NewBagItem1, PlayerId, UpdateRec),
					{NewBagItem3, DBFunAcc3, DelRecList} = get_trans_by_del_item(NewBagItem2, PlayerId, DeleteRec),
					DBFun = fun() ->
						lists:foreach(fun(E) -> E() end, DBFunAcc1),
						lists:foreach(fun(E) -> E() end, DBFunAcc2),
						lists:foreach(fun(E) -> E() end, DBFunAcc3),
						UpdatePlayerInfoDBFun()
					end,

					SuccessFun = fun() ->
						item_util:update_dic_player_bag_dict(NewBagItem3),
						UpdatePlayerInfoDBSuccessFun(),
						item_util:send_add_items(AddRecList),
						item_util:send_update_items(UpdRecList),
						item_util:send_delete_items(DelRecList),
						if
							?REWARD_TYPE_AIRLABA_SYNC_TESTTYPE1 =/= RewardLogType andalso
							?REWARD_TYPE_AIRLABA_SYNC_TESTTYPE2 =/= RewardLogType ->
								%player_niu_room_util:syn_player_gold_num_to_room(RewardList),
								%player_hundred_niu_util:syn_player_gold_num_to_room(RewardList),
								%player_car_util:syn_player_gold_num_to_room(RewardList),
								do_rank_data_change(NewPlayerInfo#player_info.id, PlayerInfo, NewPlayerInfo, RewardLogType, OldRedPackNum),
								log_util:add_item_use(NewPlayerInfo2, RewardLogType, PlayerInfo#player_info.id, RewardList);
							true ->
								skip
						end,
						do_change_depot(Reward1 ++ Deduct1, RewardLogType)
					end,
					{NewPlayerInfo, DBFun, SuccessFun, get_pb_reward_info(Reward1)};
				_ ->
					?INFO_LOG("imme_items_reward deduct_item_enough FAIL!!!!:~p",
						[{?MODULE, ?LINE, PlayerInfo#player_info.id, RewardLogType, Deduct1,player_util:get_dic_player_info()}])
			end;
		true ->
			?INFO_LOG("imme_items_reward ItemId rewards_item_id_correct FAIL!!!!:~p",
				[{?MODULE, ?LINE, Reward1, Deduct1}])
	end.

%% 1合并同类项
%% 2检测奖励内容 奖励结构:[  {物品id, 数量} ],数量为零的不要传进来
%% 3预处理合并后的玩家物品信息
%% 4合并玩家dict数据
%% 5写记录and dict 发送add upd del消息
transc_items_reward(RewardList, RewardLogType) ->
	PlayerInfo = player_util:get_dic_player_info(),
	transc_items_reward_with_playerInfo(PlayerInfo, RewardList, RewardLogType).

do_transc_items_rank_and_log_sync(GoldChange, RedPackGet, RewardLogType) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		0 =/= GoldChange ->
			RewardListGold = [{?ITEM_ID_GOLD, GoldChange}],
			role_processor_mod:cast(self(),{'rank_change',PlayerInfo#player_info.id, ?RANK_TYPE_GOLD, PlayerInfo#player_info.gold});
		true ->
			RewardListGold = []
	end,
	if
		0 =/= RedPackGet ->
			RewardListRedPack = [{?ITEM_ID_RED_PACK, RedPackGet}],
			NewRedPackNum = get_player_item_num(?ITEM_ID_RED_PACK),
			role_processor_mod:cast(self(),{'rank_change',PlayerInfo#player_info.id, ?RANK_TYPE_REDPACK, NewRedPackNum});
		true ->
			RewardListRedPack = []
	end,
	RedwardList = RewardListGold ++ RewardListRedPack,
	case RedwardList of
		[] ->
			skip;
		_ ->
			log_util:add_item_use(PlayerInfo, RewardLogType, PlayerInfo#player_info.id, [])
	end.

%% 1.合并奖励 返回 {additems, delitems}
combine_rewards(RewardList) ->
	Combine1 =
		lists:foldl(fun({ItemId, Count}, Acc) ->
			MatchList =
			lists:filter(fun(E)->
				{EItemId,OldCount}= E,
				if
					EItemId == ItemId  andalso Count*OldCount >=0 ->
						true;
					true->
						false
				end
									 end,Acc),
			case MatchList of
				[]->
					[{ItemId, Count}|Acc];
				[{ItemId, OldCount}|_]->
					Acc1=lists:delete({ItemId, OldCount},Acc),
					[{ItemId, Count + OldCount}|Acc1]
			end end,[],RewardList),
	lists:foldl(fun({ItemId, Count}, {AccAdd, AccDel}) ->
		if
			Count == 0 ->
				{AccAdd, AccDel};
			Count > 0 ->
				{[{ItemId, Count}|AccAdd], AccDel};
			true ->
				{AccAdd, [{ItemId, Count}|AccDel]}
		end end, {[], []}, Combine1).


%% 2.检测错误id true=ok
rewards_item_id_correct(CombineReward) ->
	CheckList =
		lists:filter(fun({ItemId, _}) ->
			case item_base_db:get_base(ItemId) of
				{ok, [_ItemBase]} ->
					false;
				_ ->
					true
			end end, CombineReward),
	CheckList == [].


%% 3. 检测扣除物品是否足够 true = ok
deduct_item_enough(PlayerInfo, BagItem, DeductList) ->
	ItemGold = #player_items{
		entry = ?ITEM_ID_GOLD,               % BaseId
		count = PlayerInfo#player_info.gold
	},
	ItemDiamond = #player_items{
		entry = ?ITEM_ID_DIAMOND,               % BaseId
		count = PlayerInfo#player_info.diamond
	},
	ItemCash = #player_items{
		entry = ?ITEM_ID_CASH,               % BaseId
		count = PlayerInfo#player_info.cash
	},
	ItemBag1 = dict:store(?ITEM_ID_GOLD, ItemGold, BagItem),
	NewItemBag1 = dict:store(?ITEM_ID_DIAMOND, ItemDiamond, ItemBag1),
	NewItemBag = dict:store(?ITEM_ID_CASH, ItemCash, NewItemBag1),
	DeductList1 =
		lists:filter(fun({CostId, CostNum}) ->
			case dict:find(CostId, NewItemBag) of
				error ->
					true;
				{ok, ItemInfo} ->
					if
						ItemInfo#player_items.count + CostNum >= 0 ->
							false;
						true ->
							true
					end
			end end, DeductList),
	DeductList1 == [].


%% 4.获取相关dict中记录, 合并数量, 输出( add, update, delete )record
amount_player_dict_items(PlayerInfo, Bef_ItemBag, Reward, Deduct) ->
	%% 过滤奖励中的金币钻石
	{NewPlayerInfo1, UpdateItemAcc1, AddItemAcc1} =
		lists:foldl(fun({ItemBaseId, Num}, {PlayerAcc, UpdItemAcc, AddItemAcc}) ->
			case ItemBaseId of
				?ITEM_ID_GOLD ->
					if
						is_integer(Num) ->
							NewPlayerAcc = PlayerAcc#player_info{
								gold = compare_check(ItemBaseId, PlayerAcc#player_info.gold + Num)
							},
							{NewPlayerAcc, UpdItemAcc, AddItemAcc};
						is_list(Num) ->
							[{_,Num1}] = Num,
							NewPlayerAcc = PlayerAcc#player_info{
							gold = compare_check(ItemBaseId, PlayerAcc#player_info.gold + Num1)
							},
							{NewPlayerAcc, UpdItemAcc, AddItemAcc};
						true ->
							{PlayerAcc, UpdItemAcc, AddItemAcc}
					end;
				?ITEM_ID_DIAMOND ->
					NewPlayerAcc = PlayerAcc#player_info{
						diamond = compare_check(ItemBaseId, PlayerAcc#player_info.diamond + Num)
					},
					{NewPlayerAcc, UpdItemAcc, AddItemAcc};
				?ITEM_ID_PLAYER_EXP ->
					NewPlayerAcc = PlayerAcc#player_info{
						total_exp = compare_check(ItemBaseId, PlayerAcc#player_info.total_exp + Num)
					},
					{NewPlayerAcc, UpdItemAcc, AddItemAcc};
				?ITEM_ID_CASH ->
					NewPlayerAcc = PlayerAcc#player_info{
						cash = compare_check(ItemBaseId, PlayerAcc#player_info.cash + Num)
					},
					{NewPlayerAcc, UpdItemAcc, AddItemAcc};
				?ITEM_ID_RMB ->
					if
						PlayerAcc#player_info.is_robot ->
							RechargeNum = compare_check(ItemBaseId, PlayerAcc#player_info.recharge_money + Num),
							NewPlayerAcc = PlayerAcc#player_info{
								recharge_money = RechargeNum
							},
							{NewPlayerAcc, UpdItemAcc, AddItemAcc};
						true ->
							RechargeNum = compare_check(ItemBaseId, PlayerAcc#player_info.recharge_money + Num),
							NewPlayerAcc = PlayerAcc#player_info{
								recharge_money = RechargeNum,
								vip_level = player_vip_util:calc_new_vip_level(RechargeNum)
							},
%%							player_7_day_carnival_util:update_7_day_carnival_mission(7,NewPlayerAcc#player_info.vip_level),
							{NewPlayerAcc, UpdItemAcc, AddItemAcc}
					end;
				_ ->
					case dict:find(ItemBaseId, Bef_ItemBag) of
						error ->
							{PlayerAcc, UpdItemAcc, [{ItemBaseId, Num}|AddItemAcc]};
						{ok, OldItemInfo} ->
							NewNum = compare_check(ItemBaseId, Num + OldItemInfo#player_items.count),
							{PlayerAcc, [{ItemBaseId, NewNum}|UpdItemAcc], AddItemAcc}
					end
			end end, {PlayerInfo, [], []}, Reward),

	%% 过滤扣除中的金币钻石
	{NewPlayerInfo2, UpdateItemAcc2, DeleteItemAcc1} =
		lists:foldl(fun({CostBaseId, Num}, {PlayerAcc, UpdItemAcc, DelItemAcc}) ->
			case CostBaseId of
				?ITEM_ID_GOLD ->
					NewPlayerAcc = PlayerAcc#player_info{
						gold = compare_check(CostBaseId, PlayerAcc#player_info.gold + Num)
					},
					{NewPlayerAcc, UpdItemAcc, DelItemAcc};
				?ITEM_ID_DIAMOND ->
					NewPlayerAcc = PlayerAcc#player_info{
						diamond = compare_check(CostBaseId, PlayerAcc#player_info.diamond + Num)
					},
					{NewPlayerAcc, UpdItemAcc, DelItemAcc};
				?ITEM_ID_CASH ->
					NewPlayerAcc = PlayerAcc#player_info{
						cash = compare_check(CostBaseId, PlayerAcc#player_info.cash + Num)
					},
					{NewPlayerAcc, UpdItemAcc, DelItemAcc};
				_ ->
					case dict:find(CostBaseId, Bef_ItemBag) of
						error ->
							?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}]),
							{PlayerAcc, UpdItemAcc, DelItemAcc};
						{ok, OldItemInfo} ->
							NewNum = compare_check(CostBaseId, Num + OldItemInfo#player_items.count),
							if
								NewNum > 0 ->
									{PlayerAcc, [{CostBaseId, NewNum}|UpdItemAcc], DelItemAcc};
								true ->
									{PlayerAcc, UpdItemAcc, [{OldItemInfo#player_items.id, OldItemInfo#player_items.entry}|DelItemAcc]}
							end
					end
			end end, {NewPlayerInfo1, [], []}, Deduct),

	UpdateItemAcc3 = UpdateItemAcc1 ++ UpdateItemAcc2,
	{NewPlayerInfo2, AddItemAcc1, UpdateItemAcc3, DeleteItemAcc1}.

send_reward_mail(_PlayerId, _RewardList, _Title, _Content) ->
	ok.

compare_check(?ITEM_ID_GOLD, Num) ->
	max(0, min(?GOLD_NUM_LIMIT, Num));
compare_check(_ItemType, Num) ->
	max(0, min(?ITEM_NUM_LIMIT, Num)).


%% 记录排行榜
do_rank_data_change(PlayerId, OldPlayerInfo, NewPlayerInfo, RewardLogType, OldRedPackNum) when not OldPlayerInfo#player_info.is_robot ->
	do_rank_data_change2(PlayerId, OldPlayerInfo, NewPlayerInfo, RewardLogType, OldRedPackNum);
do_rank_data_change(_PlayerId, _OldPlayerInfo, _NewPlayerInfo, _RewardLogType, OldRedPackNum) ->
	ok.

do_rank_data_change2(PlayerId, OldPlayerInfo, NewPlayerInfo, RewardLogType, OldRedPackNum) ->
	if
		OldPlayerInfo#player_info.is_robot ->
			skip;
		true ->
			CheckFun =
				fun(DataType, OldPlayerInfo1, NewPlayerInfo1) ->
					case DataType of
						'gold' ->
							{?RANK_TYPE_GOLD,  OldPlayerInfo1#player_info.gold =/= NewPlayerInfo1#player_info.gold, NewPlayerInfo1#player_info.gold};
						% 'win_gold' ->
						% 	{?RANK_TYPE_WIN_GOLD, OldPlayerInfo1#player_info.gold < NewPlayerInfo1#player_info.gold andalso check_win_gold_reward_type(RewardLogType),
						% 		NewPlayerInfo1#player_info.gold - OldPlayerInfo1#player_info.gold};
						'diamond' ->
							{?RANK_TYPE_DIAMOND, OldPlayerInfo1#player_info.diamond < NewPlayerInfo1#player_info.diamond andalso not NewPlayerInfo1#player_info.is_robot andalso  check_win_diamond_reward_type(RewardLogType)
								, NewPlayerInfo1#player_info.diamond - OldPlayerInfo1#player_info.diamond};
						'redpack' ->
							NewRedPackNum = get_player_item_num(?ITEM_ID_RED_PACK),
							{?RANK_TYPE_REDPACK, NewRedPackNum =/= OldRedPackNum, NewRedPackNum};
						_ ->
							{"", false, 0}
					end end,
			lists:foreach(fun(EType) ->
				{EtsName, Flag, NewData} = CheckFun(EType, OldPlayerInfo, NewPlayerInfo),
				if
					NewPlayerInfo#player_info.is_robot ->
						skip;
					Flag ->
						%?INFO_LOG("player_data_change ~p~n",[PlayerId]),
						role_processor_mod:cast(self(),{'rank_change',PlayerId, EtsName, NewData});
%%				gen_server:cast(rank_mod:get_mod_pid(), {'player_data_change', PlayerId, EtsName, NewData});
					true ->
						skip
				end end, ['gold', 'diamond', 'redpack'])
	end.

%% 暂时没确定哪些类型要加入
check_win_gold_reward_type(RewardType) ->
	lists:member(RewardType, [
		?REWARD_TYPE_NIU_NIU_SETTLEMENT,
		?REWARD_TYPE_HUNDRED_NIU_SETTLEMENT,
		?REWARD_TYPE_HUNDRED_NIU_OPEN_POOL,
		?REWARD_TYPE_LABA,
		?REWARD_TYPE_SUPER_LABA,
		?REWARD_TYPE_CAR
	]).

%% 暂时没确定哪些类型要加入
 check_win_diamond_reward_type(RewardType) ->
 	lists:member(RewardType, [
 		?REWARD_TYPE_REDPACK_SETTLEMENT
 	]).

%% 3. 检测扣除物品是否足够 true = ok
check_item_enough(DeductList) ->
	PlayerInfo = player_util:get_dic_player_info(),
	BagItem = item_util:get_dic_player_bag_dict(),
	ItemGold = #player_items{
		entry = ?ITEM_ID_GOLD,               % BaseId
		count = PlayerInfo#player_info.gold
	},
	ItemDiamond = #player_items{
		entry = ?ITEM_ID_DIAMOND,               % BaseId
		count = PlayerInfo#player_info.diamond
	},
	ItemCash = #player_items{
		entry = ?ITEM_ID_CASH,               % BaseId
		count = PlayerInfo#player_info.cash
	},
	ItemBag1 = dict:store(?ITEM_ID_GOLD, ItemGold, BagItem),
	NewItemBag1 = dict:store(?ITEM_ID_DIAMOND, ItemDiamond, ItemBag1),
	NewItemBag = dict:store(?ITEM_ID_CASH, ItemCash, NewItemBag1),
	DeductList1 =
		lists:filter(fun({CostId, CostNum}) ->
			case dict:find(CostId, NewItemBag) of
				error ->
					true;
				{ok, ItemInfo} ->
					if
						ItemInfo#player_items.count + CostNum >= 0 ->
							false;
						true ->
							true
					end
			end end, DeductList),
	DeductList1 == [].

%% 获取数量
get_player_item_num(ItemId) ->
	PlayerInfo = player_util:get_dic_player_info(),
	BagItem = item_util:get_dic_player_bag_dict(),
	ItemGold = #player_items{
		entry = ?ITEM_ID_GOLD,               % BaseId
		count = PlayerInfo#player_info.gold
	},
	ItemDiamond = #player_items{
		entry = ?ITEM_ID_DIAMOND,               % BaseId
		count = PlayerInfo#player_info.diamond
	},
	ItemCash = #player_items{
		entry = ?ITEM_ID_CASH,               % BaseId
		count = PlayerInfo#player_info.cash
	},
	ItemBag1 = dict:store(?ITEM_ID_GOLD, ItemGold, BagItem),
	NewItemBag1 = dict:store(?ITEM_ID_DIAMOND, ItemDiamond, ItemBag1),
	NewItemBag = dict:store(?ITEM_ID_CASH, ItemCash, NewItemBag1),
	case dict:find(ItemId, NewItemBag) of
		error ->
			0;
		{ok, ItemInfo} ->
			ItemInfo#player_items.count
	end.

%% 改动库存金币
do_change_depot(RewardList, RewardLogType) ->
	CheckList = lists:filter(fun({EId, _}) -> EId == ?ITEM_ID_GOLD end, RewardList),
	case CheckList of
		[{?ITEM_ID_GOLD, RewardNum}] ->
			if
				RewardNum > 0 ->
					case check_type_is_deduce_depot(RewardLogType) of
						true ->
							depot_manager_mod:add_to_depot(-RewardNum);
						_ ->
							skip
					end;
				RewardNum < 0 ->
					case check_type_is_add_depot(RewardLogType) of
						true ->
							depot_manager_mod:add_to_depot(-RewardNum);
						_ ->
							skip
					end;
				true ->
					skip
			end;
		_ ->
			skip
	end.


%% 需减少库存
%% ai------- ai每日分配金币
%% Activty--------- 活动获得
%% back_stage_manage_depot---- 后台控制
check_type_is_deduce_depot(RewardLogType) ->
	lists:member(RewardLogType, [
		?REWARD_TYPE_BINDING_PHONE,
		?REWARD_TYPE_CHECKIN,
		?REWARD_TYPE_VIP_SEPCIAL_REWARD,
		?REWARD_TYPE_SUBSIDY,
		?REWARD_TYPE_MISSION,

		?REWARD_TYPE_PRIZE_EXCHANGE,
		?REWARD_TYPE_MAIL,
		?REWARD_TYPE_ROBOT_MASTER_SUPPLY_ADD,
		?REWARD_TYPE_LABA,
		?REWARD_TYPE_SHOP,
		?REWARD_TYPE_GUIDE_DRAW,
		?MAIL_TYPE_GM_SEND_TO_ALL,
		?MAIL_TYPE_GM_SEND_TO_SINGLE,
		?REWARD_TYPE_ROBOT
	]).

%% 需增加库存
%% red_pack-------- ok
%% hundred_add_to_pool------ ok
%% five_settlement_back--------- ok
check_type_is_add_depot(RewardLogType) ->
	lists:member(RewardLogType, [
		?REWARD_TYPE_CHAT_MAGIC_COST,
		?REWARD_TYPE_NIU_NIU_ENTER_COST,
		?REWARD_TYPE_NIU_ROOM_CHEST,
		?REWARD_TYPE_ROBOT_MASTER_SUPPLY_DEDUCE,
		?REWARD_TYPE_LABA
	]).

check_robot_gold_add(NewPlayerInfo2, _RewardLogType) ->
	if
		NewPlayerInfo2#player_info.is_robot ->
			gen_server:cast(robot_manager:get_mod_pid(), {'robot_level_change', NewPlayerInfo2#player_info.id, NewPlayerInfo2#player_info.gold});
		true ->
			skip
	end.

update_robot_level() ->
	PlayerInfo = player_util:get_dic_player_info(),
	case PlayerInfo#player_info.is_robot of
		true ->
			gen_server:cast(robot_manager:get_mod_pid(), {'robot_level_change', PlayerInfo#player_info.id, PlayerInfo#player_info.gold});
		_ ->
			skip
	end.
