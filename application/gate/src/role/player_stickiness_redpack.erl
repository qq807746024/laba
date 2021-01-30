%%%-------------------------------------------------------------------
%%% @author wodong_lk
%% TODO 这里的代码要简单封装优化下，很多重复的。。。
%%%-------------------------------------------------------------------
-module(player_stickiness_redpack).

-include_lib("common.hrl").

-include_lib("db/include/mnesia_table_def.hrl").

-include_lib("network_proto/include/player_pb.hrl").

-include_lib("network_proto/include/mission_pb.hrl").

-export([update/3, cs_stickiness_redpack_draw_req/2, cs_player_stickiness_redpack_info_notify_req/2]).

update(RoomType, TestTypeIn, Count) ->
    {_, TestType} = priv_get_real_testtype(TestTypeIn),
    %?INFO_LOG("-------- ~p~n", [{RoomType, TestType, Count, TestTypeIn}]),
    PlayerInfo = player_util:get_dic_player_info(),
    case player_stickiness_redpack_level_info_db:get_base(PlayerInfo#player_info.id) of
        {ok, [Data]} ->
            case get_player_stickiness_redpack_info_by_room(Data, RoomType, TestType) of
                [PlayerLevelInfo] -> 
                    CurConfig = case stickiness_redpack_level_config_db:get(PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key) of 
                        {ok, [Config]} ->
                            NewPlayerLevelInfo = update_player_stickiness_redpack_with_conf(PlayerLevelInfo, Config, Count),
                            replace_player_stickiness_redpack_projlist(PlayerLevelInfo, Data, NewPlayerLevelInfo),
                            Config;
                        _ ->
                            NewPlayerLevelInfo = PlayerLevelInfo,
                            %?ERROR_LOG("stickiness_redpack_level_config_db:get not found :~p~n", [{?MODULE,?LINE,?STACK_TRACE}]),
                            not_found
                    end,
                    CurPlayerLevelInfo = NewPlayerLevelInfo;
                _ -> 
                    %% 没有玩家该房间数据
                    {CurPlayerLevelInfo, CurConfig} = create_player_stickiness_redpack_for_room(RoomType, TestType, Data, Count)
            end;
        _ -> 
            %% 没有整个玩家数据
            {CurPlayerLevelInfo, CurConfig} = create_player_stickiness_redpack(RoomType, TestType, Count, PlayerInfo)
    end,
    if
        CurPlayerLevelInfo =/= not_found andalso CurConfig =/= not_found ->
            {CurRoomType, CurTestType, CurLevel} = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
            CurRewardAmount = trunc(
                (CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold +
                    CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding) / CurConfig#stickiness_redpack_level_config.gold_cov_to_reward_item_rate),
            NotifyMsg = #sc_player_stickiness_redpack_info_notify {
                cur_info = #pb_cur_stickiness_redpack_info{
                    room_type = CurRoomType,
                    testtype = CurTestType,
                    level = CurLevel,
                    reward_type = CurConfig#stickiness_redpack_level_config.single_reward_item_type,
                    reward_amount = CurRewardAmount,
                    reward_min = CurConfig#stickiness_redpack_level_config.signle_reward_item_amount,
                    cur_total_amount = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_total_amount,
                    cur_trigger_next_amount = CurConfig#stickiness_redpack_level_config.next_level_trigger,
                    cur_earn_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold,
                    gold_cov_to_reward_item_rate = CurConfig#stickiness_redpack_level_config.gold_cov_to_reward_item_rate,
                    holding_earn_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding,
                    total_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.total_gold,
                    end_time = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.end_time
                }
            },    
            %io:format("fafafafafafafa~p~n", [{NotifyMsg}]),
            tcp_client:send_data(player_util:get_dic_gate_pid(), NotifyMsg);
        true ->
            skip
            %?ERROR_LOG("CurPlayerLevelInfo =/= not_found andalso CurConfig =/= not_found failed:~p~n", [{?MODULE,?LINE,CurPlayerLevelInfo, CurConfig, ?STACK_TRACE}])
    end.

