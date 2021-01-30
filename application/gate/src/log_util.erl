%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 四月 2017 16:51
%%%-------------------------------------------------------------------
-module(log_util).
-include("common.hrl").
-include("mysql_log.hrl").

-define(ADD_LOG_ITEM_TYPE_LIST, [
	?ITEM_ID_GOLD,
	?ITEM_ID_DIAMOND,
	?ITEM_ID_CASH,
	?ITEM_ID_PHONE_CARD_100,
	?ITEM_ID_RED_PACK
]).		%% 需要日志记录的物品

-define(HTTP_LOG_GOLD_TYPE_LIST, [
	?REWARD_TYPE_NIU_NIU_SETTLEMENT,
	?REWARD_TYPE_NIU_NIU_ENTER_COST,
	?REWARD_TYPE_HUNDRED_NIU_SETTLEMENT,
	?REWARD_TYPE_HUNDRED_NIU_OPEN_POOL,
	?REWARD_TYPE_REDPACK_SETTLEMENT,
	?REWARD_TYPE_CHAT_MAGIC_COST,
	?REWARD_TYPE_MAIL,
	?REWARD_TYPE_MISSION,
	?REWARD_TYPE_SHOP,
	?REWARD_TYPE_SUBSIDY,
	?REWARD_TYPE_RECHARGE_DIAMOND,
	?REWARD_TYPE_LABA,
	?REWARD_TYPE_RED_PACK,
	?REWARD_TYPE_VIP_SEPCIAL_REWARD,
	?REWARD_TYPE_CHANGE_NAME,
	?REWARD_TYPE_BINDING_PHONE,
	?REWARD_TYPE_PRIZE_EXCHANGE,
	?REWARD_TYPE_RED_PACK_ROOM_DRAW,
	?REWARD_TYPE_RED_PACK_ROOM_REWARD_DIAMOND,
	?REWARD_TYPE_GAME_TASK_LABA_MISSION,
	?REWARD_TYPE_GAME_TASK_LABA_BOX,
	?REWARD_TYPE_GAME_TAST_NIU_MISSION,
	?REWARD_TYPE_GAME_TAST_NIU_BOX,
	?REWARD_TYPE_MONTHCARD_DRAW,
	?REWARD_TYPE_CHECKIN,
	?REWARD_TYPE_GUIDE_DRAW,
	?REWARD_TYPE_NEWBIE_REWARD
]).		%% 需要同步给后台的金币变动类型

%% API
-export([
	add_gm_oprate/3,
	add_item_use/4,
	add_prize_exchange/3,
	add_prize_exchange_err/4,
	add_hundred_settlement/7,
	add_car_settlement/7,
	check_post_gold_log/5
]).

%% 记录成功失败 gm命令
add_gm_oprate(TabName, GmType, GmStr) ->
	%% 记录结构 log类型, time, 描述
	Record = {
		atom_to_list(GmType),	%% log类型
		append_comma(GmStr),
		util:get_date_time_str(calendar:local_time())		%% 日期
	},
	ets:insert(TabName, Record).

append_comma(GmStr) ->
	lists:concat(lists:foldl(fun(E, Acc) ->Acc ++ [E, " , "] end, [], GmStr)).


add_item_use(PlayerInfo, UseType, RoleId, RewardList) ->
	Date1 = calendar:local_time(),
	NowSecond = util:datetime_to_seconds(Date1),
	Date = util:get_date_time_str(Date1),
	lists:foreach(fun({ItemId, ItemNum}) ->
		case lists:member(ItemId, ?ADD_LOG_ITEM_TYPE_LIST) of
			true ->
				if
					is_integer(ItemNum) ->
						ItemNumInsert = ItemNum;
					is_list(ItemNum) ->
						[{_,ItemNumInsert}|_] = ItemNum;
					true ->
						?INFO_LOG("add_item_use~p~n",[{UseType, ItemNum}]),
						ItemNumInsert = 0
				end,
				add_item_use(UseType, RoleId, ItemId, ItemNumInsert, Date),
				case ItemId of
					?ITEM_ID_CASH ->
						http_static_util:post_ticket_log(PlayerInfo, UseType, ItemNum, get_cost_or_reward(ItemNum), NowSecond);
					?ITEM_ID_GOLD ->
						check_post_gold_log(PlayerInfo, UseType, ItemNum, get_cost_or_reward(ItemNum), NowSecond);
					?ITEM_ID_DIAMOND ->
						http_static_util:post_diamond_log(PlayerInfo, UseType, ItemNum, get_cost_or_reward(ItemNum), NowSecond);
					?ITEM_ID_RED_PACK->
						http_static_util:post_redbag_log(PlayerInfo, ItemId, ItemNum, UseType, NowSecond);
					_ ->
						skip
				end;
			_ ->
				skip
		end end, RewardList).

get_cost_or_reward(ItemNum) ->
	if
		is_list(ItemNum) ->
			[{_,ItemNum1}|_] = ItemNum,
			if
				ItemNum1 > 0 ->
					1;
				true ->
					2
			end;
		true ->
			if
				ItemNum > 0 ->
					1;
				true ->
					2
			end
	end.

