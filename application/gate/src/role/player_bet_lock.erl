-module(player_bet_lock).

-include_lib("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include("log.hrl").
-include("laba.hrl").
-include("role_processor.hrl").

-export([
    init_ets/0,
    update/3,
    cs_bet_lock_config_req/2,
    send_current_info/4
]).

-define(PRIV_BET_LOCK_KEY_LABA, priv_bet_lock_key_laba).

-record(player_bet_lock_elem, {
	config_key,
	total_bet,
	bet_time
}).

init_ets() ->
    case player_bet_lock_config_db:get() of
		[] ->
            ?INFO_LOG("not found any player_bet_lock_config_db, use default..~n");
		List ->
			lists:foreach(fun(E) ->
				ets:insert(?ETS_BET_LOCK_CONFIG, E)
			end, List)
	end.

% 这里的 room-type 是粘性红包定义的 room-type
update(RoomType, TestType, BetNum) ->
    PlayerInfo = player_util:get_dic_player_info(),
    GatePid = player_util:get_dic_gate_pid(),
    private_update(PlayerInfo, GatePid, RoomType, TestType, BetNum).

send_current_info(PlayerInfo, GateId, RoomType, TestType) ->
    if
        undefined =:= GateId ->
            skip;
        true ->
            private_update(PlayerInfo, GateId, RoomType, TestType, 0)
    end.

cs_bet_lock_config_req(RoomType, TestTypeIn) ->
    PlayerInfo = player_util:get_dic_player_info(),
    GameTypeIn = priv_get_game_type_by_room_type(RoomType),
    {GameType, TestType, Level} = case player_bet_lock_db:get_base(PlayerInfo#player_info.id) of
        {ok, [Data]} ->
            DealData = case GameTypeIn of
                laba ->
                    priv_get_deal_by_testtype(Data#player_bet_lock.laba, TestTypeIn);
                super_laba ->
                    priv_get_deal_by_testtype(Data#player_bet_lock.super_laba, TestTypeIn);
                hundred_niu ->
                    priv_get_deal_by_testtype(Data#player_bet_lock.hundred_niu, TestTypeIn);
                car ->
                    priv_get_deal_by_testtype(Data#player_bet_lock.car, TestTypeIn);
                airlaba ->
                    priv_get_deal_by_testtype(Data#player_bet_lock.airlaba, TestTypeIn);
                _ ->
                    % 走到这里一定有人下毒
                    undefined
            end,
            DealData#player_bet_lock_elem.config_key;
        _ ->
            {GameTypeIn, TestTypeIn, 1}
    end,
    case ets:lookup(?ETS_BET_LOCK_CONFIG, {GameType, TestType, Level}) of
        [CurConfig] ->
            CurConfigElem = [#pb_bet_lock_config_list_elem{
                level = Level,
                bet_gold_limit = CurConfig#player_bet_lock_config.bet_limit,
                next_gen_gold = CurConfig#player_bet_lock_config.bet_num,
                next_gen_vip = CurConfig#player_bet_lock_config.vip_num
            }],
            NextLevel = Level + 1,
            AllConfigElem = case ets:lookup(?ETS_BET_LOCK_CONFIG, {GameType, TestType, NextLevel}) of
                [NextConfig] ->
                    CurConfigElem ++ [#pb_bet_lock_config_list_elem{
                        level = NextLevel,
                        bet_gold_limit = NextConfig#player_bet_lock_config.bet_limit,
                        next_gen_gold = NextConfig#player_bet_lock_config.bet_num,
                        next_gen_vip = NextConfig#player_bet_lock_config.vip_num
                    }];
                _ ->
                    CurConfigElem
            end,
            NotifyMsg = #sc_bet_lock_config_resp{
                room_type = RoomType,
                testtype = TestType,
                configs = AllConfigElem
            },
            %?INFO_LOG("*****************************~p~n", [NotifyMsg]),
            tcp_client:send_data(player_util:get_dic_gate_pid(), NotifyMsg);
        _ ->
            skip
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% private
priv_init_bet_lock_info_default(GameType, TestType, Level, BetNum, Vip, Time) ->
	DefaultLv = case ets:lookup(?ETS_BET_LOCK_CONFIG, {GameType, TestType, Level}) of
		[DefConfig] ->
			CurConfig = priv_get_match_bet_lock_config(DefConfig, BetNum, Vip),
			{_, _, Lv} = CurConfig#player_bet_lock_config.key,
			Lv;
		_ ->
			1
	end,
    if
        0 =:= BetNum ->
            RealTime = 0;
        true ->
            RealTime = Time
    end,
    if
        ?TEST_TYPE_TRY_PLAY =:= TestType ->
            {
                #player_bet_lock_elem {
                    config_key = {GameType, TestType, DefaultLv},
                    total_bet = BetNum,
                    bet_time = RealTime
                },
                #player_bet_lock_elem {
                    config_key = {GameType, ?TEST_TYPE_ENTERTAINMENT, DefaultLv},
                    total_bet = 0,
                    bet_time = 0
                }
            };
        true ->
            {
                #player_bet_lock_elem {
                    config_key = {GameType, ?TEST_TYPE_TRY_PLAY, DefaultLv},
                    total_bet = 0,
                    bet_time = 0
                },
                #player_bet_lock_elem {
                    config_key = {GameType, TestType, DefaultLv},
                    total_bet = BetNum,
                    bet_time = RealTime
                }
            }
    end.

