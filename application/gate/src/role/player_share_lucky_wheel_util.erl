%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 三月 2018 14:14
%%%-------------------------------------------------------------------
-module(player_share_lucky_wheel_util).
-author("Administrator").

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/share_pb.hrl").

-define(SHARE_LUCKY_WHEEL_INFO, share_lucky_wheel_info).

%% API
-export([
  init_share_lucky_wheel_info/1,
  draw/1,
  cs_share_rank_request/1,
  cs_share_friend_request/2,
  gm_test/1,
  send_init_msg/0,
  get_share_times/0,
  para/1,
  a/0
]).

get_share_lucky_wheel_info() ->
  get(?SHARE_LUCKY_WHEEL_INFO).

update_share_lucky_wheel_info(Val) ->
  put(?SHARE_LUCKY_WHEEL_INFO, Val).

save_share_lucky_wheel_info(NewInfo) ->
  DBFun =
    fun() ->
      player_share_lucky_wheel_info_db:t_write(NewInfo)
    end,
  DBSuccessFun =
    fun() ->
      update_share_lucky_wheel_info(NewInfo)
    end,
  case dal:run_transaction_rpc(DBFun) of
    {atomic, _} ->
      DBSuccessFun();
    {aborted, Reason} ->
      ?ERROR_LOG("run transaction error:~p~n", [{?MODULE, ?LINE, Reason, ?STACK_TRACE}])
  end.

init_share_lucky_wheel_info(PlayerId) ->
  case player_share_lucky_wheel_info_db:get(PlayerId) of
    {ok, [Info]} ->
      NewInfo = share_draw_times(Info),
%%      ?INFO_LOG("NewInfo~p~n",[NewInfo]),
      update_share_lucky_wheel_info(NewInfo);
    _ ->
      NewInfo = #player_share_lucky_wheel_info{
        player_id = PlayerId,
        all_times_1 = 0,
        draw_times_1 = 0,
        fresh_time_1 = 1514736000,
        all_times_3 = 0,
        draw_times_3 = 0,
        fresh_time_3 = 1514736000,
        all_times_7 = 0,
        draw_times_7 = 0,
        fresh_time_7 = 1514736000
      },
      save_share_lucky_wheel_info(NewInfo)
  end.

get_share_times()->
  Info = get_share_lucky_wheel_info(),
  if
    Info == undefined ->
      0;
    true ->
      Info#player_share_lucky_wheel_info.all_times_1
  end.


send_init_msg()->
  NewInfo = get_share_lucky_wheel_info(),
  Msg = #sc_draw_count_response{
    draw_count  = NewInfo#player_share_lucky_wheel_info.all_times_3 - NewInfo#player_share_lucky_wheel_info.draw_times_3,
    draw_count_seven  = NewInfo#player_share_lucky_wheel_info.all_times_7 - NewInfo#player_share_lucky_wheel_info.draw_times_7,
    draw_count_one = NewInfo#player_share_lucky_wheel_info.all_times_1 - NewInfo#player_share_lucky_wheel_info.draw_times_1
  },
