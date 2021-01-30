-module(gm_airlaba_opt).
-include_lib("gate/include/common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

-include("def.hrl").

-export([
    get_user_pool/3,
    update_user_pool/3,
    update_airlaba_pool/3,
    update_airlaba_ab_pool_config/3,
    update_airlaba_const_config/3
]).

%% /cgi-bin/gm_airlaba_opt:get_user_pool?uid=角色id
get_user_pool(SessionID, _Env, Input) ->
    {Result, FailReason} = try
        {ok, Parameters} = pay_handle:parse_paremeter(Input),
		FieldNameAtoms = [
			uid
		],
		FieldNames = util:map(fun(EFieldNameAtom) ->
			erlang:atom_to_list(EFieldNameAtom)
		end, FieldNameAtoms),
        case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
			{true, _} ->
                Uid = list_to_integer(proplists:get_value("uid", Parameters)),
                case player_airlaba_info_db:get(Uid) of
                    {ok, [PlayerLabaInfo]} -> 
                        {PoolNumTT1, PoolNumTT2} = PlayerLabaInfo#player_airlaba_info.bet_pool,
                        {0, util_url:get_param_string([
                            {"bet_pool_1", PoolNumTT1},
                            {"bet_pool_2", PoolNumTT2},
                            {"hit_rate_adj", PlayerLabaInfo#player_airlaba_info.hit_rate_adj}
                        ]) };
                    _ ->
                        {2, "未找到指定用户"}
                end;
            _ ->
                {1, "参数错误"}
        end
    catch
		Error:Reason ->
			?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, get_user_pool, []),
			{1, "参数错误!"}
	end,
    ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
    mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% /cgi-bin/gm_airlaba_opt:update_user_pool?uid=角色id&bet_pool_1=个人试玩水池数量&bet_pool_2=个人娱乐水池数量&hit_rate_adj=爆率微调
update_user_pool(SessionID, _Env, Input) ->
    {Result, FailReason} = try
        {ok, Parameters} = pay_handle:parse_paremeter(Input),
		FieldNameAtoms = [
			uid,
            bet_pool,
            hit_rate_adj
		],
		FieldNames = util:map(fun(EFieldNameAtom) ->
			erlang:atom_to_list(EFieldNameAtom)
		end, FieldNameAtoms),
        case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
			{true, _} ->
                Uid = list_to_integer(proplists:get_value("uid", Parameters)),
                PoolNumTT1 = list_to_integer(proplists:get_value("bet_pool_1", Parameters)),
                PoolNumTT2 = list_to_integer(proplists:get_value("bet_pool_2", Parameters)),
                AdjRate = list_to_float(proplists:get_value("hit_rate_adj", Parameters)),
                case role_manager:get_roleprocessor(Uid) of
                    {ok, Pid} ->
                        role_processor_mod:cast(Pid, {'handle', player_airlaba_util, force_update_player_airlaba_info,
                            [PoolNumTT1, PoolNumTT2, AdjRate]});
                    _ ->
                        player_airlaba_info_db:write(#player_airlaba_info {
                            player_id = Uid,
                            bet_pool = {PoolNumTT1, PoolNumTT2},
                            hit_rate_adj = AdjRate
                        })
                end,
                {0, "成功"};
            _ ->
                {1, "参数错误"}
        end
    catch
		Error:Reason ->
			?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, update_user_pool, []),
			{1, "参数错误!"}
	end,
    ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
    mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% /cgi-bin/gm_airlaba_opt:update_airlaba_pool?add_pool_num=新增奖池数量&add_rank_pool_num=新增排行榜奖池数量
