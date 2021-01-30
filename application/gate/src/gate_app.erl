-module(gate_app).

-behaviour(application).

-include("common.hrl").
-include("laba.hrl").

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

%% Application callbacks
-export([start/2, stop/1]).
-export([
	refresh_ets_data/0,
	init_const_config/0,
	init_ets_redpack_rotation/0,
	init_ets_share_times_limit/0,
	init_ets_shop_item/0,
	init_ets_mission_base/0,
	new_ets_mission_base/0,
	init_ets_lucky_bag/0,
	init_ets_activity_chnid_config/3,
	initets_laba_and_slaba_rate_config/0,
	init_ets_fruit_pool_config/0,
	init_ets_bet_stickiness_redpack_config/0,
	init_ets_bet_lock/0,
	init_ets_fruit_fresher_protect_config/0,
	init_ets_fruit_fresher_welfare_config/0,
	init_ets_lottery_config/0
]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start(_StartType, _StartArgs) ->
	{ok, Pid} = gate_sup:start_link(),
	%% 初始化mysql連接池
	init_mysql(),

	%% 初始化ets
	init_ets(),
	init_ets_data(),
	start_local_mod(),

	%% 性能统计
	%tools:eprof_start(),
	{ok, Pid}.

init_mysql()->
	{mysql_server_info, Host, Port, Username, Password, DatabaseName} = config_mysql:get_statistics_server_info(),
	{ok, _} = mysql:connect(p3, Host, Port, Username, Password, DatabaseName, true).

stop(_State) ->
%% 	tools_operation:write_to_db_close_server_time(),
	%% 通知每个房间停止继续
	notice_all_room_close(),
	config_app:set_online_limit(0),
	ntools:kick_player_all(),
	%% 牛牛房间 百人 豪车关闭 直接等待30s再关闭
	NowSecond1 = util:now_seconds(),
	%% mysql log 刷入
	statistic_server:total_export_to_mysql(),
	NowSecond2 = util:now_seconds(),
	LastWaitSecond = min(30, 30 - (NowSecond2-NowSecond1)),
	io:format("Wating ~p Second", [LastWaitSecond]),
	timer:sleep(LastWaitSecond*1000),
	ok.

%% 初始化ets
init_ets() ->
	ets:new(?ETS_ONLINE, [{keypos, #ets_online.player_id}, named_table, set, public]),
	ets:new(?ETS_ROLE_PID, [{keypos, #ets_role_pid.player_id}, named_table, set, public]),
	ets:new(?ETS_SHOP_ITEM, [{keypos, #base_shop_item.id}, named_table, ordered_set, public]),
	%% 玩家对应信息
	ets:new(?ETS_NIUNIU_PLAYER_IN_GAME, [{keypos, #player_niu_room_info.player_id}, named_table, set, public]),

	ets:new(?ETS_LABA_PLAYER_INFO, [{keypos, #ets_laba_player_info.player_id}, named_table, set, public]),
	ets:new(?ETS_SUPER_LABA_PLAYER_INFO, [{keypos, #ets_laba_player_info.player_id}, named_table, set, public]),
	ets:new(?ETS_LABA_FRUIT_CONFIG, [{keypos, #laba_fruit_config.key}, named_table, ordered_set, public]),
	ets:new(?ETS_SUPER_LABA_FRUIT_CONFIG, [{keypos, #super_fruit_config.key}, named_table, ordered_set, public]),

	ets:new(?ETS_RANK_GOLD_1, [{keypos, #ets_rank_player_info.key}, named_table, ordered_set, public]),
	ets:new(?ETS_RANK_PROFIT_2, [{keypos, #ets_rank_player_info.key}, named_table, ordered_set, public]),
	ets:new(?ETS_RANK_DIAMOND_3, [{keypos, #ets_rank_player_info.key}, named_table, ordered_set, public]),

	ets:new(?ETS_DAILY_EARN_GOLD_RANK_REWARD_CONFIG, [{keypos, #daily_earn_gold_rank_reward_config.key}, named_table, ordered_set, public]),
	ets:new(?ETS_PRIZE_STORAGE_INFO, [{keypos, #prize_storage_info.id}, named_table, ordered_set, public]),

	ets:new(?ETS_GOLD_DEPOT_INFO, [{keypos, #gold_depot_info.id}, named_table, set, public]),
	ets:new(?ETS_RED_PACK, [{keypos, #red_pack_info.id}, named_table, ordered_set, public]),
	ets:new(?ETS_PLAYER_RED_PACK_SEARCH_KEY, [{keypos, #ets_player_red_pack_search_key.player_id}, named_table, ordered_set, public]),

	ets:new(?ETS_REDPACK_ROOM_CONFIG, [{keypos, #redpack_room_config.key}, named_table, set, public]),

	ets:new(?ETS_CONST_CONFIG, [{keypos, #const_config.key}, named_table, ordered_set, public]),

	ets:new(?ETS_BASE_ITEM, [{keypos, #ets_base_item.base_id}, named_table, set, public]),

	ets:new(?MLOG_ETS_GM_error, [named_table, duplicate_bag, public]),
	ets:new(?MLOG_ETS_GM_success, [named_table, duplicate_bag, public]),
	ets:new(?MLOG_ETS_ITEM_USE, [named_table, duplicate_bag, public]),
	ets:new(?MLOG_ETS_PRIZE_EXCHANGE, [named_table, duplicate_bag, public]),
	ets:new(?MLOG_ETS_PRIZE_EXCHANGE_ERR, [named_table, duplicate_bag, public]),
	ets:new(?ETS_SHARE_CODE, [{keypos, #ets_share_code.code}, named_table, set, public]),

	ets:new(?ETS_LUCKY_BAG, [{keypos, #ets_lucky_bag.id}, named_table, set, public]), % 红包奖池
	ets:new(?ETS_REDPACK_ROTATION, [{keypos, #ets_lucky_bag.id}, named_table, set, public]),  % 所存数据没有意义，只要key不同2,5,10

	ets:new(?ETS_SHARE_TIMES_LIMIT, [{keypos, #ets_lucky_bag.id}, named_table, set, public]), % 分享次数限制 key => 分享码， num => 次数
%%	ets:new(?ETS_RANK_RECHARGE_ACTIVITY, [{keypos, #ets_rank_player_info.key}, named_table, ordered_set, public]),

	ets:new(?ETS_MISSION_BASE, [{keypos, #player_mission_base.id}, named_table, set, public]), %
	ets:new(?ETS_ACTIVITY_CHNID_CONFIG, [{keypos, #ets_data.key}, named_table, set, public]), %
	ets:new(?ETS_ACTIVITY_GOLD_CHNID_CONFIG, [{keypos, #ets_data.key}, named_table, set, public]),

	ets:new(?ETS_LAST_WIN_POOL_PLAYER, [{keypos, #ets_data.key}, named_table, ordered_set, public]),
	ets:new(?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER, [{keypos, #ets_data.key}, named_table, ordered_set, public]),

	ets:new(?ETS_RANK_MOD_TIME_CACHE, [{keypos, #ets_data.key}, named_table, ordered_set, public]),

	lists:foreach(fun(EtsName) ->
		ets:new(EtsName, [{keypos, #ets_data.key}, named_table, set, public])
	end, ?LABA_RATE_EST_MAPLIST),
	lists:foreach(fun(EtsName) ->
		ets:new(EtsName, [{keypos, #ets_data.key}, named_table, set, public])
	end, ?LABA_TESTTYPE2_RATE_EST_MAPLIST),
	lists:foreach(fun(EtsName) ->
		ets:new(EtsName, [{keypos, #ets_data.key}, named_table, set, public])
	end, ?SUPER_LABA_RATE_EST_MAPLIST),
	lists:foreach(fun(EtsName) ->
		ets:new(EtsName, [{keypos, #ets_data.key}, named_table, set, public])
	end, ?SUPER_LABA_TESTTYPE2_RATE_EST_MAPLIST),
	
	ets:new(?ETS_LABA_POOL_REWARD_CONFIG_LIST,[{keypos, #laba_pool_reward_config.key}, named_table, set, public]),
	ets:new(?ETS_LABA_CONST_LIST,[{keypos, #laba_const_config.key}, named_table, set, public]),
	ets:new(?ETS_FRUIT_POOL_CONFIG, [{keypos, #fruit_pool_config.key}, named_table, set, public]),
	ets:new(?ETS_BET_STICKINESS_REDPACK_CONFIG, [{keypos, #bet_stickiness_redpack_config.key}, named_table, set, public]),
	ets:new(?ETS_BET_LOCK_CONFIG, [{keypos, #player_bet_lock_config.key}, named_table, set, public]),
	ets:new(?ETS_FRUIT_FRESHER_PROTECT_CONFIG, [{keypos, #fruit_fresher_protect_config.id}, named_table, set, public]),
	ets:new(?ETS_SUPER_FRUIT_FRESHER_PROTECTED_CONFIG, [{keypos, #fruit_fresher_protect_config.id}, named_table, set, public]),
	ets:new(?ETS_FRUIT_FRESHER_WELFARE_CONFIG, [{keypos, #fruit_fresher_welfare_config.key}, named_table, set, public]),
	ets:new(?ETS_SUPER_FRUIT_FRESHER_WELFARE_CONFIG, [{keypos, #fruit_fresher_welfare_config.key}, named_table, set, public]),
	ets:new(?ETS_LOTTERY_CONFIG, [{keypos, #lottery_config.id}, named_table, set, public]),
	ets:new(?ETS_LOTTERY_CONFIG_PROTO_PACKED, [{keypos, #ets_lottery_reward_items.index}, named_table, set, public]),
	ok.

init_ets_data() ->
	init_ets_shop_item(),
	init_ets_base_item(),
	init_ets_share_code(),
	init_ets_redpack_rotation(),
	init_ets_lucky_bag(),
	init_ets_share_times_limit(),
	init_ets_mission_base(),
	init_ets_activity_chnid_config(),
	init_ets_activity_gold_chnid_config(),
	init_ets_laba_win_player(),
	initets_laba_and_slaba_rate_config(),
	init_ets_fruit_pool_config(),
	init_ets_bet_stickiness_redpack_config(),
	init_ets_bet_lock(),
	init_ets_fruit_fresher_protect_config(),
	init_ets_fruit_fresher_welfare_config(),
	init_ets_lottery_config().

%% 更新配置需要刷新ets，调用此接口
refresh_ets_data() ->
	init_ets_shop_item(),
	init_ets_base_item(),
	ok.

%% 开启本地进程
start_local_mod() ->
	% 目前关闭了百人和豪车
	GlobalModList = [
		sys_notice_mod,
		depot_manager_mod,
		mutisrv_shared_deport_mod,
		test_result_manager_mod,
		http_send_mod,
		
		laba_mod,
		red_pack_mod,
		base_config_mod,
		prize_mod,

		%redpack_notice_mod,
		diamond_fudai_mod,
		rank_mod,
		daily_rank_reward_mod
	],
	lists:foreach(fun(Module) ->
		misc:get_mod_pid(Module) end, GlobalModList),
	if
		1 =:= ?SUPERFRUIT ->
			?INFO_LOG("--------------------------------~nAIR SUPERFRUIT AIR~n");
		true ->
			?INFO_LOG("Not support Server Type~n"),
			stop(undefined)
	end.
	%[misc:get_mod_pid(Module) || Module <- GlobalModList].

%%% 开启跨节点进程
%start_global_mod() ->
%	skip.
%%%     GlobalModList = [
%%%                      dup_mine_mod_s         % 采矿
%%%                     ],
%%%     [misc:get_global_mod_pid(Module) || Module <- GlobalModList].
%
%%% 开启跨服进程
%start_cross_mod() ->
%	skip.
%%%     case config_app:get_server_id() == config_app:get_cross_server_id() of
%%%         true ->
%%%             CrossModList = [
%%%                             dup_mine_mod     % 采矿
%%% 							% @todo
%%% 							%,ladder_pvp_mod   % 巅峰竞技场
%%%                            ],
%%%             [misc:get_cross_mod_pid(Module) || Module <- CrossModList];
%%%         _ ->
%%%             skip
%%%     end.

init_ets_shop_item() ->
	ets:delete_all_objects(?ETS_SHOP_ITEM),
	{ok, List} = base_shop_item_db:get_list(),
	?INFO_LOG("~p~n", [List]),
	NowSec = util:now_seconds(),
	NewItemList =
		lists:filter(fun(E) ->
			if
				E#base_shop_item.end_time == 0 orelse E#base_shop_item.start_time == 0 ->
					true;
				true ->
					not (E#base_shop_item.end_time =< NowSec)
			end
		end, List),
	lists:foreach(fun(E) ->
		ets:insert(?ETS_SHOP_ITEM, E) end, NewItemList),
	%% 红包场配置提交
	{ok, [RedPackRoomConfig]} = redpack_room_config_db:get_base(1),
	ets:insert(?ETS_REDPACK_ROOM_CONFIG, RedPackRoomConfig),

	%% 常量表
	{ok, ConstList} = const_config_db:get_list(),
	lists:foreach(fun(ERec) ->
		ets:insert(?ETS_CONST_CONFIG, ERec) end, ConstList),

	ok.


%% 初始化ETS：hero_item
init_ets_base_item() ->
	ets:delete_all_objects(?ETS_BASE_ITEM),
	List = item_base_db:get_base(),
	Fun =
		fun(E) ->
			#item_base{
				id = EBaseId,
				cls = ECls
			} = E,
			case ets:member(?ETS_BASE_ITEM, EBaseId) of
				true ->
					skip;
				_ ->
					EtsBaseItem =
						#ets_base_item{
							base_id = EBaseId,
							cls = ECls
						},
					ets:insert(?ETS_BASE_ITEM, EtsBaseItem)
			end
		end,
	util:foreach(Fun, List).

init_ets_share_code()->
	List = player_share_info_db:get(),
	lists:map(fun(E)->
		EtsCode = #ets_share_code{
			code = E#player_share_info.my_code,
			player_id = E#player_share_info.player_id
		},
		ets:insert(?ETS_SHARE_CODE,EtsCode) end,List).

notice_all_room_close() ->
	ok.

init_const_config() ->
	%% 常量表
	{ok, ConstList} = const_config_db:get_list(),
	lists:foreach(fun(ERec) ->
		ets:insert(?ETS_CONST_CONFIG, ERec) end, ConstList).

init_ets_redpack_rotation()->
	ets:delete_all_objects(?ETS_REDPACK_ROTATION),
	lists:map(fun(E) ->
		Info = #ets_lucky_bag{
			id = E
		},
		ets:insert(?ETS_REDPACK_ROTATION,Info)
						end,[2,5,10]).

init_ets_lucky_bag()->
	ets:delete_all_objects(?ETS_LUCKY_BAG),
	Info1 =
	case lucky_bag_pool_db:get(1) of
		{ok,[Info]}->
			Info;
		_->
			#lucky_bag_pool{
				id = 1,
				num = 0
			}
	end,
	ets:insert(?ETS_LUCKY_BAG,#ets_lucky_bag{id = 1,num = Info1#lucky_bag_pool.num}).

init_ets_share_times_limit()->
	ets:delete_all_objects(?ETS_SHARE_TIMES_LIMIT).


init_ets_mission_base()->
	ets:delete_all_objects(?ETS_MISSION_BASE),
	{ok,List} = player_mission_base_db:get(),
	lists:foreach(fun(E) ->
		ets:insert(?ETS_MISSION_BASE,E) end,List).

new_ets_mission_base()->
	ets:new(?ETS_MISSION_BASE, [{keypos, #player_mission_base.id}, named_table, set, public]).

init_ets_activity_chnid_config() ->
	case activity_chnid_config_db:get(1) of
		{ok,[Info]}->
			init_ets_activity_chnid_config(?ETS_ACTIVITY_CHNID_CONFIG,Info#activity_chnid_config.chnid_list,Info#activity_chnid_config.time);
		_->
			init_ets_activity_chnid_config(?ETS_ACTIVITY_CHNID_CONFIG,[],util:now_seconds())
	end.

init_ets_activity_chnid_config(EtsName,ChnidList,Time)->
	ets:delete_all_objects(EtsName),
	lists:foreach(fun({K,V}) -> ets:insert(EtsName,#ets_data{key = K,value = V}) end,[{time,Time}|ChnidList]).

init_ets_activity_gold_chnid_config()->
	case activity_gold_chnid_config_db:get(1) of
		{ok,[Info]}->
			init_ets_activity_chnid_config(?ETS_ACTIVITY_GOLD_CHNID_CONFIG,Info#activity_gold_chnid_config.chnid_list,Info#activity_gold_chnid_config.time);
		_->
			init_ets_activity_chnid_config(?ETS_ACTIVITY_GOLD_CHNID_CONFIG,[],util:now_seconds())
	end.

init_ets_laba_win_player()->
	ets:delete_all_objects(?ETS_LAST_WIN_POOL_PLAYER),
	ets:delete_all_objects(?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER),
	List = laba_win_player_db:get(),
	lists:foreach(fun(E) ->
		{Time,Type} = E#laba_win_player.key,
		%?INFO_LOG("===> ~p~n", [E]),
		if
			Type == 1 ->
				ets:insert(?ETS_LAST_WIN_POOL_PLAYER,#ets_data{key = Time,value = E#laba_win_player.info});
			true ->
				ets:insert(?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER,#ets_data{key = Time,value = E#laba_win_player.info})
		end end,List).

initets_laba_and_slaba_rate_config()->
	lists:foreach(fun(Index) ->
		LabaRateEtsHame = lists:nth(Index, ?LABA_RATE_EST_MAPLIST),
		case laba_fruit_activate_config_db:get({laba, ?TEST_TYPE_TRY_PLAY, Index}) of
			{ok,[Data]} ->
				%?INFO_LOG("===> ~p~n", [{Data}]),
				lists:foreach(fun(E) -> 
					ets:insert(LabaRateEtsHame,E) 
				end, Data#laba_fruit_activate_config.value);
			_->
				player_laba_util:rate_set(?TYPE_LABA,true,LabaRateEtsHame)
		end
	end, lists:seq(1, 11)),
	lists:foreach(fun(Index) ->
		LabaRateEtsHame = lists:nth(Index, ?LABA_TESTTYPE2_RATE_EST_MAPLIST),
		case laba_fruit_activate_config_db:get({laba, ?TEST_TYPE_ENTERTAINMENT, Index}) of
			{ok,[Data]} ->
				lists:foreach(fun(E) -> 
					ets:insert(LabaRateEtsHame,E) 
				end, Data#laba_fruit_activate_config.value);
			_->
				player_laba_util:rate_set(?TYPE_LABA,true,LabaRateEtsHame)
		end
	end, lists:seq(1, 10)),
	lists:foreach(fun(Index) ->
		LabaRateEtsHame = lists:nth(Index, ?SUPER_LABA_RATE_EST_MAPLIST),
		case laba_fruit_activate_config_db:get({super_laba, ?TEST_TYPE_TRY_PLAY, Index}) of
			{ok,[Data]} ->
				lists:foreach(fun(E) -> 
					ets:insert(LabaRateEtsHame,E) 
				end, Data#laba_fruit_activate_config.value);
			_->
				player_laba_util:rate_set(?TYPE_SUPER_LABA,true,LabaRateEtsHame)
		end
	end, lists:seq(1, 10)),
	lists:foreach(fun(Index) ->
		LabaRateEtsHame = lists:nth(Index, ?SUPER_LABA_TESTTYPE2_RATE_EST_MAPLIST),
		case laba_fruit_activate_config_db:get({super_laba, ?TEST_TYPE_ENTERTAINMENT, Index}) of
			{ok,[Data]} ->
				lists:foreach(fun(E) -> 
					ets:insert(LabaRateEtsHame,E) 
				end, Data#laba_fruit_activate_config.value);
			_->
				player_laba_util:rate_set(?TYPE_SUPER_LABA,true,LabaRateEtsHame)
		end
	end, lists:seq(1, 10)),
	case laba_fruit_activate_config_db:get(5) of
		{ok,[Data5]} ->
			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_POOL_REWARD_CONFIG_LIST,E) end,Data5#laba_fruit_activate_config.value);
		_->
			List1 = laba_pool_reward_config_db:get(),
			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_POOL_REWARD_CONFIG_LIST,E) end,List1)
	end,
	case laba_fruit_activate_config_db:get(6) of
		{ok,[Data6]} ->
			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_CONST_LIST,E) end,Data6#laba_fruit_activate_config.value);
		_->
			List2 = laba_const_config_db:get(),
			lists:foreach(fun(E) -> ets:insert(?ETS_LABA_CONST_LIST,E) end,List2)
	end.

init_ets_fruit_pool_config() ->
	case fruit_pool_config_db:get_list() of
		{ok, List} ->
			lists:foreach(fun(E) ->
				ets:insert(?ETS_FRUIT_POOL_CONFIG, E)
			end, List);
		_ ->
			?INFO_LOG("not found any fruit_pool config, use default..~n")
	end.

init_ets_bet_stickiness_redpack_config() ->
	player_bet_stickiness_redpack:init_ets().

init_ets_bet_lock() ->
	player_bet_lock:init_ets().

init_ets_fruit_fresher_protect_config() ->
	ets:delete_all_objects(?ETS_FRUIT_FRESHER_PROTECT_CONFIG),
	ets:delete_all_objects(?ETS_SUPER_FRUIT_FRESHER_PROTECTED_CONFIG),
	case fruit_fresher_protect_config_db:get() of
		[] ->
			?INFO_LOG("not found any init_ets_fruit_fresher_config...~n"),
			skip;
		List ->
			{LabaSortedList, SuperLabaSortedList} = player_laba_util_reroll:g_sort_config(List, fruit_fresher_protect_config),
			?INFO_LOG("init_ets_fruit_fresher_config--> ~p~n", [{LabaSortedList, SuperLabaSortedList}]),
			lists:foreach(fun(E) ->
				ets:insert(?ETS_FRUIT_FRESHER_PROTECT_CONFIG, E)
			end, LabaSortedList),
			lists:foreach(fun(E) ->
				ets:insert(?ETS_SUPER_FRUIT_FRESHER_PROTECTED_CONFIG, E)
			end, SuperLabaSortedList)
	end.

init_ets_fruit_fresher_welfare_config() ->
	ets:delete_all_objects(?ETS_FRUIT_FRESHER_WELFARE_CONFIG),
	ets:delete_all_objects(?ETS_SUPER_FRUIT_FRESHER_WELFARE_CONFIG),
	case fruit_fresher_welfare_config_db:get() of
		[] ->
			?INFO_LOG("not found any init_ets_fruit_fresher_welfare_config...~n"),
			skip;
		List ->
			lists:foreach(fun(E) ->
				{Type, _, _} = E#fruit_fresher_welfare_config.key,
				case Type of
					laba ->
						ets:insert(?ETS_FRUIT_FRESHER_WELFARE_CONFIG, E);
					super_laba ->
						ets:insert(?ETS_SUPER_FRUIT_FRESHER_WELFARE_CONFIG, E);
					_ ->
						skip
				end
			end, List)
	end.

init_ets_lottery_config() ->
	{ok, ConstList} = lottery_config_db:get_list(),
	CachedProtoes = lists:foldr(fun(ERec, CachedProto) ->
		Index = ERec#lottery_config.id,
		{CostItemId, CostItemNum} = ERec#lottery_config.cost_item_info,
		{random_weight, RewardList, _} = ERec#lottery_config.random_reward_list,
		ets:insert(?ETS_LOTTERY_CONFIG, ERec),
		RewardItems = lists:foldl(fun (Elem, Acc) ->
			{ItemId, ItemNum} = Elem,
			Acc ++ [#pb_lottery_item {
				item_id = ItemId, item_num = ItemNum
			}]
		end, [], RewardList),
		CachedProto ++ [#pb_lottery_reward_config {
				index = Index,
				cost_item = #pb_lottery_item {
					item_id = CostItemId, item_num = abs(CostItemNum)
				},
				reward_items = RewardItems
			}
		]
	end, [], ConstList),
	ets:insert(?ETS_LOTTERY_CONFIG_PROTO_PACKED, #ets_lottery_reward_items {
		index = 1,
		reward_items = CachedProtoes
	}).
