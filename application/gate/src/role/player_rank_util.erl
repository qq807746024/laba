%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 16:04
%%%-------------------------------------------------------------------
-module(player_rank_util).
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(RANK_LIST, [?RANK_TYPE_GOLD, ?RANK_TYPE_WIN_GOLD, ?RANK_TYPE_DIAMOND, ?RANK_TYPE_FRUIT,
	?RANK_TYPE_CAR, ?RANK_TYPE_HUNDRED_NIU, ?RANK_TYPE_REDPACK, ?RANK_TYPE_AIRLABA_EARN, ?RANK_TYPE_AIRLABA_BET]).
-define(HUNDRED_RANK_LIST, [4, 5]).	%

%% API
-export([
	rank_change/3,
	cs_rank_query_req/1,
	cs_hundred_last_week_rank_query_req/0,
	init_player_rank_info/0,
	cs_super_laba_last_week_rank_query_req/0,
	cs_query_last_daily_rank_reward_req/1
]).


rank_change(PlayerID, RankType, NewData)->
	case lists:member(RankType, ?RANK_LIST) of
		true ->
			rank_mod:update_rank(RankType, PlayerID, NewData);
		false ->
			skip
	end.

%%send_recharge_info()->
%%	PlayerInfo = player_util:get_dic_player_info(),
%%	if
%%		PlayerInfo#player_info.is_robot ->
%%			skip;
%%		true ->
%%			recharge_activity_mod:send_rank_update(player_util:get_dic_gate_pid(),PlayerInfo#player_info.id)
%%	end.

init_player_rank_info()->
	PlayerInfo = player_util:get_dic_player_info(),
	rank_change(PlayerInfo#player_info.id, ?RANK_TYPE_GOLD, PlayerInfo#player_info.gold),
	rank_change(PlayerInfo#player_info.id, ?RANK_TYPE_REDPACK, item_use:get_player_item_num(?ITEM_ID_RED_PACK)),
	ok.

cs_rank_query_req(RankType) ->
	PlayerInfo = player_util:get_dic_player_info(),
	case lists:member(RankType, ?RANK_LIST) of
		true ->
			rank_mod:send_rank(RankType, player_util:get_dic_gate_pid(), PlayerInfo#player_info.id);
		false->
			skip
	end.


cs_hundred_last_week_rank_query_req() ->
	PbList = lists:foldl(fun(E,Acc) ->
		if
			E#player_hundred_last_week_rank.rank > 100 ->
				Acc;
			true ->
				E1=#pb_hundred_last_week_data{
					rank = E#player_hundred_last_week_rank.rank,
					reward_gold = E#player_hundred_last_week_rank.reward_config,
					name1_round_win = " -- ",
					name2_total_win = E#player_hundred_last_week_rank.name2
				},
				[E1|Acc]
		end
	end ,[], ets:tab2list(?ETS_RANK_HUNDRED_LAST_WEEK)),
	Msg = #sc_hundred_last_week_rank_query_reply{
		list = PbList
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

cs_super_laba_last_week_rank_query_req()->
	case  get_fruit_rank_history() of
		{ok,[Info]} ->
			Msg = #sc_super_laba_last_week_rank_query_reply{
				list = Info#fruit_rank_history.rank
			};
		_->
			Msg = #sc_super_laba_last_week_rank_query_reply{
				list = []
			}
			end,
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_fruit_rank_history()->
	case fruit_rank_history_db:get_last() of
		{ok,'$end_of_table'} ->
			{ok, []};
		{ok, Key} ->
			fruit_rank_history_db:get(Key);
		Error ->
			?ERROR_LOG("get_fruit_rank_history Error:~p", [Error]),
			{failed, []}
	end.

priv_cs_query_last_daily_rank_reward_req(Type) ->
	DBData = case Type of
		0 ->
			daily_rank_reward_history_db:get(profit);
		1 ->
			daily_rank_reward_history_db:get(car);
		2 ->
			daily_rank_reward_history_db:get(hundred_niu);
		3 ->
			daily_rank_reward_history_db:get(airlaba);
		_ ->
			undefined
	end,
	Data = case DBData of 
		{ok, []} ->
			#daily_rank_reward_history {
				type = Type,
				date = {0, 0, 0},
				reward_records = []
			};
		{ok, '$end_of_table'} ->
			#daily_rank_reward_history {
				type = Type,
				date = {0, 0, 0},
				reward_records = []
			};
		{ok, [Data1]} ->
			Data1;
		_ ->
			?ERROR_LOG("not support query type:cs_query_last_daily_rank_reward_req => ~p", [Type]),
			#daily_rank_reward_history {
				type = Type,
				date = {0, 0, 0},
				reward_records = []
			}
	end,
	Ret = case Data#daily_rank_reward_history.date of
		{0, 0, 0} ->
			#sc_query_last_daily_rank_reward_reply {
				type = Type,
				date = 0,
				rank_info_list = Data#daily_rank_reward_history.reward_records
			};
		_ ->
			#sc_query_last_daily_rank_reward_reply {
				type = Type,
				date = util:rank_history_db_time_to_timestamp(Data#daily_rank_reward_history.date) - ?DIFF_SECONDS_0000_1970,
				rank_info_list = Data#daily_rank_reward_history.reward_records
			}
	end,
	Ret.

cs_query_last_daily_rank_reward_req(Type) ->
	Resp = priv_cs_query_last_daily_rank_reward_req(Type),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Resp).