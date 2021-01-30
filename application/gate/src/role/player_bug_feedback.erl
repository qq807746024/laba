%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc @todo 处理Bug反馈.
%%%
%%% @end
%%% Created : 20. 二月 2017 16:13
%%%-------------------------------------------------------------------

-module(player_bug_feedback).
-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").

-define(BUG_CONTENT_MIN, 	5 * 3).	                                          % 5个汉字
-define(BUG_CONTENT_MAX,    500 * 3).                                         % 200个汉字



%% ====================================================================
%% API functions
%% ====================================================================
-export([cs_bug_feedback/1,
  send_bug_feedback/1
]).

cs_bug_feedback(NewContent1) ->
  Content1 = unicode:characters_to_binary(NewContent1),
  NewContent = erlang:binary_to_list(Content1),
  case ope_cd_check(?TYPE_OPE_CD_BUG_FEEDBACK, 60000) of
    true ->
      LenContent = length(NewContent),
      if
        LenContent =< ?BUG_CONTENT_MIN orelse LenContent >= ?BUG_CONTENT_MAX ->
          Result = 3;
        true ->
          case add_bug_record(NewContent) of
            ok ->
              Result = 1;
            _  ->
              Result = 3
          end
      end;
    _    ->
      Result = 2
  end,
  send_bug_feedback(Result),
  ok.

%% ====================================================================
%% Internal functions
%% ====================================================================


send_bug_feedback(ResultCode) ->
  Msg =
    #sc_common_bug_feedback{
      result = ResultCode
    },
  GatePid = player_util:get_dic_gate_pid(),
  tcp_client:send_data(GatePid, Msg).

ope_cd_check(Type, CDSecond) ->
  case get(Type) of
    undefined ->
      true;
    OldTime ->
      NowSeconds = util:now_long_seconds(),
      NowSeconds - OldTime > CDSecond
  end.
%把bug反馈信息记录到数据库中
add_bug_record(BugContent) ->
  refresh_ope_cd(?TYPE_OPE_CD_BUG_FEEDBACK),
  add_bug_feedback(BugContent),
  ok.

refresh_ope_cd(Type) ->
  NowSeconds = util:now_long_seconds(),
  put(Type, NowSeconds).

%% 添加玩家BUG反馈
add_bug_feedback(StrContent) ->
  NowSec=util:now_seconds(),
  PlayerInfo = player_util:get_dic_player_info(),
  BugRecordId = roleid_generator:get_auto_bug_record_id(),
  BugInfo=#bug_info{
    bug_id = BugRecordId,
    player_id = PlayerInfo#player_info.id,
    time = NowSec,
    str_content = StrContent
  } ,
  DBFun =
    fun() ->
      bug_info_db:t_write(BugInfo)
    end,
  DBSuccessFun =
    fun() ->
      ok
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      ok;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
      error
  end.


