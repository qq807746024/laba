%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 四月 2018 14:41
%%%-------------------------------------------------------------------
-module(ge_activity).
-include("../../gate/include/logger.hrl").
-author("Administrator").


-include_lib("network_proto/include/activity_pb.hrl").

-export([handle/2]).

handle(#cs_task_pay_award_request{} = Msg, StateName) ->
  player_pay_activity_util:cs_task_pay_award_request(Msg#cs_task_pay_award_request.index),
  StateName;

handle(#cs_task_pay_info_request{} = _Msg, StateName) ->
  player_pay_activity_util:cs_task_pay_info_request(),
  StateName;

handle(Msg, StateName) ->
  ?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
  StateName.