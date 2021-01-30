-module(player_id_month_card).

-export([
	initialize/0,
	send_init_msg/0,
	draw/0,
	handle_timer/2,
	add_monthly_days/1
]).


-include("item.hrl").
-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/shop_pb.hrl").


handle_timer(OldSeconds, NewSeconds) ->
	case util:is_same_date(OldSeconds, NewSeconds) of
		true ->
			void;
		false ->
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerID = PlayerInfo#player_info.id,
			PlayerIDMonthCard = load_player_id_month_card(PlayerID),
			case player_util:get_dic_gate_pid() of
				GateProc when GateProc =/= undefined ->
					Reply = pack_month_card_info_msg(PlayerIDMonthCard),
					tcp_client:send_data(GateProc, Reply);
				_ ->
					void
			end
	end.

pack_month_card_info_msg(PlayerIDMonthCard) ->
	Now = calendar:local_time(),
	BalanceDays = compute_balance_days(Now, PlayerIDMonthCard),
	DrawFlag =
		case BalanceDays of
			0 ->
				2;
			_ ->
				is_already_draw(Now, PlayerIDMonthCard)
		end,
	#sc_month_card_info_update{
		today_draw_flag = DrawFlag,
		left_times = BalanceDays
	}.

initialize() ->
	void.

send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	PlayerIDMonthCard = load_player_id_month_card(PlayerID),
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			Reply = pack_month_card_info_msg(PlayerIDMonthCard),
			tcp_client:send_data(GateProc, Reply);
		_ ->
			void
	end.
%%  
draw() ->
	Now = calendar:local_time(),
	case pre_draw(Now) of
		{true, AccDict} ->
			PlayerIDMonthCard = dict:fetch(player_id_month_card, AccDict),
			NewPlayerIDMonthCard = PlayerIDMonthCard#player_id_month_card{last_draw_datetime = Now},
			Rewards = dict:fetch(rewards, AccDict),
			{_NewPlayerInfo, TryDBFun, TryDBSuccessFun, _PbReward} =
				item_use:transc_items_reward(Rewards, ?REWARD_TYPE_MONTHCARD_DRAW),

			DBFun = fun() ->
				TryDBFun(),
				player_id_month_card_db:t_write_player_id_month_card(NewPlayerIDMonthCard)
			end,
			DBSuccessFun = fun() ->
				TryDBSuccessFun(),
				case player_util:get_dic_gate_pid() of
					GateProc when GateProc =/= undefined ->
						Update = pack_month_card_info_msg(NewPlayerIDMonthCard),
						send_sc_month_card_draw_reply(GateProc, 0, ""),
						tcp_client:send_data(GateProc, Update);
					_ ->
						void
				end
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					GateProc = player_util:get_dic_gate_pid(),
					send_sc_month_card_draw_reply(GateProc, 1, "DBError"),
					?ERROR_LOG("Error ~p~n", [{Reason, ?MODULE, ?LINE}])
			end;
		{false, ErrMsg} ->
			GateProc = player_util:get_dic_gate_pid(),
			send_sc_month_card_draw_reply(GateProc, 1, ErrMsg),
			?ERROR_LOG("Error ~p~n", [{?MODULE, ?LINE}])
	end.

send_sc_month_card_draw_reply(GateId, Result, Err) ->
	Msg = #sc_month_card_draw_reply{
		result = Result,
		err = Err
	},
	tcp_client:send_data(GateId, Msg).


pre_draw(Now) ->
	AccDict = dict:new(),
	Requires = [check_days,
		check_already_draw,
		check_rewards],
	pre_draw_require(Now, AccDict, Requires).

pre_draw_require(_Now, AccDict, []) ->
	{true, AccDict};

pre_draw_require(Now, AccDict, [check_days | T]) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	PlayerIDMonthCard = load_player_id_month_card(PlayerID),
	BalanceDays = compute_balance_days(Now, PlayerIDMonthCard),

	case BalanceDays > 0 of
		true ->
			AccDict2 = dict:store(player_id_month_card, PlayerIDMonthCard, AccDict),
			pre_draw_require(Now, AccDict2, T);
		false ->
			{false, "剩余天数不足"}
	end;