priv_update_bet_lock_elem_(OldElem, BetNum, Vip) ->
    NewTotalBet = OldElem#player_bet_lock_elem.total_bet + BetNum,
    if
        0 =:= BetNum ->
            RealTime = 0;
        true ->
            RealTime = util:now_seconds()
    end,
    {NewInfo, IsNewLevel} = case ets:lookup(?ETS_BET_LOCK_CONFIG, OldElem#player_bet_lock_elem.config_key) of
        [OldConfig] ->
            if
                NewTotalBet > OldConfig#player_bet_lock_config.bet_num orelse Vip > OldConfig#player_bet_lock_config.vip_num ->
                    NewConfig = priv_get_match_bet_lock_config(OldConfig, NewTotalBet, Vip),
					{_, _, OldLevel} = OldConfig#player_bet_lock_config.key,
					{_, _, NewLevel} = NewConfig#player_bet_lock_config.key,
                    {OldElem#player_bet_lock_elem {
                        config_key = NewConfig#player_bet_lock_config.key,
                        total_bet = OldElem#player_bet_lock_elem.total_bet + BetNum,
                        bet_time = RealTime
                    }, OldLevel =/= NewLevel};
                true ->
                    {OldElem#player_bet_lock_elem{
                        total_bet = NewTotalBet
                    }, false}
            end;
        _ ->
            {OldElem#player_bet_lock_elem{
                total_bet = NewTotalBet
            }, false}
    end,
    {NewInfo, IsNewLevel}.

priv_update_bet_lock_elem(Elem, _GameType, TestType, BetNum, Vip) ->
    {TestType1Info, TestType2Info} = Elem,
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
            {Elem, false};
        _ ->
            {NewInfo, IsNewLevel} = priv_update_bet_lock_elem_(OldInfo, BetNum, Vip),
            if
                ?TEST_TYPE_TRY_PLAY =:= TestType ->
                    {{NewInfo, TestType2Info}, IsNewLevel};
                true ->
                    {{TestType1Info, NewInfo}, IsNewLevel}
            end
    end.

priv_get_match_bet_lock_config(OldConfig, TotalBet, Vip) ->
	NewConfig = priv_get_next_bet_lock_config(OldConfig),
	{_, _, OldLevel} = OldConfig#player_bet_lock_config.key,
	{_, _, NewLevel} = NewConfig#player_bet_lock_config.key,
	if
		OldLevel =:= NewLevel ->
			NewConfig;
		true ->
			if
				NewConfig#player_bet_lock_config.bet_num >= TotalBet andalso NewConfig#player_bet_lock_config.vip_num >= Vip ->
					NewConfig;
				true ->
					priv_get_match_bet_lock_config(NewConfig, TotalBet, Vip)
			end
	end.

