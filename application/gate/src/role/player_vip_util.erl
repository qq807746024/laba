%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 21:04
%%%-------------------------------------------------------------------
-module(player_vip_util).
-author("wodong_0013").

-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/red_pack_pb.hrl").

-define(RED_PACK_CREAT_VIP_LV, 3).
-define(RED_PACK_OPEN_VIP_LV, 0).


%% API
-export([
  init_player_vip/1,
  calc_new_vip_level/1,
  cs_vip_daily_reward/0,
  is_can_create_red_pack/0,
  is_can_open_red_pack/0,
  gm_test/2

]).
%%1.玩家获得VIP等级后，每天在登录奖励界面还可领取额外的金币奖励。TODO 每日刷新
%%3.发红包限制 猜红包

get_player_vip(PlayerId) ->
	case player_vip_daily_reward_db:get(PlayerId) of
		{ok, [PlayerVip]} ->
			PlayerVip;
		_ ->
			#player_vip_daily_reward{
				player_id = PlayerId
			}
	end.

init_player_vip(PlayerId) ->
	case player_vip_daily_reward_db:get(PlayerId) of
		{ok, [_PlayerVip]} ->
			skip;
		_ ->
			NewPlayerVip =
				#player_vip_daily_reward{
					player_id = PlayerId,
					daily_reward_draw_time = 946656000
				},
			save_player_vip_info(NewPlayerVip)
	end.

save_player_vip_info(NewPlayerVip) ->
	DBFun =
		fun() ->
			player_vip_daily_reward_db:t_write(NewPlayerVip)
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


%%计算vip等级
calc_new_vip_level(TotalRechargeRmb) ->
	VipList1 = base_vip_db:get_base(),
	VipList = lists:keysort(#base_vip.level, VipList1),
	case calc_vip_level(TotalRechargeRmb, VipList) of
		'max' ->
			Last = lists:last(VipList),
			Last#base_vip.level;
		Level ->
			Level
	end.

calc_vip_level(_TotalRechargeRmb, []) ->'max';
calc_vip_level(TotalRechargeRmb, [Base | T]) ->
	if
		TotalRechargeRmb == Base#base_vip.upgrade_exp ->
			Base#base_vip.level;
		TotalRechargeRmb > Base#base_vip.upgrade_exp ->
			calc_vip_level(TotalRechargeRmb, T);
		true ->
			Base#base_vip.level - 1
	end.

%% 领取VIP特别奖励
cs_vip_daily_reward() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerVip = get_player_vip(PlayerInfo#player_info.id),
	VipLv = PlayerInfo#player_info.vip_level,
	Check = case base_vip_db:get_base(VipLv) of
		{ok, [VipBase]} ->
			% 检测是否今日领取
			%?INFO_LOG("vip~p~n",[PlayerVip]),
			case check_daily_rewad(PlayerVip) of
				{false, Err} ->
					{false, Err};
				_ ->
					get_daily_rewad(VipBase#base_vip.daily_login_reward)
			end;
		_ ->
			{false, "vip等级不足"}
	end,
	case Check of
		{false, Err1} ->
			send_vip_daily_reward_back(1, Err1, []);
		Reward ->
			NowSec = util:now_seconds(),
			NewPlayerVip = PlayerVip#player_vip_daily_reward{
				daily_reward_draw_time = NowSec
			},
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward([Reward], ?REWARD_TYPE_VIP_SEPCIAL_REWARD),
			DBFun = fun() ->
				DBFun1(),
				player_vip_daily_reward_db:t_write(NewPlayerVip)
			end,
			DBSuccessFun = fun() ->
				SuccessFun1(),
				send_vip_daily_reward_back(0, "", item_use:get_pb_reward_info([Reward]))
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_vip_daily_reward_back(1, "数据库错误", [])
			end
	end,
	ok.
%% 领取VIP特别奖励返回
send_vip_daily_reward_back(Result, Err, Rewards) ->
	Msg = #sc_vip_daily_reward{
		result = Result,
		err = Err,
		rewards = Rewards
	},
	%?INFO_LOG("sc_vip_daily_reward~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

%% VIP特别奖励
get_daily_rewad(List) ->
	[_, Id, Num] = List,
	{Id, Num}.

check_daily_rewad(PlayerVip) ->
	NowSec = util:now_seconds(),
	OldSec = PlayerVip#player_vip_daily_reward.daily_reward_draw_time,
	Flag = util:is_same_date(OldSec, NowSec),
	if
		Flag ->
			{false, "已领取"};
		true ->
			ok
	end.

is_can_create_red_pack() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerInfo#player_info.vip_level >= ?RED_PACK_CREAT_VIP_LV.

is_can_open_red_pack() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerInfo#player_info.vip_level >= ?RED_PACK_OPEN_VIP_LV.

%%check_time(NewSec, PlayerVip) ->
%%  %?INFO_LOG("vip_time~p~n",[PlayerVip#player_vip.daily_reward_draw_time]),
%%  case util:is_same_date(PlayerVip#player_vip.daily_reward_draw_time, NewSec) of
%%    true ->
%%      PlayerVip;
%%    false ->
%%      PlayerVip#player_vip{
%%        daily_reward_draw_time = NewSec
%%      }
%%  end.

gm_test(Type, _Key) ->
	if
		Type == 1 ->
			cs_vip_daily_reward();
		Type == 2 ->
			PlayerInfo = player_util:get_dic_player_info(),
			NewPlayerInfo = PlayerInfo#player_info{
				recharge_money = 99999,
				vip_level = calc_new_vip_level(99999)
			},
			player_util:save_player_info(NewPlayerInfo),
			player_util:send_player_info(),
			ok;
		true ->
			skip
	end.