check_post_gold_log(PlayerInfo, UseType, ItemNum, Type, NowSecond) ->
	if
		is_list(ItemNum) ->
			[{_,ItemNum1}|_] = ItemNum,
			http_static_util:post_gold_log(PlayerInfo, UseType, ItemNum1, Type, NowSecond);
		is_integer(ItemNum) ->
			http_static_util:post_gold_log(PlayerInfo, UseType, ItemNum, Type, NowSecond);
		true ->
			?INFO_LOG("check_post_gold_log~p~n",[{UseType, ItemNum,PlayerInfo}]),
			skip
	end.
%% 	case lists:member(UseType, ?HTTP_LOG_GOLD_TYPE_LIST) of
%% 		true ->
%% 			http_static_util:post_gold_log(PlayerInfo, UseType, ItemNum, Type, NowSecond);
%% 		_ ->
%% 			skip
%% 	end.


%% 记录玩家物品操作(包括金币等变动)
add_item_use(UseType, RoleId, ItemId, ItemNum, Date) ->
	%% 位置需按mysql表字段顺序
	Record = {
		RoleId,		%% 玩家id
		UseType,	%% log类型
		ItemId,		%% 物品id
		ItemNum,
		Date		%% 日期
	},
	ets:insert(?MLOG_ETS_ITEM_USE, Record).

%% 记录玩家物品操作(包括金币等变动)
add_prize_exchange(RoleId, ItemId, Date) ->
	%% 位置需按mysql表字段顺序
	Record = {
		RoleId,		%% 玩家id
		ItemId,		%% 物品id
		Date		%% 日期
	},
	ets:insert(?MLOG_ETS_PRIZE_EXCHANGE, Record).

%% 记录玩家物品操作错误(包括金币等变动)
add_prize_exchange_err(RoleId, ItemId, Date, Err) ->
	%% 位置需按mysql表字段顺序
	Record = {
		RoleId,		%% 玩家id
		ItemId,		%% 物品id
		Date,		%% 日期
		Err			%% 错误
	},
	ets:insert(?MLOG_ETS_PRIZE_EXCHANGE_ERR, Record).

%% 记录玩家物品操作(包括金币等变动)
add_hundred_settlement(RoomId, TimesId, RateList, TotalSetList, RealSetList, MasterWin, Date) ->
	skip.
	% %% 位置需按mysql表字段顺序
	% [Rate1, Rate2, Rate3, Rate4] = RateList,
	% TotalSetList1=
	% 	lists:foldl(fun(E, Acc) ->
	% 		case lists:keyfind(E, 1, Acc) of
	% 			false ->
	% 				[{E, 0}|Acc];
	% 			_ ->
	% 				Acc
	% 		end end, TotalSetList, [1,2,3,4]),
	% RealSetList1=
	% 	lists:foldl(fun(E, Acc) ->
	% 		case lists:keyfind(E, 1, Acc) of
	% 			false ->
	% 				[{E, 0}|Acc];
	% 			_ ->
	% 				Acc
	% 		end end, RealSetList, [1,2,3,4]),

	% [{_,TotalSet1}, {_,TotalSet2}, {_,TotalSet3}, {_,TotalSet4}] = lists:keysort(1,TotalSetList1),
	% [{_,RealSet1}, {_,RealSet2}, {_,RealSet3}, {_,RealSet4}] = lists:keysort(1,RealSetList1),
	% Record = {
	% 	RoomId,
	% 	TimesId,
	% 	lists:concat([Rate1, ",", Rate2, ",", Rate3, ",", Rate4]),
	% 	lists:concat([TotalSet1, ",", TotalSet2, ",", TotalSet3, ",", TotalSet4]),
	% 	lists:concat([RealSet1, ",", RealSet2, ",", RealSet3, ",", RealSet4]),
	% 	MasterWin,
	% 	Date
	% },
	% ets:insert(?MLOG_ETS_HUNDRED_SETTLEMENT, Record).

%% 豪车结算
add_car_settlement(RoomId, TimesId, TotalSetList, PlayerSetList, {Result,Index}, PoolRewardNum, Date) ->
	%% 位置需按mysql表字段顺序

	[{_,TotalSet1}, {_,TotalSet2}, {_,TotalSet3}, {_,TotalSet4}, {_,TotalSet5}, {_,TotalSet6}, {_,TotalSet7}, {_,TotalSet8}] = lists:keysort(1,TotalSetList),
	[{_,PlayerSet1}, {_,PlayerSet2}, {_,PlayerSet3}, {_,PlayerSet4}, {_,PlayerSet5}, {_,PlayerSet6}, {_,PlayerSet7}, {_,PlayerSet8}] = lists:keysort(1,PlayerSetList),
	Record = {
		RoomId,
		TimesId,
		lists:concat([TotalSet1, ",", TotalSet2, ",", TotalSet3, ",", TotalSet4,",", TotalSet5,",", TotalSet6,",", TotalSet7,",", TotalSet8]),
		lists:concat([PlayerSet1, ",", PlayerSet2, ",", PlayerSet3, ",", PlayerSet4, ",", PlayerSet5, ",", PlayerSet6, ",", PlayerSet7, ",", PlayerSet8]),
		Result,
		Index,
		PoolRewardNum,
		Date
	},
	ets:insert(?MLOG_ETS_CAR_SETTLEMENT, Record).