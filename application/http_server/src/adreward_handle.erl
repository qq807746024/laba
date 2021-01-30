-module(adreward_handle).

-export([reward/3]).

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("gate/include/common.hrl").

reward(SessionID, _Env, Input)  ->
    {ok, Parameters}  = pay_handle:parse_paremeter(Input),
    FieldNameAtoms = [uid],
    FieldNames = util:map(fun(EFieldNameAtom) ->
        erlang:atom_to_list(EFieldNameAtom)
    end, FieldNameAtoms),
    case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
        {true, _} ->
            AccountId = proplists:get_value("uid", Parameters),
            Resp = case account_to_player_id_db:get_base(AccountId) of
                {ok,[Accountnfo]}    ->
                    case player_info_db:get_base(Accountnfo#account_to_player_id.player_id) of
                        {ok,[PlayerInfo]}->
                            case role_manager:get_roleprocessor(PlayerInfo#player_info.id) of
                                {ok, PlayerPID} ->
                                    role_processor_mod:cast(PlayerPID, {'handle_adreward'}),
                                    [
                                        "Content-type: text/html; charset=utf-8\r\n\r\n",
                                        "{
                                            \"ret\":0,
                                            \"msg\":\"成功\"
                                        }"
                                    ];
                                _ ->
                                    % TODO 是否要补
                                    [
                                        "Content-type: text/html; charset=utf-8\r\n\r\n",
                                        "{
                                            \"ret\":4,
                                            \"msg\":\"玩家不在线\"
                                        }"
                                    ]
                            end;
                        _ ->
                            [
                                "Content-type: text/html; charset=utf-8\r\n\r\n",
                                "{
                                    \"ret\":2,
                                    \"msg\":\"获取角色数据失败\"
                                }"
                            ]
                    end;
                _ ->
                    [
                        "Content-type: text/html; charset=utf-8\r\n\r\n",
                        "{
                            \"ret\":3,
                            \"msg\":\"获取账户映射数据失败\"
                    }"]
            end,
            mod_esi:deliver(SessionID, Resp);
        {false, FieldName} ->
            mod_esi:deliver(SessionID, [
                "Content-type: text/html; charset=utf-8\r\n\r\n",
                "{
                    \"ret\":1,
                    \"msg\":" ++ "\"缺少必要参数:" ++ FieldName ++ "\"
            }"])
    end,
    ok.
