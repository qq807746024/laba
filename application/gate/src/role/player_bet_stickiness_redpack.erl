-module(player_bet_stickiness_redpack).

-include_lib("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include("log.hrl").
-include("laba.hrl").
-include("role_processor.hrl").

-record(player_bet_stickiness_info, {
    stickiness_key, % 下注粘性红包配置id
	total_bet, % 总下注金额
    redpack_keys = [], % 可以领取的红包配置对应的 key
    % 下面预留
	bet_time % 最近一次下注时间
}).

-export([
    update/3,
    cs_player_bet_stickiness_redpack_draw_req/3,
    init_ets/0,
    send_current_info/4
]).

init_ets() ->
    case bet_stickiness_redpack_config_db:get() of
		[] ->
            ?INFO_LOG("not found any bet_stickiness_redpack_config_db, use default..~n");
		List ->
			lists:foreach(fun(E) ->
				ets:insert(?ETS_BET_STICKINESS_REDPACK_CONFIG, E)
			end, List)
	end.

% 这里的 room-type 是粘性红包定义的 room-type
update(RoomType, TestType, BetNum) ->
    PlayerInfo = player_util:get_dic_player_info(),
    GateId = player_util:get_dic_gate_pid(),
    %?INFO_LOG("bet stickiness update ~p~n", [{RoomType, TestType, BetNum}]),
    priv_update(PlayerInfo, GateId, RoomType, TestType, BetNum).

cs_player_bet_stickiness_redpack_draw_req(RoomType, TestType, Level) ->
    %?INFO_LOG("bet stickiness draw ~p~n", [{RoomType, TestType, Level}]),
    PlayerInfo = player_util:get_dic_player_info(),
    GameType = priv_get_game_type_by_room_type(RoomType),
    {RespMsg, NeedNotify} = case player_bet_stickiness_redpack_db:get_base(PlayerInfo#player_info.id) of
        {ok, [Data]} ->
            BetInfo = case GameType of
                laba ->
                    priv_get_deal_by_testtype(Data#player_bet_stickiness_redpack.laba, TestType);
                super_laba ->
                    priv_get_deal_by_testtype(Data#player_bet_stickiness_redpack.super_laba, TestType);
                hundred_niu ->
                    priv_get_deal_by_testtype(Data#player_bet_stickiness_redpack.hundred_niu, TestType);
                car ->
                    priv_get_deal_by_testtype(Data#player_bet_stickiness_redpack.car, TestType);
                airlaba ->
                    priv_get_deal_by_testtype(Data#player_bet_stickiness_redpack.airlaba, TestType);
                _ ->
                    undefined
            end,
            case BetInfo of
                undefined ->
                    {#sc_player_bet_stickiness_redpack_draw_resp {
                        room_type = RoomType,
                        testtype = TestType,
                        level = Level,
                        reward_amount = 0,
                        desc = "0005-错误的参数"
                    }, false};
                _ ->
                    HaveThisReward = lists:any(fun ({EGameType, ETestType, ELevel}) ->
                        EGameType =:= GameType andalso ETestType =:= TestType andalso ELevel =:= Level
                    end, BetInfo#player_bet_stickiness_info.redpack_keys),
                    case HaveThisReward of
                        true ->
                            DrawKey = {GameType, TestType, Level},
                            case ets:lookup(?ETS_BET_STICKINESS_REDPACK_CONFIG, DrawKey) of
                                [Config] ->
                                    {[{_, RewardAmount}], DBFunReward, SuccessFun} = priv_process_player_draw_reward(Config, priv_get_log_type(GameType, TestType)),
                                    if
                                        false =:= dead_code ->
                                            DBFun = fun() ->
                                                NewRedPackLeys = lists:filter(fun({EGameType, ETestType, ELevel}) ->
                                                    EGameType =/= GameType orelse ETestType =/= TestType orelse ELevel =/= Level
                                                end, BetInfo#player_bet_stickiness_info.redpack_keys),
                                                NewBetInfo = BetInfo#player_bet_stickiness_info{
                                                    redpack_keys = NewRedPackLeys
                                                },
                                                NewData = case GameType of
                                                    laba ->
                                                        Data#player_bet_stickiness_redpack{
                                                            laba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.laba, NewBetInfo, TestType)
                                                        };
                                                    super_laba ->
                                                        Data#player_bet_stickiness_redpack{
                                                            super_laba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.super_laba, NewBetInfo, TestType)
                                                        };
                                                    hundred_niu ->
                                                        Data#player_bet_stickiness_redpack{
                                                            hundred_niu = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.hundred_niu, NewBetInfo, TestType)
                                                        };
                                                    car ->
                                                        Data#player_bet_stickiness_redpack{
                                                            car = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.car, NewBetInfo, TestType)
                                                        };
                                                    airlaba ->
                                                        Data#player_bet_stickiness_redpack{
                                                            airlaba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.airlaba, NewBetInfo, TestType)
                                                        };
                                                    _ ->
                                                        Data
                                                end,
                                                player_bet_stickiness_redpack_db:t_write(NewData),
                                                DBFunReward()
                                            end;
                                    true ->
                                        DBFun = fun () ->
                                            NewBetInfo = #player_bet_stickiness_info{
                                                stickiness_key = {GameType, TestType, 1},
                                                total_bet = 0,
                                                redpack_keys = [],
                                                bet_time = util:now_seconds()
                                            },
                                            NewData = case GameType of
                                                laba ->
                                                    Data#player_bet_stickiness_redpack{
                                                        laba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.laba, NewBetInfo, TestType)
                                                    };
                                                super_laba ->
                                                    Data#player_bet_stickiness_redpack{
                                                        super_laba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.super_laba, NewBetInfo, TestType)
                                                    };
                                                hundred_niu ->
                                                    Data#player_bet_stickiness_redpack{
                                                        hundred_niu = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.hundred_niu, NewBetInfo, TestType)
                                                    };
                                                car ->
                                                    Data#player_bet_stickiness_redpack{
                                                        car = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.car, NewBetInfo, TestType)
                                                    };
                                                airlaba ->
                                                    Data#player_bet_stickiness_redpack{
                                                        airlaba = priv_set_deal_by_testtype(Data#player_bet_stickiness_redpack.airlaba, NewBetInfo, TestType)
                                                    };
                                                _ ->
                                                    Data
                                            end,
                                            player_bet_stickiness_redpack_db:t_write(NewData),
                                            DBFunReward()
                                        end
                                    end,
                                    case dal:run_transaction_rpc(DBFun) of
                                        {atomic, _} ->
                                            SuccessFun(),
                                            {#sc_player_bet_stickiness_redpack_draw_resp {
                                                room_type = RoomType,
                                                testtype = TestType,
                                                level = Level,
                                                reward_amount = RewardAmount,
                                                desc = ""
                                            }, true};
                                        _ ->
                                            {#sc_player_bet_stickiness_redpack_draw_resp {
                                                room_type = RoomType,
                                                testtype = TestType,
                                                level = Level,
                                                reward_amount = 0,
                                                desc = "0004-更新红包数据失败"
                                            }, false}
                                    end;
                                _ ->
                                    {#sc_player_bet_stickiness_redpack_draw_resp {
                                        room_type = RoomType,
                                        testtype = TestType,
                                        level = Level,
                                        reward_amount = 0,
                                        desc = "0003-未找到该对应红包配置，活动已经结束"
                                    }, false}
                            end;
                        _ ->
                            {#sc_player_bet_stickiness_redpack_draw_resp {
                                room_type = RoomType,
                                testtype = TestType,
                                level = Level,
                                reward_amount = 0,
                                desc = "0002-未找到该玩家对应红包记录"
                            }, false}
                    end
            end;
        _ ->
            {#sc_player_bet_stickiness_redpack_draw_resp {
                room_type = RoomType,
                testtype = TestType,
                level = Level,
                reward_amount = 0,
                desc = "0001-未找到该玩家下注记录"
            }, false}
    end,
    %?INFO_LOG("YYYYYYY----~p~n", [RespMsg]),
    GateId = player_util:get_dic_gate_pid(),
    tcp_client:send_data(GateId, RespMsg),
    if
        NeedNotify ->
            priv_update(PlayerInfo, GateId, RoomType, TestType, 0);
        true ->
            skip
    end.