cs_stickiness_redpack_draw_req(RoomType, TestTypeIn) ->
    {_, TestType} = priv_get_real_testtype(TestTypeIn),
    PlayerInfo = player_util:get_dic_player_info(),
    case player_stickiness_redpack_level_info_db:get_base(PlayerInfo#player_info.id) of
        {ok, [PlayerStickinessData]} ->
            case get_player_stickiness_redpack_info_by_room(PlayerStickinessData, RoomType, TestType) of
                [OldPlayerLevelInfo] ->
                    case stickiness_redpack_level_config_db:get(OldPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key) of 
                        {ok, [Config]} ->
                            PlayerLevelInfo = update_player_stickiness_redpack_with_conf(OldPlayerLevelInfo, Config, 0),
                            RedRewardAmount = trunc((PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold +
                                PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding)  / Config#stickiness_redpack_level_config.gold_cov_to_reward_item_rate),
                            if 
                                RedRewardAmount < Config#stickiness_redpack_level_config.signle_reward_item_amount ->
                                    skip;
                                true ->
                                    % 领取奖励
                                    RedRewardAmountLeft = RedRewardAmount rem Config#stickiness_redpack_level_config.signle_reward_item_amount,
                                    RedFinalRewardAmount = RedRewardAmount - RedRewardAmountLeft,
                                    GoldLeft = (PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold +
                                        PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding) - RedFinalRewardAmount * Config#stickiness_redpack_level_config.gold_cov_to_reward_item_rate,
                                    CurRedTotalAmount = PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_total_amount + RedFinalRewardAmount,
                                    OriKey = PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
                                    if 
                                        Config#stickiness_redpack_level_config.next_level_trigger > CurRedTotalAmount ->
                                            NewConfig = Config;
                                        true ->
                                            {_, _, OriLevel} = OriKey,
                                            case stickiness_redpack_level_config_db:get({RoomType, TestType, OriLevel + 1}) of
                                                {ok, [_NewConfig]} ->
                                                    % 升级
                                                    NewConfig = _NewConfig;
                                                _ ->
                                                    NewConfig = Config
                                            end
                                    end,
                                    {NewActivateTime, ValidTime} = get_task_endtime_by_conf(NewConfig),
                                    NewPlayerLevelInfo = PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem {
                                        key = NewConfig#stickiness_redpack_level_config.key,
                                        cur_total_amount = CurRedTotalAmount,
                                        cur_earn_gold  = 0,
                                        holding = GoldLeft,
                                        end_time = ValidTime,
                                        activate_time = NewActivateTime
                                        %single_reward_item_type = NewConfig#stickiness_redpack_level_config.single_reward_item_type,
                                        %signle_reward_item_amount = NewConfig#stickiness_redpack_level_config.signle_reward_item_amount
                                    },
                                    NewProjList = lists:keyreplace(
                                        PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
                                        2,
                                        PlayerStickinessData#player_stickiness_redpack_level_info.proj_list,
                                        NewPlayerLevelInfo
                                    ),
                                    NewData = PlayerStickinessData#player_stickiness_redpack_level_info {
                                        proj_list = NewProjList
                                    },
                                    if 
                                        1 =:= RoomType ->
                                            if
                                                ?TEST_TYPE_ENTERTAINMENT == TestType ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_LABA_TESTTYPE2;
                                                true ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_LABA_TESTTYPE1
                                            end;
                                        2 =:= RoomType ->
                                            if
                                                ?TEST_TYPE_ENTERTAINMENT == TestType ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE2;
                                                true ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE1
                                            end;
                                        3 =:= RoomType ->
                                            if
                                                ?TEST_TYPE_ENTERTAINMENT == TestType ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_HUNDRED_TESTTYPE2;
                                                true ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_HUNDRED_TESTTYPE1
                                            end;
                                        4 =:= RoomType ->
                                            if
                                                ?TEST_TYPE_ENTERTAINMENT == TestType ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_CAR_TESTTYPE2;
                                                true ->
                                                    RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_CAR_TESTTYPE1
                                            end;
                                        true ->
                                            RewardlogTypeOri = ?REWARD_TYPE_STICKINESS_REDPACK_CONFIGERR
                                    end,
                                    if
                                        TestTypeIn >= ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM andalso ?TEST_TYPE_TRY_PLAY_CHNL_MAX_NUM >= TestTypeIn ->
                                            RewardlogType = RewardlogTypeOri * ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM * 10 + TestTypeIn;
                                        true ->
                                            RewardlogType = RewardlogTypeOri
                                    end,
                                    {_, DBFun1, SuccessFun1, _} = item_use:transc_items_reward([{
                                        Config#stickiness_redpack_level_config.single_reward_item_type, RedFinalRewardAmount}], RewardlogType),
                                    DBFun = fun () ->
                                        DBFun1(),
                                        player_stickiness_redpack_level_info_db:t_write(NewData)
                                    end,
                                    case dal:run_transaction_rpc(DBFun) of
                                        {atomic, _} ->
                                            SuccessFun1(),
                                            {CurRoomType, CurTestType, CurLevel} = NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
                                            tcp_client:send_data(player_util:get_dic_gate_pid(), #sc_stickiness_redpack_draw_resp{
                                                cur_info = #pb_cur_stickiness_redpack_info {
                                                    room_type = CurRoomType,
                                                    testtype = CurTestType,
                                                    level = CurLevel,
                                                    reward_type = Config#stickiness_redpack_level_config.single_reward_item_type,
                                                    reward_amount = 0,
                                                    reward_min = Config#stickiness_redpack_level_config.signle_reward_item_amount,
                                                    cur_total_amount = NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_total_amount,
                                                    cur_trigger_next_amount = Config#stickiness_redpack_level_config.next_level_trigger,
                                                    cur_earn_gold= NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold,
                                                    gold_cov_to_reward_item_rate = Config#stickiness_redpack_level_config.gold_cov_to_reward_item_rate,
                                                    holding_earn_gold = NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding,
                                                    total_gold = NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.total_gold,
                                                    end_time = NewPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.end_time
                                                },
                                                reward_type = Config#stickiness_redpack_level_config.single_reward_item_type,
                                                reward_amount = RedFinalRewardAmount
                                            });
                                        {aborted, Reason} ->
                                            ?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
                                    end,
                                    skip
                            end;
                        _ ->
                            skip
                    end;
                _ ->
                    skip
                    %?ERROR_LOG("cs_stickiness_redpack_draw_req PlayerLevelInfo not found:~p~n", [{?MODULE,?LINE,PlayerStickinessData, ?STACK_TRACE}])
            end;
        _ ->
            skip
            %?ERROR_LOG("cs_stickiness_redpack_draw_req PlayerStickinessData not found:~p~n", [{?MODULE,?LINE, RoomType, TestType, ?STACK_TRACE}])
    end.

cs_player_stickiness_redpack_info_notify_req(RoomType, TestTypeIn) ->
    {_, TestType} = priv_get_real_testtype(TestTypeIn),
    PlayerInfo = player_util:get_dic_player_info(),
    case player_stickiness_redpack_level_info_db:get_base(PlayerInfo#player_info.id) of
        {ok, [PlayerStickinessData]} ->
            case get_player_stickiness_redpack_info_by_room(PlayerStickinessData, RoomType, TestType) of
                [_PlayerLevelInfo] ->
                    case stickiness_redpack_level_config_db:get(_PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key) of 
                        {ok, [_Config]} ->
                            Config = _Config,
                            PlayerLevelInfo = update_player_stickiness_redpack_with_conf(_PlayerLevelInfo, Config, 0),
                            replace_player_stickiness_redpack_projlist(_PlayerLevelInfo, PlayerStickinessData, PlayerLevelInfo);
                        _ ->
                            PlayerLevelInfo = _PlayerLevelInfo,
                            Config = not_found
                            %?ERROR_LOG("cs_player_stickiness_redpack_info_notify_req stickiness_redpack_level_config_db not found:~p~n", [{?MODULE,?LINE,PlayerStickinessData, ?STACK_TRACE}])
                    end;
                _ ->
                    %% 没有玩家该房间数据
                    {PlayerLevelInfo, Config} = create_player_stickiness_redpack_for_room(RoomType, TestType, PlayerStickinessData, 0)
            end,
            CurPlayerLevelInfo = PlayerLevelInfo, 
            CurConfig = Config;
        _ ->
            {CurPlayerLevelInfo, CurConfig} = create_player_stickiness_redpack(RoomType, TestType, 0, PlayerInfo)
    end,
    if
        CurPlayerLevelInfo =/= not_found andalso CurConfig =/= not_found ->
            RedRewardAmount = trunc((CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold +
                CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding) / CurConfig#stickiness_redpack_level_config.gold_cov_to_reward_item_rate),
            if 
                RedRewardAmount < CurConfig#stickiness_redpack_level_config.signle_reward_item_amount ->
                    RedFinalRewardAmount = 0;
                true ->
                    % 领取奖励
                    RedRewardAmountLeft = RedRewardAmount rem CurConfig#stickiness_redpack_level_config.signle_reward_item_amount,
                    RedFinalRewardAmount = RedRewardAmount - RedRewardAmountLeft
            end,
            {CurRoomType, CurTestType, CurLevel} = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
            tcp_client:send_data(player_util:get_dic_gate_pid(), #sc_player_stickiness_redpack_info_notify{
                cur_info = #pb_cur_stickiness_redpack_info {
                    room_type = CurRoomType,
                    testtype = CurTestType,
                    level = CurLevel,
                    reward_type = CurConfig#stickiness_redpack_level_config.single_reward_item_type,
                    reward_amount = RedFinalRewardAmount,
                    reward_min = CurConfig#stickiness_redpack_level_config.signle_reward_item_amount,
                    cur_total_amount = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_total_amount,
                    cur_trigger_next_amount = CurConfig#stickiness_redpack_level_config.next_level_trigger,
                    cur_earn_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.cur_earn_gold,
                    gold_cov_to_reward_item_rate = CurConfig#stickiness_redpack_level_config.gold_cov_to_reward_item_rate,
                    holding_earn_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.holding,
                    total_gold = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.total_gold,
                    end_time = CurPlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.end_time
                }
            });
        true ->
            skip
            %?ERROR_LOG("CurPlayerLevelInfo =/= not_found andalso CurConfig =/= not_found failed:~p~n", [{?MODULE,?LINE,CurPlayerLevelInfo, CurConfig, ?STACK_TRACE}])
    end.

% -- private
get_player_stickiness_redpack_info_by_room(PlayerStickinessData, RoomType, TestType) ->
    lists:filter(fun (Elem) ->
        {ThisRoomType, ThisTestType, _} = Elem#player_stickiness_redpack_level_info_proj_elem.key,
        if
            ThisRoomType =:= RoomType andalso ThisTestType =:= TestType ->
                true;
            true -> 
                false
        end
    end, PlayerStickinessData#player_stickiness_redpack_level_info.proj_list).

replace_player_stickiness_redpack_projlist(PlayerLevelInfo, Data, NewPlayerLevelInfo) ->
    NewProjList = lists:keyreplace(
        PlayerLevelInfo#player_stickiness_redpack_level_info_proj_elem.key,
        2,
        Data#player_stickiness_redpack_level_info.proj_list,
        NewPlayerLevelInfo
    ),
    NewData = Data#player_stickiness_redpack_level_info {
        proj_list = NewProjList
    },
    player_stickiness_redpack_level_info_db:write(NewData).

create_player_stickiness_redpack_for_room(RoomType, TestType, Data, Count) ->
    case stickiness_redpack_level_config_db:get({RoomType, TestType, 1}) of 
        {ok, [Config]} ->
            PlayerLevelInfo = create_default_player_stickiness_redpack_level_info_proj_elem(RoomType, TestType, Count, Config),
            NewProjList = Data#player_stickiness_redpack_level_info.proj_list ++ [PlayerLevelInfo],
            NewData = Data#player_stickiness_redpack_level_info {
                proj_list = NewProjList
            },
            player_stickiness_redpack_level_info_db:write(NewData);
        _ ->
            %?ERROR_LOG("stickiness_redpack_level_config_db:get not found :~p~n", [{?MODULE,?LINE,?STACK_TRACE}]),
            PlayerLevelInfo = not_found,
            Config = not_found
    end,
    {PlayerLevelInfo, Config}.

create_player_stickiness_redpack(RoomType, TestType, Count, PlayerInfo) ->
    case stickiness_redpack_level_config_db:get({RoomType, TestType, 1}) of 
        {ok, [Config]} ->
            PlayerLevelInfo = create_default_player_stickiness_redpack_level_info_proj_elem(RoomType, TestType, Count, Config),
            Data = #player_stickiness_redpack_level_info {
                key = PlayerInfo#player_info.id,
                proj_list = [PlayerLevelInfo]
            },
            player_stickiness_redpack_level_info_db:write(Data);
        _ ->
            %?ERROR_LOG("stickiness_redpack_level_config_db:get not found :~p~n", [{?MODULE,?LINE,?STACK_TRACE}]),
            PlayerLevelInfo = not_found,
            Config = not_found
    end,
    {PlayerLevelInfo, Config}.

