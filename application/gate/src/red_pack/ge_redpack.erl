%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 三月 2017 11:50
%%%-------------------------------------------------------------------
-module(ge_redpack).
-author("Administrator").

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("network_proto/include/red_pack_pb.hrl").
-include_lib("network_proto/include/niu_game_pb.hrl").
%% API
-export([handle/2]).

%%
handle(#cs_red_pack_query_list_req{} = Msg,StateName)->
  player_redpack_util:cs_red_pack_query_list_req(Msg#cs_red_pack_query_list_req.begin_id,Msg#cs_red_pack_query_list_req.end_id),
  StateName;

handle(#cs_red_pack_open_req{} = Msg,StateName)->
  player_redpack_util:cs_red_pack_open_req(Msg#cs_red_pack_open_req.uid,Msg#cs_red_pack_open_req.check_num),
  StateName;

handle(#cs_red_pack_create_req{} = Msg,StateName)->
  player_redpack_util:cs_red_pack_create_req(Msg#cs_red_pack_create_req.set_num,Msg#cs_red_pack_create_req.des),
  StateName;

handle(#cs_red_pack_cancel_req{} = Msg,StateName)->
  player_redpack_util:cs_red_pack_cancel_req(Msg#cs_red_pack_cancel_req.uid),
  StateName;

handle(#cs_redpack_room_draw_req{} = _Msg,StateName)->
	player_redpack_room_util:cs_redpack_room_draw_req(),
	StateName;

handle(#cs_red_pack_do_select_req{} = Msg,StateName)->
	player_redpack_util:cs_red_pack_do_select_req(Msg#cs_red_pack_do_select_req.notice_id, Msg#cs_red_pack_do_select_req.opt),
	StateName;

handle(#cs_red_pack_search_req{} = Msg, StateName) ->
	player_redpack_util:cs_red_pack_search_req(list_to_integer(Msg#cs_red_pack_search_req.uid)),
	StateName;

handle(Msg, StateName) ->
  ?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
  StateName.