send_current_info(PlayerInfo, GateId, RoomType, TestType) ->
    %?INFO_LOG("bet stickiness send current info ~p~n", [{RoomType, TestType, PlayerInfo, ?STACK_TRACE}]),
    if
        undefined =:= GateId ->
            skip;
        true ->
            priv_update(PlayerInfo, GateId, RoomType, TestType, 0)
    end.

%%======================================================================================================
priv_get_game_type_by_room_type(RoomType) ->
    case RoomType of
        ?STICKINESS_REDPACK_EARN_LABA ->
            laba;
        ?STICKINESS_REDPACK_EARN_SUPER_LABA ->
            super_laba;
        ?STICKINESS_REDPACK_EARN_HUNDRED_NIU ->
            hundred_niu;
        ?STICKINESS_REDPACK_EARN_CAR ->
            car;
        ?STICKINESS_REDPACK_EARN_AIRLABA ->
            airlaba;
        _ ->
            ?INFO_LOG("bet_stickiness room type error ~p~n", [RoomType]),
            ni_you_du
    end.

priv_get_deal_by_testtype(DealTuple, TestType) ->
    if
        ?TEST_TYPE_TRY_PLAY =:= TestType ->
            {DealData, _} = DealTuple;
        true ->
            {_, DealData} = DealTuple
    end,
    DealData.

