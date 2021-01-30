%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 三月 2017 13:26
%%%-------------------------------------------------------------------
-module(player_prize_util).

-define(PLAYER_PRIZE_DICT, player_prize_dict).		%% 字典
-define(PLAYER_FIRST_PRIZE_REWARD, player_first_prize_reward).		%% 字典

-define(PRIZE_CLS_RED_PACK, 1).		%% 红包，其实就是现金
-define(PRIZE_CLS_PHONE_CARD, 2).		%% 电话卡
-define(PRIZE_CLS_REAL, 3).		%% 实物
-define(PRIZE_CLS_GOLD, 4).		%% 奖券兑换金币
-define(PRIZE_CLS_VIRTUAL_GOODS, 5).		%% 虚拟物品
-define(PRIZE_CLS_DIRECT_TO_GOLD, 6). %%  兑换成红包的直接兑换成现金

-define(PHONE_CARD_CHARGE_TYPE_DIRECT, 1).		%% 直冲
-define(PHONE_CARD_CHARGE_TYPE_CDKEY, 2).		%% 卡密

-define(FIRST_REWARD_LIMIT_TIMES, 1).		%% 首次兑换1元红包几率奖励金币

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/prize_exchange_pb.hrl").
%% API
-export([
	init/1,
	send_init_msg/0,

	cs_prize_query_one_req/1,
	cs_prize_exchange_req/4,

	cs_prize_address_change_req/1,

	cs_prize_query_phonecard_key_req/1,

	test_change_rechage_record/0,
	http_query_order_state/2,
	init_first_prize_reward/1,
	send_prize_exchange_reply/4,
	handle_time/2,
	gm_test/1
]).


init(PlayerId) ->
	case player_prize_info_db:get(PlayerId) of
		{ok, [PlayerPrizeInfo]} ->
			PlayerPrizeInfo1 = check_time_and_vip(PlayerPrizeInfo),
			if
				PlayerPrizeInfo1 == PlayerPrizeInfo ->
					update_player_prize_info(PlayerPrizeInfo1);
				true ->
					save_player_prize_info(PlayerPrizeInfo1)
			end;
		_ ->
			NowTime = util:now_seconds(),
			PlayerPrizeInfo = #player_prize_info{
				player_id = PlayerId,
				last_exchange_time = NowTime	%% 上次兑换时间
			},
			save_player_prize_info(PlayerPrizeInfo)
	end.

check_time_and_vip(OldPlayerPrizeInfo) ->
	NowTime = util:now_seconds(),
	CurPlayerPrizeInfo = case util:is_same_date(OldPlayerPrizeInfo#player_prize_info.last_exchange_time, NowTime) of
		true ->
			OldPlayerPrizeInfo;
		_ ->
			OldPlayerPrizeInfo#player_prize_info{
				exchange_list = [],
				last_exchange_time = NowTime
			}
	end,
	PlayerInfo = player_util:get_dic_player_info(),
	if
		0 < PlayerInfo#player_info.vip_level ->
			% 有 vip 的用户不做限制了
			CurPlayerPrizeInfo#player_prize_info{
				vip_limit_exchange_list = lists:filter(fun ({_, ConifgVipLimit, _}) ->
					ConifgVipLimit > PlayerInfo#player_info.vip_level
				end, CurPlayerPrizeInfo#player_prize_info.vip_limit_exchange_list)
			};
		true ->
			CurPlayerPrizeInfo
	end.

