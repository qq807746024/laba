%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 三月 2017 16:01
%%%-------------------------------------------------------------------
-module(base_config_mod).
-author("Administrator").


-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

-define(TIME_DIFF_SEC, 60).        % 计时器检测间隔
-define(SEC_NUM_CHECK, 59).        % 59.59时更新活动配置

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start_link/1,
  get_mod_pid/0,

  test_delete_misson/0,
  test_delete_misson_history/0,
  load_now_use_base_config/1,
  check_niu_room/0
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

start_link(ModProcessName) ->
  gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
  misc:get_mod_pid(?MODULE).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
  Result :: {ok, State}
  | {ok, State, Timeout}
  | {ok, State, hibernate}
  | {stop, Reason :: term()}
  | ignore,
  State :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([ModProcessName]) ->
  process_flag(trap_exit, true),
  util_process:register_local(ModProcessName, self()),

  NowSeconds = util:now_seconds(),
  {_, {_NowH, _NowM, NowS}} = util:seconds_to_datetime(NowSeconds),
  erlang:send_after((?TIME_DIFF_SEC - NowS + ?SEC_NUM_CHECK) * 1000, self(), 'timer_check'),
  erlang:send_after(1000,self(),'check_player_mission'),

  State = #state{},
  {ok, State}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
  Result :: {reply, Reply, NewState}
  | {reply, Reply, NewState, Timeout}
  | {reply, Reply, NewState, hibernate}
  | {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason, Reply, NewState}
  | {stop, Reason, NewState},
  Reply :: term(),
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity,
  Reason :: term().
%% ====================================================================
handle_call(Request, From, State) ->
  try
    do_call(Request, From, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("mod call Error! info = ~p, stack = ~p", [{Error, Reason, Request}, erlang:get_stacktrace()]),
      {reply, ok, State}
  end.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
  Result :: {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason :: term(), NewState},
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Msg, State) ->
  try
    do_cast(Msg, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
      {noreply, State}
  end.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
  Result :: {noreply, NewState}
  | {noreply, NewState, Timeout}
  | {noreply, NewState, hibernate}
  | {stop, Reason :: term(), NewState},
  NewState :: term(),
  Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(Info, State) ->
  try
    do_info(Info, State)
  catch
    Error:Reason ->
      ?ERROR_LOG("mod cast Error! info = ~p, stack = ~p", [{Error, Reason, Info}, erlang:get_stacktrace()]),
      {noreply, State}
  end.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
  Reason :: normal
  | shutdown
  | {shutdown, term()}
  | term().
%% ====================================================================
terminate(_Reason, _State) ->
  ?ERROR_LOG("~p terminated ", [?MODULE]),
  ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
  Result :: {ok, NewState :: term()} | {error, Reason :: term()},
  OldVsn :: Vsn | {down, Vsn},
  Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


do_call(Request, From, State) ->
  ?ERROR_LOG("mod call bad match! info = ~p", [{?MODULE, Request, From}]),
  {reply, ok, State}.

do_cast({'start_clear_missions'},State)->
  erlang:send(self(),'check_player_mission'),
  {noreply, State};

do_cast({'get_list'},State)->
  ?INFO_LOG("get_list~p => ~p",[get_list(),get_time_list()]),
  {noreply, State};


do_cast('test',State)->
  PlayerId = player_info_db:get_first(),
  erlang:send_after(1000,self(),{'test',PlayerId}),
  {noreply, State};

%%do_cast('close_txt',State)->
%%  error_logger:logfile(close),
%%  filelib:ensure_dir("../log/"),
%%  {{Yeah, Month, Day}, _} = calendar:local_time(),
%%  DayInfoStr = io_lib:format("~p-~p-~p",[Yeah, Month, Day+1]),
%%  FileName = lists:concat(["../log/log_", DayInfoStr, ".log"]),
%%  %FileName = "../log/log_node.log",
%%  error_logger:logfile({open, FileName}),
%%
%%  {noreply, State};
%%
%%do_cast('insert_log',State)->
%%  erlang:send(self(),'insert_log'),
%%  {noreply, State};

do_cast(Msg, State) ->
  ?ERROR_LOG("mod cast bad match! info = ~p", [{?MODULE, Msg}]),
  {noreply, State}.

%%do_info('insert_log',State) ->
%%  erlang:send_after(1000,self(),'insert_log'),
%%  lists:foreach(fun(E)->
%%    ?INFO_LOG("insert_log => ~p~n",[E]) end,lists:seq(1,100)),
%%  {noreply, State};


do_info({'test',FirstId},State) ->
  case FirstId of
    '$end_of_table' ->
      ?INFO_LOG("ok==ok"),
      TopId = player_info_db:get_first(),
      erlang:send_after(1000,self(),{'test_2',TopId});
    _->
      TailId =
      lists:foldl(fun(_E,AccId)->
        case player_info_db:get_base(AccId) of
          {ok,[_Info]}->
%%            NewInfo = Info#player_info{
%%              gold = util:rand(1,30000)
%%            },
%%            Dbfun = fun() ->player_info_db:t_write_player_info(NewInfo) end,
%%            dal:run_transaction_rpc(Dbfun),
            player_info_db:get_next(AccId);
          _->
            AccId
        end end,FirstId,lists:seq(1,200)),
      erlang:send_after(1000,self(),{'test',TailId})
  end,
  {noreply, State};