update_airlaba_pool(SessionID, _Env, Input) ->
    {Result, FailReason} = try
        {ok, Parameters} = pay_handle:parse_paremeter(Input),
		FieldNameAtoms = [
			add_pool_num,
            add_rank_pool_num
		],
		FieldNames = util:map(fun(EFieldNameAtom) ->
			erlang:atom_to_list(EFieldNameAtom)
		end, FieldNameAtoms),
        case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
			{true, _} ->
                AddPoolNum = list_to_integer(proplists:get_value("add_pool_num", Parameters)),
                AddRankPoolNum = list_to_integer(proplists:get_value("add_rank_pool_num", Parameters)),
                laba_mod:cast_add_airlaba_pool(AddPoolNum, AddRankPoolNum),
                {0, "成功"};
            _ ->
                {1, "参数错误"}
        end
    catch
		Error:Reason ->
			?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, update_airlaba_pool, []),
			{1, "参数错误!"}
	end,
    ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
    mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% /cgi-bin/gm_airlaba_opt:update_airlaba_ab_pool_config?test_type=试玩娱乐类型&personal_rate=个人水池比例&common_rate_cur=当级公共水池比例
%%  &common_rate_share=共享水池比例
update_airlaba_ab_pool_config(SessionID, _Env, Input) ->
    {Result, FailReason} = try
        {ok, Parameters} = pay_handle:parse_paremeter(Input),
		FieldNameAtoms = [
            test_type,
			personal_rate,
            common_rate_cur,
            common_rate_share
		],
		FieldNames = util:map(fun(EFieldNameAtom) ->
			erlang:atom_to_list(EFieldNameAtom)
		end, FieldNameAtoms),
        case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
			{true, _} ->
                TestType = list_to_integer(proplists:get_value("test_type", Parameters)),
                PRate = list_to_float(proplists:get_value("personal_rate", Parameters)),
                CRateC = list_to_float(proplists:get_value("common_rate_cur", Parameters)),
                CRarteS = list_to_float(proplists:get_value("common_rate_share", Parameters)),
                airlaba_ab_pool_config_db:write(#airlaba_ab_pool_config{
                    id = TestType,
                    personal_pool_rate = PRate,
                    common_pool_rate = {CRateC, CRarteS}
                }),
                gate_app:init_ets_airlaba_abpool_config(),
                {0, "成功"};
            _ ->
                {1, "参数错误"}
        end
    catch
		Error:Reason ->
			?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, update_airlaba_ab_pool_config, []),
			{1, "参数错误!"}
	end,
    ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
    mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% /cgi-bin/gm_airlaba_opt:update_airlaba_const_config?test_type=房间试玩类型&sys_rate=系统税&pool_rate=奖池税&rank_rate=排行榜税
update_airlaba_const_config(SessionID, _Env, Input) ->
    {Result, FailReason} = try
        {ok, Parameters} = pay_handle:parse_paremeter(Input),
        % {airlaba_const_config, rate, {0.05, 0.02, 0.1}, "系统税，捐奖池税, 捐排行榜奖池税"}.
		FieldNameAtoms = [
            test_type,
			sys_rate,
            pool_rate,
            rank_rate
		],
		FieldNames = util:map(fun(EFieldNameAtom) ->
			erlang:atom_to_list(EFieldNameAtom)
		end, FieldNameAtoms),
        case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
			{true, _} ->
                TestType = list_to_integer(proplists:get_value("test_type", Parameters)),
                SysRate = list_to_float(proplists:get_value("sys_rate", Parameters)),
                PoolRate = list_to_float(proplists:get_value("pool_rate", Parameters)),
                RankRate = list_to_float(proplists:get_value("rank_rate", Parameters)),
                airlaba_const_config_db:write(#airlaba_const_config{
                    key = {rate, TestType},
                    value = {SysRate, PoolRate, RankRate},
                    desc = "系统税，捐奖池税, 捐排行榜奖池税"
                }),
                gate_app:init_ets_airlaba_const_config(),
                {0, "成功"};
            _ ->
                {1, "参数错误"}
        end
    catch
		Error:Reason ->
			?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
			log_util:add_gm_oprate(?MLOG_ETS_GM_error, update_airlaba_const_config, []),
			{1, "参数错误!"}
	end,
    ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
    mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).
