%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 四月 2017 18:23
%%%-------------------------------------------------------------------
-module(http_static_util).
-include("common.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

%% 参数列表定义
-define(ONLINE_PARAM_LIST, ["totals","xs","cj","zj","gj","gb","fh","brnn","fruit","car","server"]).
-define(MD5_KEY, "Nn&_7^e$D9>i30$jnT").
-define(IS_IGNORE_ROBOT, true).

%% API
-export([
	test_user/1,
	get_param_string/1,

	post_online_info/0,	%% 在线人数与房间信息

	%post_ticket_info/4		%% 同步奖券消耗 ( 先日志出发送)
	post_fruit_log/10,		%% 同步拉霸

	post_hundred_niu/8,		%% 同步百人

	post_car/10,         %% 同步豪车

	post_set_red_pack/4,		%% 红包上架

	post_redpack_trade/5,		%% 红包售出

	post_user_info/4,		%% 玩家信息更新

	post_enter_room/3,		%% 进入房间

	post_leave_room/2,		%% 离开房间

	post_gold_log/5,		%% 金币变动
	post_diamond_log/5, 	%% 钻石变动
	post_ticket_log/5, 	%% 奖券变动
	post_redbag_log/5,  %%红包变动

	post_redpack_room_log/7,	%% 红包场

	post_prize_exchange/10,	%% 兑换

	post_task_log/5,		%% 任务领奖

	post_url/2,
	post_exchange_url/3,
	post_url_base/3,
	post_login_out/4,

	post_normal_niu/8,

	post_play_three_times/1,
	post_talk/3,     %% 聊天
	post_bet_log/6,   %% 押注记录
	post_brpool_log/2, %% 百人水池
	post_get_play_info/3, %%红包场玩和百人消耗
	post_redpool/2, %% 红包场奖池
	post_first_redgold/4,
	post_share/4,  %% 邀请接口
	post_verified/3, %%实名认证
	post_seventask/4, %% 七日任务
	post_inituser/1, %% 登录获得角色ID
	post_sharelottery/4,  %% 分享活动抽奖
	post_emaillog/6,

	post_get_self_share_list/3, % 我的分享列表
	post_self_share_query/4, %我的分享页面查询接口
	post_get_share_rank_list/5, % 获取分享排名列表
	post_get_get_task_count/1, % 获得抽奖次数

	post_car_pool_log/4, % 同步

	% ------------------------- 下面开始是新后台
	post_sa_car_pool/2, % 同步豪车水池

	%do_post_url/3
	%post_url_base_one_time/3,
	post_fruit_pool_log/8, % 水果水池日志
	post_super_fruit_pool_log/8, % 超级水果水池日志
	post_daily_salary_log/3,
	post_airlaba_pool_log/4,
	post_airlaba_user_log/12,

	post_airlaba_rank/1,
	post_player_lottery/3
]).

%% 总人数 五人场6等级人数 百人 水果 car=0 server=1 一分钟调用一次
post_online_info() ->
	OnlineNum = ets:info(?ETS_ONLINE, size),	%% ok
	
	%{ok, NumList} = gen_server:call(niu_room_manager:get_mod_pid(), {'query_in_game_player_num', 'real'}),
	NumList = [],
	ListNiu1 = lists:zip(["xs","cj","zj","gj","gb","fh", "red"], lists:keysort(1,NumList)),	%% ok
	ListNiu = lists:map(fun({Key, {_, Num}}) -> {Key, Num} end, ListNiu1),
	Pattern = #player_niu_room_info{
		is_robot = false,
		_ = '_'
	},
	AllPlayerList = ets:match_object(?ETS_HUNDRED_PLAYER_IN_GAME, Pattern),
	AllRealPlayerList = lists:filter(fun(E) -> E#player_niu_room_info.room_id > 0 end, AllPlayerList),
	InHundredNum = length(AllRealPlayerList),		%% 玩家is_robot + check_room=0

	{InFruitNum11, InAirlabaNum11, InFruitNum12, InAirlabaNum12} = ets:foldr(fun (Elem, Acc) ->
		{LabaNum1, AirLabaNum1, LabaNum2, AirLabaNum2} = Acc,
		if
			Elem#ets_laba_player_info.is_in_airlaba ->
				if
					?TEST_TYPE_TRY_PLAY =:= Elem#ets_laba_player_info.test_type ->
						{LabaNum1, AirLabaNum1 + 1, LabaNum2, AirLabaNum2};
					true ->
						{LabaNum1, AirLabaNum1, LabaNum2, AirLabaNum2 + 1}
				end;
			true ->
				if
					?TEST_TYPE_TRY_PLAY =:= Elem#ets_laba_player_info.test_type ->
						{LabaNum1 + 1, AirLabaNum1, LabaNum2, AirLabaNum2};
					true ->
						{LabaNum1, AirLabaNum1, LabaNum2 + 1, AirLabaNum2}
				end
		end
	end, {0, 0, 0, 0}, ?ETS_LABA_PLAYER_INFO),
	{InFruitNum21, InAirlabaNum21, InFruitNum22, InAirlabaNum22} = ets:foldr(fun (Elem, Acc) ->
		{LabaNum1, AirLabaNum1, LabaNum2, AirLabaNum2} = Acc,
		if
			Elem#ets_laba_player_info.is_in_airlaba ->
				if
					?TEST_TYPE_TRY_PLAY =:= Elem#ets_laba_player_info.test_type ->
						{LabaNum1, AirLabaNum1 + 1, LabaNum2, AirLabaNum2};
					true ->
						{LabaNum1, AirLabaNum1, LabaNum2, AirLabaNum2 + 1}
				end;
			true ->
				if
					?TEST_TYPE_TRY_PLAY =:= Elem#ets_laba_player_info.test_type ->
						{LabaNum1 + 1, AirLabaNum1, LabaNum2, AirLabaNum2};
					true ->
						{LabaNum1, AirLabaNum1, LabaNum2 + 1, AirLabaNum2}
				end
		end
	end, {0, 0, 0, 0}, ?ETS_SUPER_LABA_PLAYER_INFO),
	%InFruitNum1 = ets:info(?ETS_LABA_PLAYER_INFO, size),
	%InFruitNum2 = ets:info(?ETS_SUPER_LABA_PLAYER_INFO, size),

	AllCarPlayerList = ets:match_object(?ETS_CAR_PLAYER_IN_GAME, Pattern),
	AllRealCarPlayerList = lists:filter(fun(E) -> E#player_niu_room_info.room_id > 0 end, AllCarPlayerList),
	InCarNum = length(AllRealCarPlayerList),

	ListAll = [
		{"totals", OnlineNum}] ++ ListNiu ++ [
		{"brnn", InHundredNum},
		{"fruit_testtype1", InFruitNum11},
		{"fruit_testtype2", InFruitNum12},
		{"superfruit_testtype1", InFruitNum21},
		{"superfruit_testtype2", InFruitNum22},
		{"airlaba_testtype1", InAirlabaNum11},
		{"airlaba_testtype2", InAirlabaNum12},
		{"airsuperlaba_testtype1", InAirlabaNum21},
		{"airsuperlaba_testtype2", InAirlabaNum22},
		{"car", InCarNum},
		{"server", config_app:get_server_id()}
	],
	post_url("online", get_param_string(ListAll)).

post_fruit_log(PlayerInfo, WinNum, CostNum, PoolWin,PoolAdd,Tax,ReMark,Type,TestType, Second) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"get", WinNum},
				{"use", CostNum},
				{"pool_win", PoolWin},
				{"pooladd", PoolAdd},
				{"tax", Tax},
				{"new_gold", PlayerInfo#player_info.gold},
				{"type",Type},
				{"test_type", TestType},
				{"remark", ReMark},
				{"c_time", Second}
			],
			post_url("fruitlog", get_param_string(List1))
	end.

post_redpack_room_log(PlayerInfo, WinNum, CostNum, RedPackReward,Tax,ReMark,Second) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"get", WinNum},
				{"use", CostNum},
				{"tax", Tax},
				{"redbag", RedPackReward},
				{"isrobot", IsRobot},
				{"new_dia", PlayerInfo#player_info.diamond},
				{"remark", ReMark},
				{"c_time", Second}
			],
			post_url("qrredbag", get_param_string(List1))
	end.

