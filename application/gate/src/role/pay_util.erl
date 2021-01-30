%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 20:43
%%%-------------------------------------------------------------------
-module(pay_util).
-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

%% API
-export([
	handle_pay/4,
	pay_receive_handle/1,
	handle_already_receive_pay_info/0
]).

pay_receive_handle(Id) ->
	case already_receive_pay_info_db:load_already_receive_pay_info(Id) of
		{ok, [AlreadyReceivePayInfo]}   ->
			pay_receive_handle1(AlreadyReceivePayInfo);
		_   ->
			?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}]),
			ok
	end.

%% 获得订单的处理状态
get_order_handle_status(OrderID) ->
	case already_enter_pay_info_db:load_already_enter_pay_info(OrderID) of
		{ok, []} ->
			true;
		{ok, [AlreadyEnterPayInfo]} ->
			case string:strip(AlreadyEnterPayInfo#already_enter_pay_info.order_status) of
				"1" -> false;  %%  已经成功支付了
				_ -> true    %%  存在，但是未成功支付
			end;
		_ ->
			false
	end.

pay_receive_handle1(AlreadyReceivePayInfo) ->
	PlayerInfo = player_util:get_dic_player_info(),
	Id = AlreadyReceivePayInfo#already_receive_pay_info.id,
	OrderID = string:strip(AlreadyReceivePayInfo#already_receive_pay_info.order_id),
	HandleFlag = get_order_handle_status(OrderID),
	case HandleFlag of
		true    ->
			case string:strip(AlreadyReceivePayInfo#already_receive_pay_info.order_status) == "1" of
				true ->
					{DBFun, DBSuccessFun} = handle_pay(AlreadyReceivePayInfo, PlayerInfo, Id, true),
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _ }    ->  DBSuccessFun();
						_               ->  void
					end;
				false   ->
					%%  发送给客户端提示信息
					case player_util:get_dic_gate_pid() of
						undefined   ->
							void;
						GateProc    ->
							SendTextTips =
								#sc_tips{
									type = 2,
									text = "order_status Error"
								},
							tcp_client:send_data(GateProc, SendTextTips)
					end,
					ok
			end;
		false   ->
			%%  不处理
			ok
	end.

%% 获得充值类型购买的情况
get_recharge_type_buy_info(PlayerID, Pid) ->
	case already_player_id_pid_to_count_db:load_already_player_id_pid_to_count(PlayerID, Pid) of
		{ok, [AlreadyPlayerIDPidToCount]} ->
			void;
		_ ->
			AlreadyPlayerIDPidToCount = #already_player_id_pid_to_count{player_id_pid = {PlayerID, Pid},
				player_id = PlayerID,
				pid = Pid,
				count = 0}
	end,
	AlreadyPlayerIDPidToCount.