priv_get_next_bet_lock_config(OldConfig) ->
    {GameType, TestType, Level} = OldConfig#player_bet_lock_config.key,
    case ets:lookup(?ETS_BET_LOCK_CONFIG, {GameType, TestType, Level + 1}) of
        [NewConfig] ->
            NewConfig;
        _ ->
            OldConfig
    end.

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
            ?INFO_LOG("bet lock priv_get_game_type_by_room_type ERROR ~p~n", [RoomType]),
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

private_update(PlayerInfo, GatePid, RoomType, TestType, BetNum) ->
    GameType = priv_get_game_type_by_room_type(RoomType),
    {NewData, IsNewLevel} = case player_bet_lock_db:get_base(PlayerInfo#player_info.id) of
        {ok, [Data]} ->
            case GameType of
                laba ->
					{NewLaba, IsNewLv} = priv_update_bet_lock_elem(
                            Data#player_bet_lock.laba,
                            GameType, TestType, BetNum,
							PlayerInfo#player_info.vip_level),
                    {Data#player_bet_lock{
                        laba = NewLaba
                    }, IsNewLv};
                super_laba ->
					{NewSuperLaba, IsNewLv} = priv_update_bet_lock_elem(
                            Data#player_bet_lock.super_laba,
                            GameType, TestType, BetNum,
							PlayerInfo#player_info.vip_level),
                    {Data#player_bet_lock{
                        super_laba = NewSuperLaba
                    }, IsNewLv};
                hundred_niu ->
					{NewHundredNiu, IsNewLv} = priv_update_bet_lock_elem(
                            Data#player_bet_lock.hundred_niu,
                            GameType, TestType, BetNum,
							PlayerInfo#player_info.vip_level),
                    {Data#player_bet_lock{
                        hundred_niu = NewHundredNiu
                    }, IsNewLv};
                car ->
					{NewCar, IsNewLv} = priv_update_bet_lock_elem(
                            Data#player_bet_lock.car,
                            GameType, TestType, BetNum,
							PlayerInfo#player_info.vip_level),
                    {Data#player_bet_lock{
                        car = NewCar
                    }, IsNewLv};
                airlaba ->
					{NewAirlaba, IsNewLv} = priv_update_bet_lock_elem(
                            Data#player_bet_lock.airlaba,
                            GameType, TestType, BetNum,
							PlayerInfo#player_info.vip_level),
                    {Data#player_bet_lock{
                        airlaba = NewAirlaba
                    }, IsNewLv};
                _ ->
                    {Data, false}
            end;
        _ ->
            case GameType of
                laba ->
                    {#player_bet_lock {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_bet_lock_info_default(GameType, TestType, 1, BetNum,
							PlayerInfo#player_info.vip_level, util:now_seconds()),
                        super_laba = priv_init_bet_lock_info_default(super_laba, TestType, 1, 0, 0, 0),
                        hundred_niu = priv_init_bet_lock_info_default(hundred_niu, TestType, 1, 0, 0, 0),
                        car = priv_init_bet_lock_info_default(car, TestType, 1, 0, 0, 0),
                        airlaba = priv_init_bet_lock_info_default(airlaba, TestType, 1, 0, 0, 0)
                    }, true};
                super_laba ->
                    {#player_bet_lock {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_bet_lock_info_default(laba, TestType, 1, 0, 0, 0),
                        super_laba = priv_init_bet_lock_info_default(GameType, TestType, 1, BetNum,
							PlayerInfo#player_info.vip_level, util:now_seconds()),
                        hundred_niu = priv_init_bet_lock_info_default(hundred_niu, TestType, 1, 0, 0, 0),
                        car = priv_init_bet_lock_info_default(car, TestType, 1, 0, 0, 0),
                        airlaba = priv_init_bet_lock_info_default(airlaba, TestType, 1, 0, 0, 0)
                    }, true};
                hundred_niu ->
                    {#player_bet_lock {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_bet_lock_info_default(laba, TestType, 1, 0, 0, 0),
                        super_laba = priv_init_bet_lock_info_default(super_laba, TestType, 1, 0, 0, 0),
                        hundred_niu = priv_init_bet_lock_info_default(GameType, TestType, 1, BetNum,
							PlayerInfo#player_info.vip_level, util:now_seconds()),
                        car = priv_init_bet_lock_info_default(car, TestType, 1, 0, 0, 0),
                        airlaba = priv_init_bet_lock_info_default(airlaba, TestType, 1, 0, 0, 0)
                    }, true};
                car ->
                    {#player_bet_lock {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_bet_lock_info_default(laba, TestType, 1, 0, 0, 0),
                        super_laba = priv_init_bet_lock_info_default(super_laba, TestType, 1, 0, 0, 0),
                        hundred_niu = priv_init_bet_lock_info_default(hundred_niu, TestType, 1, 0, 0, 0),
                        car = priv_init_bet_lock_info_default(GameType, TestType, 1, BetNum, 
							PlayerInfo#player_info.vip_level, util:now_seconds()),
                        airlaba = priv_init_bet_lock_info_default(airlaba, TestType, 1, 0, 0, 0)
                    }, true};
                airlaba ->
                    {#player_bet_lock {
                        player_id = PlayerInfo#player_info.id,
                        laba = priv_init_bet_lock_info_default(laba, TestType, 1, 0, 0, 0),
                        super_laba = priv_init_bet_lock_info_default(super_laba, TestType, 1, 0, 0, 0),
                        hundred_niu = priv_init_bet_lock_info_default(hundred_niu, TestType, 1, 0, 0, 0),
                        car = priv_init_bet_lock_info_default(car, TestType, 1, 0, 0, 0),
                        airlaba = priv_init_bet_lock_info_default(GameType, TestType, 1, BetNum, 
							PlayerInfo#player_info.vip_level, util:now_seconds())
                    }, true};
                _ ->
                    skip
            end
    end,
    %?INFO_LOG("---------~p~n", [NewData]),
    case NewData of
        skip ->
            DBFun = fun () -> skip end,
            DBSuccessFun = fun () -> skip end;
        _ ->
            DBFun = fun () ->
                player_bet_lock_db:t_write(NewData)
            end,
            DBSuccessFun = fun () ->
				if
					false andalso not IsNewLevel ->
						DealData = undefined;
					true ->
						DealData = case GameType of
							laba ->
								priv_get_deal_by_testtype(NewData#player_bet_lock.laba, TestType);
							super_laba ->
								priv_get_deal_by_testtype(NewData#player_bet_lock.super_laba, TestType);
							hundred_niu ->
								priv_get_deal_by_testtype(NewData#player_bet_lock.hundred_niu, TestType);
							car ->
								priv_get_deal_by_testtype(NewData#player_bet_lock.car, TestType);
                            airlaba ->
                                priv_get_deal_by_testtype(NewData#player_bet_lock.airlaba, TestType);
							_ ->
								% 走到这里一定有人下毒
								undefined
						end
				end,
                case DealData of
                    undefined ->
                        skip;
                    _ ->
                        {_, _, CurLevel} = DealData#player_bet_lock_elem.config_key,
						case ets:lookup(?ETS_BET_LOCK_CONFIG, DealData#player_bet_lock_elem.config_key) of
							[CurConfig] ->
								NotifyMsg = #sc_bet_lock_update_notify{
									room_type = RoomType,
									testtype = TestType,
									cur_level = #pb_bet_lock_config_list_elem{
										level = CurLevel,
										bet_gold_limit = CurConfig#player_bet_lock_config.bet_limit,
										next_gen_gold = CurConfig#player_bet_lock_config.bet_num,
										next_gen_vip = CurConfig#player_bet_lock_config.vip_num
									},
									total_amount = DealData#player_bet_lock_elem.total_bet
								},
								tcp_client:send_data(GatePid, NotifyMsg);
							_ ->
								skip
						end
                end
            end
    end,
    case dal:run_transaction_rpc(DBFun) of
		{atomic, _}	->
			DBSuccessFun();
		{aborted, Reason}	->
			?ERROR_LOG("player_bet_lock update FAIL!!! ~p~n", [{?MODULE, Reason, player_util:get_dic_player_info()}])
	end.