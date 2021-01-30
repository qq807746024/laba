%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 六月 2017 16:30
%%%-------------------------------------------------------------------
-module(player_share_util).
-author("Administrator").

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/share_pb.hrl").

-define(PLAYER_SHARE_INFO, player_share_info).
-define(MISSION_TYPE_UNDONE, 0).
-define(MISSION_TYPE_DONE, 1).
-define(MISSION_TYPE_DRAW, 2).

-define(RAND_CODE_MAX_TIMES, 50). %随机邀请码次数

%% API
-export([
  init_player_share_info/1,
  send_login_info/0,
  cs_share_mission_reward_req/2,
  cs_share_new_bee_reward_req/1,
  do_share_mission/2,
  send_share_mission_done/1,
  send_share_mission_done_2/1,
  do_share_mission_type_prize/2,
  do_share_mission_offline/1,
  cs_share_with_friends_req/0,
  gm_test/3
]).

get_player_share_info() ->
  get(?PLAYER_SHARE_INFO).

update_player_share_info(Info) ->
  put(?PLAYER_SHARE_INFO, Info).



save_share_info(PlayerShareInfo) ->
  DBFun =
    fun() ->
      player_share_info_db:t_write(PlayerShareInfo)
    end,
  DBSuccessFun =
    fun() ->
      update_player_share_info(PlayerShareInfo)
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun(),
      ok;
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
      error
  end.

insert_share_code_ets(PlayerId, Code) ->
  EtsCode = #ets_share_code{
    code = Code,
    player_id = PlayerId
  },
  ets:insert(?ETS_SHARE_CODE, EtsCode).


init_player_share_info(PlayerId) ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      case player_share_info_db:get(PlayerId) of
        {ok, [PlayerShareInfo]} ->
          NewPlayerShareInfo = delete_mission(PlayerShareInfo),
          if
            NewPlayerShareInfo == PlayerShareInfo ->
              update_player_share_info(PlayerShareInfo);
            true ->
              save_share_info(NewPlayerShareInfo)
          end;
        _ ->
          Code = set_new_code(?RAND_CODE_MAX_TIMES),
          if
            Code == 0 ->
              Code1 = PlayerId * 100 + util:rand(1, 99);
            true ->
              Code1 = Code
          end,
          PlayerShareInfo = #player_share_info{
            player_id = PlayerId,
            my_code = Code1,
            obj_player_id = 0,
            share_player_num = 0,
            is_newbee_reward_draw = false,
            share_mission_list = []
          },
          save_share_info(PlayerShareInfo),
          insert_share_code_ets(PlayerId, Code)
      end
  end.

delete_mission(PlayerShareInfo) ->
  NewMissions = lists:filter(fun(E) ->
    {_Key, Status} = E,
    if
      Status == ?MISSION_TYPE_DRAW ->
        false;
      true ->
        true
    end end, PlayerShareInfo#player_share_info.share_mission_list),
  PlayerShareInfo#player_share_info{
    share_mission_list = NewMissions
  }.

