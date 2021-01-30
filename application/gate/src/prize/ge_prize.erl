%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 三月 2017 16:45
%%%-------------------------------------------------------------------
-module(ge_prize).

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("network_proto/include/prize_exchange_pb.hrl").
%% API
-export([handle/2]).

%% 查询排行榜
handle(#cs_prize_query_one_req{} = Msg,StateName)->
	player_prize_util:cs_prize_query_one_req(Msg#cs_prize_query_one_req.obj_id),
	StateName;

%% 查询排行榜
handle(#cs_prize_address_change_req{} = Msg,StateName)->
	player_prize_util:cs_prize_address_change_req(Msg#cs_prize_address_change_req.new_info),
	StateName;

handle(#cs_prize_exchange_req{} = Msg, StateName) ->
	player_prize_util:cs_prize_exchange_req(Msg#cs_prize_exchange_req.obj_id, Msg#cs_prize_exchange_req.phone_card_charge_type
		,Msg#cs_prize_exchange_req.phone_number, Msg#cs_prize_exchange_req.address_id),
	StateName;

handle(#cs_prize_query_phonecard_key_req{} = Msg, StateName) ->
	player_prize_util:cs_prize_query_phonecard_key_req(Msg#cs_prize_query_phonecard_key_req.rec_id),
	StateName;


handle(Msg, StateName) ->
	?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
	StateName.