%%
%% handle_pay(AlreadyReceivePayInfo, PlayerInfo, ID, _IsOnlinePay) ->
%% 	%NowSeconds = util:now_seconds(),
%% 	CallBack = AlreadyReceivePayInfo#already_receive_pay_info.call_back,
%% 	[PidTmp,_ | _] = string:tokens(CallBack, ","),
%% 	{Pid,_} = string:to_integer(string:strip(PidTmp)),
%% 	PlayerID = PlayerInfo#player_info.id,
%%
%% 	AlreadyPlayerIDPidToCount = get_recharge_type_buy_info(PlayerID, Pid),
%% 	{ok, [PayItemInfo]} = base_vip_recharge_db:load_pay_item_info(Pid),
%%
%% 	%% 根据购买情况赠送相应的宝石
%% 	{_DiamondRewards, TotalDiamondNum} =
%% 		case AlreadyPlayerIDPidToCount#already_player_id_pid_to_count.count > 0 of
%% 			true ->
%% 				{[{diamond, PayItemInfo#base_vip_recharge.not_first_extra}], PayItemInfo#base_vip_recharge.not_first_extra + PayItemInfo#base_vip_recharge.award_base};
%% 			false ->
%% 				% 首次购买
%% 				{[{diamond, PayItemInfo#base_vip_recharge.first_extra}], PayItemInfo#base_vip_recharge.first_extra + PayItemInfo#base_vip_recharge.award_base}
%% 		end,
%%
%% 	%% 在线购买，发送提示信息
%% 	SendTextTipsSuccessFun =
%% 		fun() ->
%% 			case player_util:get_dic_gate_pid() of
%% 				undefined ->
%% 					void;
%% 				GateProc ->
%% 					Text =
%% 						case TotalDiamondNum =< PayItemInfo#base_vip_recharge.award_base of
%% 							true ->
%% 								io_lib:format("购买成功【~p】元宝", [PayItemInfo#base_vip_recharge.award_base]);
%% 							false   ->
%% 								io_lib:format("购买成功【~p】元宝\n赠送【~p】元宝",
%% 									[PayItemInfo#base_vip_recharge.award_base, TotalDiamondNum - PayItemInfo#base_vip_recharge.award_base])
%% 						end,
%% 					SendTextTips = #sc_tips{type =1, text = Text},
%% 					tcp_client:send_data(GateProc, SendTextTips)
%% 			end
%% 		end,
%%
%% 	NewAlreadyPlayerIDPidToCount = AlreadyPlayerIDPidToCount#already_player_id_pid_to_count{
%% 		count = AlreadyPlayerIDPidToCount#already_player_id_pid_to_count.count + 1},
%% 	{_PlayerInfo1, DBFunPlayerInfo, DBSuccessFunPlayerInfo, _} = item_use:transc_items_reward(
%% 		[{?ITEM_ID_RMB, PayItemInfo#base_vip_recharge.price}, {?ITEM_ID_DIAMOND, TotalDiamondNum}],
%% 		?REWARD_TYPE_RECHARGE_DIAMOND),
%% 	%NewRecharge = PlayerInfo1#player_info.recharge_money + PayItemInfo#base_vip_recharge.price,
%%
%% 	%?INFO_LOG("NewRecharge ~p Vip ~p",[NewRecharge, player_vip_util:calc_new_vip_level(NewRecharge)]),
%% %% 	NewPlayerInfo =
%% %% 		PlayerInfo1#player_info{
%% %% 			vip_level = player_vip_util:calc_new_vip_level(NewRecharge),
%% %% 			recharge_money = NewRecharge
%% %% 		},
%%
%% 	AlreadyEnterPayInfo1 =
%% 		#already_enter_pay_info{
%% 			order_id = AlreadyReceivePayInfo#already_receive_pay_info.order_id,
%% 			money = PayItemInfo#base_vip_recharge.price,
%% 			server_id = AlreadyReceivePayInfo#already_receive_pay_info.server_id,
%% 			role_id = AlreadyReceivePayInfo#already_receive_pay_info.role_id,
%% 			call_back = AlreadyReceivePayInfo#already_receive_pay_info.call_back,
%% 			openid = AlreadyReceivePayInfo#already_receive_pay_info.openid,
%% 			order_status = AlreadyReceivePayInfo#already_receive_pay_info.order_status,
%% 			pay_type = AlreadyReceivePayInfo#already_receive_pay_info.pay_type,
%% 			pay_time = AlreadyReceivePayInfo#already_receive_pay_info.pay_time,
%% 			chn_id = AlreadyReceivePayInfo#already_receive_pay_info.chn_id,
%% 			sub_chn_id = AlreadyReceivePayInfo#already_receive_pay_info.sub_chn_id,
%% 			remark = AlreadyReceivePayInfo#already_receive_pay_info.remark
%% 		},
%%
%%
%% 	DBFun =
%% 		fun() ->
%% 			already_player_id_pid_to_count_db:t_write_already_player_id_pid_to_count(NewAlreadyPlayerIDPidToCount),
%% 			already_receive_pay_info_db:t_delete_already_receive_pay_info(ID),
%% 			already_enter_pay_info_db:t_write_already_enter_pay_info(AlreadyEnterPayInfo1),
%% 			DBFunPlayerInfo(),
%% 			player_mission:recharge(PayItemInfo#base_vip_recharge.price)
%% 		end,
%%
%% 	DBSuccessFun =
%% 		fun() ->
%% 			SendTextTipsSuccessFun(),
%% 			DBSuccessFunPlayerInfo()
%% 		end,
%% 	{DBFun, DBSuccessFun}.


handle_pay(AlreadyReceivePayInfo, PlayerInfo, ID, _IsOnlinePay) ->
	%NowSeconds = util:now_seconds(),
	CallBack = AlreadyReceivePayInfo#already_receive_pay_info.call_back,
	[PidTmp,_ | _] = string:tokens(CallBack, ","),
	{Pid,_} = string:to_integer(string:strip(PidTmp)),
	PlayerID = PlayerInfo#player_info.id,

	AlreadyPlayerIDPidToCount = get_recharge_type_buy_info(PlayerID, Pid),
	[PayItemInfo] = ets:lookup(?ETS_SHOP_ITEM, Pid),
	[_, RechargeRmb] = PayItemInfo#base_shop_item.cost_list,
	[_, IgnoreRmb] = PayItemInfo#base_shop_item.player_lv_ignore_cost,

	%% 在线购买，发送提示信息
	SendTextTipsSuccessFun =
		fun() ->
			case player_util:get_dic_gate_pid() of
				undefined ->
					void;
				GateProc ->
					Text = lists:concat(["成功购买 : ", PayItemInfo#base_shop_item.name]),
					SendTextTips = #sc_tips{type =2, text = Text},
					tcp_client:send_data(GateProc, SendTextTips)
			end
		end,

	NewAlreadyPlayerIDPidToCount = AlreadyPlayerIDPidToCount#already_player_id_pid_to_count{
		count = AlreadyPlayerIDPidToCount#already_player_id_pid_to_count.count + 1},
	{_PlayerInfo1, DBFunPlayerInfo, DBSuccessFunPlayerInfo, _} = item_use:transc_items_reward(
		[{?ITEM_ID_RMB, RechargeRmb - IgnoreRmb}],
		?REWARD_TYPE_RECHARGE_DIAMOND),

	AlreadyEnterPayInfo1 =
		#already_enter_pay_info{
			order_id = AlreadyReceivePayInfo#already_receive_pay_info.order_id,
			money = RechargeRmb,
			server_id = AlreadyReceivePayInfo#already_receive_pay_info.server_id,
			role_id = AlreadyReceivePayInfo#already_receive_pay_info.role_id,
			call_back = AlreadyReceivePayInfo#already_receive_pay_info.call_back,
			openid = AlreadyReceivePayInfo#already_receive_pay_info.openid,
			order_status = AlreadyReceivePayInfo#already_receive_pay_info.order_status,
			pay_type = AlreadyReceivePayInfo#already_receive_pay_info.pay_type,
			pay_time = AlreadyReceivePayInfo#already_receive_pay_info.pay_time,
			chn_id = AlreadyReceivePayInfo#already_receive_pay_info.chn_id,
			sub_chn_id = AlreadyReceivePayInfo#already_receive_pay_info.sub_chn_id,
			remark = AlreadyReceivePayInfo#already_receive_pay_info.remark
		},

	DBFun =
		fun() ->
			already_player_id_pid_to_count_db:t_write_already_player_id_pid_to_count(NewAlreadyPlayerIDPidToCount),
			already_receive_pay_info_db:t_delete_already_receive_pay_info(ID),
			already_enter_pay_info_db:t_write_already_enter_pay_info(AlreadyEnterPayInfo1),
			DBFunPlayerInfo(),
			player_mission:recharge(RechargeRmb)
		end,

	DBSuccessFun =
		fun() ->
			SendTextTipsSuccessFun(),
			DBSuccessFunPlayerInfo(),
			player_shop:cs_buy(Pid, 'back'),
			player_share_util:do_share_mission(PlayerID,
				PlayerInfo#player_info.recharge_money + RechargeRmb)
		end,
	{DBFun, DBSuccessFun}.


%% 登录处理充值
handle_already_receive_pay_info() ->
	PlayerInfo = player_util:get_dic_player_info(),

	{ok, AlreadyRecievePayInfoList} = already_receive_pay_info_db:load_already_receive_pay_info_by_openid(PlayerInfo#player_info.account),
	handle_already_receive_pay_info(AlreadyRecievePayInfoList).

handle_already_receive_pay_info([]) ->
	ok;
handle_already_receive_pay_info([AlreadyReceivePayInfo | T] = AlreadyRecievePayInfoList) ->
	PlayerInfo = player_util:get_dic_player_info(),
	ID = AlreadyReceivePayInfo#already_receive_pay_info.id,
	case string:strip(AlreadyReceivePayInfo#already_receive_pay_info.order_status) of
		"1" ->
			OrderID = string:strip(AlreadyReceivePayInfo#already_receive_pay_info.order_id),
			HandleFlag = get_order_handle_status(OrderID),
			case HandleFlag of
				true ->
					{DBFun, DBSuccessFun} = handle_pay(AlreadyReceivePayInfo, PlayerInfo, ID, false);
				false ->
					DBFun = fun() -> already_receive_pay_info_db:t_delete_already_receive_pay_info(ID) end,
					DBSuccessFun = fun() -> void end
			end;
		_ ->
			DBFun = fun() ->
				already_receive_pay_info_db:t_delete_already_receive_pay_info(ID)
			end,
			DBSuccessFun = fun() -> void end
	end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			handle_already_receive_pay_info(T);
		_ ->
			handle_already_receive_pay_info(AlreadyRecievePayInfoList)
	end.
