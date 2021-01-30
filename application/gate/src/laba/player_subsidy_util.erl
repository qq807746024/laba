%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 二月 2017 17:26
%%%	破产补助
%%%-------------------------------------------------------------------
-module(player_subsidy_util).

-author("wodong_0013").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").



%% API
-export([
	cs_niu_subsidy_req/1,
	handle_time/2,
	send_update_info/0
]).

%% 补助
cs_niu_subsidy_req(Type) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerSubsidyInfo = get_player_subsidy_info(PlayerInfo#player_info.id),
	NowSecond = util:now_seconds(),
	OldPlayerGold = PlayerInfo#player_info.gold,
	LimitTimes = get_subsidy_times_by_type(Type),
	if
		Type == 1 ->
			%% 检测玩家补助次数
			LastDrawDate = PlayerSubsidyInfo#player_subsidy_info.last_date,
			DrawTimes = PlayerSubsidyInfo#player_subsidy_info.last_date_draw_times;

		true ->
			LastDrawDate = PlayerSubsidyInfo#player_subsidy_info.special_last_date,
			DrawTimes = PlayerSubsidyInfo#player_subsidy_info.special_last_date_draw_time
	end,
	case util:is_same_date(LastDrawDate, NowSecond) of
		true ->
			HaveDrawTime = DrawTimes;
		_ ->
			HaveDrawTime = 0
	end,
	ConditionGoldMax = player_util:get_server_const(?CONST_CONFIG_KEY_SUBSIDY_CONDITION),

	if
		OldPlayerGold >= ConditionGoldMax andalso Type == 1->
			send_sc_niu_subsidy_reply(1, "金币过多，暂不能领");
		HaveDrawTime >= LimitTimes ->
			send_sc_niu_subsidy_reply(1, "已用完次数了");
		true ->
			if
				Type == 1 ->
					NewPlayerSubsidyInfo = PlayerSubsidyInfo#player_subsidy_info{
						last_date = NowSecond,
						last_date_draw_times = HaveDrawTime + 1
					},
					DailyMaxTimes = get_subsidy_daily_times(),

					Max = max(0,  DailyMaxTimes - NewPlayerSubsidyInfo#player_subsidy_info.last_date_draw_times),
					player_subsidy_info_db:write(NewPlayerSubsidyInfo),
					do_subsidy(Type),
					send_niu_subsidy_info_update_msg(max(0, Max)),
					send_sc_niu_subsidy_reply(0, "");
				Type == 2 ->
					NewPlayerSubsidyInfo = PlayerSubsidyInfo#player_subsidy_info{
						special_last_date = NowSecond,
						special_last_date_draw_time = HaveDrawTime + 1
					},
					Max = max(0,get_spe_subsidy_daily_times() - NewPlayerSubsidyInfo#player_subsidy_info.special_last_date_draw_time),
					player_subsidy_info_db:write(NewPlayerSubsidyInfo),
					do_subsidy(Type),
					send_niu_special_subsidy_info_update_msg(max(0, Max),PlayerSubsidyInfo#player_subsidy_info.is_share),
					send_sc_niu_subsidy_reply(0, "");
				true ->
					?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}]),
					send_sc_niu_subsidy_reply(1, "类型错误")
			end
	end.

do_subsidy(Type) ->
	if
		Type == 1 ->
			RewardNum = get_subsidy_reward_num();
		true ->
			RewardNum = get_spe_subsidy_reward_num()
	end,
	RewardList = [{?ITEM_ID_GOLD,RewardNum}],
	item_use:imme_items_reward(RewardList, ?REWARD_TYPE_SUBSIDY),
	ok.


send_sc_niu_subsidy_reply(Result, Err) ->
	Msg = #sc_niu_subsidy_reply{
		result = Result,
		err = Err
	},
	%?INFO_LOG("11~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_player_subsidy_info(PlayerId) ->
	case player_subsidy_info_db:get_base(PlayerId) of
		{ok, [PlayerInfo]} ->
			PlayerInfo;
		_ ->
			#player_subsidy_info{
				player_id = PlayerId
			}
	end.


send_update_info() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerSubsidyInfo = get_player_subsidy_info(PlayerInfo#player_info.id),
	LastDrawDate = PlayerSubsidyInfo#player_subsidy_info.last_date,
	SpecialLastDrawDate = PlayerSubsidyInfo#player_subsidy_info.special_last_date,
	NowSecond = util:now_seconds(),
	case util:is_same_date(LastDrawDate, NowSecond) of
		true ->
			HaveDrawTime = PlayerSubsidyInfo#player_subsidy_info.last_date_draw_times;
		_ ->
			HaveDrawTime = 0
	end,
	case util:is_same_date(SpecialLastDrawDate, NowSecond) of
		true ->
			SpeHaveDrawTime = PlayerSubsidyInfo#player_subsidy_info.special_last_date_draw_time;
		_ ->
			SpeHaveDrawTime = 0
	end,
	send_niu_special_subsidy_info_update_msg(max(0, get_spe_subsidy_daily_times() - SpeHaveDrawTime),PlayerSubsidyInfo#player_subsidy_info.is_share),
	DailyMaxTimes = get_subsidy_daily_times(),
	send_niu_subsidy_info_update_msg(max(0, DailyMaxTimes - HaveDrawTime)).

send_niu_subsidy_info_update_msg(LeftTime) ->
	Msg = #sc_niu_subsidy_info_update{
		left_times = LeftTime,
		subsidy_gold = get_subsidy_reward_num()
	},

	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

send_niu_special_subsidy_info_update_msg(LeftTime,IsShare) ->
	Msg = #sc_niu_special_subsidy_info_update{
		left_times = LeftTime,
		subsidy_gold = get_spe_subsidy_reward_num(),
		is_share = IsShare
	},
	%?INFO_LOG("33~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_subsidy_times_by_type(Type)->
	if
		Type == 1 ->
			get_subsidy_daily_times();
		true ->
			get_spe_subsidy_daily_times()
	end.

%%破产补助金额
get_subsidy_reward_num()->
	player_util:get_server_const(?CONST_CONFIG_KEY_SUBSIDY_GOLD_NUM).

%%破产补助次数（每日）
get_subsidy_daily_times() ->
	player_util:get_server_const(?CONST_CONFIG_KEY_SUBSIDY_DAILY_TIMES).

%%特别破产补助金额
get_spe_subsidy_reward_num()->
	player_util:get_server_const(?CONST_CONFIG_KEY_SPE_SUBSIDY_GOLD_NUM).

%%特别破产补助次数（每日）
get_spe_subsidy_daily_times() ->
	player_util:get_server_const(?CONST_CONFIG_KEY_SPE_SUBSIDY_DAILY_TIMES).


handle_time(OldSecond, NewSecond) ->
	case util:is_same_date(OldSecond, NewSecond) of
		true ->
			skip;
		_ ->
			send_update_info()
	end.