priv_set_deal_by_testtype({OriData1, OriData2}, SetTuple, TestType) ->
    if
        ?TEST_TYPE_TRY_PLAY =:= TestType ->
            {SetTuple, OriData2};
        true ->
            {OriData1, SetTuple}
    end.

priv_init_stickiness_info_default(GameType, TestType, Level, BetNum, Time) ->
    %?INFO_LOG("--- priv_init_stickiness_info_default --- ~p~n", [{GameType, TestType, Level, BetNum, Time}]),
    if
        0 =:= BetNum ->
            BetTime = 0;
        true ->
            BetTime = Time
    end,
    if
        ?TEST_TYPE_TRY_PLAY =:= TestType ->
            {
                #player_bet_stickiness_info {
                    stickiness_key = {GameType, TestType, Level},
                    total_bet = BetNum,
                    redpack_keys = [],
                    bet_time = BetTime
                },
                #player_bet_stickiness_info {
                    stickiness_key = {GameType, ?TEST_TYPE_ENTERTAINMENT, Level},
                    total_bet = 0,
                    redpack_keys = [],
                    bet_time = 0
                }
            };
        true ->
            {
                #player_bet_stickiness_info {
                    stickiness_key = {GameType, ?TEST_TYPE_TRY_PLAY, Level},
                    total_bet = 0,
                    redpack_keys = [],
                    bet_time = 0
                },
                #player_bet_stickiness_info {
                    stickiness_key = {GameType, TestType, Level},
                    total_bet = BetNum,
                    redpack_keys = [],
                    bet_time = BetTime
                }
            }
    end.

priv_update_stickiness_info(Elem, _GameType, TestType, BetNum, IsForce) ->
    if
        undefined =:= Elem ->
            {TestType1Info, TestType2Info} = {0, 0};
        true ->
            {TestType1Info, TestType2Info} = Elem
    end,
    case TestType of
        ?TEST_TYPE_TRY_PLAY ->
            OldInfo = TestType1Info;
        ?TEST_TYPE_ENTERTAINMENT ->
            OldInfo = TestType2Info;
        _ ->
            OldInfo = undefined
    end,
    case OldInfo of
        undefined ->
            Elem;
        _ ->
            NewInfo = priv_update_stickiness_info_(OldInfo, BetNum, IsForce),
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    {NewInfo, TestType2Info};
                true ->
                    {TestType1Info, NewInfo}
            end
    end.

