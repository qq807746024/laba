%% @author zouv
%% @doc @todo 物品操作

-module(item_util).

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/item_pb.hrl").

-export([

		 create_item_info/3,
		 get_dic_player_bag_dict/0,
		 update_dic_player_bag_dict/1,
		 get_dic_player_item_info/1,
		 update_dic_player_item_info/1,

		 get_item_num_by_item_base_id/1,
		 
		 %% 发送更新
		 send_add_items/1,
         send_update_items/1,
		 send_delete_items/1,
		 send_bag_update/0,
		 check_contain_gold_reward/1

		]).

create_item_info(PlayerId, BaseId, Count) ->
	{ok, [ItemBase]} = item_base_db:get_base(BaseId),
	NowSeconds = util:now_seconds(),
	#player_items{
				  id = roleid_generator:get_auto_item_id(),
				  player_id = PlayerId,
				  entry = ItemBase#item_base.id,
				  count = Count,
				  create_time = NowSeconds
				 }.

%% --------------- 背包物品 ---------------
get_dic_player_bag_dict() ->
	get(?DIC_PLAYER_BAG_INFO).

update_dic_player_bag_dict(BagDict) ->
	put(?DIC_PLAYER_BAG_INFO, BagDict).

get_dic_player_item_info(BaseId) ->
	BagDict = get_dic_player_bag_dict(),
	case dict:find(BaseId, BagDict) of
		{ok, ItemInfo} ->
			ItemInfo;
		_ ->
			[]
	end.

update_dic_player_item_info(ItemInfo) ->
	ItemId = ItemInfo#player_items.entry,
	BagDict = get_dic_player_bag_dict(),
	NewBagDict = dict:store(ItemId, ItemInfo, BagDict),
	update_dic_player_bag_dict(NewBagDict).

get_item_num_by_item_base_id(ItemBaseID) ->
	case get_dic_player_item_info(ItemBaseID) of
		[] ->
			0;
		ItemInfo ->
			ItemInfo#player_items.count
	end.


send_add_items(List)->
	case List of
		[] ->
			skip;
		_ ->
			case player_util:get_dic_gate_pid() of
				undefined ->
					void;
				GatePid ->
					Units=
						lists:map(fun(EItemInfo)->
							packet_item(EItemInfo)
						end,List),
					ScItemUpdate = #sc_items_add{add_list = Units},
					tcp_client:send_data(GatePid, ScItemUpdate)
			end
	end.

send_update_items(List)->
	case List of
		[] ->
			skip;
		_ ->
			case player_util:get_dic_gate_pid() of
				undefined ->
					void;
				GatePid ->
					Units=
						lists:map(fun(EItemInfo)->
							packet_item(EItemInfo)
						end,List),
					ScItemUpdate = #sc_items_update{upd_list = Units},
					tcp_client:send_data(GatePid, ScItemUpdate)
			end
	end.

send_delete_items(IdList)->
	case IdList of
		[] ->
			skip;
		_ ->
			case player_util:get_dic_gate_pid() of
				undefined ->
					void;
				GatePid ->
					%?INFO_LOG("Delete ~p~n",[IdList]),
					UuidList = lists:map(fun(E)->
						{ok, Uuid} = id_transform_util:item_id_to_proto(E),
						Uuid end,IdList),
					ScDeleteItem  = #sc_items_delete{del_list = UuidList},
					tcp_client:send_data(GatePid, ScDeleteItem)
			end
	end.


%% 发送背包信息
send_bag_update() ->
	GatePid = player_util:get_dic_gate_pid(),
	case GatePid of
		undefined ->
			ok;
		_ ->
			BagDict = get_dic_player_bag_dict(),
			ItemList = dict:to_list(BagDict),
			Units=
				lists:map(fun({_, EItemInfo})->
					packet_item(EItemInfo)
					end,ItemList),
			Msg = #sc_items_init_update{all_list = Units},
			tcp_client:send_data(GatePid, Msg)
	end.

packet_item(ItemInfo) ->
	#player_items{
		id = Id,
		entry = BaseId,               % BaseId
		count = Count
	} = ItemInfo,
	{ok, Uuid} = id_transform_util:item_id_to_proto(Id),
	#pb_item_info{
		uuid = Uuid,
		base_id = BaseId,
		count = Count
	}.

check_contain_gold_reward(RewardList) ->
	GoldReward =
		lists:foldl(fun({ItemId, Num}, Acc) ->
			if
				ItemId == ?ITEM_ID_GOLD ->
					Num+Acc;
				true ->
					Acc
			end end, 0, RewardList),
	if
		GoldReward == 0 ->
			false;
		true ->
			{true, GoldReward}
	end.