-module(player_id_period_card).

-export([add_period_days/2, draw/1, handle_timer/2,
	 initialize/0, send_init_msg/0]).

-include("item.hrl").

-include("role_processor.hrl").

-include("common.hrl").

-include_lib("db/include/mnesia_table_def.hrl").

-include_lib("network_proto/include/shop_pb.hrl").

-define(PERIOD_CARD_TYPE_LIST, [
	?PERIOD_CARD_TYPE_WEEK
]).


handle_timer(OldSeconds, NewSeconds) ->
	case util:is_same_date(OldSeconds, NewSeconds) of
		true ->
			void;
		false ->
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerID = PlayerInfo#player_info.id,
			lists:foreach(fun (Type) ->
				PlayerIDPeriodCard = load_player_id_period_card(PlayerID, Type),
				case player_util:get_dic_gate_pid() of
					GateProc when GateProc =/= undefined ->
						Reply = pack_period_card_info_msg(PlayerIDPeriodCard),
						tcp_client:send_data(GateProc, Reply);
					_ ->
						void
				end
			end, ?PERIOD_CARD_TYPE_LIST)
	end.

pack_period_card_info_msg(PlayerIDPeriodCard) ->
	Now = calendar:local_time(),
	BalanceDays = compute_balance_days(Now, PlayerIDPeriodCard),
	DrawFlag =
		case BalanceDays of
			0 ->
				2;
			_ ->
				is_already_draw(Now, PlayerIDPeriodCard)
		end,
	{_, Type} = PlayerIDPeriodCard#player_id_period_card.key,
	#sc_period_card_info_update{
		type = Type,
		today_draw_flag = DrawFlag,
		left_times = BalanceDays
	}.

initialize() ->
	void.

send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	lists:foreach(fun (Type) ->
		PlayerIDPeriodCard = load_player_id_period_card(PlayerID, Type),
		case player_util:get_dic_gate_pid() of
			GateProc when GateProc =/= undefined ->
				Reply = pack_period_card_info_msg(PlayerIDPeriodCard),
				tcp_client:send_data(GateProc, Reply);
			_ ->
				void
		end
	end, ?PERIOD_CARD_TYPE_LIST).
%%  
draw(Type) ->
	Now = calendar:local_time(),
	case pre_draw(Type, Now) of
		{true, AccDict} ->
			PlayerIDPeriodCard = dict:fetch(player_id_period_card, AccDict),
			NewPlayerIDPeriodCard = PlayerIDPeriodCard#player_id_period_card{last_draw_datetime = Now},
			Rewards = dict:fetch(rewards, AccDict),
			{_, Type} = NewPlayerIDPeriodCard#player_id_period_card.key,
			case Type of 
				?PERIOD_CARD_TYPE_WEEK ->
					HttpLogType = ?REWARD_TYPE_PERIODCARD_DRAW_WEEK;
				_ ->
					HttpLogType = ?REWARD_TYPE_PERIODCARD_DRAW_UNKNOWN
			end,
			{_NewPlayerInfo, TryDBFun, TryDBSuccessFun, _PbReward} =
				item_use:transc_items_reward(Rewards, HttpLogType),

			DBFun = fun() ->
				TryDBFun(),
				player_id_period_card_db:t_write_player_id_period_card(NewPlayerIDPeriodCard)
			end,
			DBSuccessFun = fun() ->
				TryDBSuccessFun(),
				case player_util:get_dic_gate_pid() of
					GateProc when GateProc =/= undefined ->
						Update = pack_period_card_info_msg(NewPlayerIDPeriodCard),
						send_sc_period_card_draw_reply(Type, GateProc, 0, ""),
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
					send_sc_period_card_draw_reply(Type, GateProc, 1, "DBError"),
					?ERROR_LOG("Error ~p~n", [{Reason, ?MODULE, ?LINE}])
			end;
		{false, ErrMsg} ->
			GateProc = player_util:get_dic_gate_pid(),
			send_sc_period_card_draw_reply(Type, GateProc, 1, ErrMsg),
			?ERROR_LOG("Error ~p~n", [{?MODULE, ?LINE}])
	end.

send_sc_period_card_draw_reply(Type, GateId, Result, Err) ->
	Msg = #sc_period_card_draw_reply{
		type = Type,
		result = Result,
		err = Err
	},
	tcp_client:send_data(GateId, Msg).


pre_draw(Type, Now) ->
	AccDict = dict:new(),
	Requires = [check_days,
		check_already_draw,
		check_rewards],
	pre_draw_require(Type, Now, AccDict, Requires).

pre_draw_require(Type, _Now, AccDict, []) ->
	{true, AccDict};

