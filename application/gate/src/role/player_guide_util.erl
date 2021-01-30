%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 四月 2017 16:56
%%%-------------------------------------------------------------------
-module(player_guide_util).

-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(MAX_GUIDE_ID, 2).	%% 最大引导id

%% API
-export([
	send_init_msg/0,
	cs_guide_next_step_req/1
]).


send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	StepId = PlayerInfo#player_info.guide_step_id,
	Msg = #sc_guide_info_update{
		step_id = StepId
	},
	%?INFO_LOG("step_id = StepId ~p~n",[StepId]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

cs_guide_next_step_req(NextStepId) ->
	%?INFO_LOG("NextStepId ~p~n",[NextStepId]),
	PlayerInfo = player_util:get_dic_player_info(),
	StepId = PlayerInfo#player_info.guide_step_id,
	%?INFO_LOG("NowStepId ~p~n",[StepId]),
	if
		StepId == 0 andalso NextStepId == ?MAX_GUIDE_ID+1 ->
			Reward = [],
			Result = 0,
			UseNextStep = ?MAX_GUIDE_ID;
		NextStepId > ?MAX_GUIDE_ID orelse NextStepId =/= StepId+1 ->
			Reward = [],
			Result = 1,
			UseNextStep = StepId;
			%send_sc_guide_next_step_reply(1, []);
		true ->
			Result = 0,
			case player_util:get_server_const(?CONST_CONFIG_NEWPLAYER_GUIDE_REWARD) of 
				[] ->
					Reward = [];
				{_, Reward} ->
					void;
				_ ->
					Reward = []
			end,
			UseNextStep = NextStepId
	end,

	%?INFO_LOG("UseNextStep ~p~n",[UseNextStep]),

	case Result of
		1 ->
			send_sc_guide_next_step_reply(Result, []);
		_ ->
			{PlayerInfo1, DBRewardFun, SuccessRewardFun, PbReward} =
				case Reward of
					[] ->
						{PlayerInfo, fun()->skip end, fun()->skip end, []};
					_ ->
						item_use:transc_items_reward(Reward, ?REWARD_TYPE_GUIDE_DRAW)
				end,
			NewPlayerInfo = PlayerInfo1#player_info{guide_step_id = UseNextStep},
			DBFun = fun() ->
				DBRewardFun(),
				player_info_db:t_write_player_info(NewPlayerInfo)
			end,

			SuccessFun = fun() ->
				SuccessRewardFun(),
				player_util:update_dic_player_info(NewPlayerInfo),
				send_sc_guide_next_step_reply(Result, PbReward),
				send_init_msg()
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					SuccessFun(),
					ok;
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					error
			end
	end.


send_sc_guide_next_step_reply(Result, Reward) ->
	Msg = #sc_guide_next_step_reply{
		result = Result,
		reward = Reward
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).