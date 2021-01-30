%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 四月 2017 14:52
%%% 招财金牛
%%%-------------------------------------------------------------------
-module(player_golden_bull_util).
-author("wodong_0013").
-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/shop_pb.hrl").

-define(PLAYER_GOLDEN_BULL_MISSION, player_golden_bull_mission).
-define(GOLDEN_BULL_FORCE_DAILY_REFRESH, true).

%% API
-export([
	init/1,
	send_init_msg/0,
	cs_golden_bull_draw_req/1,
	cs_golden_bull_mission/0,
	update_mission/1,
	handle_time/2
]).


init(PlayerId) ->
	case player_golden_bull_db:get(PlayerId) of
		{ok, [_PlayerGolden]} ->
			skip;
		_ ->
			NewPlayerGolden =
				#player_golden_bull{
					player_id = PlayerId,
					last_draw_time = 946656000
				},
			save_player_gold_info(NewPlayerGolden)
	end,
	init_golden_bull_mission(PlayerId).

save_player_gold_info(NewPlayerGolden) ->
	DBFun =
		fun() ->
			player_golden_bull_db:t_write(NewPlayerGolden)
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

init_golden_bull_mission(PlayerId)->
	case player_golden_bull_mission_db:get(PlayerId) of
		{ok, [PlayerGoldenMission]} ->
			NewPlayerGoldenMission =  check_time(PlayerGoldenMission),
			if
				NewPlayerGoldenMission == PlayerGoldenMission ->
					update_player_golden_bull_mission(NewPlayerGoldenMission);
				true ->
					save_player_golden_bull_mission(NewPlayerGoldenMission)
			end;
		_ ->
			NewPlayerGoldenMission =
				#player_golden_bull_mission{
					player_id = PlayerId,
					process = 0,
					status = 0,
					last_refresh_time = 946656000
				},
			save_player_golden_bull_mission(NewPlayerGoldenMission)
	end.

update_player_golden_bull_mission(Val)->
	put(?PLAYER_GOLDEN_BULL_MISSION,Val).

get_player_golden_bull_mission()->
	get(?PLAYER_GOLDEN_BULL_MISSION).

save_player_golden_bull_mission(NewPlayerGolden) ->
	DBFun =
		fun() ->
			player_golden_bull_mission_db:t_write(NewPlayerGolden)
		end,
	DBSuccessFun =
		fun() ->
			update_player_golden_bull_mission(NewPlayerGolden)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			true;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	LeftTime = check_have_left_time(PlayerInfo#player_info.id),
	send_golden_bull_info_update(LeftTime).

send_golden_bull_info_update(LeftTime) ->
	Msg = #sc_golden_bull_info_update{
		left_times = LeftTime
	},
