-module(player_laba_util_reroll).

-include("common.hrl").

-include("laba.hrl").

-include("role_processor.hrl").

-include_lib("db/include/mnesia_table_def.hrl").

-include_lib("network_proto/include/laba_pb.hrl").

-include("./player_laba_util.hrl").

-export([
    reset_laba_fresher_protect_stat/1,
    check_reroll_by_laba_fresher_protect/3,
    g_sort_config/2
]).

-define(CACHED_FRUIT_FRESHER_PROTECT_STAT, cached_fruit_fresher_protect_stat).
-define(CACHED_SUPER_FRUIT_FRESHER_PROTECT_STAT, cached_super_fresher_protect_stat).

-record(fruit_fresher_protect_stat, {
    allfall_times = 0,
    protect_config = undefined
}).

reset_laba_fresher_protect_stat(Type) ->
    priv_put_protect_stat(#fruit_fresher_protect_stat{
        allfall_times = 0,
        protect_config = undefined
    }, Type).

% 必须在没拉到的时候调用（全陪）
check_reroll_by_laba_fresher_protect(BetIndex, LineNum, Type) -> 
    OldStat = priv_get_protect_stat(Type),
    CurStat = OldStat#fruit_fresher_protect_stat{
        allfall_times = OldStat#fruit_fresher_protect_stat.allfall_times + 1
    },
    MatchConfig = priv_get_match_ffp(BetIndex, LineNum, CurStat#fruit_fresher_protect_stat.allfall_times, Type),
    NewStat = CurStat#fruit_fresher_protect_stat{
        protect_config = MatchConfig
    },
    RerollConfig = case MatchConfig of
        undefined ->
            {false, 0, 0};
        _ ->
            case MatchConfig#fruit_fresher_protect_config.win_rate of
                [Min, Max] ->
                    Rand = util:rand(1, 10000),
                    {MatchConfig#fruit_fresher_protect_config.reroll_perc >= Rand, Min, Max};
                _ ->
                    {false, 0, 0}
            end
    end,
    priv_put_protect_stat(NewStat, Type),
    RerollConfig.

% 可全局调用，不属于进程函数
g_sort_config(ConfigList, fruit_fresher_protect_config) ->
    {_, {LabaConfigList, SuperLabaConfigList}} = lists:mapfoldl(fun (Elem, Acc) ->
        {LabaConfigListAcc, SuperLabaConfigListAcc} = Acc,
        case Elem#fruit_fresher_protect_config.id of
            {laba, _} ->
                {Elem, {LabaConfigListAcc ++ [Elem], SuperLabaConfigListAcc}};
            {super_laba, _} ->
                {Elem, {LabaConfigListAcc, SuperLabaConfigListAcc ++ [Elem]}};
            _ ->
                {Elem, Acc}
        end
    end, {[], []}, ConfigList),
    LabaConfigListSorted = priv_g_sort_config(LabaConfigList, fruit_fresher_protect_config),
    SuperLabaConfigListSorted = priv_g_sort_config(SuperLabaConfigList, fruit_fresher_protect_config),
    {LabaConfigListSorted, SuperLabaConfigListSorted}.

priv_g_sort_config(ConfigList, fruit_fresher_protect_config) ->
    SoredList = lists:sort(fun(A, B) ->
        if
            A#fruit_fresher_protect_config.bet_index < B#fruit_fresher_protect_config.bet_index ->
                true;
            A#fruit_fresher_protect_config.bet_index > B#fruit_fresher_protect_config.bet_index ->
                false;
            true ->
                if
                    % 线多优先匹配
                    A#fruit_fresher_protect_config.set_line_min > B#fruit_fresher_protect_config.set_line_min ->
                        true;
                    A#fruit_fresher_protect_config.set_line_min < B#fruit_fresher_protect_config.set_line_min ->
                        false;
                    true ->
                        if
                            % 失败多的优先启用
                            A#fruit_fresher_protect_config.max_allfall_times > B#fruit_fresher_protect_config.max_allfall_times ->
                                true;
                            true ->
                                false
                        end
                end
        end
    end, ConfigList),
    SoredList.

priv_put_protect_stat(Stat, Type) ->
    if
        ?TYPE_LABA =:= Type ->
            put(?CACHED_FRUIT_FRESHER_PROTECT_STAT, Stat);
        true ->
            put(?CACHED_SUPER_FRUIT_FRESHER_PROTECT_STAT, Stat)
    end.

priv_get_protect_stat(Type) ->
    Stat = case Type of
        ?TYPE_LABA ->
            get(?CACHED_FRUIT_FRESHER_PROTECT_STAT);
        _ ->
            get(?CACHED_SUPER_FRUIT_FRESHER_PROTECT_STAT)
    end,
    case Stat of
        undefined ->
            #fruit_fresher_protect_stat{
                allfall_times = 0,
                protect_config = undefined
            };
        _ ->
            Stat
    end.

priv_get_match_ffp(BetIndex, LineNum, AllFallTimes, Type) ->
    EtsList = case Type of
        ?TYPE_LABA ->
            ets:tab2list(?ETS_FRUIT_FRESHER_PROTECT_CONFIG);
        _ ->
            ets:tab2list(?ETS_SUPER_FRUIT_FRESHER_PROTECTED_CONFIG)
    end,
    MatchList = lists:filter(fun(Elem) ->
        if
            Elem#fruit_fresher_protect_config.bet_index >= BetIndex andalso 
                LineNum >= Elem#fruit_fresher_protect_config.set_line_min  andalso
                AllFallTimes >= Elem#fruit_fresher_protect_config.max_allfall_times ->
                    true;
            true ->
                false
        end
    end, EtsList),
    case MatchList of
        [] ->
            undefined;
        _ ->
            [Ret | _] = MatchList,
            Ret
    end.
