
% 这里的函数只能在角色进程中调用不然会有问题
-module(player_statistics_util).

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

-export([
    init_statistics/1,
    get_dict_statistics/0,
    full_update/1,
    
    cast_cost/3,
    cast_earn/3
]).

cast_cost(_GameType, _BetNum, ?TEST_TYPE_TRY_PLAY) ->
    skip;
cast_cost(GameType, BetNum, ?TEST_TYPE_ENTERTAINMENT) ->
    if
        0 >= BetNum ->
            skip;
        true ->
            role_processor_mod:cast(self(), {'et_statistics_bet', GameType, BetNum})
    end;
cast_cost(_GameType, _BetNum, _) ->
    skip.

cast_earn(_GameType, _EarnNum, ?TEST_TYPE_TRY_PLAY) ->
    skip;
cast_earn(GameType, EarnNum, ?TEST_TYPE_ENTERTAINMENT) ->
    if
        0 >= EarnNum ->
            skip;
        true ->
            role_processor_mod:cast(self(), {'et_statistics_earn', GameType, EarnNum})
    end;
cast_earn(_GameType, _EarnNum, _) ->
    skip.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%以下为角色进程调用
init_statistics(PlayerId) ->
    case player_statistics_db:get_base(PlayerId) of
        {ok,[Info]} ->
            put(?DIC_PLAYER_STATISTICS_INFO, Info);
        _ ->
            {Today, _} = calendar:local_time(),
            put(?DIC_PLAYER_STATISTICS_INFO, #player_statistics{
                player_id = PlayerId,
                et_prev_daily_bet = {0,0,0,0,0},
                et_prev_daily_bet_update_date = Today,
                et_last_daily_bet = {0,0,0,0,0},
                et_last_daily_bet_update_date = Today,
                et_prev_daily_earn = {0,0,0,0,0},
                et_prev_daily_earn_update_date = Today,
                et_last_daily_earn = {0,0,0,0,0},
                et_last_daily_earn_update_date = Today,
                daily_earn_draw_time = Today
            })
    end.

get_dict_statistics() ->
    get(?DIC_PLAYER_STATISTICS_INFO).

full_update(NewRecord) ->
    put(?DIC_PLAYER_STATISTICS_INFO, NewRecord),
    player_statistics_db:write_player_statistics(NewRecord).
