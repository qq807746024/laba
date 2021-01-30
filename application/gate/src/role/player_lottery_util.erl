-module(player_lottery_util).

-author("Administrator").

%% API
-export([cs_lottery_draw_req/1, handle_time/2]).

-include("common.hrl").

-include_lib("db/include/mnesia_table_def.hrl").

-include_lib("network_proto/include/player_pb.hrl").

-define(LOTTERY_REQ_CLSTYPE_QUERY, 0).

cs_lottery_draw_req(ClsType) ->
    NowSec = util:now_seconds(),
    {DefaultDrawTimes, MinVip} = player_util:get_server_const(?CONST_CONFIG_KEY_LOTTERY_CONFIG),
    PlayerInfo = player_util:get_dic_player_info(),
	PlayerLotteryInfo = priv_reset_period_draw_times(PlayerInfo, NowSec),
	LeftTimes = max(0, DefaultDrawTimes - PlayerLotteryInfo#player_lottery_info.period_times),
	%?INFO_LOG("cs_lottery_draw_req ~p~n", [{ClsType}]),
    RespMsg = case ClsType of
		?LOTTERY_REQ_CLSTYPE_QUERY ->
			[Configs] = ets:lookup(?ETS_LOTTERY_CONFIG_PROTO_PACKED, 1),
			#sc_lottery_draw_resp{
				left_times = LeftTimes,
				reward_item_id = 0,
				reward_item_num = 0,
				is_reward = false,
				reward_configs = Configs#ets_lottery_reward_items.reward_items
			};
		_ ->
			if
				MinVip > PlayerInfo#player_info.vip_level ->
					?INFO_LOG("sasasasasasasasa-----"),
					#sc_lottery_draw_resp{
						left_times = 0,
						reward_item_id = 0,
						reward_item_num = 0,
						is_reward = false,
						reward_configs = []
					};
				0 >= LeftTimes ->
					#sc_lottery_draw_resp{
						left_times = 0,
						reward_item_id = 0,
						reward_item_num = 0,
						is_reward = false,
						reward_configs = []
					};
				true ->
					LotteryConfig = priv_get_config(ClsType),
					IsPlayerItemEnough = priv_is_player_item_enough(PlayerInfo, LotteryConfig),
					if
						IsPlayerItemEnough ->
							[{RewardItemId, RewardItemNum}] = util_random:get_random_rewards(
								LotteryConfig#lottery_config.random_reward_list),
							TranscItems = [{RewardItemId, RewardItemNum}] ++ [LotteryConfig#lottery_config.cost_item_info],
							{NewPlayerInfo, DBFun1, SuccessFun1, PbRewardList} = item_use:transc_items_reward(TranscItems, ?REWARD_TYPE_LOTTERY),
							NowSec = util:now_seconds(),
							DBFun = fun() ->
								DBFun1(),
								player_lottery_info_db:t_write_player_info(PlayerLotteryInfo#player_lottery_info{
									period_times = PlayerLotteryInfo#player_lottery_info.period_times + 1,
									last_draw_time = NowSec
								})
							end,
							case dal:run_transaction_rpc(DBFun) of
								{atomic, _} ->
									SuccessFun1(),
									http_static_util:post_player_lottery(NewPlayerInfo, TranscItems, NowSec),
									player_shop:send_buy_back(0, "", PbRewardList, 0, 0),
									#sc_lottery_draw_resp{
										left_times = LeftTimes - 1,
										reward_item_id = RewardItemId,
										reward_item_num = RewardItemNum,
										is_reward = true,
										reward_configs = []
									};
								{aborted, Reason} ->
									?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
									#sc_lottery_draw_resp{
										left_times = LeftTimes,
										reward_item_id = 0,
										reward_item_num = 0,
										is_reward = false,
										reward_configs = []
									}
							end;
						true ->
							#sc_lottery_draw_resp{
								left_times = LeftTimes,
								reward_item_id = 0,
								reward_item_num = 0,
								is_reward = false,
								reward_configs = []
							}
					end
			end
	end,
	%?INFO_LOG("cs_lottery_draw_req ~p~n", [{RespMsg}]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), RespMsg).

handle_time(OldSecond, NewSecond) ->
	case util:is_same_date(OldSecond, NewSecond) of
		true ->
			skip;
		_ ->
			PlayerInfo = player_util:get_dic_player_info(),
			NewLotteryInfo = priv_reset_period_draw_times(PlayerInfo, NewSecond),
			player_lottery_info_db:write_player_info(NewLotteryInfo)
	end.

priv_get_config(ClsType) ->
	[Config] = ets:lookup(?ETS_LOTTERY_CONFIG, ClsType),
	Config.

priv_is_player_item_enough(PlayerInfo, Config) ->
	{NeedItemId, NeedItemNum} = Config#lottery_config.cost_item_info,
	case NeedItemId of
		?ITEM_ID_GOLD ->
			PlayerInfo#player_info.gold >= abs(NeedItemNum);
		?ITEM_ID_RED_PACK ->
			RedPackNum = item_use:get_player_item_num(?ITEM_ID_RED_PACK),
			RedPackNum >= abs(NeedItemNum);
		_ ->
			false
	end.

priv_reset_period_draw_times(PlayerInfo, NowSec) ->
    case player_lottery_info_db:get_base(PlayerInfo#player_info.id) of
		{ok, [PlayerLotteryInfo]} ->
			IsSameDate = util:is_same_date(NowSec, PlayerLotteryInfo#player_lottery_info.last_draw_time),
			if 
				IsSameDate ->
					PlayerLotteryInfo;
				true ->
					PlayerLotteryInfo#player_lottery_info{period_times = 0}
			end;
		_ ->
			#player_lottery_info{
				player_id =
				PlayerInfo#player_info.id,
				period_times = 0, last_draw_time = 0}
    end.
