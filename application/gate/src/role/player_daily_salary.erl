
% 玩家每日工资
-module(player_daily_salary).

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-export([
    handle_time/3,
    update_last_bet/2,
    update_last_earn/2,
    cs_player_salary_query_req/0,
    can_draw/0,
    draw/0
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%以下为角色进程调用
cs_player_salary_query_req() ->
    {YesterdayEarn, TodayEarn, YesterdaySalary, CanDraw} = priv_chk_draw(),
    Msg = #sc_player_salary_query_resp {
        yesterday_earn = YesterdayEarn,
        today_earn = TodayEarn,
        yesterday_salary = YesterdaySalary,
        is_draw = not CanDraw
    },
    tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

can_draw() ->
    {_, _, _, CanDraw} = priv_chk_draw(),
    CanDraw.

draw() ->
    {_, _, YesterdaySalary, CanDraw} = priv_chk_draw(),
    case CanDraw of
        false ->
            {[], fun() -> skip end, fun() -> skip end};
        true ->
            {Today, _} = calendar:local_time(),
            OldStatistics = player_statistics_util:get_dict_statistics(),
            Reward = [{?ITEM_ID_GOLD, YesterdaySalary}],
            NewStatistics = OldStatistics#player_statistics {
                daily_earn_draw_time = Today
            },
            DBFun = fun() ->
                skip
            end,
            DBSuccessFun = fun () ->
                player_statistics_util:full_update(NewStatistics),
                http_send_mod:do_cast_http_post_fun(post_daily_salary_log,[
                    NewStatistics#player_statistics.player_id, YesterdaySalary, util:now_seconds()])
            end,
            {Reward, DBFun, DBSuccessFun}
    end.

% 登入时候调用，定时任务调用
handle_time(IsInit, OldSec, NowSec) ->
    if
        IsInit ->
            priv_calc_yesterday_and_today_bet(),
            priv_calc_yesterday_and_today_earn();
        true ->
            case util:is_same_date(OldSec, NowSec) of
                true ->
                    skip;
                _ ->
                    priv_calc_yesterday_and_today_bet(),
                    priv_calc_yesterday_and_today_earn()
            end
    end.

update_last_bet(laba, BetNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_bet_info(),
    priv_update_last_bet_info({OL + BetNum, OSL, OH, OC, OAL}, Today, OldRecord);
update_last_bet(super_laba, BetNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_bet_info(),
    priv_update_last_bet_info({OL, OSL + BetNum, OH, OC, OAL}, Today, OldRecord);
update_last_bet(hundred_niu, BetNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_bet_info(),
    priv_update_last_bet_info({OL, OSL, OH + BetNum, OC, OAL}, Today, OldRecord);
update_last_bet(car, BetNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_bet_info(),
    priv_update_last_bet_info({OL, OSL, OH, OC + BetNum, OAL}, Today, OldRecord);
update_last_bet(airlaba, BetNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_bet_info(),
    priv_update_last_bet_info({OL, OSL, OH, OC, OAL + BetNum}, Today, OldRecord).

update_last_earn(laba, EarnNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_earn_info(),
    priv_update_last_earn_info({OL + EarnNum, OSL, OH, OC, OAL}, Today, OldRecord);
update_last_earn(super_laba, EarnNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_earn_info(),
    priv_update_last_earn_info({OL, OSL + EarnNum, OH, OC, OAL}, Today, OldRecord);
update_last_earn(hundred_niu, EarnNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_earn_info(),
    priv_update_last_earn_info({OL, OSL, OH + EarnNum, OC, OAL}, Today, OldRecord);
update_last_earn(car, EarnNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_earn_info(),
    priv_update_last_earn_info({OL, OSL, OH, OC + EarnNum, OAL}, Today, OldRecord);
update_last_earn(airlaba, EarnNum) ->
    {Today, {OL, OSL, OH, OC, OAL}, OldRecord, _} = priv_get_last_earn_info(),
    priv_update_last_earn_info({OL, OSL, OH, OC, OAL + EarnNum}, Today, OldRecord).

priv_calc_yesterday_and_today_bet() ->
    PlayerStatisticsOri = player_statistics_util:get_dict_statistics(),
    {PrevBetInfo, LastBetInfo} = case PlayerStatisticsOri of
        undefined ->
            {{0,0,0,0,0}, {0,0,0,0,0}};
        _ ->
            {Today, _} = calendar:local_time(),
            CalcedPrevStatistics = case priv_get_diffdays(PlayerStatisticsOri#player_statistics.et_prev_daily_bet_update_date, Today) of
                0 ->
                    PlayerStatisticsOri;
                1 ->
                    PlayerStatisticsOri;
                _ ->
                    PlayerStatisticsOri#player_statistics {
                        et_prev_daily_bet = {0,0,0,0,0},
                        et_prev_daily_bet_update_date = Today
                    }
            end,
            CalcedStatistics = case priv_get_diffdays(CalcedPrevStatistics#player_statistics.et_last_daily_bet_update_date, Today) of
                0 ->
                    CalcedPrevStatistics;
                1 ->
                    {PrevLaba, PrevSuperLaba, PrevHundredNiu, PrevCar, PrevAirLaba} = CalcedPrevStatistics#player_statistics.et_prev_daily_bet,
                    {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba} = CalcedPrevStatistics#player_statistics.et_last_daily_bet,
                    CalcedPrevStatistics#player_statistics {
                        et_prev_daily_bet = {PrevLaba + LastLaba, PrevSuperLaba + LastSuperLaba, PrevHundredNiu + LastHundredNiu, PrevCar + LastCar, PrevAirLaba + LastAirLaba},
                        et_prev_daily_bet_update_date = Today,
                        et_last_daily_bet = {0,0,0,0,0},
                        et_last_daily_bet_update_date = Today
                    };
                _ ->
                    CalcedPrevStatistics#player_statistics {
                        et_last_daily_bet = {0,0,0,0,0},
                        et_last_daily_bet_update_date = Today
                    }
            end,
            player_statistics_util:full_update(CalcedStatistics),
            {CalcedStatistics#player_statistics.et_prev_daily_bet, CalcedStatistics#player_statistics.et_last_daily_bet}
    end,
    {PrevBetInfo, LastBetInfo}.

priv_calc_yesterday_and_today_earn() ->
    PlayerStatisticsOri = player_statistics_util:get_dict_statistics(),
    {PrevEarnInfo, LastEarnInfo} = case PlayerStatisticsOri of
        undefined ->
            {{0,0,0,0,0}, {0,0,0,0,0}};
        _ ->
            {Today, _} = calendar:local_time(),
            %Today = {2020,4,23},
            DiffDay = priv_get_diffdays(PlayerStatisticsOri#player_statistics.et_last_daily_earn_update_date, Today),
            %?INFO_LOG("----> ~p~n", [DiffDay]),
            CalcedStatistics = case DiffDay of
                0 ->
                    PlayerStatisticsOri;
                1 ->
                    {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba} = PlayerStatisticsOri#player_statistics.et_last_daily_earn,
                    PlayerStatisticsOri#player_statistics {
                        et_prev_daily_earn = {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba},
                        et_prev_daily_earn_update_date = Today,
                        et_last_daily_earn = {0,0,0,0,0},
                        et_last_daily_earn_update_date = Today
                    };
                _ ->
                    PlayerStatisticsOri#player_statistics {
                        et_prev_daily_earn = {0,0,0,0,0},
                        et_prev_daily_earn_update_date = Today,
                        et_last_daily_earn = {0,0,0,0,0},
                        et_last_daily_earn_update_date = Today
                    }
            end,
            player_statistics_util:full_update(CalcedStatistics),
            {CalcedStatistics#player_statistics.et_prev_daily_earn, CalcedStatistics#player_statistics.et_last_daily_earn}
    end,
    {PrevEarnInfo, LastEarnInfo}.

priv_get_last_bet_info() ->
    {Today, _} = calendar:local_time(),
    OldRecordOri = player_statistics_util:get_dict_statistics(),
    LastBetOri = OldRecordOri#player_statistics.et_last_daily_bet,
    LastBetDate = OldRecordOri#player_statistics.et_last_daily_bet_update_date,
    {LastBet, OldRecord, OldRecordModified} = case priv_get_diffdays(LastBetDate, Today) of
        0 ->
            {LastBetOri, OldRecordOri, false};
        1 ->
            {PrevLaba, PrevSuperLaba, PrevHundredNiu, PrevCar, PrevAirLaba} = OldRecordOri#player_statistics.et_prev_daily_bet,
            {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba} = OldRecordOri#player_statistics.et_last_daily_bet,
            {{0,0,0,0,0}, OldRecordOri#player_statistics {
                et_prev_daily_bet = {PrevLaba + LastLaba, PrevSuperLaba + LastSuperLaba, PrevHundredNiu + LastHundredNiu, PrevCar + LastCar, PrevAirLaba + LastAirLaba},
                et_prev_daily_bet_update_date = Today,
                et_last_daily_bet = {0,0,0,0,0}%,
                %et_last_daily_bet_update_date = Today
            }, true};
        _ ->
            % 一般不可能来这里
            {{0,0,0,0,0}, OldRecordOri#player_statistics {
                et_prev_daily_bet = {0,0,0,0,0},
                et_prev_daily_bet_update_date = Today,
                et_last_daily_bet = {0,0,0,0,0}%,
                %et_last_daily_bet_update_date = Today
            }, true}
    end,
    {Today, LastBet, OldRecord, OldRecordModified}.

priv_get_last_earn_info() ->
    {Today, _} = calendar:local_time(),
    OldRecordOri = player_statistics_util:get_dict_statistics(),
    LastEarnOri = OldRecordOri#player_statistics.et_last_daily_earn,
    LastEarnDate = OldRecordOri#player_statistics.et_last_daily_earn_update_date,
    {LastEarn, OldRecord, OldRecordModified} = case priv_get_diffdays(LastEarnDate, Today) of
        0 ->
            {LastEarnOri, OldRecordOri, false};
        1 ->
            {PrevLaba, PrevSuperLaba, PrevHundredNiu, PrevCar, PrevAirLaba} = OldRecordOri#player_statistics.et_prev_daily_earn,
            {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba} = OldRecordOri#player_statistics.et_last_daily_earn,
            {{0,0,0,0,0}, OldRecordOri#player_statistics {
                et_prev_daily_earn = {LastLaba, LastSuperLaba, LastHundredNiu, LastCar, LastAirLaba},
                et_prev_daily_earn_update_date = Today,
                et_last_daily_earn = {0,0,0,0,0}%,
                %et_last_daily_earn_update_date = Today
            }, true};
        _ ->
            % 一般不可能来这里
            {{0,0,0,0,0}, OldRecordOri#player_statistics {
                et_prev_daily_earn = {0,0,0,0,0},
                et_prev_daily_earn_update_date = Today,
                et_last_daily_earn = {0,0,0,0,0}%,
                %et_last_daily_earn_update_date = Today
            }, true}
    end,
    {Today, LastEarn, OldRecord, OldRecordModified}.

priv_update_last_bet_info(NewBet, Today, OldRecord) ->
    NewRecord = OldRecord#player_statistics{
        et_last_daily_bet = NewBet,
        et_last_daily_bet_update_date = Today
    },
    player_statistics_util:full_update(NewRecord).

priv_update_last_earn_info(NewEarn, Today, OldRecord) ->
    NewRecord = OldRecord#player_statistics{
        et_last_daily_earn = NewEarn,
        et_last_daily_earn_update_date = Today
    },
    player_statistics_util:full_update(NewRecord).

priv_get_chk_statistics() ->
    {Today, _, Record, _} = priv_get_last_earn_info(),
    %if
    %    IsModify ->
    %        player_statistics_util:full_update(Record);
    %    true ->
    %        skip
    %end,
    {Today, Record}.

priv_get_diffdays(RecordTime, Today) ->
    RecordSeconds = util:datetime_to_seconds({RecordTime,{0,0,0}}),
    TodaySeconds = util:datetime_to_seconds({Today,{0,0,0}}),
    util:get_diff_days(RecordSeconds, TodaySeconds).

priv_chk_draw() ->
    {Today, Record} = priv_get_chk_statistics(),
    {YL, YSL, YH, YC, YAL} = Record#player_statistics.et_prev_daily_earn,
    {TL, TSL, TH, TC, TAL} = Record#player_statistics.et_last_daily_earn,
    LastDrawDate = Record#player_statistics.daily_earn_draw_time,
    YesterdayEarn = YL + YSL + YH + YC + YAL,
    TodayEarn = TL + TSL + TH + TC + TAL,
    DiffDay = priv_get_diffdays(LastDrawDate, Today),
    if
        DiffDay > 0 ->
            IsDraw = false;
        true ->
            IsDraw = true
    end,
    Pec = player_util:get_server_const(?CONST_CONFIG_KEY_DAILY_SALARY_EARN_PEC),
    YesterdaySalary = trunc(YesterdayEarn * Pec),
    {YesterdayEarn, TodayEarn, YesterdaySalary, not IsDraw andalso YesterdaySalary > 0}.