pre_draw_require(Type, Now, AccDict, [check_days | T]) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	PlayerIDPeriodCard = load_player_id_period_card(PlayerID, Type),
	BalanceDays = compute_balance_days(Now, PlayerIDPeriodCard),

	case BalanceDays > 0 of
		true ->
			AccDict2 = dict:store(player_id_period_card, PlayerIDPeriodCard, AccDict),
			pre_draw_require(Type, Now, AccDict2, T);
		false ->
			{false, "剩余天数不足"}
	end;

pre_draw_require(Type, Now, AccDict, [check_already_draw | T]) ->
	{NowDate, _} = Now,
	PlayerIDPeriodCard = dict:fetch(player_id_period_card, AccDict),
	{LastDrawDate, _} = PlayerIDPeriodCard#player_id_period_card.last_draw_datetime,
	case LastDrawDate == NowDate of
		true -> {false, "今天已经领取了"};
		false -> pre_draw_require(Type, Now, AccDict, T)
	end;

pre_draw_require(Type, Now, AccDict, [check_rewards | T]) ->
	PlayerIDPeriodCard = dict:fetch(player_id_period_card, AccDict),
	{_, Type} = PlayerIDPeriodCard#player_id_period_card.key,
	case Type of 
		?PERIOD_CARD_TYPE_WEEK ->
			{MonthCard_RewardType, MonthCard_Reward} = player_util:get_server_const(?CONST_CONFIG_KEY_PERIOD_CARD_WEEK_DAILY_GEN);
		_ ->
			{MonthCard_RewardType, MonthCard_Reward} = {error, error}
	end,
	if
		error =:= MonthCard_RewardType orelse error =:= MonthCard_Reward ->
			{false, "错误的配置"};
		true ->
			RewardList = [{MonthCard_RewardType, MonthCard_Reward}],
			AccDict2 = dict:store(rewards, RewardList, AccDict),
			pre_draw_require(Type, Now, AccDict2, T)
	end;

pre_draw_require(Type, Now, AccDict, [_ | T]) ->
	pre_draw_require(Type, Now, AccDict, T).

is_already_draw(Now, PlayerIDMonthCard) ->
	{LastDrawDate, _} = PlayerIDMonthCard#player_id_period_card.last_draw_datetime,
	{NowDate, _} = Now,

	case NowDate == LastDrawDate of
		true -> 0;
		false -> 1
	end.

compute_balance_days(Now, PlayerIDMonthCard) ->
	{BeginDate, _} = PlayerIDMonthCard#player_id_period_card.begin_datetime,
	TotalCount = PlayerIDMonthCard#player_id_period_card.total_count,
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


load_player_id_period_card(PlayerID, Type) ->
	case player_id_period_card_db:load_player_id_period_card({PlayerID, Type}) of
		{ok, [PlayerIDPeriodCard]} -> void;
		{ok, []} ->
			PlayerIDPeriodCard = #player_id_period_card{
				key = {PlayerID, Type},
				begin_datetime = {{2000, 1, 1}, {0, 0, 0}},
				total_count = 0,
				last_draw_datetime = {{2000, 1, 1}, {0, 0, 0}}}
	end,
	PlayerIDPeriodCard.

add_period_days(Now, Type) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerID = PlayerInfo#player_info.id,
	PlayerIDPeriodCard = load_player_id_period_card(PlayerID, Type),
	BalanceDays = compute_balance_days(Now, PlayerIDPeriodCard),

	NewPlayerIDPeriodCard =
		case BalanceDays == 0 of
			false ->
				PlayerIDPeriodCard#player_id_period_card{total_count = PlayerIDPeriodCard#player_id_period_card.total_count + 7};
			true ->
				{LastDrawDate, _} = PlayerIDPeriodCard#player_id_period_card.last_draw_datetime,
				{NowDate, _} = Now,

				IncreaseDays = case LastDrawDate == NowDate of
								   true -> 8;
								   false -> 7
							   end,

				PlayerIDPeriodCard#player_id_period_card{begin_datetime = Now,
					total_count = IncreaseDays}
		end,

	DBFun = fun() ->
		player_id_period_card_db:t_write_player_id_period_card(NewPlayerIDPeriodCard)
	end,
	DBSuccessFun = fun() ->
		tcp_client:send_data(player_util:get_dic_gate_pid(), pack_period_card_info_msg(NewPlayerIDPeriodCard))
	end,
	{DBFun, DBSuccessFun}.
%% 	case dal:run_transaction_rpc(DBFun) of
%% 		{atomic, _} ->
%% 			DBSuccessFun();
%% 		{aborted, Reason} ->
%% 			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
%% 	end.