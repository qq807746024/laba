%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 二月 2017 14:43
%%%-------------------------------------------------------------------
-module(ge_shop).
-author("Administrator").

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/shop_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include_lib("network_proto/include/activity_pb.hrl").

-export([handle/2]).


handle(#cs_shop_buy_query{} = Msg, StateName) ->
  #cs_shop_buy_query{
    id = Id1
  } = Msg,
  player_shop:cs_buy(Id1, 'client'),
  StateName;
handle(#cs_golden_bull_draw_req{} = Msg, StateName) ->
	#cs_golden_bull_draw_req{
		key = Key
	} = Msg,
	player_golden_bull_util:cs_golden_bull_draw_req(Key),
	StateName;

handle(#cs_month_card_draw_req{} = _Msg, StateName) ->
	player_id_month_card:draw(),
	StateName;

handle(#cs_period_card_draw_req{} = Msg, StateName) ->
	player_id_period_card:draw(Msg#cs_period_card_draw_req.type),
	StateName;

handle(#cs_redpack_task_draw_req{} = Msg, StateName) ->
	player_pack_task:cs_redpack_task_draw_req(Msg#cs_redpack_task_draw_req.game_type,
		Msg#cs_redpack_task_draw_req.task_id, 'game'),
	StateName;

handle(#cs_activity_info_query_req{} = Msg, StateName) ->
	player_activity_util:cs_activity_info_query_req(Msg#cs_activity_info_query_req.id),
	StateName;

handle(#cs_activity_draw_req{} = Msg, StateName) ->
	player_activity_util:cs_activity_draw_req(Msg#cs_activity_draw_req.activity_id, Msg#cs_activity_draw_req.sub_id),
	StateName;

handle(#cs_golden_bull_mission{} = _Msg,StateName)->
	player_golden_bull_util:cs_golden_bull_mission(),
	StateName;

handle(Msg, StateName) ->
	?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
    StateName.