do_info({'test_2',FirstId},State) ->
  case FirstId of
    '$end_of_table' ->
      ?INFO_LOG("ok==ok");
    _->
      TailId =
        lists:foldl(fun(_E,AccId)->
          case player_info_db:get_base(AccId) of
            {ok,[Info]}->
              NewInfo = Info#player_info{
                gold = util:rand(1,30000)
              },
              Dbfun = fun() ->player_info_db:t_write_player_info(NewInfo) end,
              dal:run_transaction_rpc(Dbfun),
              player_info_db:get_next(AccId);
            _->
              AccId
          end end,FirstId,lists:seq(1,200)),
      erlang:send_after(1000,self(),{'test',TailId})
  end,
  {noreply, State};

do_info({'test_3',FirstId},State) ->
  case FirstId of
    '$end_of_table' ->
      ?INFO_LOG("ok==ok"),
      TopId = player_info_db:get_first(),
      erlang:send_after(1000,self(),{'test_2',TopId});
    _->
      TailId =
        lists:foldl(fun(_E,AccId)->
          case player_info_db:get_base(AccId) of
            {ok,[Info]}->
              NewInfo = Info#player_info{
                gold = util:rand(1,30000)
              },
              Dbfun = fun() ->player_info_db:t_write_player_info(NewInfo) end,
              dal:run_transaction_rpc(Dbfun),
              player_info_db:get_next(AccId);
            _->
              AccId
          end end,FirstId,lists:seq(1,200)),
      erlang:send_after(1000,self(),{'test',TailId})
  end,
  {noreply, State};


do_info('timer_check', State) ->
  NowSeconds = util:now_seconds(),
  {_, {_NowHour1, _NowM, NowS}} = util:seconds_to_datetime(NowSeconds),
  erlang:send_after((?TIME_DIFF_SEC - NowS + ?SEC_NUM_CHECK) * 1000, self(), 'timer_check'),
  % 跨小时必到一次数据
  %% 需预先导入
  {_, {NowHour2, _, _}} = util:seconds_to_datetime(NowSeconds + 60),
%%  check_niu_room(),

%%  if
%%    NowHour1 == NowHour2 ->
%%      skip;
%%    true ->
%%      load_now_use_base_config(NowSeconds + 60)
%%  end,
  if
    NowHour2 == 0 ->
      gate_app:init_ets_share_times_limit();
    true ->
      skip
  end,
  {noreply, State};

do_info('check_player_mission',State)->
  erlang:send_after(3600*1000,self(),'check_player_mission'),
  NowSeconds = util:now_seconds(),
  {_, {NowHour1, _NowM, _NowS}} = util:seconds_to_datetime(NowSeconds),
  CleanLaunchHour = player_util:get_server_const(?CONST_CONFIG_KEY_PLAYER_MISSION_CLEAN_TIME),
  if
    NowHour1 == CleanLaunchHour ->
      ?INFO_LOG("============> check_player_mission start clean...~n"),
      PlayerMissionKey= player_mission_db:get_first(),
      delete_player_mission(PlayerMissionKey,NowSeconds);