post_task_log(PlayerInfo, TaskId, RewardItemId, RewardNum, Second) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"taskid", TaskId},
				{"goods_id", RewardItemId},
				{"num", RewardNum},
				{"c_time", Second}
			],
			post_url("tasks", get_param_string(List1))
	end.

post_hundred_niu(PlayerInfo,WinNum, CostNum, PoolWin, Tax,ReMark,Second, TestType) ->
	case PlayerInfo of
		{Uid1, PlayerId, IsRobot,Gold} ->
			NewGold = Gold,
			case IsRobot of
				true ->
					Uid = 0;
				_ ->
					if
						Uid1 == [] ->
							Uid = "";
						true ->
							Uid = list_to_integer(Uid1)
					end
			end;
		_ ->
			NewGold = PlayerInfo#player_info.gold,
			PlayerId = PlayerInfo#player_info.id,
			{IsRobot, Uid} = get_player_uid(PlayerInfo)
	end,
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->

			List1 = [
				{"uid", Uid},
				{"char_id", PlayerId},
				{"get", WinNum},
				{"use", CostNum},
				{"pool_add", 0},
				{"tax", Tax},
				{"pool_win", PoolWin},
				{"new_gold", NewGold},
				{"test_type", TestType},
				{"remark", ReMark},
				{"c_time", Second}
			],
			post_url("brnnlog", get_param_string(List1))
	end.