%%  ?INFO_LOG("sc_draw_count_response~p~n",[Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

draw(Type) ->
  ShareLuckyWheelInfo = get_share_lucky_wheel_info(),
  if
    ShareLuckyWheelInfo == undefined->
      send_sc_share_draw_response(1,"未参与活动",0);
    true ->
      case get_all_times_and_draw_times(Type, ShareLuckyWheelInfo)  of
        {AllTimes, DrawTimes} ->
%%          ?INFO_LOG("get_all_times_and_draw_times~p~n",[{AllTimes, DrawTimes}]),
          if
            DrawTimes + 1 > AllTimes ->
              send_sc_share_draw_response(1,"次数不足",0);
            true ->
             [{Index, Reward}] = get_lucky_wheel_reward(Type),
              if
                Index == 0 ->
                  skip;
                true ->
                  {NewPlayerInfo, DBReward, SuccessReward, _PbReward} =
                    item_use:transc_items_reward([Reward], ?REWARD_TYPE_SHARE_LUCKY_WHEEL),

                  NewShareLuckyWheelInfo = add_draw_times(ShareLuckyWheelInfo, Type, 1),

                  DBFun = fun() ->
                    DBReward(),
                    player_share_lucky_wheel_info_db:t_write(NewShareLuckyWheelInfo)
                          end,

                  DBSuccess = fun() ->
                    SuccessReward(),
                    update_share_lucky_wheel_info(NewShareLuckyWheelInfo),
                    send_init_msg(),
                    send_sc_share_draw_response(0,"",Index),
                    http_static_util:post_sharelottery(NewPlayerInfo,Type,Reward,util:now_seconds())
                              end,

                  case dal:run_transaction_rpc(DBFun) of
                    {atomic, _} ->
                      DBSuccess();
                    {aborted, Reason} ->
                      ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
                  end
              end
          end;
        _->
          send_sc_share_draw_response(1,"查询数据错误",0)
      end
  end.

send_sc_share_draw_response(Result,Err,Index) ->
  Msg = #sc_share_draw_response{
    result = Result,
    err = Err,
    index = Index
  },
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_all_times_and_draw_times(Type, ShareLuckyWheelInfo) ->
  case Type of
    1 ->
      {ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_1, ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_1};
    2 ->
      {ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_3, ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_3};
    3 ->
      {ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_7, ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_7}
  end.

get_lucky_wheel_reward(Type) ->
  case share_redpack_config_db:get(Type) of
    {ok, [Config]} ->
      {random_weight, RewardList, WeightList} = Config#share_redpack_config.reward,
      IndexList = lists:seq(1, length(RewardList)),
      RewardList2 = lists:zip(IndexList, RewardList),
      util_random:get_random_rewards({random_weight, RewardList2, WeightList});
    _ ->
      [{0, {0, 0}}]
  end.

add_draw_times(ShareLuckyWheelInfo, Type, Count) ->
  case Type of
    1 ->
      ShareLuckyWheelInfo#player_share_lucky_wheel_info{
        draw_times_1 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_1 + Count
      };
    2 ->
      ShareLuckyWheelInfo#player_share_lucky_wheel_info{
        draw_times_3 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_3 + Count
      };
    3 ->
      ShareLuckyWheelInfo#player_share_lucky_wheel_info{
        draw_times_7 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_7 + Count
      }
  end.

cs_share_rank_request(Page) ->
  PlayerInfo = player_util:get_dic_player_info(),
  {{Y, M, _}, _} = calendar:local_time(),

  StartTime = util:datetime_to_seconds({{Y, M, 1}, {0, 0, 0}}),
  EndTime =
  if
    M == 12 ->
      util:datetime_to_seconds({{Y + 1, 1, 1}, {0, 0, 0}});
    true ->
      util:datetime_to_seconds({{Y, M + 1, 1}, {0, 0, 0}})
  end,
  case http_static_util:post_get_share_rank_list(Page, 7, PlayerInfo#player_info.id, StartTime, EndTime) of
    false ->
      skip;
    Data ->
      try
          case para(Data) of
            [List,TotatPages,Rank,ShareCount] ->
%%              ?INFO_LOG("231212~p~n",[{List,TotatPages,Rank,ShareCount}]),
              PbRankItems =
              lists:map(fun([ERank,EAccount,EShareCount])->
                EName =
                case player_info_db:get_player_info_by_account(EAccount) of
                  [EPlayerInfo|_] ->
                    EPlayerInfo#player_info.player_name;
                  _->
                    ""
                end,
                #pb_share_rank_item_response{
                  name = EName,
                  rank = ERank,
                  count = EShareCount
                } end,List),

            send_sc_share_rank_response(ShareCount,Rank,TotatPages,PbRankItems,StartTime,EndTime);
            _->
              skip
          end
      catch
          E:R  ->
            ?INFO_LOG("share_rank_err~p~n",[{Data,E,R,erlang:get_stacktrace()}])
      end
  end.

send_sc_share_rank_response(ShareCount,Rank,TotatPages,PbRankItems,StartTime,EndTime)->
  Msg = #sc_share_rank_response{
    count = ShareCount,
    rank = Rank,
    pages = TotatPages,
    list = PbRankItems,
    begintime = StartTime,
    endtime = EndTime
  },