priv_update_stickiness_info_(OldInfo, BetNum, IsForce) ->
    if
        0 =:= BetNum andalso not IsForce ->
            OldInfo;
        true ->
            NewTotalBet = OldInfo#player_bet_stickiness_info.total_bet + BetNum,
            NewInfo = case ets:lookup(?ETS_BET_STICKINESS_REDPACK_CONFIG, OldInfo#player_bet_stickiness_info.stickiness_key) of
                [OldConfig] ->
                    if
                        NewTotalBet >= OldConfig#bet_stickiness_redpack_config.bet_num ->
                            NewConfig = get_next_stickiness_config(OldConfig, NewTotalBet),
                            if
                                NewConfig#bet_stickiness_redpack_config.key =:= OldConfig#bet_stickiness_redpack_config.key ->
                                    OldInfo#player_bet_stickiness_info {
                                        total_bet = NewConfig#bet_stickiness_redpack_config.bet_num,
                                        bet_time = util:now_seconds()
                                    };
                                true ->
                                    OldInfo#player_bet_stickiness_info {
                                        stickiness_key = NewConfig#bet_stickiness_redpack_config.key,
                                        total_bet = OldInfo#player_bet_stickiness_info.total_bet + BetNum,
                                        %redpack_keys = OldInfo#player_bet_stickiness_info.redpack_keys ++ [OldConfig#bet_stickiness_redpack_config.key],
                                        redpack_keys = [OldConfig#bet_stickiness_redpack_config.key],
                                        bet_time = util:now_seconds()
                                    }
                            end;
                        true ->
                            OldInfo#player_bet_stickiness_info{
                                total_bet = NewTotalBet,
                                bet_time = util:now_seconds()
                            }
                    end;
                _ ->
                    OldInfo#player_bet_stickiness_info{
                        total_bet = NewTotalBet
                    }
            end,
            NewInfo
    end.

get_next_stickiness_config(OldConfig, NewTotalBet) ->
    {GameType, TestType, Level} = OldConfig#bet_stickiness_redpack_config.key,
    case ets:lookup(?ETS_BET_STICKINESS_REDPACK_CONFIG, {GameType, TestType, Level + 1}) of
        [NewConfig] ->
            if
                0 =:= NewConfig#bet_stickiness_redpack_config.bet_num ->
                    OldConfig;
                NewConfig#bet_stickiness_redpack_config.bet_num < NewTotalBet ->
                    get_next_stickiness_config(NewConfig, NewTotalBet);
                true ->
                    NewConfig
            end;
        _ ->
            OldConfig
    end.

priv_get_log_type(GameType, TestType) ->
    case GameType of
        laba ->
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_LABA_TESTTYPE1;
                true ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_LABA_TESTTYPE2
            end;
        super_laba ->
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE1;
                true ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE2
            end;
        hundred_niu ->
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_HUNDRED_TESTTYPE1;
                true ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_HUNDRED_TESTTYPE2
            end;
        car ->
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_CAR_TESTTYPE1;
                true ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_CAR_TESTTYPE2
            end;
        airlaba ->
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_AIRLABA_TESTTYPE1;
                true ->
                    ?REWARD_TYPE_BET_STICKINESS_REDPACK_AIRLABA_TESTTYPE2
            end;
        _ ->
            ?REWARD_TYPE_BET_STICKINESS_REDPACK_UNKNOWN
    end.