post_car(PlayerInfo, Get,Use, PoolWin, PoolAdd, Tax, TestType, BetList, LastResult, Second) ->
	case PlayerInfo of
		{Uid1, PlayerId, Gold, IsRobot} ->
			case IsRobot of
				true ->
					Uid = 0;
				_ ->
					Uid = list_to_integer(Uid1)
			end,
			NowGold = Gold;
		_ ->
			PlayerId = PlayerInfo#player_info.id,
			{_IsRobot, Uid} = get_player_uid(PlayerInfo),
			NowGold = PlayerInfo#player_info.gold
	end,

	if 0 =/= Uid ->
		?INFO_LOG("--====------PoolAdd~p~n", [{PoolAdd, Uid}]),
		{{RPos, RIndex}, RMasterId} = LastResult,
		StrBetList = lists:foldl(fun({EPos,ENum},Acc) ->
			lists:concat([Acc,";","{",EPos,",",ENum,"}"]) end,[],BetList),
		Remark = lists:concat([RMasterId,",",RPos,",",RIndex,",",TestType,",",StrBetList]),
		List1 = [
			{"uid", Uid},
			{"char_id", PlayerId},
			{"get", Get},
			{"use", Use},
			{"pool_win", PoolWin},
			{"new_good", NowGold},
			{"tax",Tax},
			{"c_time", Second},
			{"pooladd", PoolAdd},
			{"test_type", TestType},
			{"remark", Remark}
		],
		post_url("carlog", get_param_string(List1));
	true ->
		skip
	end.
	

post_set_red_pack(PlayerInfo, RedPackId, RedPackNum, Second) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"suid", Uid},
				{"schar_id", PlayerInfo#player_info.id},
				{"goods_id", 0},
				{"shelve_id", RedPackId},
				{"price", RedPackNum},
				{"stime", Second}
			],
			%?INFO_LOG("post_set_red_pack ~p~n",[ List1 ]),
			post_url("shelves", get_param_string(List1))
	end.

post_redpack_trade(SalorId, ObjAccountId, ObjPlayerId, RedPackId, Second) ->
	List1 = [
		{"schar_id", SalorId},
		{"buid", list_to_integer(ObjAccountId)},
		{"bchar_id", ObjPlayerId},
		{"shelve_id", RedPackId},
		{"etime", Second}
	],
	%?INFO_LOG("post_redpack_trade ~p~n",[ List1 ]),
	post_url("redsale", get_param_string(List1)).