%%  ?INFO_LOG("sc_share_rank_response~p~n",[Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(),Msg).

cs_share_friend_request(Page, ObjAccount) ->
  PlayerInfo = player_util:get_dic_player_info(),
  ShareLuckyWheelInfo = get_share_lucky_wheel_info(),
  if
    ShareLuckyWheelInfo == undefined->
      skip;
    true ->
      if
        ObjAccount == undefined ->
          case http_static_util:post_get_self_share_list(Page, 7, PlayerInfo#player_info.id) of
%%      case http_static_util:post_get_self_share_list(1, 10, "10258180") of
            false ->
              skip;
            Data ->
              try
                case para(Data) of
                  [List,ShareCount,TotatPages] ->
%%                    ?INFO_LOG("List,ShareCount,TotatPages~p~n",[{List,ShareCount,TotatPages}]),
                    PbShareItems =
                      lists:map(fun([EAccount,EDay1,EDay2,EDay3,IsRed,ECreateTime])->
%%                        ?INFO_LOG("EAccount~p~n",[EAccount]),
                        EName =
                          case player_info_db:get_player_info_by_account(EAccount) of
                            [EPlayerInfo|_] ->
                              EPlayerInfo#player_info.player_name;
                            _->
                              ""
                          end,
                        #pb_share_history_friend_item_response{
                          userid = EAccount,
                          name = EName,
                          create_time = ECreateTime,
                          first_day = EDay1,
                          three_day = EDay2,
                          seven_day = EDay3,
                          is_red = IsRed
                        } end,List),
                    Draw1 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_1 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_1,
                    Draw2 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_3 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_3,
                    Draw3 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_7 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_7,
                    send_sc_share_history_response(ShareCount,Draw1,Draw2,Draw3,TotatPages,PbShareItems);
                  _->
                    skip
                end
              catch
                E:R  ->
                  ?INFO_LOG("share_friend_request_err~p~n",[{E,R,Data,erlang:get_stacktrace()}])
              end
          end;
        true ->
%%          ?INFO_LOG("Page, ObjAccount~p~n",[{ObjAccount,player_info_db:get_player_info_by_account(ObjAccount)}]),
          case player_info_db:get_player_info_by_account(ObjAccount) of
            [ObjPlayerInfo]->
%%              ?INFO_LOG("Page, ObjAccount~p~n",[http_static_util:post_self_share_query(Page, 7, PlayerInfo#player_info.id, ObjPlayerInfo#player_info.id)]),
              case http_static_util:post_self_share_query(Page, 7, PlayerInfo#player_info.id, ObjPlayerInfo#player_info.id) of
%%      case http_static_util:post_self_share_query(1, 10, "10258180", "10241765") of
                false ->
                  skip;
                Data ->
                  try
                    case para(Data) of
                      [List,ShareCount,TotatPages] ->
%%                        ?INFO_LOG("List,ShareCount,TotatPages~p~n",[{List,ShareCount,TotatPages}]),
                        PbShareItems =
                          lists:map(fun([EAccount,EDay1,EDay2,EDay3,IsRed,ECreateTime])->
                            EName =
                              case player_info_db:get_player_info_by_account(EAccount) of
                                [EPlayerInfo|_] ->
                                  EPlayerInfo#player_info.player_name;
                                _->
                                  ""
                              end,
                            #pb_share_history_friend_item_response{
                              userid = EAccount,
                              name = EName,
                              create_time = ECreateTime,
                              first_day = EDay1,
                              three_day = EDay2,
                              seven_day = EDay3,
                              is_red = IsRed
                            } end,List),
                        Draw1 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_1 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_1,
                        Draw2 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_3 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_3,
                        Draw3 = ShareLuckyWheelInfo#player_share_lucky_wheel_info.all_times_7 - ShareLuckyWheelInfo#player_share_lucky_wheel_info.draw_times_7,
                        send_sc_share_history_response(ShareCount,Draw1,Draw2,Draw3,TotatPages,PbShareItems);
                      _->
                        skip
                    end
                  catch
                    E:R  ->
                      ?INFO_LOG("share_friend_request_err~p~n",[{E,R,Data,erlang:get_stacktrace()}])
                  end
              end;
            _->
              skip
          end
      end
  end.

send_sc_share_history_response(Count, Draw1, Draw3, Draw7, Page, List) ->
  Msg = #sc_share_history_response{
    count = Count,
    one_draw = Draw1,
    three_draw = Draw3,
    seven_draw = Draw7,
    pages = Page,
    list = List
  },
%%  ?INFO_LOG("sc_share_history_response~p~n",[Msg]),
  tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

share_draw_times(ShareLuckyWheelInfo)->
  PlayerInfo = player_util:get_dic_player_info(),
  case get_post_get_get_task_count(PlayerInfo#player_info.id) of
    {Day1,Day2,Day3}->
%%      ?INFO_LOG("Day1,Day2,Day3~p~n",[{Day1,Day2,Day3}]),
      NewShareLuckyWheelInfo = ShareLuckyWheelInfo#player_share_lucky_wheel_info{
        all_times_1 = Day1,
        all_times_3 = Day2,
        all_times_7 = Day3
      },
      NewShareLuckyWheelInfo;
    _->
%%      ?INFO_LOG("share_draw_times"),
      ShareLuckyWheelInfo
  end.


get_post_get_get_task_count(Account)->
  case http_static_util:post_get_get_task_count(Account) of
    false ->
      skip;
    Data ->
      try
        case para(Data) of
          [Day1,Day2,Day3] ->
            {Day1,Day2,Day3};
          _->
            skip
        end
      catch
        E:R  ->
          ?INFO_LOG("task_count_err~p~n",[{Data,E,R,erlang:get_stacktrace()}])
      end
  end.

para({obj, Val}) ->
  lists:map(fun(E) -> para(E) end, Val);

para({"list", Val}) ->
  lists:map(fun(E) -> para(E) end, Val);

para({"rand_id", Val}) ->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"share_count", Val}) when is_binary(Val) ->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"share_count", Val}) ->
  Val;