update_player_stickiness_redpack_with_conf(PlayerStickinessElem, Conf, AddCount) ->
    #stickiness_redpack_level_config{
        signle_reward_item_amount = SignleRewardItemAmount,
        gold_cov_to_reward_item_rate = GoldCovToRewardItemRate,
        reset_mode = ResetMode
    } = Conf,
    #player_stickiness_redpack_level_info_proj_elem{
        cur_earn_gold = CurEarnGold,
        end_time = EndTime,
        activate_time = ActivateTime,
        holding = Holding,
        total_gold = TotalGold
    } = PlayerStickinessElem,
    case ResetMode of
        server_side_by_day ->
            {NewActivateTime, ValidTime} = get_task_endtime_by_conf(Conf),
            if
                ActivateTime > EndTime orelse ActivateTime =:= EndTime ->
                    ?INFO_LOG("ActivateTime > EndTime orelse ActivateTime =:= EndTime ~p~n", [{ActivateTime, EndTime}]),
                    NewPlayerStickinessElem = PlayerStickinessElem#player_stickiness_redpack_level_info_proj_elem{
                        end_time = ValidTime
                    };
                true ->
                    NowSeconds = util:now_seconds(),
                    if
                        NowSeconds > EndTime orelse NowSeconds =:= EndTime ->
                            % 任务过期
                            RewardRed = trunc((CurEarnGold + Holding + AddCount) / GoldCovToRewardItemRate),
                            LeftRewardRed = RewardRed rem SignleRewardItemAmount,
                            VaildRewardRed = RewardRed - LeftRewardRed,
                            NewPlayerStickinessElem = PlayerStickinessElem#player_stickiness_redpack_level_info_proj_elem {
                                cur_earn_gold = VaildRewardRed * GoldCovToRewardItemRate,
                                end_time = ValidTime,
                                activate_time = NewActivateTime,
                                holding = 0,
                                total_gold = TotalGold + Holding + AddCount
                            },
                            ?INFO_LOG("NowSeconds > EndTime orelse NowSeconds =:= EndTime -> ~p~n", [{NewPlayerStickinessElem}]);
                        true ->
                            NewPlayerStickinessElem = PlayerStickinessElem#player_stickiness_redpack_level_info_proj_elem{
                                holding = Holding + AddCount,
                                total_gold = TotalGold + AddCount
                            }
                    end
            end;
        none ->
            NewPlayerStickinessElem = PlayerStickinessElem#player_stickiness_redpack_level_info_proj_elem{
                cur_earn_gold = CurEarnGold + AddCount,
                total_gold = TotalGold + AddCount
            };
        _ ->
            ?ERROR_LOG("Not impl update_player_stickiness_redpack_with_conf mode!!!"),
            NewPlayerStickinessElem = PlayerStickinessElem,
            skip
    end,
    NewPlayerStickinessElem.

