-module(mutisrv_rank_reward_handle).

-export([ms_send_rank_reward/3]).

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("gate/include/common.hrl").

% /cgi-bin/mutisrv_rank_reward_handle:ms_send_rank_reward  post
ms_send_rank_reward(SessionID, _Env, Input) ->
    try
        case game_earn_gold_rank_detail_config_db:get(airlaba_bet) of
            {ok, [DetailConfig]} ->
                #game_earn_gold_rank_detail_config {
                    title = Title,
                    context_tmpl = Tmpl
                } = DetailConfig,
                SelfServerId = config_app:get_server_id(),
                {ok, JsonArray, _} = rfc4627:decode(Input),
                PbHistory = lists:foldl(fun (Elem, Acc) ->
                    ServerId = rfc4627:get_field(Elem, "server_id", undefied),
                    PlayerId = erlang:binary_to_list(rfc4627:get_field(Elem, "player_id", <<"">>)),
                    Rank = rfc4627:get_field(Elem, "rank", undefied),
                    GoldNum = rfc4627:get_field(Elem, "gold_num", undefined),
                    PlayerName = rfc4627:get_field(Elem, "player_name", ""),
                    PlayerVip = rfc4627:get_field(Elem, "player_vip", 0),
                    PlayerIcon = rfc4627:get_field(Elem, "player_icon", ""),
                    Sex = rfc4627:get_field(Elem, "sex", 0),
                    WinGold = rfc4627:get_field(Elem, "win_gold", 0),
                    if
                        ServerId =:= SelfServerId andalso 0 =/= GoldNum ->
                            airlaba_bet_rank_reward_mod:send_one_reward_by_master(DetailConfig, PlayerId, Rank, GoldNum),
                            ?INFO_LOG("ms_send_rank_reward ~p~n", [{PlayerId, GoldNum}]);
                        true ->
                            skip
                    end,
                    [#pb_rank_info{
                        rank = Rank,
                        player_uuid = PlayerId,
                        player_name = PlayerName,
                        player_icon = PlayerIcon,
                        player_vip = PlayerVip,
                        gold_num = GoldNum,
                        sex = Sex
                    } | Acc]
                end, [], JsonArray),
                airlaba_bet_rank_reward_mod:write_history_from_master(PbHistory);
            _ ->
                mod_esi:deliver(SessionID, [
                    "Content-type: text/html; charset=utf-8\r\n\r\n",
                    "{
                        \"ret\":2,
                        \"msg\":\"未找到数据库配置\"
                }"])
            end
    catch
        Error:Reason ->
            ?ERROR_LOG("ms_send_rank_reward error Reason==> ~p~n", [{Error, Reason}]),
            mod_esi:deliver(SessionID, [
                "Content-type: text/html; charset=utf-8\r\n\r\n",
                "{
                    \"ret\":1,
                    \"msg\":\"解析错误\"
            }"])
    end.
