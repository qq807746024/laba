%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 三月 2017 16:40
%%%-------------------------------------------------------------------
-module(ge_laba).

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("network_proto/include/laba_pb.hrl").

-include_lib("network_proto/include/niu_game_pb.hrl").
%% API
-export([handle/2]).

handle(#cs_laba_enter_room_req{} = Msg, StateName) ->
	player_laba_util:cs_laba_enter_room_req(Msg#cs_laba_enter_room_req.type, Msg#cs_laba_enter_room_req.test_type, false),
	StateName;

handle(#cs_airlaba_enter_room_req{} = Msg, StateName) ->
	player_airlaba_util:cs_airlaba_enter_room_req(Msg#cs_airlaba_enter_room_req.laba_req, 
		Msg#cs_airlaba_enter_room_req.base_bet_num, Msg#cs_airlaba_enter_room_req.base_line_num),
	StateName;

handle(#cs_laba_leave_room_req{} = Msg, StateName) ->
	player_laba_util:cs_laba_leave_room_req(Msg#cs_laba_leave_room_req.type, false),
	StateName;

handle(#cs_airlaba_leave_room_req{} = Msg, StateName) ->
	player_airlaba_util:cs_airlaba_leave_room_req(Msg#cs_airlaba_leave_room_req.laba_req),
	StateName;

handle(#cs_laba_spin_req{} = Msg, StateName) ->
	player_laba_util:cs_laba_spin_req(Msg#cs_laba_spin_req.line_num, Msg#cs_laba_spin_req.line_set_chips,Msg#cs_laba_spin_req.type,Msg#cs_laba_spin_req.test_type),
	StateName;

handle(#cs_win_player_list{} = Msg, StateName) ->
	player_laba_util:cs_win_player_list(Msg#cs_win_player_list.type),
	StateName;

handle(#cs_airlaba_fire_bet_req{} = Msg, StateName) ->
	player_airlaba_util:cs_airlaba_fire_bet_req(Msg#cs_airlaba_fire_bet_req.bullet_cost, Msg#cs_airlaba_fire_bet_req.bullet_num,
		Msg#cs_airlaba_fire_bet_req.bullet_item_id, Msg#cs_airlaba_fire_bet_req.hit_objtype, Msg#cs_airlaba_fire_bet_req.hit_objid),
	StateName;

handle(#cs_airlaba_switch_phase_req{} = _Msg, StateName) ->
	player_airlaba_util:cs_airlaba_switch_phase_req(),
	StateName;

handle(#cs_airlaba_use_item_req{} = Msg, StateName) ->
	player_airlaba_util:cs_airlaba_use_item_req(Msg#cs_airlaba_use_item_req.item_id, Msg#cs_airlaba_use_item_req.item_num, 
		Msg#cs_airlaba_use_item_req.order_id),
	StateName;

handle(#cs_airlaba_impov_sub_req{} = Msg, StateName) ->
	player_airlaba_util:cs_airlaba_impov_sub_req(Msg#cs_airlaba_impov_sub_req.type),
	StateName;

handle(#cs_niu_query_player_room_info_req{} = _Msg, StateName) ->
	Msg = #sc_niu_player_room_info_update{
		room_id = 0,
		enter_end_time = 0
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg),
	StateName;

handle(Msg, StateName) ->
	?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
	StateName.