para({"user_id", Val}) ->
  binary_to_list(Val);

para({"totalpages", Val}) ->
  Val;

para({"rank", Val}) ->
  Val;

para({"day_1", Val}) when is_binary(Val)->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"day_3", Val}) when is_binary(Val)->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"day_7", Val}) when is_binary(Val)->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"day_1", Val}) ->
  Val;

para({"day_3", Val}) ->
  Val;

para({"day_7", Val}) ->
  Val;

para({"create_time", Val}) ->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({"is_red", Val}) ->
  Val2 = binary_to_list(Val),
  list_to_integer(Val2);

para({_, Val}) ->
  Val.

gm_test(Type) ->
  if
    Type == 1 ->
      http_static_util:post_get_share_rank_list(1, 10, "1", 1520179200, 1522857599);
    Type == 2 ->
      Data = http_static_util:post_get_self_share_list(1, 10, "10258180"),
      para(Data),
      ?INFO_LOG("Type 2 == > ~p~n",[para(Data)]);
    Type == 3 ->
      Data = http_static_util:post_self_share_query(1, 10, "10258180", "10241765"),
      [List,ShareCount,TotatPages] = para(Data),
      ?INFO_LOG("Type 3 == > ~p~n",[{List,ShareCount,TotatPages}]);
    Type == 4 ->
      ?INFO_LOG("my_share_info~p~n",[get_share_lucky_wheel_info()]);
    true ->
      skip
  end.

a()->
  {obj,
    [{"list",
      [{obj,
        [{"user_id",<<"733217">>},
          {"day_1",<<"0">>},
          {"day_3",<<"0">>},
          {"day_7",<<"0">>},
          {"is_red",<<"0">>},
          {"create_time",<<"1522386914">>}]},
        {obj,
          [{"user_id",<<"733124">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386268">>}]},
        {obj,
          [{"user_id",<<"733119">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386248">>}]},
        {obj,
          [{"user_id",<<"733103">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386184">>}]},
        {obj,
          [{"user_id",<<"733098">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386166">>}]},
        {obj,
          [{"user_id",<<"733069">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386077">>}]},
        {obj,
          [{"user_id",<<"733060">>},
            {"day_1",<<"0">>},
            {"day_3",<<"0">>},
            {"day_7",<<"0">>},
            {"is_red",<<"0">>},
            {"create_time",<<"1522386054">>}]}]},
      {"share_count",197},
      {"totalpages",29}]}.