%%      {Dailys,Weeklys,_}=
%%      lists:foldl(fun(E,{Acc1,Acc2,Acc3}) ->
%%        Flag1 = (E#player_mission.mission_id >= 510000 andalso E#player_mission.mission_id < 520000) orelse  (E#player_mission.mission_id >= 530000 andalso E#player_mission.mission_id < 540000),
%%        Flag2 = (E#player_mission.mission_id >= 520000 andalso E#player_mission.mission_id < 530000),
%%        if
%%          Flag1 ->
%%            OldSec = util:datetime_to_seconds(E#player_mission.accept_time),
%%            case util:is_same_date(OldSec,NowSeconds) of
%%              true ->
%%                {Acc1,Acc2,Acc3};
%%              false ->
%%                {[E|Acc1],Acc2,Acc3}
%%            end;
%%          Flag2 ->
%%            OldSec = util:datetime_to_seconds(E#player_mission.accept_time),
%%            case util:is_same_week(OldSec,NowSeconds) of
%%              true ->
%%                {Acc1,Acc2,Acc3};
%%              false ->
%%                {Acc1,[E|Acc2],Acc3}
%%            end;
%%          true ->
%%            {Acc1,Acc2,Acc3}
%%        end end, {[],[],[]},PlayerMissionList),
%%      DBfunAcc1 =
%%      lists:foldl(fun(E,Acc)->
%%        case role_manager:get_roleprocessor(E#player_mission.player_id) of
%%          {ok,_Pid}->
%%            Acc;
%%          _->
%%           EDBfun = fun()->
%%             player_mission_db:delete(E#player_mission.key)
%%                    end,
%%            [EDBfun|Acc]
%%        end end,[],Dailys),
%%      DBfunAcc2 =
%%      lists:foldl(fun(E,Acc)->
%%        case role_manager:get_roleprocessor(E#player_mission.player_id) of
%%          {ok,_Pid}->
%%            Acc;
%%          _->
%%            EDBfun = fun()->
%%              player_mission_db:delete(E#player_mission.key)
%%                     end,
%%            [EDBfun|Acc]
%%        end end,[],Weeklys),
%%      DBFun = fun() ->
%%        lists:foreach(fun(E) -> E() end, DBfunAcc1),
%%        lists:foreach(fun(E) -> E() end, DBfunAcc2)
%%        end,
%%      case dal:run_transaction_rpc(DBFun) of
%%        {atomic, _} ->
%%          ?INFO_LOG("clear_missions_ok"),
%%          ok;
%%        {aborted, Reason} ->
%%          ?ERROR_LOG("Error ~p~n", [{Reason, ?MODULE, ?LINE}])
%%      end;
    true ->
      ?INFO_LOG("==========> check_player_mission skip_missions_ok ~n"),
      skip
  end,
  {noreply, State};


do_info(Info, State) ->
  ?ERROR_LOG("mod info bad match! info = ~p", [{?MODULE, Info}]),
  {noreply, State}.

load_now_use_base_config(NowSecond) ->
  NowDate = util:seconds_to_datetime(NowSecond),

  do_update_base_shop_item(NowDate).

do_update_base_shop_item(NowDate) ->
  %?INFO_LOG("base_config_mod~p~n"),
  ItemList = ets:tab2list(?ETS_SHOP_ITEM),
  case base_shop_item_db:get_list() of
    {ok, NewList} ->
      NewItemList =
        lists:filter(fun(E) ->
          if
            E#base_shop_item.end_time == 0 orelse E#base_shop_item.start_time == 0 ->
              true;
            true ->
              not (E#base_shop_item.end_time =< NowDate)
          end
                     end, NewList),
      {AddList, DeleteList} =
        lists:foldl(fun(E, {AddAcc, DeleteAcc}) ->
          case lists:member(E, DeleteAcc) of
            true ->
              NewDeleteAcc = lists:delete(E, DeleteAcc),
              {AddAcc, NewDeleteAcc};
            false ->
              {[E | AddAcc], DeleteAcc}
          end end, {[], ItemList}, NewItemList),
      %?INFO_LOG("add_list,delete_list~p~p~n",[AddList,DeleteList]),

      if
        AddList == [] andalso DeleteList == [] ->
          skip;
        true ->
          lists:foreach(fun(E) ->
            ets:delete_object(?ETS_SHOP_ITEM, E) end, DeleteList),

          lists:foreach(fun(E) ->
            ets:insert(?ETS_SHOP_ITEM, E) end, AddList),

          ets:foldl(fun(E, Acc) ->
            #ets_online{
              gate_pid = GatePid
            } = E,
            role_processor_mod:cast(GatePid, {'player_shop_update'}),
            Acc end,
            [],
            ?ETS_ONLINE)
      end;
    _ ->
      ?INFO_LOG("get_base_shop_item_fail~p", [{?MODULE, ?LINE}]),
      skip
  end.

delete_player_mission(CurKey,NowSeconds)->
  case CurKey of
    '$end_of_table' ->
      ?INFO_LOG("finish delete_player_mission ~p~n",[util:now_seconds()]),
      test_delete_misson_history();
    _->
      {ok,[PlayerMission]} = player_mission_db:get(CurKey),
      Flag0 = (PlayerMission#player_mission.mission_id >= 500000 andalso PlayerMission#player_mission.mission_id < 510000),
      Flag1 = (PlayerMission#player_mission.mission_id >= 510000 andalso PlayerMission#player_mission.mission_id < 520000)
        orelse (PlayerMission#player_mission.mission_id >= 12510000 andalso PlayerMission#player_mission.mission_id < 12520000)
        orelse (PlayerMission#player_mission.mission_id >= 22510000 andalso PlayerMission#player_mission.mission_id < 22520000)
        orelse (PlayerMission#player_mission.mission_id >= 32510000 andalso PlayerMission#player_mission.mission_id < 32520000)
        orelse (PlayerMission#player_mission.mission_id >= 530000 andalso PlayerMission#player_mission.mission_id < 540000) 
        orelse (PlayerMission#player_mission.mission_id >= 710000 andalso PlayerMission#player_mission.mission_id < 720000),
      Flag2 = (PlayerMission#player_mission.mission_id >= 520000 andalso PlayerMission#player_mission.mission_id < 530000),
      MonthlyFlag = (PlayerMission#player_mission.mission_id >= 540000 andalso PlayerMission#player_mission.mission_id < 550000),
%%      List = get_list(),
%%      NewList =
%%        case lists:keyfind(PlayerMission#player_mission.mission_id,1,List) of
%%          {Id,OldNum}->
%%            lists:keystore(PlayerMission#player_mission.mission_id,1,List,{Id,OldNum+1});
%%          false ->
%%            lists:keystore(PlayerMission#player_mission.mission_id,1,List,{PlayerMission#player_mission.mission_id,1})
%%        end,
%%      put_list(NewList),
%%      if
%%        PlayerMission#player_mission.mission_id>= 710000 andalso PlayerMission#player_mission.mission_id < 720000 ->
%%          TimeList = get_time_list(),
%%          NewTimeList =
%%            case lists:keyfind(PlayerMission#player_mission.player_id,1,TimeList) of
%%              {_,OldNum1}->
%%                lists:keystore(PlayerMission#player_mission.player_id,1,TimeList,{PlayerMission#player_mission.player_id,OldNum1+1});
%%              false ->
%%                lists:keystore(PlayerMission#player_mission.player_id,1,TimeList,{PlayerMission#player_mission.player_id,1})
%%            end,
%%      put_time_list(NewTimeList);
%%        true ->
%%          skip
%%      end,
      if
        Flag0 ->
          OldSec = util:datetime_to_seconds(PlayerMission#player_mission.accept_time),
          if
            NowSeconds >= OldSec + 30*?DAY_SECOND ->
              player_mission_db:delete(PlayerMission#player_mission.key);
            true ->
              skip
          end;
        Flag1 ->
          OldSec = util:datetime_to_seconds(PlayerMission#player_mission.accept_time),
          case util:is_same_date(OldSec,NowSeconds) of
            true ->
              skip;
            false ->
              player_mission_db:delete(PlayerMission#player_mission.key)
          end;
        Flag2 ->
          OldSec = util:datetime_to_seconds(PlayerMission#player_mission.accept_time),
          case util:is_same_week(OldSec,NowSeconds) of
            true ->
              skip;
            false ->
              player_mission_db:delete(PlayerMission#player_mission.key)
          end;
        MonthlyFlag ->
          case util:is_same_month_by_datetime(util:seconds_to_datetime(NowSeconds), PlayerMission#player_mission.accept_time) of
            true ->
              skip;
            _ ->
              player_mission_db:delete(PlayerMission#player_mission.key)
          end;
        true ->
          skip
      end,
      NextKey = player_mission_db:get_next(CurKey),
      delete_player_mission(NextKey,NowSeconds)
  end.

delete_player_mission_history(CurKey,Date,WeekNum) ->
  case CurKey of
    '$end_of_table' ->
      ?INFO_LOG("finish delete_player_mission_history ~p~n",[util:now_seconds()]),
      skip;
    {_PlayerId,_PlayerMissionId} ->
      NextKey = player_mission_history_db:get_next(CurKey),
      delete_player_mission_history(NextKey,Date,WeekNum);
    {PlayerId,PlayerMissionId,{OldYear,OldWeekNumOrMonth}} ->
      {{Y,M,_},_} = Date,
      MonthlyFlag = (PlayerMissionId >= 540000 andalso PlayerMissionId < 550000),
      if
        MonthlyFlag ->
          if
            Y > OldYear ->
              ?INFO_LOG("delete player mission history ~p~n", [{PlayerId,PlayerMissionId,{OldYear,OldWeekNumOrMonth}}]),
              player_mission_history_db:delete(CurKey);
            M > OldWeekNumOrMonth ->
              ?INFO_LOG("delete player mission history ~p~n", [{PlayerId,PlayerMissionId,{OldYear,OldWeekNumOrMonth}}]),
              player_mission_history_db:delete(CurKey);
            true ->
              skip
          end;
        true ->
          if
            Y > OldYear ->
              player_mission_history_db:delete(CurKey);
            WeekNum > OldWeekNumOrMonth ->
              player_mission_history_db:delete(CurKey);
            true ->
              skip
          end
      end,
      NextKey = player_mission_history_db:get_next(CurKey),
      delete_player_mission_history(NextKey,Date,WeekNum);
    {_PlayerId,_PlayerMissionId,{OldY,OldM,OldD}}->
      {{Y,M,D},_} = Date,
      if
        Y > OldY ->
          player_mission_history_db:delete(CurKey);
        M > OldM ->
          player_mission_history_db:delete(CurKey);
        D > OldD ->
          player_mission_history_db:delete(CurKey);
        true ->
          skip
      end,
      NextKey = player_mission_history_db:get_next(CurKey),
      delete_player_mission_history(NextKey,Date,WeekNum);
    _->
      NextKey = player_mission_history_db:get_next(CurKey),
      delete_player_mission_history(NextKey,Date,WeekNum)
  end.


test_delete_misson()->
  NowSeconds = util:now_seconds(),
  put_time_list([]),
  put_list([]),
  ?INFO_LOG("NowSeconds~p",[NowSeconds]),
  PlayerMissionKey= player_mission_db:get_first(),
  delete_player_mission(PlayerMissionKey,NowSeconds).

test_delete_misson_history()->
  Date = calendar:local_time(),
  WeekNum = util:week_of_year2(),
  ?INFO_LOG("NowSeconds~p",[Date]),
  PlayerMissionKey= player_mission_history_db:get_first(),
  delete_player_mission_history(PlayerMissionKey,Date,WeekNum).

get_list()->
  case get(list) of
    undefined ->
      [];
    List->
      List
  end.

put_list(Val)->
  put(list,Val).

get_time_list()->
  case get(time_list) of
    undefined ->
      [];
    List->
      List
  end.

put_time_list(Val)->
  put(time_list,Val).

%%test(PlayerMission,NowSeconds)->
%%  List = get_list(),
%%  NewList =
%%    case lists:keyfind(PlayerMission#player_mission.mission_id,1,List) of
%%      {Id,OldNum}->
%%        lists:keystore(PlayerMission#player_mission.mission_id,1,List,{Id,OldNum+1});
%%      false ->
%%        lists:keystore(PlayerMission#player_mission.mission_id,1,List,{PlayerMission#player_mission.mission_id,1})
%%    end,
%%  put_list(NewList),
%%  OldSec1 = util:datetime_to_seconds(PlayerMission#player_mission.accept_time),
%%  Flag11 = util:is_same_date(OldSec1,NowSeconds),
%%  Flag22 = util:is_same_week(OldSec1,NowSeconds),
%%  TimeList = get_time_list(),
%%  Type2 =
%%    if
%%      Flag11 ->
%%        1;
%%      Flag22 ->
%%        2;
%%      true ->
%%        3
%%    end,
%%  NewTimeList =
%%    case lists:keyfind(Type2,1,TimeList) of
%%      {Type2,OldNum1}->
%%        lists:keystore(Type2,1,TimeList,{Type2,OldNum1+1});
%%      false ->
%%        lists:keystore(Type2,1,TimeList,{Type2,1})
%%    end,
%%  put_time_list(NewTimeList).

check_niu_room()->
  List = ets:tab2list(?ETS_NIUNIU_ROOM),
  lists:map(fun(E) ->
    ?INFO_LOG("niu_room_body~p",[{E#niu_room_info.room_id,E#niu_room_info.room_level,E#niu_room_info.state,E#niu_room_info.end_sec_time}]) end,List).