send_login_info() ->
  PlayerInfo = player_util:get_dic_player_info(),
  if
    PlayerInfo#player_info.is_robot ->
      skip;
    true ->
      PlayerShareInfo = get_player_share_info(),
      MyCode = PlayerShareInfo#player_share_info.my_code,
      MyCode1 = integer_to_list(MyCode),
      Code = PlayerShareInfo#player_share_info.obj_code, %% 分享给我的邀请码
      Code1 = integer_to_list(Code),
      Free = PlayerShareInfo#player_share_info.is_newbee_reward_draw,
      Count = PlayerShareInfo#player_share_info.share_player_num,
      PbShareMission = lists:foldl(fun(E, Acc) ->
        {{FriendId, Type}, Status} = E,
        if
          Status == ?MISSION_TYPE_DONE ->
            case player_info_db:get_base(FriendId) of
              {ok, [FriendPlayerInfo]} ->
                EPbShareMission = package_share_mission(FriendPlayerInfo, Type, Status),
                [EPbShareMission | Acc];
              _ ->
                Acc
            end;
          true ->
            Acc
        end
                                   end, [], PlayerShareInfo#player_share_info.share_mission_list),
      send_share_info_back(MyCode1, Code1, Free, Count, PbShareMission)
  end.

package_share_mission(FriendPlayerInfo, Type, Status) ->
  {ok, Uid} = id_transform_util:role_id_to_proto(FriendPlayerInfo#player_info.id),
	if
		FriendPlayerInfo#player_info.icon == "" ->
			Head = integer_to_list(FriendPlayerInfo#player_info.sex);
		true ->
			Head = FriendPlayerInfo#player_info.icon
	end,
  #pb_share_mission{
    friend_id = Uid,
    name = FriendPlayerInfo#player_info.player_name,
    head = Head,
    vip_lv = FriendPlayerInfo#player_info.vip_level,
    title = get_title(Type),
    type = Type,
    status = Status
  }.

send_share_info_back(MyCode, Code, Free, Count, PbShareMission) ->
  Msg = #sc_share_info{
    my_code = MyCode,
    code = Code,
    free = Free,
    count = Count,
    list = PbShareMission
  },
  %?INFO_LOG("sc_share_info~p~n", [Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_title(Type) ->
  case share_reward_config_db:get(Type) of
    {ok, [RewardConfig]} ->
      RewardConfig#share_reward_config.descirbe;
    _ ->
      ""
  end.

cs_share_new_bee_reward_req(Code1) ->
  CheckCode =
  try
    Code2 = list_to_integer(Code1),
    {true,Code2}
  catch
    _Error:_Reason ->
      false
  end,
  case CheckCode of
    false->
      send_share_new_bee_reward_back(1, "输入错误，邀请码由数字组成", []);
    {true,Code}->

      PlayerInfo = player_util:get_dic_player_info(),
      PlayerShareInfo = get_player_share_info(),
      NowSec = util:now_seconds(),
      Flag1 = NowSec > PlayerInfo#player_info.create_time + ?DAY_SECOND ,
      Flag2 = PlayerShareInfo#player_share_info.is_newbee_reward_draw,
      case ets:lookup(?ETS_SHARE_CODE, Code) of
        [Info] ->
	      ObjPlayerId = Info#ets_share_code.player_id,
          Flag3 = true;
        _ ->
	      ObjPlayerId = 0,
          Flag3 = false
      end,
      TimesInfo =
        case ets:lookup(?ETS_SHARE_TIMES_LIMIT, Code) of
          [TimesInfo1] ->
            TimesInfo1#ets_lucky_bag{
              num = TimesInfo1#ets_lucky_bag.num + 1
            };
          _->
            #ets_lucky_bag{
              id = Code,
              num = 1
            }
        end,
      if
%%        TimesInfo#ets_lucky_bag.num > 3 ->
%%          send_share_new_bee_reward_back(1, "该邀请码今天已经被3名玩家使用过！", []);
        Flag1 ->
	    	send_share_new_bee_reward_back(1, "注册24小时内才可填写邀请码！", []);
        Flag2 ->
	    	send_share_new_bee_reward_back(1, "你已经领取过新人礼包了哦!", []);
        not Flag3 ->
	    	send_share_new_bee_reward_back(1, "邀请码错误", []);
	    ObjPlayerId == PlayerInfo#player_info.id ->
	    	send_share_new_bee_reward_back(1, "不能使用自己的邀请码", []);
        true ->
          Rewards = get_share_newbee_reward(),
          {_NewPlayerInfo, DBFun1, SuccessFun1, Pbrewards} =
            item_use:transc_items_reward(Rewards, ?REWARD_TYPE_SHARE),


          {ok, [ObjPlayerShareInfo]} = player_share_info_db:get(ObjPlayerId),

          NewPlayerShareInfo = change_share_info(PlayerShareInfo, ObjPlayerId, Code),
          {NewObjPlayerShareInfo, Missions} = update_obj_share_info(PlayerInfo, ObjPlayerShareInfo),

          DBFun = fun() ->
            DBFun1(),
            player_share_info_db:t_write(NewPlayerShareInfo),
            case role_manager:get_roleprocessor(ObjPlayerId) of
              {ok, ObjPlayerPid} ->
                role_processor_mod:cast(ObjPlayerPid, {'send_share_mission_update_2', Missions});
              _ ->
                player_share_info_db:t_write(NewObjPlayerShareInfo)
            end end,
          DBSuccessFun = fun() ->
            SuccessFun1(),
            ets:insert(?ETS_SHARE_TIMES_LIMIT, TimesInfo),
            update_player_share_info(NewPlayerShareInfo),
            send_share_new_bee_reward_back(0, "", Pbrewards),
            http_static_util:post_share(ObjPlayerId,PlayerInfo#player_info.id,1,util:now_seconds())
                         end,
          case dal:run_transaction_rpc(DBFun) of
            {atomic, _} ->
              DBSuccessFun();
            {aborted, Reason} ->
              ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
              send_share_new_bee_reward_back(1, "数据库错误", [])
          end
      end
  end.

send_share_new_bee_reward_back(Result, Err, Pbrewards) ->
  Msg = #sc_share_new_bee_reward_reply{
    result = Result,
    err = Err,
    rewards = Pbrewards
  },
  %?INFO_LOG("sc_share_new_bee_reward_requst~p~n", [Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

cs_share_mission_reward_req(FriendUid, Type) ->
  {ok, FriendId} = id_transform_util:role_id_to_internal(FriendUid),
  %?INFO_LOG("share_mission~p~n",[{FriendId,Type}]),
  case pre_share_mission_reward(FriendId, Type) of
    {true, AccDict} ->
      Rewards = dict:fetch(reward, AccDict),
      NewShareMissions = dict:fetch(new_share_mission, AccDict),
      PlayerShareInfo = get_player_share_info(),
      NewPlayerShareInfo = PlayerShareInfo#player_share_info{
        share_mission_list = NewShareMissions
      },
      {_NewPlayerInfo, DBFun1, SuccessFun1, Pbrewards} =
        item_use:transc_items_reward(Rewards, ?REWARD_TYPE_SHARE),

      DBFun = fun() ->
        DBFun1(),
        player_share_info_db:t_write(NewPlayerShareInfo)
              end,
      DBSuccessFun = fun() ->
        SuccessFun1(),
        update_player_share_info(NewPlayerShareInfo),
        send_share_mission_reward_back(0, "", Pbrewards, FriendUid, Type),
        http_static_util:post_share(PlayerShareInfo#player_share_info.player_id,FriendId,2,util:now_seconds()),
        player_mission:share_times(1)
                     end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSuccessFun();
        {aborted, Reason} ->
          ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
          send_share_mission_reward_back(1, "数据库错误", [], "", 0)
      end;
    {false, Err} ->
      send_share_mission_reward_back(1, Err, [], "", 0)
  end.

pre_share_mission_reward(FriendId, Type) ->
  Requires = [
    check_type,
    check_friend_id,
    check_done,
    check_reward
  ],
  AccDict = dict:from_list([
    {friend_id, FriendId},
    {type, Type}
  ]),
  share_mission_reward_requires(AccDict, Requires).

share_mission_reward_requires(AccDict, []) ->
  {true, AccDict};

share_mission_reward_requires(AccDict, [check_type | T]) ->
  Type = dict:fetch(type, AccDict),
  if
    Type > 4 orelse Type < 1 ->
      {false, "任务类型错误"};
    true ->
      share_mission_reward_requires(AccDict, T)
  end;

share_mission_reward_requires(AccDict, [check_done | T]) ->
  FriendId = dict:fetch(friend_id, AccDict),
  Type = dict:fetch(type, AccDict),
  PlayerShareInfo = get_player_share_info(),
  %?INFO_LOG("share_info~p~n",[PlayerShareInfo]),
  ShareMissions = PlayerShareInfo#player_share_info.share_mission_list,
  case lists:keyfind({FriendId, Type}, 1, ShareMissions) of
    false ->
      {false, "查询任务错误"};
    {{FriendId, Type}, Status} ->
      case Status of
        ?MISSION_TYPE_UNDONE ->
          {false, "任务未完成"};
        ?MISSION_TYPE_DRAW ->
          {false, "奖励已领取"};
        _ ->
          NewShareMissions =
            lists:keystore({FriendId, Type}, 1, ShareMissions, {{FriendId, Type}, ?MISSION_TYPE_DRAW}),
          AccDict1 = dict:store(new_share_mission, NewShareMissions, AccDict),
          share_mission_reward_requires(AccDict1, T)
      end
  end;

share_mission_reward_requires(AccDict, [check_reward | T]) ->
  Type = dict:fetch(type, AccDict),
  Reward = get_share_mission_reward(Type),
  AccDict1 = dict:store(reward, Reward, AccDict),
  share_mission_reward_requires(AccDict1, T);

share_mission_reward_requires(AccDict, [_ | T]) ->
  share_mission_reward_requires(AccDict, T).

send_share_mission_reward_back(Result, Err, Pbrewards, FriendUid, Type) ->
  Msg = #sc_share_mission_reward_reply{
    result = Result,
    err = Err,
    rewards = Pbrewards,
    friend_id = FriendUid,
    type = Type
  },
%%  ?INFO_LOG("sc_hare_mission_reward_reply~p~n", [Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_share_mission_reward(Type) ->
  case share_reward_config_db:get(Type) of
    {ok, [RewardConfig]} ->
      [_, Id, Num] = RewardConfig#share_reward_config.reward,
      [{Id, Num}];
    _ ->
      []
  end.

do_share_mission(PlayerId, RechargeNum) ->
  Condition1 = get_share_mission_condition(1),
%%  Condition2 = get_share_mission_condition(2),
%%  Condition3 = get_share_mission_condition(3),
  %?INFO_LOG("do_share_mission~p~n", [{RechargeNum,Condition1}]),
  if
    RechargeNum >= Condition1 ->
      do_share_mission({PlayerId, 1});
    true ->
      skip
  end.

do_share_mission_type_prize(PlayerId,Num) ->
  Condition1 = get_share_mission_condition(4),
%%  Condition2 = get_share_mission_condition(2),
%%  Condition3 = get_share_mission_condition(3),
  %?INFO_LOG("do_share_mission~p~n", [{RechargeNum,Condition1}]),
  if
    Num >= Condition1 ->
      do_share_mission({PlayerId, 4});
    true ->
      skip
  end.
%%  if
%%    RechargeNum >= Condition2 ->
%%      do_share_mission({PlayerId, 2});
%%    true ->
%%      skip
%%  end,
%%  if
%%    RechargeNum >= Condition3 ->
%%      do_share_mission({PlayerId, 3});
%%    true ->
%%      skip
%%  end.
do_share_mission_offline({PlayerId, Type}) ->
  case player_share_info_db:get(PlayerId) of
    {ok,[PlayerShareInfo]}->
      ObjPlayerId = PlayerShareInfo#player_share_info.obj_player_id,
      if
        ObjPlayerId == 0->
          skip;
        true ->
          Check =
            case player_share_info_db:get(ObjPlayerId) of
              {ok, [ObjPlayerShareInfo]} ->
                OldShareMissions = ObjPlayerShareInfo#player_share_info.share_mission_list,
                case lists:keyfind({PlayerId, Type}, 1, OldShareMissions) of
                  false ->
                    false;
                  {{PlayerId, Type}, ?MISSION_TYPE_DONE} ->
                    false;
                  {{PlayerId, Type}, ?MISSION_TYPE_DRAW} ->
                    false;
                  {{PlayerId, Type}, ?MISSION_TYPE_UNDONE} ->
                    {true, ObjPlayerShareInfo, OldShareMissions};
                  _ ->
                    false
                end;
              _ ->
                false
            end,
          case Check of
            false ->
              skip;
            {true, ObjPlayerShareInfo1, OldShareMissions1} ->
              NewShareMissions =
                lists:keystore({PlayerId, Type}, 1, OldShareMissions1, {{PlayerId, Type}, ?MISSION_TYPE_DONE}),
              NewObjPlayerShareInfo = ObjPlayerShareInfo1#player_share_info{
                share_mission_list = NewShareMissions
              },

              DBFun = fun() ->
                case role_manager:get_roleprocessor(ObjPlayerId) of
                  {ok, ObjPlayerPid} ->
                    role_processor_mod:cast(ObjPlayerPid, {'send_share_mission_update', [{PlayerId, Type}]});
                  _ ->
                    player_share_info_db:t_write(NewObjPlayerShareInfo)
                end
                      end,
              DBSccussFun = fun() -> void end,
              case dal:run_transaction_rpc(DBFun) of
                {atomic, _} ->
                  DBSccussFun();
                {aborted, Reason} ->
                  ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
              end
          end
      end;
    _->
      skip
  end.


do_share_mission({PlayerId, Type}) ->
  PlayerShareInfo = get_player_share_info(),
  ObjPlayerId = PlayerShareInfo#player_share_info.obj_player_id,
  Check =
    case player_share_info_db:get(ObjPlayerId) of
      {ok, [ObjPlayerShareInfo]} ->
        OldShareMissions = ObjPlayerShareInfo#player_share_info.share_mission_list,
        case lists:keyfind({PlayerId, Type}, 1, OldShareMissions) of
          false ->
            false;
          {{PlayerId, Type}, ?MISSION_TYPE_DONE} ->
            false;
          {{PlayerId, Type}, ?MISSION_TYPE_DRAW} ->
            false;
          {{PlayerId, Type}, ?MISSION_TYPE_UNDONE} ->
            {true, ObjPlayerShareInfo, OldShareMissions};
          _ ->
            false
        end;
      _ ->
        false
    end,
  case Check of
    false ->
      skip;
    {true, ObjPlayerShareInfo1, OldShareMissions1} ->
      NewShareMissions =
        lists:keystore({PlayerId, Type}, 1, OldShareMissions1, {{PlayerId, Type}, ?MISSION_TYPE_DONE}),
      NewObjPlayerShareInfo = ObjPlayerShareInfo1#player_share_info{
        share_mission_list = NewShareMissions
      },

      DBFun = fun() ->
        case role_manager:get_roleprocessor(ObjPlayerId) of
          {ok, ObjPlayerPid} ->
            role_processor_mod:cast(ObjPlayerPid, {'send_share_mission_update', [{PlayerId, Type}]});
          _ ->
            player_share_info_db:t_write(NewObjPlayerShareInfo)
        end
              end,
      DBSccussFun = fun() -> void end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSccussFun();
        {aborted, Reason} ->
          ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
      end
  end.

send_share_mission_done(KeyList) ->
  if
    KeyList == [] ->
      skip;
    true ->

      PlayerShareInfo = get_player_share_info(),

      AllMissions = PlayerShareInfo#player_share_info.share_mission_list,
      SendMissions = lists:foldl(fun(E, Acc) ->
        case lists:keyfind(E, 1, AllMissions) of
          false ->
            Acc;
          Tuple ->
            [Tuple | Acc]
        end end, [], KeyList),
      NewShareMissions =
        lists:foldl(fun(E, OldAcc) ->
          lists:keystore(E, 1, OldAcc, {E, ?MISSION_TYPE_DONE})
                    end, AllMissions, KeyList),
      NewPlayerShareInfo = PlayerShareInfo#player_share_info{
        share_mission_list = NewShareMissions
      },

      PbShareMissions = lists:foldl(fun(E, Acc) ->
        {{FriendId, Type}, _Status} = E,
        case player_info_db:get_base(FriendId) of
          {ok, [FriendPlayerInfo]} ->
            EPbShareMission = package_share_mission(FriendPlayerInfo, Type, ?MISSION_TYPE_DONE),
            [EPbShareMission | Acc];
          _ ->
            Acc
        end end, [], SendMissions),

      DBFun = fun() ->
        player_share_info_db:t_write(NewPlayerShareInfo)
              end,
      DBSccussFun = fun() ->
        update_player_share_info(NewPlayerShareInfo),
        send_share_mission_update(PbShareMissions,PlayerShareInfo#player_share_info.share_player_num)
                    end,
      case dal:run_transaction_rpc(DBFun) of
        {atomic, _} ->
          DBSccussFun();
        {aborted, Reason} ->
          ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
      end
  end.

send_share_mission_done_2(Missions) ->

  PlayerShareInfo = get_player_share_info(),
  OldCount = PlayerShareInfo#player_share_info.share_player_num,

  AllMissions = PlayerShareInfo#player_share_info.share_mission_list,
  NewShareMissions =
    lists:foldl(fun(E, OldAcc) ->
      {Key, _Status} = E,
      lists:keystore(Key, 1, OldAcc, E)
                end, AllMissions, Missions),
  NewPlayerShareInfo = PlayerShareInfo#player_share_info{
    share_mission_list = NewShareMissions,
  share_player_num = OldCount + 1
  },

  SendMissions = lists:filter(fun({_EKey, EStatus}) ->
    EStatus == ?MISSION_TYPE_DONE end, Missions),

  PbShareMissions = lists:foldl(fun(E, Acc) ->
    {{FriendId, Type}, _Status} = E,
    case player_info_db:get_base(FriendId) of
      {ok, [FriendPlayerInfo]} ->
        EPbShareMission = package_share_mission(FriendPlayerInfo, Type, ?MISSION_TYPE_DONE),
        [EPbShareMission | Acc];
      _ ->
        Acc
    end end, [], SendMissions),

  DBFun = fun() ->
    player_share_info_db:t_write(NewPlayerShareInfo)
          end,
  DBSccussFun = fun() ->
    update_player_share_info(NewPlayerShareInfo),
    if
      PbShareMissions == [] ->
        send_share_mission_update([],OldCount + 1);
      true ->
        send_share_mission_update(PbShareMissions,OldCount + 1)
    end
                end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSccussFun();
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
  end.


send_share_mission_update(PbShareMissions,Count) ->
  Msg = #sc_share_mission_update{
    list = PbShareMissions,
    count = Count
  },
  %?INFO_LOG("sc_share_mission_update~p~n", [Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


set_new_code(Count) ->
  if
    Count == 0 ->
      0;
    true ->
      case check_code() of
        false ->
          set_new_code(Count - 1);
        Code ->
          Code
      end
  end.

check_code() ->
  Code = util:rand(10000000, 99999999),
  case ets:lookup(?ETS_SHARE_CODE, Code) of
    [_info] ->
      false;
    _ ->
      Code
  end.

update_obj_share_info(PlayerInfo, ObjPlayerShareInfo) ->

  OldPlayerNum = ObjPlayerShareInfo#player_share_info.share_player_num,
  {NewShareMissions, Missions} =
    insert_share_mission(ObjPlayerShareInfo#player_share_info.share_mission_list, PlayerInfo#player_info.id, PlayerInfo),
  NewObjPlayerShareInfo = ObjPlayerShareInfo#player_share_info{
    share_mission_list = NewShareMissions,
    share_player_num = OldPlayerNum + 1
  },
  {NewObjPlayerShareInfo, Missions}.

insert_share_mission(ShareMissions, PlayerId, _PlayerInfo) ->
%%  Condition1 = get_share_mission_condition(1),
%%  Condition2 = get_share_mission_condition(2),
%%  Condition3 = get_share_mission_condition(3),
%%  if
%%    PlayerInfo#player_info.recharge_money > Condition1 ->
%%      KeyList = [{{PlayerId, 1}, ?MISSION_TYPE_DONE}],
%%      ShareMissions1 = lists:keystore({PlayerId, 1}, 1, ShareMissions, {{PlayerId, 1}, ?MISSION_TYPE_DONE});
%%    true ->
%%      KeyList = [{{PlayerId, 1}, ?MISSION_TYPE_UNDONE}],
%%      ShareMissions1 = lists:keystore({PlayerId, 1}, 1, ShareMissions, {{PlayerId, 1}, ?MISSION_TYPE_UNDONE})
%%  end,
%%  if
%%    PlayerInfo#player_info.recharge_money > Condition2 ->
%%      KeyList2 = [{{PlayerId, 2}, ?MISSION_TYPE_DONE} | KeyList],
%%      ShareMissions2 = lists:keystore({PlayerId, 2}, 1, ShareMissions1, {{PlayerId, 2}, ?MISSION_TYPE_DONE});
%%    true ->
%%      KeyList2 = [{{PlayerId, 2}, ?MISSION_TYPE_UNDONE} | KeyList],
%%      ShareMissions2 = lists:keystore({PlayerId, 2}, 1, ShareMissions1, {{PlayerId, 2}, ?MISSION_TYPE_UNDONE})
%%  end,
%%  if
%%    PlayerInfo#player_info.recharge_money >= Condition3 ->
%%      KeyList3 = [{{PlayerId, 3}, ?MISSION_TYPE_DONE} ],
%%      ShareMissions3 = lists:keystore({PlayerId, 3}, 1, ShareMissions2, {{PlayerId, 3}, ?MISSION_TYPE_DONE});
%%    true ->
%%      KeyList3 = [{{PlayerId, 3}, ?MISSION_TYPE_UNDONE} | KeyList2],
%%      ShareMissions3 = lists:keystore({PlayerId, 3}, 1, ShareMissions2, {{PlayerId, 3}, ?MISSION_TYPE_UNDONE})
%%  end,
  KeyList4 = [{{PlayerId, 4}, ?MISSION_TYPE_UNDONE}],
  ShareMissions4 = lists:keystore({PlayerId, 4}, 1, ShareMissions, {{PlayerId, 4}, ?MISSION_TYPE_UNDONE}),
  {ShareMissions4, KeyList4}.

get_share_mission_condition(Type) ->
  case share_reward_config_db:get(Type) of
    {ok, [RewardConfig]} ->
      RewardConfig#share_reward_config.condition;
    _ ->
      if
        Type == 1 ->
          1;
        Type == 2 ->
          30;
        Type == 3 ->
          100;
        true ->
          10
      end
  end.

get_share_newbee_reward() ->
  [{?ITEM_ID_GOLD, player_util:get_server_const(?CONST_CONFIG_KEY_SHARE_CODE_NEWBEE_REWARD)}].


change_share_info(PlayerShareInfo, ObjPlayerId, Code) ->
  PlayerShareInfo#player_share_info{
    obj_player_id = ObjPlayerId,
    is_newbee_reward_draw = true,
    obj_code = Code
  }.

cs_share_with_friends_req()->
  skip.
  %player_7_day_carnival_util:update_7_day_carnival_mission(5,1).



gm_test(Type, Code, Type2) ->
  if
    Type == 1 ->
      Uid = integer_to_list(Code),
      cs_share_new_bee_reward_req(Uid);
    Type == 2 ->
      {ok, Uid} = id_transform_util:role_id_to_proto(Code),
      cs_share_mission_reward_req(Uid, Type2);
    Type == 3 ->
      do_share_mission(Code, Type2);
    Type == 4 ->
      PlayerInfo = player_util:get_dic_player_info(),
      PlayerId = PlayerInfo#player_info.id,
      A = PlayerId * 100 + util:rand(1, 99),
      ?INFO_LOG("code2~p~n", [A]);
    true ->
      ok
  end.