send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			PlayerPrizeInfo = get_player_prize_info(),
			%% 配置信息
			send_prize_config(PlayerInfo, PlayerPrizeInfo#player_prize_info.exchange_list,
				PlayerPrizeInfo#player_prize_info.vip_limit_exchange_list,
				PlayerPrizeInfo#player_prize_info.life_time_limit_exchange_list),
			%% 地址信息
			send_prize_address_info_update(PlayerPrizeInfo#player_prize_info.address_list),
			%% 记录信息
			%% send_login_record_update(PlayerPrizeInfo#player_prize_info.player_id),
			%% 发送库存消息
			send_storage_msg()
	end.

send_storage_msg() ->
	TotalTables = ets:tab2list(?ETS_PRIZE_STORAGE_INFO),
	List =
		lists:foldl(fun(ERec, Acc) ->
			[{ERec#prize_storage_info.id, {ERec#prize_storage_info.count, ERec#prize_storage_info.card_count}}|Acc]
		end, [], TotalTables),
	Msg = prize_mod:pack_storage_info_msg(List),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


send_prize_config(PlayerInfo, ExchangeList, VipLimitExchangeList, LiftTimeLimitExchangeList) ->
	ConfigList = prize_exchange_config_db:get_base(),
	PbList = lists:map(fun(ERec) ->
		{NeedItemId, NeedNum}  = ERec#prize_exchange_config.cost_info,
		case lists:keyfind(ERec#prize_exchange_config.id, 1, ExchangeList) of
			{_, Times} ->
				ok;
			_ ->
				Times = 0
		end,
		{IsVipLimit, VipLimitLevel, VipLimitLeftTimes} = case ERec#prize_exchange_config.vip_limit of
			no_limit ->
				{false, 0, 0};
			{LimitVip, LimitTimes} ->
				LeftTimes = case lists:keyfind(ERec#prize_exchange_config.id, 1, VipLimitExchangeList) of
					false ->
						LimitTimes;
					{_, _, UsedTimes} ->
						max(0, LimitTimes - UsedTimes)
				end,
				{true, LimitVip, LeftTimes}
		end,
		if
			PlayerInfo#player_info.vip_level > VipLimitLevel ->
				{FinalVip, FinalVipTimes, SpecVipLeftTimes} = {ERec#prize_exchange_config.vip_lvl, Times, 0};
			true ->
				{FinalVip, FinalVipTimes, SpecVipLeftTimes} = case IsVipLimit of
					true ->
						if
							0 =:= VipLimitLeftTimes ->
								{ERec#prize_exchange_config.vip_lvl, Times, VipLimitLeftTimes};
							true ->
								{VipLimitLevel, Times, VipLimitLeftTimes}
						end;
					_ ->
						{ERec#prize_exchange_config.vip_lvl, Times, 0}
				end
		end,
		% FinalVipTimes vip已经兑换次数 LifeTimeLeftTimes 一生还剩下多少次
		{FinalTimes, SpecLeftTimes} = case ERec#prize_exchange_config.life_time_limit of
			no_limit ->
				{FinalVipTimes, SpecVipLeftTimes};
			_ ->
				LifeTimeLeftTimes = case lists:keyfind(ERec#prize_exchange_config.id, 1, LiftTimeLimitExchangeList) of
					false ->
						ERec#prize_exchange_config.life_time_limit;
					{_, LifeTimeUsedTimes} ->
						max(0, ERec#prize_exchange_config.life_time_limit - LifeTimeUsedTimes)
				end,
				case LifeTimeLeftTimes of
					0 ->
						{ERec#prize_exchange_config.exchange, 0};
					_ ->
						{Times, min(LifeTimeLeftTimes, SpecVipLeftTimes)}
				end
		end,
		#pb_prize_info{
			obj_id = ERec#prize_exchange_config.id,
			name = ERec#prize_exchange_config.name,
			need_item_id = NeedItemId,
			need_item_num = NeedNum,
			need_vip_level = FinalVip,
			icon = ERec#prize_exchange_config.tex,
			tag = ERec#prize_exchange_config.hot_sell,
			cls = ERec#prize_exchange_config.cls,
			dsc = ERec#prize_exchange_config.dsc,
			today_buy_times = max(0, ERec#prize_exchange_config.exchange - FinalTimes),
			sort_id = ERec#prize_exchange_config.sort,
			special_left_times = SpecLeftTimes
		}
	end, ConfigList),
	Msg = #sc_prize_config_update{
		list = PbList
	},
	GateId = player_util:get_dic_gate_pid(),
	tcp_client:send_data(GateId, Msg).

send_prize_address_info_update(AddressInfoList) ->
	Msg1 = #sc_prize_address_info_update{
		list = AddressInfoList
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg1).

send_login_record_update(PlayerId) ->
	Pattern = #player_prize_exchange_record{
		player_id = PlayerId,
		_ = '_'
	},
	DBFun = fun() ->	List = mnesia:match_object(Pattern),
		send_prize_exchange_record_update(List)
	end,
	{atomic, _} = dal:run_transaction_rpc(DBFun).

send_prize_exchange_record_update(List) ->
	Msg2 = #sc_prize_exchange_record_update{
		list = pack_prize_record(List)
	},
	%?INFO_LOG("record_update ~p~n",[List]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg2).

pack_prize_record(List) ->
	lists:map(fun(ERec) ->
		{ok, RecId} = id_transform_util:mail_id_to_proto(ERec#player_prize_exchange_record.id),
		#pb_prize_exchange_record{
			id = RecId,
			record_type = ERec#player_prize_exchange_record.record_type,
			obj_id = ERec#player_prize_exchange_record.obj_id,
			need_item_id = ERec#player_prize_exchange_record.need_item_id,
			need_item_num = ERec#player_prize_exchange_record.need_item_num,
			second_time = ERec#player_prize_exchange_record.second_time,
			recharge_type = ERec#player_prize_exchange_record.card_charge_type,
			recharge_state = ERec#player_prize_exchange_record.card_state,
			card_number = ERec#player_prize_exchange_record.card_number,
			card_psd = ERec#player_prize_exchange_record.card_psd
		}
	end, List).

get_player_prize_info() ->
	get(?PLAYER_PRIZE_DICT).

update_player_prize_info(Val) ->
	put(?PLAYER_PRIZE_DICT, Val).

save_player_prize_info(Info) ->
	DBFun =
		fun() ->
			player_prize_info_db:t_write(Info)
		end,
	DBSuccessFun =
		fun() ->
			update_player_prize_info(Info)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
	end.


priv_cs_prize_query_one_req(ObjId, NeedCheckTime) ->
	PlayerPrizeInfoOld = get_player_prize_info(),
	if
		true =:= NeedCheckTime ->
			handle_time(PlayerPrizeInfoOld#player_prize_info.last_exchange_time, util:now_seconds());
		true ->
			skip
	end,
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerPrizeInfo = get_player_prize_info(),
	{ok, [PrizeConfig]} = prize_exchange_config_db:get_base(ObjId),
	HaveExchangeTimes =
		case lists:keyfind(ObjId, 1, PlayerPrizeInfo#player_prize_info.exchange_list) of
			false ->
				0;
			{_, Times} ->
				Times
		end,
	{IsVipLimit, VipLimitLevel, VipLimitLeftTimes} = case PrizeConfig#prize_exchange_config.vip_limit of
		no_limit ->
			{false, 0, 0};
		{LimitVip, LimitTimes} ->
			LeftTimes = case lists:keyfind(PrizeConfig#prize_exchange_config.id, 1,
					PlayerPrizeInfo#player_prize_info.vip_limit_exchange_list) of
				false ->
					LimitTimes;
				{_, _, UsedTimes} ->
					max(0, LimitTimes - UsedTimes)
			end,
			{true, LimitVip, LeftTimes}
	end,
	FinalVipLevel = case IsVipLimit of
		true ->
			if
				0 =:= VipLimitLeftTimes orelse PlayerInfo#player_info.vip_level > VipLimitLevel ->
					PrizeConfig#prize_exchange_config.vip_lvl;
				true ->
					VipLimitLevel
			end;
		_ ->
			PrizeConfig#prize_exchange_config.vip_lvl
	end,
	FinalLimitLeftTimes = case PrizeConfig#prize_exchange_config.life_time_limit of
		no_limit ->
			VipLimitLeftTimes;
		_ ->
			min(PrizeConfig#prize_exchange_config.life_time_limit, VipLimitLeftTimes)
	end,
	case ets:lookup(?ETS_PRIZE_STORAGE_INFO, ObjId) of
		[StorageInfo] ->
			Msg = #sc_prize_query_one_reply{
				obj_id = ObjId,
				day_times_config = StorageInfo#prize_storage_info.day_times,
				today_exchange_times = HaveExchangeTimes,
				store_num = StorageInfo#prize_storage_info.count,
				crad_num = StorageInfo#prize_storage_info.card_count,
				special_left_times = FinalLimitLeftTimes,
				need_vip_level = FinalVipLevel
			},
			tcp_client:send_data(player_util:get_dic_gate_pid(), Msg);
		_ ->
			sys_notice_mod:send_notice("兑换商品id错误")
	end.

cs_prize_query_one_req(ObjId) ->
	priv_cs_prize_query_one_req(ObjId, true).

cs_prize_exchange_req(ObjId, PCardChargeType, PhoneNumber, _AddressId) ->
%%	?INFO_LOG("111~p~n",[{ObjId,PCardChargeType, PhoneNumber}]),
	if
		PCardChargeType == ?PRIZE_CLS_GOLD->
			cs_cash_transformation_req(1);
		PCardChargeType == ?PRIZE_CLS_DIRECT_TO_GOLD ->
			redpack_direct_gold_transformation_req(ObjId);
		true ->
			case pre_exchange(ObjId, PCardChargeType, PhoneNumber) of
				{true, AccDict} ->
					DBFun = dict:fetch(db_fun, AccDict),
					SuccessFun = dict:fetch(success_fun, AccDict),
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							SuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
					end;
				{false, Err} ->
					send_prize_exchange_reply(1, Err, [], 0);
				_ ->
					send_prize_exchange_reply(1, "未知错误", [], 0)
			end
	end.

pre_exchange(ObjId, PCardChargeType, PhoneNumber) ->
	Requires = [
		check_obj_id_ok,
		check_config_condition,
		%%check_daily_times,
		check_cost_item,
		check_prize_enough,
		check_db_fun
	],
	AccDict = dict:from_list([
		{card_charge_type, PCardChargeType},
		{phone_number, PhoneNumber}
	]),
	exchange_requires(ObjId, AccDict, Requires).

exchange_requires(_ObjId, AccDict, []) ->
	{true, AccDict};

exchange_requires(ObjId, AccDict, [check_obj_id_ok|T]) ->
	case prize_exchange_config_db:get_base(ObjId) of
		{ok, [PrizeConfig]} ->
			AccDict2 = dict:store(exchange_config, PrizeConfig, AccDict),
			exchange_requires(ObjId, AccDict2, T);
		_ ->
			{false, "物品id不存在"}
	end;

exchange_requires(ObjId, AccDict, [check_cost_item|T]) ->
	PrizeConfig = dict:fetch(exchange_config, AccDict),
	{CostId, CostNum} = PrizeConfig#prize_exchange_config.cost_info,
	case check_player_item_enough(CostId, -CostNum) of
		true ->
			AccDict2 = dict:store(cost_item, [{CostId, -CostNum}], AccDict),
			exchange_requires(ObjId, AccDict2, T);
		_ ->
			{false, "消耗品不足"}
	end;

exchange_requires(ObjId, AccDict, [check_prize_enough|T]) ->
  PrizeConfig = dict:fetch(exchange_config, AccDict),
  Cls = PrizeConfig#prize_exchange_config.cls,
  ChargeType = dict:fetch(card_charge_type, AccDict),
  ChargeType1 =
    case Cls of
      ?PRIZE_CLS_PHONE_CARD ->
        ChargeType;
      _ ->
        1
    end,
	case gen_server:call(prize_mod:get_mod_pid(), {'exchange_prize', ObjId, ChargeType1}) of
		{true, LeftNum, LeftCardNum} ->
      UseLeftNum =
        case ChargeType1 of
          1 ->
            LeftNum;
          _ ->
            LeftCardNum
        end,
			AccDict2 = dict:store(prize_left, UseLeftNum, AccDict),
			exchange_requires(ObjId, AccDict2, T);
		_ ->
			{false, "库存不足"}
	end;

exchange_requires(ObjId, AccDict, [check_config_condition|T]) ->
	PrizeConfig = dict:fetch(exchange_config, AccDict),
	PlayerInfo = player_util:get_dic_player_info(),
	Cls = PrizeConfig#prize_exchange_config.cls,
	PlayerPrizeInfo = get_player_prize_info(),
	DailyExchaneLimit = PrizeConfig#prize_exchange_config.exchange,
	LifeTimeExchangeLimit = PrizeConfig#prize_exchange_config.life_time_limit,
	{VipLimit, VipLimitExchangeLimit} = case PrizeConfig#prize_exchange_config.vip_limit of
		no_limit ->
			{-1, 999999999};
		_ ->
			PrizeConfig#prize_exchange_config.vip_limit
	end,
	HaveExchangeTimes =
		case lists:keyfind(ObjId, 1, PlayerPrizeInfo#player_prize_info.exchange_list) of
			false ->
				0;
			{_, Times} ->
				Times
		end,
	HaveVipLimitExchangeTimes =
		case lists:keyfind(ObjId, 1, PlayerPrizeInfo#player_prize_info.vip_limit_exchange_list) of
			false ->
				0;
			{_, _, LimitTimes} ->
				LimitTimes
		end,
	HaveLifeTimeLimitExchangeTimes =
		case lists:keyfind(ObjId, 1, PlayerPrizeInfo#player_prize_info.life_time_limit_exchange_list) of
			false ->
				LifeTimeTimes = 0;
			{_, LifeTimeTimes} ->
				LifeTimeTimes
		end,
	if
		HaveExchangeTimes >= DailyExchaneLimit ->
			{false, "已达到每日可兑换次数"};
		VipLimit >= PlayerInfo#player_info.vip_level andalso HaveVipLimitExchangeTimes >= VipLimitExchangeLimit ->
			{false, "已达到非Vip最大兑换次数"};
		LifeTimeTimes >= LifeTimeExchangeLimit ->
			{false, "已达到终身最大兑换次数"};
		true ->
			case Cls of
				?PRIZE_CLS_REAL ->
					AddressList = PlayerPrizeInfo#player_prize_info.address_list,
					if
						AddressList == [] ->
							{false, "请先设置地址"};
						true ->
							exchange_requires(ObjId, AccDict, T)
					end;
				_ ->
					exchange_requires(ObjId, AccDict, T)
			end
	end;


exchange_requires(ObjId, AccDict, [check_db_fun|T]) ->
	%% 1电话卡
	{DBFun, DFSuccess} = get_db_fun_from_type(AccDict),
	AccDict2 = dict:store(db_fun, DBFun, AccDict),
	AccDict3 = dict:store(success_fun, DFSuccess, AccDict2),
	exchange_requires(ObjId, AccDict3, T);

exchange_requires(ObjId, AccDict, [_|T]) ->
	exchange_requires(ObjId, AccDict, T).


send_prize_exchange_reply(Result, Err, Reward, ObjId) ->
	Msg = #sc_prize_exchange_reply{
		result = Result,
		err = Err,
		reward = Reward,
		obj_id = ObjId
	},
	%io:format("prize_exchange_result:~p ~ts~n",[Result, list_to_binary(Err)]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

cs_prize_address_change_req(PbAddressInfo) ->
	case check_address_info(PbAddressInfo) of
		true ->
			PlayerPrizeInfo = get_player_prize_info(),
			NewPlayerPrizeInfo = PlayerPrizeInfo#player_prize_info{
				address_list = [PbAddressInfo]
			},
			save_player_prize_info(NewPlayerPrizeInfo),
			send_prize_address_change_reply(0, ""),
			send_prize_address_info_update(NewPlayerPrizeInfo#player_prize_info.address_list),
			ok;
		{false, Err} ->
			send_prize_address_change_reply(1, Err)
	end.

send_prize_address_change_reply(Result, Err) ->
	Msg1 = #sc_prize_address_change_reply{
		result = Result,
		err = Err
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg1).

check_address_info(_PbAddressInfo) ->
	true.

%% http_confirm_delivery(SessionID, Count)   ->
%% 	ID      = util:now_seconds(),
%% 	Data    = {obj, [{sid, erlang:list_to_binary(SessionID)}]},
%% 	Game    = {obj, [
%% 		{cpId, 40890},
%% 		{gameId, 543520},
%% 		{channelId, <<"2">>},
%% 		{serverId, 0}]
%% 	},
%% 	ApiKey   = "a02648eb7ab0f4123b5cb252161eae7b",
%% 	Sign    = sign(crypto:hash(md5, lists:concat(["40890sid=", SessionID, ApiKey]))),
%% 	Body    =   {obj, [
%% 		{id, ID},
%% 		{data, Data},
%% 		{game, Game},
%% 		{sign, erlang:list_to_binary(Sign)}
%% 	]},
%% 	Url = "http://sdk.g.uc.cn/ss/",
%% 	BodyStr = rfc4627:encode(Body),
%% 	Headers = [
%% 		{"Content-Type", "application/json"},
%% 		{"content-length",erlang:integer_to_list(length(BodyStr))}
%% 	],
%%
%% 	Res = httpc:request(post, {Url, Headers, "application/json", BodyStr}, [{timeout, 5*1000}], []),
%% 	case  Res of
%% 		{ok, {{_, 200, _}, _, Content}}  ->
%% 			{ok, JsonData, _} = rfc4627:decode(lists:concat([Content])),
%% 			{ok, State} = rfc4627:get_field(JsonData, "state"),
%% 			{ok, Code}  = rfc4627:get_field(State, "code"),
%% 			case Code of
%% 				1   ->
%% 					{ok, ResData}   = rfc4627:get_field(JsonData, "data"),
%% 					{ok, Ucid}      = rfc4627:get_field(ResData,  "ucid"),
%% 					{true, integer_to_list(Ucid)};
%% 				_   ->
%% 					{ok, ErrMsg}   =   rfc4627:get_field(State, "msg"),
%% 					{false, ErrMsg}
%% 			end;
%% 		_   ->
%% 			http_confirm_delivery(SessionID, Count-1)
%% 	end.
%%
%% sign(MD5Bin)  ->
%% 	MD5List = binary:bin_to_list(MD5Bin),
%% 	MD5List2= util:map(fun(E) ->
%% 		E2 = erlang:integer_to_list(E, 16),
%% 		case length(E2) of
%% 			1   ->  "0" ++ E2;
%% 			_   ->  E2
%% 		end
%% 	end, MD5List),
%% 	string:to_lower(lists:concat(MD5List2)).

check_player_item_enough(CostId,CostNum) ->
	PlayerInfo = player_util:get_dic_player_info(),
	BagItem = item_util:get_dic_player_bag_dict(),
	DeductList = [{CostId,CostNum}],
	item_use:deduct_item_enough(PlayerInfo, BagItem, DeductList).

get_db_fun_from_type(AccDict) ->
	%% 记录通知
	PrizeConfig = dict:fetch(exchange_config, AccDict),
	PCardChargeType = dict:fetch(card_charge_type, AccDict),
	CostList = dict:fetch(cost_item, AccDict),
	PhoneNumber = dict:fetch(phone_number, AccDict),
	PlayerPrizeInfo = get_player_prize_info(),
	{CostId, CostNeedNum} = PrizeConfig#prize_exchange_config.cost_info,
	NowTime = util:now_seconds(),
	AutoId = roleid_generator:get_auto_prize_record_id(),
	NewRec =
		#player_prize_exchange_record{
			id = AutoId,
			player_id = PlayerPrizeInfo#player_prize_info.player_id,
			record_type = PrizeConfig#prize_exchange_config.cls,
			obj_id = PrizeConfig#prize_exchange_config.id,
			need_item_id = CostId,
			need_item_num = CostNeedNum,
			second_time = NowTime
		},
	NewRec1=
		case PrizeConfig#prize_exchange_config.cls of
			?PRIZE_CLS_PHONE_CARD ->
				NewRec#player_prize_exchange_record{
					card_charge_type = PCardChargeType,
					card_number = PhoneNumber,
					card_psd = ""
				};
			?PRIZE_CLS_VIRTUAL_GOODS->
				NewRec#player_prize_exchange_record{
					card_charge_type = PCardChargeType,
					card_number = PhoneNumber,
					card_psd = ""
				};
			?PRIZE_CLS_REAL ->
				[AddressInfo] = PlayerPrizeInfo#player_prize_info.address_list,
				NewRec#player_prize_exchange_record{
					address_info = AddressInfo
				};
			_ ->
				NewRec
		end,
	DBRecord = fun() ->
			player_prize_exchange_record_db:t_write(NewRec1)
		end,
	SuccessRecord = fun() ->
			send_prize_exchange_record_update([NewRec1])
		end,
	{DBFirstPrizeReward,SuccessFirstPrizeReward,FirstReward,FirstRewardNum} = first_prize_reward(PrizeConfig,CostNeedNum),
	%% 扣除物品
	{NewPlayerInfo, DBCost, SuccessCost, _PbReward} = item_use:transc_items_reward(CostList++FirstReward, ?REWARD_TYPE_PRIZE_EXCHANGE),
	%% 记录每天购买次数
	OldExchangeList = PlayerPrizeInfo#player_prize_info.exchange_list,
	ObjId = PrizeConfig#prize_exchange_config.id,
	NewList=
		case lists:keyfind(ObjId, 1, OldExchangeList) of
			false ->
				[{ObjId, 1}|OldExchangeList];
			{_, OldTimes} ->
				lists:keystore(ObjId, 1, OldExchangeList, {ObjId, OldTimes+1})
		end,
	OldVipLimitExchangeList = PlayerPrizeInfo#player_prize_info.vip_limit_exchange_list,
	NewVipLimitExchangeList = case PrizeConfig#prize_exchange_config.vip_limit of
		no_limit ->
			OldVipLimitExchangeList;
		{ConfigLimitVip, _} ->
			case lists:keyfind(ObjId, 1, OldVipLimitExchangeList) of
				false ->
					[{ObjId, ConfigLimitVip, 1}|OldVipLimitExchangeList];
				{_, _, VipLimitOldTimes} ->
					lists:keystore(ObjId, 1, OldVipLimitExchangeList, {ObjId, ConfigLimitVip, VipLimitOldTimes+1})
			end
	end,
	OldLifeTimeLimitExchangeList = PlayerPrizeInfo#player_prize_info.life_time_limit_exchange_list,
	NewLifeTimeLimitExchangeList = case PrizeConfig#prize_exchange_config.life_time_limit of
		no_limit ->
			OldLifeTimeLimitExchangeList;
		_ ->
			case lists:keyfind(ObjId, 1, OldLifeTimeLimitExchangeList) of
				false ->
					[{ObjId, 1}|OldLifeTimeLimitExchangeList];
				{_, LiftTimeLimitOldTimes} ->
					lists:keystore(ObjId, 1, OldLifeTimeLimitExchangeList, {ObjId, LiftTimeLimitOldTimes+1})
			end
	end,
	NewPlayerPrizeInfo = PlayerPrizeInfo#player_prize_info{
		exchange_list = NewList,
		last_exchange_time = NowTime,
		vip_limit_exchange_list = NewVipLimitExchangeList,
		life_time_limit_exchange_list = NewLifeTimeLimitExchangeList
	},
	DBPrize = fun() ->
		player_prize_info_db:t_write(NewPlayerPrizeInfo)
	end,
	SuccessPrize = fun() ->
		update_player_prize_info(NewPlayerPrizeInfo)
	end,
	DBUpdate7DayCarnival = fun() ->
		if
			?PRIZE_CLS_RED_PACK =:= PrizeConfig#prize_exchange_config.cls ->
				player_7_day_carnival_util:update_7_day_carnival_mission(3, CostNeedNum),
				player_7_day_carnival_util:update_7_day_carnival_mission(6, CostNeedNum);
			true ->
				skip
		end
	end,

	DBFun = fun() ->
		DBCost(),
		DBPrize(),
		DBRecord(),
		DBUpdate7DayCarnival(),
		DBFirstPrizeReward()
	end,

	SuccessFun = fun() ->
		SuccessCost(),
		SuccessPrize(),
		SuccessRecord(),
		SuccessFirstPrizeReward(),
		send_prize_exchange_reply(0, "", [], ObjId),
		priv_cs_prize_query_one_req(ObjId, false),
		do_notice_to_http_server(NewPlayerInfo, ObjId, AutoId, PCardChargeType, PlayerPrizeInfo#player_prize_info.address_list,
			PrizeConfig#prize_exchange_config.cls, PhoneNumber
		),
		if
			PrizeConfig#prize_exchange_config.cls == 1 ->
%%				case role_manager:get_roleprocessor(PlayerPrizeInfo#player_prize_info.player_id) of
%%					{ok,Pid} ->
%%						role_processor_mod:cast(Pid,{'do_share_mission','type_prize',CostNeedNum});
%%					_->
%%						skip
%%				end,
				if
					1 =:= ?SUPERFRUIT -> 
						Content = lists:concat(["亲爱的玩家，您已成功兑换了",PrizeConfig#prize_exchange_config.dsc,"，现已到账，请到微信支付记录中查看。"]);
					true ->
						Content = lists:concat(["亲爱的玩家，您已成功兑换了",PrizeConfig#prize_exchange_config.dsc,"，您可自助领取。\n\n红包领取流程：
							1.  游戏内兑换红包\n2.  搜索关注公众号“????”\n3.  点击“红包领取”按钮\n4.  点击领取对应金额红包"])
				end,
				player_mail:send_system_mail(PlayerPrizeInfo#player_prize_info.player_id,1,?MAIL_TYPE_PRIZE,"微信红包兑换成功",Content,[]);
			PrizeConfig#prize_exchange_config.cls == 5 ->
				CustomerServiceQQ = player_util:get_server_const(?CONST_CONFIG_KEY_CUSTOMER_SERVICE_QQ),
				Content = lists:concat(["亲爱的玩家，您已成功兑换了",PrizeConfig#prize_exchange_config.dsc,"，请您联系客服",CustomerServiceQQ,"，提供您相应的账号信息，以便我们核实信息发放奖励"]),
				player_mail:send_system_mail(PlayerPrizeInfo#player_prize_info.player_id,1,?MAIL_TYPE_PRIZE,"您已成功兑换",Content,[]);
			true ->
				skip
		end,
		if
			FirstRewardNum == 0 ->
				skip;
			true ->
				http_static_util:post_first_redgold(NewPlayerInfo,PrizeConfig#prize_exchange_config.name,FirstRewardNum,util:now_seconds())
		end,
		if
			ObjId == 99016 orelse ObjId == 99018 ->
				player_mission:daily_5_yuan_redpack_prize(1);
			ObjId == 99050 ->
				player_mission:daily_1_yuan_redpack_prize(1);
			true ->
				skip
		end,
		if
			FirstReward == []->
				skip;
			true ->
				PbRewards = item_use:get_pb_reward_info(FirstReward),
				player_mission:send_draw_mission_back(0,"",PbRewards)
		end,
		announcement_server:prize_something(NewPlayerInfo#player_info.player_name, ObjId)
	end,
	{DBFun, SuccessFun}.

%% 通知小纯洁
do_notice_to_http_server(NewPlayerInfo, PrizeObjId, AutoId, _PCardChargeType, AddressInfo1, Cls, PhoneNumber) ->
	case AddressInfo1 of
		[] ->
			AddressPhoneNum = <<"0">>,
			PlayerName = <<"">>,
			Province = <<"">>,
			City = <<"">>,
			AdressStr = <<"">>;
		[AddressInfo] ->
			PlayerName = AddressInfo#pb_prize_address_info.name,
			case Cls of
				?PRIZE_CLS_REAL ->
					#pb_prize_address_info{
						province_name = Province,
						city_name = City,
						address = AdressStr,
						phone_number = AddressPhoneNum
					} = AddressInfo;
				_ ->
					AddressPhoneNum = <<"0">>,
					Province = <<"">>,
					City = <<"">>,
					AdressStr = <<"">>
			end
	end,


	case Cls of
		?PRIZE_CLS_PHONE_CARD ->
			case PhoneNumber of
				undefined ->
					PhoneNum = <<"0">>;
				_ ->
					PhoneNum = list_to_binary(PhoneNumber)
			end;
		?PRIZE_CLS_VIRTUAL_GOODS ->
			case PhoneNumber of
				undefined ->
					PhoneNum = <<"0">>;
				_ ->
					PhoneNum = list_to_binary(PhoneNumber)
			end;
		_ ->
			PhoneNum = AddressPhoneNum
	end,

	%% 提交订单 实物的带地址信息
	case PlayerName of
		<<"">> ->
			PlayerName1 = list_to_binary(NewPlayerInfo#player_info.player_name);
		_ ->
			PlayerName1 = PlayerName
	end,
	http_static_util:post_prize_exchange(NewPlayerInfo, PlayerName1, AutoId, PhoneNum, PrizeObjId, 1, Cls, Province, City, AdressStr).

%% is_phone_card(PrizeObjId) ->
%% 	PrizeObjId >= 99001 andalso PrizeObjId =< 99004.


test_change_rechage_record() ->
	PlayerInfo = player_util:get_dic_player_info(),
	Pattern = #player_prize_exchange_record{
		player_id = PlayerInfo#player_info.id,
		record_type = ?PRIZE_CLS_PHONE_CARD,
		card_charge_type = 2,	%% 2卡密
		_ = '_'
	},
	DBFun = fun() ->	List = mnesia:match_object(Pattern),
		lists:foreach(fun(ERec) ->
			NewRec = ERec#player_prize_exchange_record{
				card_state = 1,
				card_number = "12312312",
				card_psd = "xxccxxzzz"
			},
			player_prize_exchange_record_db:write(NewRec),
			send_prize_exchange_record_update([NewRec])
		end, List)
	end,
	{atomic, _} = dal:run_transaction_rpc(DBFun).

%% 查询卡密id
cs_prize_query_phonecard_key_req(OrderId1) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		OrderId1 == "0" ->
			send_login_record_update(PlayerInfo#player_info.id);
		true ->
			PlayerId = PlayerInfo#player_info.id,
			{ok, OrderId} = id_transform_util:item_id_to_internal(OrderId1),
			{Result, Data} =
				case player_prize_exchange_record_db:get(OrderId) of
					{ok, [Record]} ->
						if
							Record#player_prize_exchange_record.player_id == PlayerId ->
								if
									Record#player_prize_exchange_record.record_type == ?PRIZE_CLS_PHONE_CARD andalso
										Record#player_prize_exchange_record.card_charge_type == ?PHONE_CARD_CHARGE_TYPE_CDKEY ->
										{true, Record};
									true ->
										{false, "订单类型错误"}
								end;
							true ->
								{false, "非法操作"}
						end;
					_ ->
						{false, "订单号错误"}
				end,

			case Result of
				true ->
					%% 获取卡密
					{State, Key} = http_query_order_state(OrderId1, PlayerInfo#player_info.account),
					send_prize_query_phonecard_key_reply(0, "", State, Key);
				_ ->
					send_prize_query_phonecard_key_reply(1, Data, 0, "")
			end
	end.

send_prize_query_phonecard_key_reply(Result, Err, State, Key) ->
	Msg = #sc_prize_query_phonecard_key_reply{
		result = Result,
		err = Err,
		state = State,
		key = Key
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

http_query_order_state(OrderId, Account) ->
	Url = lists:concat([config_app:get_exchange_http_url(), "checkstate"]),
	List = [
		{"uid", Account},
		{"ordersn", OrderId}
	],
	ParamStr = http_static_util:get_param_string(List),
	try
		case httpc:request(post, {Url, [], "application/x-www-form-urlencoded;charset=utf-8", ParamStr}, [{timeout, 2*1000}], []) of
			{ok, {{_, 200, _}, _, Content}}  ->
				{ok, JsonData, _} = rfc4627:decode(Content),
				{ok, Code}  = rfc4627:get_field(JsonData, "code"),
				case Code of
					0   ->
						{ok, KeyData}   =   rfc4627:get_field(JsonData, "data"),
						{ok, CardNo}   =   rfc4627:get_field(KeyData, "cardno"),
						{ok, CardPwd}   =   rfc4627:get_field(KeyData, "cardpwd"),
						{0, lists:concat([binary_to_list(CardNo), ",", binary_to_list(CardPwd)])};
					_   ->
						{1, ""}
				end;
			_ ->
				?INFO_LOG("http_query_order_state Failed ~p~n ", [{?MODULE, ?LINE}]),
				{1, ""}
		end
	catch
		_ ->
			?INFO_LOG("http_query_order_state Error ~p~n ", [{?MODULE, ?LINE}]),
			{1, ""}
	end.


handle_time(OldSec, NewSec) ->
	case util:is_same_date(OldSec, NewSec) of
		true ->
			skip;
		_ ->
			PlayerPrizeInfo = get_player_prize_info(),
			PlayerPrizeInfo1 = check_time_and_vip(PlayerPrizeInfo),
			if
				PlayerPrizeInfo1 == PlayerPrizeInfo ->
					update_player_prize_info(PlayerPrizeInfo1);
				true ->
					save_player_prize_info(PlayerPrizeInfo1)
			end
	end.

init_first_prize_reward(PlayerId)->
	case player_first_prize_reward_db:get(PlayerId) of
		{ok,[Info]}->
			update_first_prize_reward_info(Info);
		_->
			Info = #player_first_prize_reward{
				player_id = PlayerId,
				times = 0,
				refresh_time = util:now_seconds()
			},

			save_first_prize_reward_info(Info)
	end.

%%first_prize_reward_check_time_and_vip(Info)->
%%	NowSec = util:now_seconds(),
%%	case util:is_same_date(Info#player_first_prize_reward.refresh_time, NowSec) of
%%		true ->
%%			Info;
%%		_->
%%			Info#player_first_prize_reward{
%%				times = 0,
%%				refresh_time = NowSec
%%			}
%%	end.

get_first_prize_reward_info() ->
	get(?PLAYER_FIRST_PRIZE_REWARD).

update_first_prize_reward_info(Val) ->
	put(?PLAYER_FIRST_PRIZE_REWARD, Val).

save_first_prize_reward_info(NewInfo)->
	DBFun =
		fun() ->
			player_first_prize_reward_db:t_write(NewInfo)
		end,
	DBSuccessFun =
		fun() ->
			update_first_prize_reward_info(NewInfo)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}])
	end.

first_prize_reward(PrizeConfig,CostNeedNum)-> %% 随机奖励
	Info = get_first_prize_reward_info(),
	if
		PrizeConfig#prize_exchange_config.cls == 1 ->
			case first_prize_reward_config_db:get(1) of
				{ok,[Config]} ->
					NewInfo = Info#player_first_prize_reward{
						times = Info#player_first_prize_reward.times + 1
					},
					if
						Config#first_prize_reward_config.condition > CostNeedNum ->
							{fun() -> player_first_prize_reward_db:t_write(NewInfo) end,fun() -> update_first_prize_reward_info(NewInfo) end,[],0};
						Info#player_first_prize_reward.times >= ?FIRST_REWARD_LIMIT_TIMES ->
							{fun() -> void end,fun() -> void end,[],0};
						true ->
							[WinPos1] = util_random:get_random_rewards(Config#first_prize_reward_config.weight_list),
							{fun() -> player_first_prize_reward_db:t_write(NewInfo) end,fun() -> update_first_prize_reward_info(NewInfo) end,[{?ITEM_ID_GOLD,WinPos1}],WinPos1}
					end;
				_->
					{fun() -> void end,fun() -> void end,[],0}
			end;
		true ->
			{fun() -> void end,fun() -> void end,[],0}
	end.

gm_test(Type)->
	if
		Type == 1 ->
			PlayerInfo = player_util:get_dic_player_info(),
			player_first_prize_reward_db:delete(PlayerInfo#player_info.id);
		true ->
			skip
	end.

cs_cash_transformation_req(Num)->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		Num < 0 ->
			send_prize_exchange_reply(1, "参数错误", [], 0);
		PlayerInfo#player_info.cash < Num ->
			send_prize_exchange_reply(1, "奖券不足", [], 0);
		true ->
			GoldNum = cash_convert_to_gold(Num),
			Rewards = [{?ITEM_ID_CASH,-Num},{?ITEM_ID_GOLD,GoldNum}],
			{_NewPlayerInfo, DBFun1, SuccessFun1, Pbrewards} =
				item_use:transc_items_reward(Rewards, ?REWARD_TYPE_CASH_TRANSFORMATION),
			case dal:run_transaction_rpc(DBFun1) of
				{atomic, _} ->
					SuccessFun1(),
					send_prize_exchange_reply(0, "", Pbrewards, 0);
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_prize_exchange_reply(1, "数据库错误",[], 0)
			end
	end.

cash_convert_to_gold(Num)->
	player_util:get_server_const(?CONST_CONFIG_KEY_CASH_TO_GOLD) * Num.

redpack_direct_gold_transformation_req(ObjId) ->
	case prize_exchange_config_db:get_base(ObjId) of
		{ok, [PrizeConfig]} ->
			{CostId, CostNum} = PrizeConfig#prize_exchange_config.cost_info,
			case check_player_item_enough(CostId, -CostNum) of
				true ->
					PlayerPrizeInfo = get_player_prize_info(),
					NowTime = util:now_seconds(),
					AutoId = roleid_generator:get_auto_prize_record_id(),
					NewRec = #player_prize_exchange_record{
						id = AutoId,
						player_id = PlayerPrizeInfo#player_prize_info.player_id,
						record_type = PrizeConfig#prize_exchange_config.cls,
						obj_id = PrizeConfig#prize_exchange_config.id,
						need_item_id = CostId,
						need_item_num = CostNum,
						second_time = NowTime
					},
					Rewards = [{CostId,-CostNum},{?ITEM_ID_GOLD,PrizeConfig#prize_exchange_config.item_num}],
					{_NewPlayerInfo, DBCostFun, DBSuccessCostFun, Pbrewards} = item_use:transc_items_reward(Rewards, ?REWARD_TYPE_REDPACK_DIRECT_TO_GOLD),
					%% 记录每天购买次数
					OldExchangeList = PlayerPrizeInfo#player_prize_info.exchange_list,
					ObjId = PrizeConfig#prize_exchange_config.id,
					NewList=
						case lists:keyfind(ObjId, 1, OldExchangeList) of
							false ->
								[{ObjId, 1}|OldExchangeList];
							{_, OldTimes} ->
								lists:keystore(ObjId, 1, OldExchangeList, {ObjId, OldTimes+1})
						end,
					OldVipLimitExchangeList = PlayerPrizeInfo#player_prize_info.vip_limit_exchange_list,
					NewVipLimitExchangeList = case PrizeConfig#prize_exchange_config.vip_limit of
						no_limit ->
							OldVipLimitExchangeList;
						{ConfigLimitVip, _} ->
							case lists:keyfind(ObjId, 1, OldVipLimitExchangeList) of
								false ->
									[{ObjId, 1}|OldVipLimitExchangeList];
								{_, _, VipLimitOldTimes} ->
									lists:keystore(ObjId, 1, OldVipLimitExchangeList, {ObjId, ConfigLimitVip, VipLimitOldTimes+1})
							end
					end,
					OldLifeTimeLimitExchangeList = PlayerPrizeInfo#player_prize_info.life_time_limit_exchange_list,
					NewLifeTimeLimitExchangeList = case PrizeConfig#prize_exchange_config.life_time_limit of 
						no_limit->
							OldLifeTimeLimitExchangeList;
						_  ->
							case lists:keyfind(ObjId, 1, OldLifeTimeLimitExchangeList) of
								false ->
									[{ObjId, 1}|OldLifeTimeLimitExchangeList];
								{_, LifeTimeLimitOldTimes} ->
									lists:keystore(ObjId, 1, OldLifeTimeLimitExchangeList, {ObjId, LifeTimeLimitOldTimes+1})
							end
					end,
					NewPlayerPrizeInfo = PlayerPrizeInfo#player_prize_info{
						exchange_list = NewList,
						last_exchange_time = NowTime,
						vip_limit_exchange_list = NewVipLimitExchangeList,
						life_time_limit_exchange_list = NewLifeTimeLimitExchangeList
					},
					DBFun = fun () -> 
						DBCostFun(),
						player_prize_info_db:t_write(NewPlayerPrizeInfo),
						player_prize_exchange_record_db:t_write(NewRec)
					end,
					DBSuccessFun = fun () ->
						DBSuccessCostFun(),
						update_player_prize_info(NewPlayerPrizeInfo),
						send_prize_exchange_record_update([NewRec]),
						send_prize_exchange_reply(0, "", Pbrewards, 0),
						cs_prize_query_one_req(ObjId)
						%do_notice_to_http_server(NewPlayerInfo, ObjId, AutoId, ?PRIZE_CLS_DIRECT_TO_GOLD,
						%	"",PrizeConfig#prize_exchange_config.cls, "")
					end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							send_prize_exchange_reply(1, "数据库错误",[], 0)
					end;
				_ ->
					send_prize_exchange_reply(1, "消耗品不足",[], 0)
			end;
		_ ->
			send_prize_exchange_reply(1, "物品id不存在",[], 0)
	end.