%%	?INFO_LOG("sc_golden_bull_info_update~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

check_have_left_time(PlayerId) ->
	{ok, [PlayerGoldenBull]} = player_golden_bull_db:get(PlayerId),
	case util:is_same_date(util:now_seconds(), PlayerGoldenBull#player_golden_bull.last_draw_time) of
		true ->
			0;
		_ ->
			1
	end.

cs_golden_bull_draw_req(Key) ->
	PlayerInfo = player_util:get_dic_player_info(),
	RechargeRmb = PlayerInfo#player_info.recharge_money,
	PlayerGoldenMission = get_player_golden_bull_mission(),

	CheckData =
		case golden_bull_reward_config_db:get_base(Key) of
			{ok, [Config]} ->
				NeedRecharge = Config#golden_bull_reward_config.recharge*Key,
				RewardGold = Config#golden_bull_reward_config.reward_gold,

				if
					RechargeRmb < NeedRecharge ->
						{false, "充值金额不够"};
					true ->
						LeftTimes = check_have_left_time(PlayerInfo#player_info.id),
						if
							PlayerGoldenMission#player_golden_bull_mission.process < Config#golden_bull_reward_config.gold_total ->
								{false, lists:concat(["需累计赢金",Config#golden_bull_reward_config.gold_total])};
							LeftTimes > 0 andalso 0 =:= PlayerGoldenMission#player_golden_bull_mission.status ->
								{true, RewardGold};
							true ->
								{false, "次数用完了"}
						end
				end;
			_ ->
				{false, "取表出错"}
		end,
	case CheckData of
		{false, Err} ->
			send_sc_golden_bull_draw_reply(1, Err);
		{true, RewardGold1} ->
			NewData = #player_golden_bull{
				player_id = PlayerInfo#player_info.id,
				last_draw_time = util:now_seconds()
			},
			NewPlayerGoldenMission =  PlayerGoldenMission#player_golden_bull_mission{
				status = 1
			},

			{_PlayerInfo, RewardDBFun, RewardSuccessFun, _} = item_use:transc_items_reward([{?ITEM_ID_GOLD, RewardGold1}], ?REWARD_TYPE_GOLDEN_BULL),
			DBFun = fun() ->
				player_golden_bull_db:t_write(NewData),
				player_golden_bull_mission_db:t_write(NewPlayerGoldenMission),
				RewardDBFun()
			end,
			SuccessFun = fun() ->
				RewardSuccessFun(),
				update_player_golden_bull_mission(NewPlayerGoldenMission),
				send_sc_golden_bull_draw_reply(0, ""),
				send_golden_bull_info_update(0)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					SuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
			end
	end.

send_sc_golden_bull_draw_reply(Result, Err) ->
	Msg = #sc_golden_bull_draw_reply{
		result = Result,
		err = Err
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

handle_time(OldSec, NewSec) ->
	case util:is_same_date(OldSec, NewSec) of
		true ->
			skip;
		false ->
			send_golden_bull_info_update(1),
			PlayerGoldenBullMission = get_player_golden_bull_mission(),
			if
				PlayerGoldenBullMission#player_golden_bull_mission.status == 1 ->
					NewPlayerGoldenBullMission = PlayerGoldenBullMission#player_golden_bull_mission{
						process = 0,
						status = 0,
						last_refresh_time = NewSec
					},
					Flag = save_player_golden_bull_mission(NewPlayerGoldenBullMission),
					if
						Flag ->
							cs_golden_bull_mission();
						true ->
							skip
					end;
				true ->
					skip
			end
	end.


check_time(PlayerGoldenMission)->
	NewSec = util:now_seconds(),
	case util:is_same_date(PlayerGoldenMission#player_golden_bull_mission.last_refresh_time, NewSec) of
		true ->
			PlayerGoldenMission;
		false ->
			if
				?GOLDEN_BULL_FORCE_DAILY_REFRESH orelse PlayerGoldenMission#player_golden_bull_mission.status == 1 ->
					NewPlayerGoldenBullMission = PlayerGoldenMission#player_golden_bull_mission{
						process = 0,
						status = 0,
						last_refresh_time = NewSec
					},
					NewPlayerGoldenBullMission;
				true ->
					PlayerGoldenMission
			end
	end.

cs_golden_bull_mission()->
	PlayerGoldenMission = get_player_golden_bull_mission(),
	Msg = #sc_golden_bull_mission{
		process = min(300000000,PlayerGoldenMission#player_golden_bull_mission.process)
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

update_mission(Count)->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			PlayerGoldenMission = get_player_golden_bull_mission(),
			if
				PlayerGoldenMission#player_golden_bull_mission.status == 1->
					skip;
				true ->
					NewPlayerGoldenMission = PlayerGoldenMission#player_golden_bull_mission{
						process = PlayerGoldenMission#player_golden_bull_mission.process + Count
					},
					Flag = save_player_golden_bull_mission(NewPlayerGoldenMission),
					if
						Flag ->
							cs_golden_bull_mission();
						true ->
							skip
					end
			end
	end.