pre_draw_require(Now, AccDict, [check_already_draw | T]) ->
	{NowDate, _} = Now,
	PlayerIDMonthCard = dict:fetch(player_id_month_card, AccDict),
	{LastDrawDate, _} = PlayerIDMonthCard#player_id_month_card.last_draw_datetime,
	case LastDrawDate == NowDate of
		true -> {false, "今天已经领取了"};
		false -> pre_draw_require(Now, AccDict, T)
	end;

pre_draw_require(Now, AccDict, [check_rewards | T]) ->
	{MonthCard_RewardType, MonthCard_Reward} = player_util:get_server_const(?CONST_CONFIG_KEY_MONTH_CARD_DAILY_GEN),
	RewardList = [{MonthCard_RewardType, MonthCard_Reward}],
	AccDict2 = dict:store(rewards, RewardList, AccDict),
	pre_draw_require(Now, AccDict2, T);

pre_draw_require(Now, AccDict, [_ | T]) ->
	pre_draw_require(Now, AccDict, T).

is_already_draw(Now, PlayerIDMonthCard) ->
	{LastDrawDate, _} = PlayerIDMonthCard#player_id_month_card.last_draw_datetime,
	{NowDate, _} = Now,

	case NowDate == LastDrawDate of
		true -> 0;
		false -> 1
	end.

compute_balance_days(Now, PlayerIDMonthCard) ->
	{BeginDate, _} = PlayerIDMonthCard#player_id_month_card.begin_datetime,
	%{LastDrawDate, _} = PlayerIDMonthCard#player_id_month_card.last_draw_datetime,
	TotalCount = PlayerIDMonthCard#player_id_month_card.total_count,
	{NowDate, _} = Now,

	NowDays = calendar:date_to_gregorian_days(NowDate),
	BeginDays = calendar:date_to_gregorian_days(BeginDate),
	%LastDrawDays = calendar:date_to_gregorian_days(LastDrawDate),
	case NowDays - BeginDays >= TotalCount of
		true ->
			0;
		false ->
			TotalCount - (NowDays - BeginDays)
%% 			case LastDrawDays == NowDays of
%% 				true ->
%% 					TotalCount - (NowDays - BeginDays) - 1;
%% 				false ->
%% 					TotalCount - (NowDays - BeginDays)
%% 			end
	end.


load_player_id_month_card(PlayerID) ->
	case player_id_month_card_db:load_player_id_month_card(PlayerID) of
		{ok, [PlayerIDMonthCard]} -> void;
		{ok, []} ->
			PlayerIDMonthCard = #player_id_month_card{player_id = PlayerID,
				begin_datetime = {{2000, 1, 1}, {0, 0, 0}},
				total_count = 0,
				last_draw_datetime = {{2000, 1, 1}, {0, 0, 0}}}
	end,
	PlayerIDMonthCard.

add_monthly_days(Now) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	PlayerIDMonthCard = load_player_id_month_card(PlayerID),
	BalanceDays = compute_balance_days(Now, PlayerIDMonthCard),

	NewPlayerIDMonthCard =
		case BalanceDays == 0 of
			false ->
				PlayerIDMonthCard#player_id_month_card{total_count = PlayerIDMonthCard#player_id_month_card.total_count + 30};
			true ->
				{LastDrawDate, _} = PlayerIDMonthCard#player_id_month_card.last_draw_datetime,
				{NowDate, _} = Now,

				IncreaseDays = case LastDrawDate == NowDate of
								   true -> 31;
								   false -> 30
							   end,

				PlayerIDMonthCard#player_id_month_card{begin_datetime = Now,
					total_count = IncreaseDays}
		end,

	DBFun = fun() ->
		player_id_month_card_db:t_write_player_id_month_card(NewPlayerIDMonthCard)
	end,
	DBSuccessFun = fun() ->
		tcp_client:send_data(player_util:get_dic_gate_pid(), pack_month_card_info_msg(NewPlayerIDMonthCard))
	end,
	{DBFun, DBSuccessFun}.
%% 	case dal:run_transaction_rpc(DBFun) of
%% 		{atomic, _} ->
%% 			DBSuccessFun();
%% 		{aborted, Reason} ->
%% 			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
%% 	end.