get_player_uid(PlayerInfo) ->
	case PlayerInfo#player_info.is_robot of
		true ->
			{true, 0};
		_ ->
			{false, list_to_integer(PlayerInfo#player_info.account)}
	end.

post_user_info(PlayerInfo, RedBagNum, Type, PlayerWin) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"nickname", PlayerInfo#player_info.player_name},
				{"level", PlayerInfo#player_info.level},
				{"vip", PlayerInfo#player_info.vip_level},
				{"gold", PlayerInfo#player_info.gold},
				{"ticket", PlayerInfo#player_info.cash},
				{"redbag", RedBagNum},
				{"diamond", PlayerInfo#player_info.diamond},
				{"c_time", PlayerInfo#player_info.create_time},
				{"lastlogin", PlayerInfo#player_info.login_time},
				{"isrobot", IsRobot},
				{"islogin", Type},
				{"wingold", PlayerWin}
			],
			%?INFO_LOG("{nickname, PlayerInfo#player_info.player_name} ~p~n",[List1]),
		%% 	player_util:log_by_player_id(1000649, "~p", [List1]),
		%% 	player_util:log_by_player_id(1000629, "~p", [List1]),
			post_url("userinfo", get_param_string(List1)),
			post_login_out(Uid, PlayerInfo#player_info.id, util:now_seconds(), Type)
	end.

test_user(PlayerId) ->
	%Key = player_info_db:get_first(),
	{ok, [PlayerInfo]} = player_info_db:get_base(PlayerId),
	post_user_info(PlayerInfo, 0, 0, 0).

post_enter_room(PlayerInfo, RoomId, TestType) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomId},
				{"gold", PlayerInfo#player_info.gold},
				{"ticket", PlayerInfo#player_info.cash},
				{"diamond", PlayerInfo#player_info.diamond},
				{"login_time", util:now_seconds()},
				{"isrobot", IsRobot},
				{"testtype", TestType}
			],
			%player_util:log_by_player_id(1000314, "post_enter_room RoomId:~p ", [RoomId]),
			post_url("arealogin", get_param_string(List1))
	end.

post_leave_room(PlayerInfo, RoomId) ->
	case get(?HTTP_POST_LEAVE_GAME) of
		false ->
			{IsRobot, Uid} = get_player_uid(PlayerInfo),
			if
				IsRobot andalso ?IS_IGNORE_ROBOT ->
					skip;
				true ->
					List1 = [
						{"uid", Uid},
						{"char_id", PlayerInfo#player_info.id},
						{"room", RoomId},
						{"gold", PlayerInfo#player_info.gold},
						{"ticket", PlayerInfo#player_info.cash},
						{"diamond", PlayerInfo#player_info.diamond},
						{"logout_time", util:now_seconds()},
						{"isrobot", IsRobot}
					],
					%player_util:log_by_player_id(1000314, "post_leave_room RoomId:~p ", [RoomId]),
					post_url("arealogout", get_param_string(List1))
			end;
		_ ->
			skip
	end.

post_gold_log(PlayerInfo, RoomId, RewardGold, RewardType, Seconds) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomId},
				{"gold", abs(RewardGold)},
				{"new_gold", PlayerInfo#player_info.gold},
				{"c_time", Seconds},
				{"type", RewardType},
				{"isrobot", IsRobot}
			],
			post_url("gold", get_param_string(List1))
	end.

post_diamond_log(PlayerInfo, RoomId, RewardDiamod, RewardType, Seconds) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomId},
				{"diamond", abs(RewardDiamod)},
				{"new_diamond", PlayerInfo#player_info.diamond},
				{"c_time", Seconds},
				{"type", RewardType},
				{"isrobot", IsRobot}
			],
			post_url("diamond", get_param_string(List1))
	end.

post_ticket_log(PlayerInfo, RoomId, TicketNum, RewardType, Seconds) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomId},
				{"ticket", abs(TicketNum)},
				{"c_time", Seconds},
				{"type", RewardType},
				{"isrobot", IsRobot}
			],
			post_url("ticket", get_param_string(List1))
	end.

post_redbag_log(PlayerInfo, ItemId, Num, RewardType, Seconds) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"goods_id", ItemId},
				{"money", Num},
				{"c_time", Seconds},
				{"room", RewardType}
			],
			post_url("redbaglog", get_param_string(List1))
	end.

post_airlaba_user_log(PlayerInfo, GoldUse, GoldGet, GoldEarn, RedPackGet, SysAdd, PoolAdd, RankAdd, UserPoolGold, CommonPoolGold, TestType, Time) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List = [
				{"uid", Uid},
				{"gold_use", GoldUse}, 
				{"gold_get", GoldGet},
				{"gold_earn", GoldEarn},
				{"redpack_get", RedPackGet},
				{"sys_rate", SysAdd},
				{"pool_rate", PoolAdd},
				{"rank_rate", RankAdd},
				{"upool", UserPoolGold},
				{"cpool", CommonPoolGold},
				{"test_type", TestType},
				{"ctime", Time}
			],
			post_url("airlaba_userlog", get_param_string(List))
	end.

post_login_out(Uid, PlayerId, Seconds, Type) ->
	List1 = [
		{"uid", Uid},
		{"char_id", PlayerId},
		{"c_time", Seconds},
		{"type", Type}
	],
	case Type of
		0 ->
			%%登出时检查
			case player_util:get_http_room_level_id() of
				0 ->
					skip;
				Level when is_integer(Level) ->
					PlayerInfo = player_util:get_dic_player_info(),
					post_leave_room(PlayerInfo, Level),
					ets:delete(?ETS_LABA_PLAYER_INFO, PlayerId),
					put(?HTTP_POST_LEAVE_GAME, true);
				_ ->
					skip
			end;
		_ ->
			skip
	end,
	post_url("gamelogin", get_param_string(List1)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_param_string(PreList) ->
	SignList = lists:map(fun({_, EData}) -> EData end, lists:keysort(1, PreList)),
	Check = lists:concat(SignList),
	StrMd5 = string:join( [ Check, ?MD5_KEY], ""),
	Md5Hex = lists:flatten([io_lib:format("~2.16.0b", [D]) || D <- binary_to_list(erlang:md5(StrMd5))]),
	ParamList = PreList ++ [{"sign", Md5Hex}],
	%rfc4627:encode({obj, ParamList}).
	ParamStr1 = lists:foldl(fun({EKey, EValue}, Acc) ->
		Acc ++ ["&", EKey, "=", EValue] end, [], ParamList),
	[_|Last] = lists:concat(ParamStr1),
	Last.

post_prize_exchange(PlayerInfo, TrueName, OrderSn, PhoneNum, GoodsId, Num, TypeId, Province, City, Detail) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			Cls =
				if
					TypeId == 3 ->
						1;		%% 实物
					true ->
						2
				end,
			NowSecond = util:now_seconds(),
			List1 = [
				{"uid", Uid},
				{"truename", binary_to_list(TrueName)},
				{"ordersn", OrderSn},
				{"mobile", binary_to_list(PhoneNum)},
				{"goods_id", GoodsId},
				{"num", Num},
				{"type", Cls},
				{"c_time", NowSecond},
				{"province", binary_to_list(Province)},
				{"city", binary_to_list(City)},
				{"county", ""},
				{"detail", binary_to_list(Detail)}
			],
			FuncCallBack =
				fun(Err)->
					log_util:add_prize_exchange_err(PlayerInfo#player_info.id, GoodsId, util:get_date_time_str(util:seconds_to_datetime(NowSecond)), Err)
				end,
			log_util:add_prize_exchange(PlayerInfo#player_info.id, GoodsId, util:get_date_time_str(util:seconds_to_datetime(NowSecond))),
			post_exchange_url("shopexchange", get_param_string(List1), FuncCallBack)
	end.


post_normal_niu(PlayerInfo, RoomLevel, WinNum, CostNum, Tax, InMoney,ReMark, TestType) ->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomLevel},
				{"get", WinNum},
				{"use", CostNum},
				{"tax", Tax},
				{"inmoney", InMoney},
				{"test_type", TestType},
				{"new_gold", PlayerInfo#player_info.gold},
				{"remark", ReMark},
				{"c_time", util:now_seconds()}
			],
			post_url("kplog", get_param_string(List1))
	end.

post_play_three_times(PlayerInfo)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"c_time", util:now_seconds()}
				],
			if
				IsRobot == 1 ->
					skip;
				true ->
					post_url("taskcomplete", get_param_string(List1))
			end
	end.

post_talk(PlayerInfo,RoomType,NewContent)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"room", RoomType},
				{"msg", NewContent},
				{"c_time", util:now_seconds()}
			],
			if
				IsRobot == 1 ->
					skip;
				true ->
					post_url("talklogs", get_param_string(List1))
			end
	end.

post_bet_log(GameType,PlayerId,Account,CardTypes,BetList,Pool)->
	List1 = [
		{"room", GameType},
		{"uid", Account},
		{"char_id", PlayerId},
		{"cardtype", CardTypes},
		{"bet", BetList},
		{"pool", Pool},
		{"c_time", util:now_seconds()}
	],
	post_url("betlogs", get_param_string(List1)).

post_brpool_log({Num,Num2},NowSec)->
	List1 = [
		{"pool", Num},
		{"int", trunc(Num2)},
		{"c_time", NowSec}
	],
	post_url("brpool", get_param_string(List1)).

post_get_play_info(PlayerInfo,Times,CostNum)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"play_num", Times},
				{"bet_gold", CostNum},
				{"c_time", util:now_seconds()}
			],
			post_url("getplayinfo", get_param_string(List1))
	end.

post_redpool(Num,Time)->
	List1 = [
		{"pool_num", Num},
		{"c_time", Time}
	],
	post_url("redpool", get_param_string(List1)).

post_first_redgold(PlayerInfo,String,Num,Time)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"redbag", String},
				{"gold", Num},
				{"c_time", Time}
			],
			post_url("firstredgold", get_param_string(List1))
	end.

post_share(Uid,ReUid,Type,Time)->
	List1 = [
		{"uid", Uid},
		{"re_uid", ReUid},
		{"diamond", 0},
		{"type", Type},
		{"c_time", Time}
	],
	post_url("share", get_param_string(List1)).

post_verified(PlayerInfo,Name,IDNum)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"truename", Name},
				{"id_card", IDNum},
				{"c_time", util:now_seconds()}
			],
			post_url("verified", get_param_string(List1))
	end.