get_task_endtime_by_conf(Conf) ->
    #stickiness_redpack_level_config{
        reset_argv_array = ResetArray,
        reset_mode = ResetMode
    } = Conf,
    case ResetMode of
        server_side_by_day ->
            [AdjustTime | _] = ResetArray,
            {util:now_seconds(), util:get_today_start_second() + AdjustTime};
        none ->
            {util:now_seconds(), -1};
        _ ->
            ?ERROR_LOG("Not impl update_player_stickiness_redpack_with_conf mode!!!"),
            {util:now_seconds(), -1}
    end.

create_default_player_stickiness_redpack_level_info_proj_elem(RoomType, TestType, Count, Config) ->
    {ActTime, ValTime} = get_task_endtime_by_conf(Config),
    #player_stickiness_redpack_level_info_proj_elem{
        key = {RoomType, TestType, 1},
	    %single_reward_item_type = Config#stickiness_redpack_level_config.single_reward_item_type,
	    %signle_reward_item_amount = Config#stickiness_redpack_level_config.signle_reward_item_amount,
        cur_total_amount = 0,
	    cur_earn_gold = 0,
        holding = Count,
        total_gold = Count,
        end_time = ValTime,
        activate_time = ActTime
    }.

priv_get_real_testtype(TestType) ->
    if
        % 现在客户端会自己拿渠道 id 了，不用考虑上一期用户
        TestType >= ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM ->
            {TestType div ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM, TestType rem ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM * 10};
        true ->
            {0, TestType}
    end.