priv_process_player_draw_reward(Config, LogType) ->
    RewardItem = util_random:get_random_rewards(Config#bet_stickiness_redpack_config.redpack_weight),
    {_, DBFun, SuccessFun, _} = item_use:transc_items_reward(RewardItem, LogType),
    {RewardItem, DBFun, SuccessFun}.

priv_update(PlayerInfo, GateId, RoomType, TestType, BetNum) ->
    GameType = priv_get_game_type_by_room_type(RoomType),
    NewData = case player_bet_stickiness_redpack_db:get_base(PlayerInfo#player_info.id) of
        {ok, [Data]} ->
            case GameType of
                laba ->
                    Data#player_bet_stickiness_redpack{
                        laba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.laba,
                            GameType, TestType, BetNum, false)
                    };
                super_laba ->
                    Data#player_bet_stickiness_redpack{
                        super_laba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.super_laba,
                            GameType, TestType, BetNum, false)
                    };
                hundred_niu ->
                    Data#player_bet_stickiness_redpack{
                        hundred_niu = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.hundred_niu,
                            GameType, TestType, BetNum, false)
                    };
                car ->
                    Data#player_bet_stickiness_redpack{
                        car = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.car,
                            GameType, TestType, BetNum, false)
                    };
                airlaba ->
                    Data#player_bet_stickiness_redpack{
                        airlaba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.airlaba,
                            GameType, TestType, BetNum, false)
                    };
                _ ->
                    Data
            end;
        _ ->
            case GameType of
                laba ->
                    Data = #player_bet_stickiness_redpack {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_stickiness_info_default(GameType, TestType, 1, 
                            BetNum + player_util:get_server_const(?CONST_CONFIG_LABA_FIRST_ROLL_BETSTICKINESS_OFFSET), util:now_seconds()),
                        super_laba = priv_init_stickiness_info_default(super_laba, TestType, 1, 0, 0),
                        hundred_niu = priv_init_stickiness_info_default(hundred_niu, TestType, 1, 0, 0),
                        car = priv_init_stickiness_info_default(car, TestType, 1, 0, 0),
                        airlaba = priv_init_stickiness_info_default(airlaba, TestType, 1, 0, 0)
                    },
                    Data#player_bet_stickiness_redpack{
                        laba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.laba,
                            GameType, TestType, 0, true)
                    };
                super_laba ->
                    Data = #player_bet_stickiness_redpack {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_stickiness_info_default(laba, TestType, 1, 0, 0),
                        super_laba = priv_init_stickiness_info_default(GameType, TestType, 1, BetNum, util:now_seconds()),
                        hundred_niu = priv_init_stickiness_info_default(hundred_niu, TestType, 1, 0, 0),
                        car = priv_init_stickiness_info_default(car, TestType, 1, 0, 0),
                        airlaba = priv_init_stickiness_info_default(airlaba, TestType, 1, 0, 0)
                    },
                    Data#player_bet_stickiness_redpack{
                        super_laba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.super_laba,
                            GameType, TestType, 0, true)
                    };
                hundred_niu ->
                    Data = #player_bet_stickiness_redpack {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_stickiness_info_default(laba, TestType, 1, 0, 0),
                        super_laba = priv_init_stickiness_info_default(super_laba, TestType, 1, 0, 0),
                        hundred_niu = priv_init_stickiness_info_default(GameType, TestType, 1, BetNum, util:now_seconds()),
                        car = priv_init_stickiness_info_default(car, TestType, 1, 0, 0),
                        airlaba = priv_init_stickiness_info_default(airlaba, TestType, 1, 0, 0)
                    },
                    Data#player_bet_stickiness_redpack{
                        hundred_niu = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.hundred_niu,
                            GameType, TestType, 0, true)
                    };
                car ->
                    Data = #player_bet_stickiness_redpack {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_stickiness_info_default(laba, TestType, 1, 0, 0),
                        super_laba = priv_init_stickiness_info_default(super_laba, TestType, 1, 0, 0),
                        hundred_niu = priv_init_stickiness_info_default(hundred_niu, TestType, 1, 0, 0),
                        car = priv_init_stickiness_info_default(GameType, TestType, 1, BetNum, util:now_seconds()),
                        airlaba = priv_init_stickiness_info_default(airlaba, TestType, 1, 0, 0)
                    },
                    Data#player_bet_stickiness_redpack{
                        car = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.car,
                            GameType, TestType, 0, true)
                    };
                airlaba ->
                    Data = #player_bet_stickiness_redpack {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_stickiness_info_default(laba, TestType, 1, 0, 0),
                        super_laba = priv_init_stickiness_info_default(super_laba, TestType, 1, 0, 0),
                        hundred_niu = priv_init_stickiness_info_default(hundred_niu, TestType, 1, 0, 0),
                        car = priv_init_stickiness_info_default(car, TestType, 1, 0, 0),
                        airlaba = priv_init_stickiness_info_default(GameType, TestType, 1, BetNum, util:now_seconds())
                    },
                    Data#player_bet_stickiness_redpack{
                        airlaba = priv_update_stickiness_info(
                            Data#player_bet_stickiness_redpack.airlaba,
                            GameType, TestType, 0, true)
                    };
                _ ->
                    skip
            end
    end,
    case NewData of
        skip ->
            DBFun = fun () -> skip end,
            DBSuccessFun = fun () -> skip end;
        _ ->
            DBFun = fun () ->
                player_bet_stickiness_redpack_db:t_write(NewData)
            end,
            DBSuccessFun = fun () ->
                DealData = case GameType of
                    laba ->
                        priv_get_deal_by_testtype(NewData#player_bet_stickiness_redpack.laba, TestType);
                    super_laba ->
                        priv_get_deal_by_testtype(NewData#player_bet_stickiness_redpack.super_laba, TestType);
                    hundred_niu ->
                        priv_get_deal_by_testtype(NewData#player_bet_stickiness_redpack.hundred_niu, TestType);
                    car ->
                        priv_get_deal_by_testtype(NewData#player_bet_stickiness_redpack.car, TestType);
                    airlaba ->
                        priv_get_deal_by_testtype(NewData#player_bet_stickiness_redpack.airlaba, TestType);
                    _ ->
                        % 走到这里一定有人下毒
                        undefined
                end,
                case DealData of
                    undefined ->
                        skip;
                    _ ->
                        RedpackLvArr = lists:foldl(fun (Key, RPArr) ->
                            {_, _, LevelE} = Key,
                            %?INFO_LOG("ohMZSH-----------> ~p~n", [Key]),
                            % TODO 拼装红包这里要处理下（比如配置不见了，该怎么办）
                            % 应该每个玩家不会留很多的红包，所以 for 循环不会很长
                            case ets:lookup(?ETS_BET_STICKINESS_REDPACK_CONFIG, Key) of
                                [Config] ->
                                    {random_weight, [{_, Reward1}, {_, Reward2}, {_, Reward3}], _ } = Config#bet_stickiness_redpack_config.redpack_weight,
                                    Elem = #pb_player_bet_stickiness_redpack_list_elem{
                                        level = LevelE,
                                        redpack_1 = Reward1,
                                        redpack_2 = Reward2,
                                        redpack_3 = Reward3
                                    },
                                    RPArr ++ [Elem];
                                _ ->
                                    RPArr
                            end
                        end, [], DealData#player_bet_stickiness_info.redpack_keys),
                        NowLevelBet = case ets:lookup(?ETS_BET_STICKINESS_REDPACK_CONFIG, DealData#player_bet_stickiness_info.stickiness_key) of
                            [Config] ->
                                Config#bet_stickiness_redpack_config.bet_num;
                            _ ->
                                0
                        end,
                        {_, _, CurLevel} = DealData#player_bet_stickiness_info.stickiness_key,
                        NotifyMsg = #sc_player_bet_stickiness_notify{
                            room_type = RoomType,
                            testtype = TestType,
                            cur_bet = DealData#player_bet_stickiness_info.total_bet,
                            total_bet = NowLevelBet,
                            cur_level = CurLevel,
                            redpack_list = RedpackLvArr
                        },
                        tcp_client:send_data(GateId, NotifyMsg)
                end
            end
    end,
    case dal:run_transaction_rpc(DBFun) of
		{atomic, _}	->
			DBSuccessFun();
		{aborted, Reason}	->
			?ERROR_LOG("player_bet_stickiness_redpack update FAIL!!! ~p~n", [{?MODULE, Reason, player_util:get_dic_player_info()}])
	end.