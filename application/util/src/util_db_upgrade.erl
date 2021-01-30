-module(util_db_upgrade).

-include_lib("db/include/mnesia_table_def.hrl").

-compile(export_all).

upgrade_player_stickiness_repack_info() ->
    Transformer = fun (X) ->
        ProjList = X#player_stickiness_redpack_level_info.proj_list,
        NewProjList = lists:map(fun (Elem) ->
            case Elem of
                {_, Key, CurTotalAmount, CurEarnGold} ->
                    {ok, [Config]} = stickiness_redpack_level_config_db:get(Key),
                    #stickiness_redpack_level_config{
                        reset_argv_array = ResetArray,
                        gold_cov_to_reward_item_rate = CovRate
                    } = Config,
                    [AdjustTime | _] = ResetArray,
                    {ActivateTime, ValidTime} = {util:now_seconds(), util:get_today_start_second() + AdjustTime},
                    New = #player_stickiness_redpack_level_info_proj_elem{
                        key = Key,
                        cur_total_amount = CurTotalAmount,
                        cur_earn_gold = 0,
                        end_time = ValidTime,
                        activate_time = ActivateTime,
                        holding = CurEarnGold,
                        total_gold = CurTotalAmount * CovRate
                    },
                    New;
                _ ->
                    ?ERROR_LOG("Bad Elem when upgrade_player_stickiness_repack_info ~p~n", [Elem]),
                    Elem
                end
        end, ProjList),
        X#player_stickiness_redpack_level_info{
            proj_list = NewProjList
        }
	end,
    {atomic, ok} =
	mnesia:transform_table(player_stickiness_redpack_level_info,
		Transformer,
		record_info(fields,
			player_stickiness_redpack_level_info),
	player_stickiness_redpack_level_info).