post_seventask(PlayerInfo,TaskDay,TaskId,ShareCharId)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"taskday", TaskDay},
				{"taskid", TaskId},
				{"c_time", util:now_seconds()},
				{"share_char_id", ShareCharId}
			],
			post_url("seventask", get_param_string(List1)),
			post_user_url("seventask", get_param_string(List1))
	end.


post_inituser(PlayerInfo)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"c_time", PlayerInfo#player_info.create_time}
			],
			post_user_url("inituser", get_param_string(List1))
	end.

post_sharelottery(PlayerInfo,Type1,Reward,Time)->
	{IsRobot, Uid} = get_player_uid(PlayerInfo),
	if
		IsRobot andalso ?IS_IGNORE_ROBOT ->
			skip;
		true ->
			Type =
				case Type1 of
					1 ->
						1;
					2 ->
						3;
					3 ->
						7
				end,

			{ItemId,Num} = Reward,
			List1 = [
				{"uid", Uid},
				{"char_id", PlayerInfo#player_info.id},
				{"type", Type},
				{"goods_id", ItemId},
				{"num", Num},
				{"c_time", Time}
			],
			post_url("sharelottery", get_param_string(List1))
	end.

post_emaillog(PlayerId,MailId,Title,RewardStr,MailCategory,Time)->
	List1 = [
		{"char_id", PlayerId},
		{"email_id", MailId},
		{"title", Title},
		{"attachment", RewardStr},
		{"type ", MailCategory},
		{"c_time", Time}
	],
	post_url("emaillog", get_param_string(List1)).




%% -------------分享活动 -------------
post_get_self_share_list(Page,Limit,Id)->
	List1 = [
		{"page", Page},
		{"limit", Limit},
		{"share_char_id",Id}
	],
	post_url_base_one_time("getselfsharelist", get_param_string(List1)).

post_self_share_query(Page,Limit,Id,ObjId)->
	List1 = [
		{"page", Page},
		{"limit", Limit},
		{"share_char_id",Id},
		{"char_id",ObjId}
	],
	post_url_base_one_time("selfsharequery", get_param_string(List1)).

post_get_share_rank_list(Page,Limit,Id,BTime,ETime)->
	List1 = [
		{"page", Page},
		{"limit", Limit},
		{"share_char_id",Id},
		{"b_time",BTime},
		{"e_time",ETime}
	],
	post_url_base_one_time("getshareranklist", get_param_string(List1)).

post_get_get_task_count(Id)->
	List1 = [
		{"char_id",Id}
	],
	post_url_base_one_time("gettaskcount", get_param_string(List1)).

post_car_pool_log(TotalNum, TodayNum, DiffNum, Time) ->
	List1 = [
		{"totalNum", trunc(TotalNum)},
		{"todayNum", TodayNum},
		{"diffNum", DiffNum},
		{"time", Time}
	],
	post_url("carpool", get_param_string(List1)).

post_fruit_pool_log(BetIndex, TotalNum, DiffNum, BetRet, EarnRet, TestType, SubPoolList, Time) ->
	PoolStr = lists:foldl(fun(Num, Acc) ->
		lists:concat([Acc, ",", Num])
	end, "", SubPoolList),
	List1 = [
		{"betIndex", BetIndex},
		{"totalNum", trunc(TotalNum)},
		{"diffNum", DiffNum},
		{"betRet", BetRet},
		{"earnRet", EarnRet},
		{"subPool", PoolStr},
		{"testType", TestType},
		{"time", Time}
	],
	post_url("fruitpool", get_param_string(List1)).

post_super_fruit_pool_log(BetIndex, TotalNum, DiffNum, BetRet, EarnRet, TestType, SubPoolList, Time) ->
	PoolStr = lists:foldl(fun(Num, Acc) ->
		lists:concat([Acc, ",", Num])
	end, "", SubPoolList),
	List1 = [
		{"betIndex", BetIndex},
		{"totalNum", trunc(TotalNum)},
		{"diffNum", DiffNum},
		{"betRet", BetRet},
		{"earnRet", EarnRet},
		{"subPool", PoolStr},
		{"testType", TestType},
		{"time", Time}
	],
	post_url("superfruitpool", get_param_string(List1)).

post_daily_salary_log(PlayerId, SalaryNum, Time) ->
	List1 = [
		{"char_id", PlayerId},
		{"salary", SalaryNum},
		{"time", Time}
	],
	post_url("dailysalarylog", get_param_string(List1)).

post_airlaba_pool_log(NewPoolShared, NewCurPoolList, TestType, Time) ->
	PoolStr = lists:foldl(fun(Num, Acc) ->
		lists:concat([Acc, ",", Num])
	end, "", NewCurPoolList),
	List1 = [
		{"poolShared", trunc(NewPoolShared)},
		{"poolCurList", PoolStr},
		{"testType", TestType},
		{"time", Time}
	],
	post_url("airlabapool", get_param_string(List1)).

post_player_lottery(PlayerInfo, ItemList, Sec) ->
	ItemStr = lists:foldl(fun(Item, Acc) ->
		{ItemId, ItemNum} = Item,
		lists:concat([Acc, ",", ItemId, ",", ItemNum])
	end, "", ItemList),
	List1 = [
		{"uid", PlayerInfo#player_info.id},
		{"items", ItemStr},
		{"time", Sec}
	],
	post_url("lotterylog", get_param_string(List1)).

post_sa_car_pool(PoolNum, ServerSeconds) ->
	List = [
		{"poolNum", PoolNum},
		{"serverSec", ServerSeconds}
	],
	post_superadm_url("car/pool-notofy", get_param_string(List)).

post_airlaba_rank(RankJson) ->
	post_redismaster_url("updateAirlabaRank", RankJson).

%% ---------------------------------------
post_url(Function, ParamStr) ->
	case config_app:get_static_normal_open() of
		true ->
			post_url_base(Function, ParamStr, config_app:get_statis_http_url());
		_ ->
			skip
	end.

post_exchange_url(Function, ParamStr, FuncCallback) ->
	case config_app:get_static_exchange_open() of
		true ->
			post_url_base_exchange(Function, ParamStr, config_app:get_exchange_http_url(), FuncCallback);
		_ ->
			skip
	end.

post_superadm_url(Function, ParamStr) ->
	Url = config_app:get_superadm_http_url(),
	case Url of
		undefined ->
			skip;
		_ ->
			post_url_base(Function, ParamStr, Url)
	end.

post_redismaster_url(Function, ParamStr) ->
	Url = config_app:get_redismaster_http_url(),
	case Url of
		undefined ->
			skip;
		_ ->
			post_url_json(Function, ParamStr, Url)
	end.

post_user_url(Function, ParamStr) ->
	post_url_base(Function, ParamStr, config_app:get_user_http_url()).

%% post_url_base(Function, ParamStr, Url) ->
%% 	case player_util:get_dic_player_info() of
%% 		undefined ->
%% 			skip;
%% 		PlayerInfo ->
%% 			role_http_processor:cast_add_a_http_event(PlayerInfo#player_info.id, do_post_url, [Function, ParamStr, Url])
%% 	end.

post_url_json(Function, ParamStr, BaseUrl) ->
	Url = lists:concat([BaseUrl, Function]),
	httpc:request(post, {Url, [], "application/json;charset=utf-8", ParamStr}, [], [{sync, false}]).

post_url_base(Function, ParamStr, BaseUrl) ->
	Url = lists:concat([BaseUrl, Function]),
	httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", ParamStr}, [], [{sync, false}]).
%% 	Url = lists:concat([BaseUrl, Function]),
%% 	try
%% 		case httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", ParamStr}, [], [{sync, false}]) of
%% 			{ok, {{_, 200, _}, _, Content}} ->
%% 				{ok, JsonData, _} = rfc4627:decode(Content),
%% 				{ok, Code}  = rfc4627:get_field(JsonData, "code"),
%% 				case Code of
%% 					1   ->
%% 						{ok, Msg}  = rfc4627:get_field(JsonData, "msg"),
%% 						%PlayerInfo = player_util:get_dic_player_info(),
%% 						io:format("Post Url ~p ~ts~n",[Url, Msg]);
%% 					_ ->
%% 						skip
%% 				end;
%% 			{ok, {{_, 502, _}, _, _Content}} ->
%% 				%?INFO_LOG("post_url Failed 22~p~n ", [{Function, ParamStr}]),
%% 				skip;
%% 			_Error ->
%% 				%skip
%% 				skip
%% 				%do_timer_after_send([Function, ParamStr, BaseUrl])
%% 		end
%% 	catch
%% 		_ ->
%% 			?INFO_LOG("post_url Error ~p~n ", [{Function, ParamStr, ?MODULE, ?LINE}])
%% 	end.
%%

post_url_base_exchange(Function, ParamStr, BaseUrl, FuncCallback) ->
	Url = lists:concat([BaseUrl, Function]),
	FuncPost =
		fun(F, Counter)->
			case httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", ParamStr}, [{timeout, 10000}], []) of
				{ok, {{_, 200, _}, _, Content}} ->
					{ok, JsonData, _} = rfc4627:decode(Content),
					{ok, Code}  = rfc4627:get_field(JsonData, "code"),
					case Code of
						0 ->
							{ok, _Data}  = rfc4627:get_field(JsonData, "data");
						999 ->
							restore;
						_ ->
							false
					end;
				Error ->
					?INFO_LOG("[~p] post_url_base_exchange Error ~p~n ", [Counter, {Function, ParamStr, Error}]),
					if Counter < 5 ->
						F(F, Counter+1);
					true ->
						error
					end
			end
		end,
	FuncLoop =
		fun()->
			try FuncPost(FuncPost, 1) of
				error ->
					FuncCallback(1),
					error;
				restore ->
					FuncCallback(999),
					restore;
				false ->
					FuncCallback(2),
					false;
				Other -> Other
			catch
				_ ->
					?INFO_LOG("post_url_base_exchange Crash ~p~n ", [{Function, ParamStr, ?MODULE, ?LINE}]),
					FuncCallback(3),
					crash
			end
		end,
		spawn(FuncLoop).

post_url_base_one_time(Function, ParamStr) ->
	BaseUrl = config_app:get_share_http_url(),
 	Url = lists:concat([BaseUrl, Function]),
 	try
 		case httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", ParamStr}, [{timeout, 5000}], []) of
 			{ok, {{_, 200, _}, _, Content}} ->
 				{ok, JsonData, _} = rfc4627:decode(Content),
 				{ok, Code}  = rfc4627:get_field(JsonData, "code"),
 				case Code of
 					0 ->
%% 						{ok, Msg}  = rfc4627:get_field(JsonData, "msg"),
						{ok, Data}  = rfc4627:get_field(JsonData, "data"),
%%						?INFO_LOG("post_url_base_one_time~p~n",[Data]),
 						%PlayerInfo = player_util:get_dic_player_info(),
						Data;
 					_ ->
 						false
 				end;
 			{ok, {{_, 502, _}, _, _Content}} ->
 				false;
 			_Error ->
 				%skip
 				?INFO_LOG("post_url Failed ~p~n ", [{Function, ParamStr, _Error}]),
				false
 		end
 	catch
 		_ ->
 			?INFO_LOG("post_url Error ~p~n ", [{Function, ParamStr, ?MODULE, ?LINE}]),
			false
 	end.
%% test_post_url() ->
%% 	Url = "http://123.57.214.206:9802/api/userinfo?uid=0&char_id=1000088&nickname=asd&level=1&vip=4&gold=3539027&ticket=0&redbag=0&diamond=4331&c_time=1492671751&lastlogin=1492671753&isrobot=1",
%% 	case httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", []}, [{timeout, 2000}], []) of
%% 		{ok, Data} ->
%% 			?INFO_LOG("Post Url ~p ~p~n",[Url, Data]),
%% 			skip;
%% 		Data ->
%% 			?INFO_LOG("post_url Failed ~p~n ", [Data])
%% 	end.

%% do_timer_after_send(ParamList) ->
%% 	erlang:send_after(2*1000, self(), {'do_http_request', ParamList}).


%% url_encode(Data) ->
%% 	url_encode(Data,"").
%%
%% url_encode([],Acc) ->
%% 	Acc;
%%
%% url_encode([{Key,Value}|R],"") ->
%% 	url_encode(R, edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value));
%% url_encode([{Key,Value}|R],Acc) ->
%% 	url_encode(R, Acc ++ "&" ++ edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value)).
