-module(pay_handle).

-export([delivery/3,
	parse_paremeter/1,
	all_paremeters_is_exist/2
]).

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("gate/include/common.hrl").

%http://127.0.0.1:9891/cgi-bin/pay_handle:delivery?order_id=80&money=100&server_id=14&role_id=100000&call_back=1,com.WeiYu.Game.tiantianaidaota.diamond_300&openid=mqmh1&order_status=1&pay_type=&pay_time=&chn_id=&sub_chn_id=&remark=
delivery(SessionID, _Env, Input)  ->
    {ok, Parameters}  = parse_paremeter(Input),
    FieldNameAtoms = 
        [  
         order_id,
         money,
         server_id,
         role_id,
         call_back,
         openid,
         order_status,
         pay_type,
         pay_time,
         chn_id,
         sub_chn_id,
         remark
        ],
    FieldNames = 
        util:map(fun(EFieldNameAtom) ->
                      erlang:atom_to_list(EFieldNameAtom)
                  end, 
                  FieldNameAtoms),
    case all_paremeters_is_exist(Parameters, FieldNames) of
        {true, _} ->
            try 
                OrderID     = proplists:get_value("order_id", Parameters),
                Money       = proplists:get_value("money", Parameters),
                ServerID    = proplists:get_value("server_id", Parameters),
                RoleID      = proplists:get_value("role_id", Parameters),
                CallBack    = proplists:get_value("call_back", Parameters),
                OpenID      = proplists:get_value("openid", Parameters),
                OrderStatus = proplists:get_value("order_status", Parameters),
                PayType     = proplists:get_value("pay_type", Parameters),
                PayTime     = proplists:get_value("pay_time", Parameters),
                ChnID       = proplists:get_value("chn_id", Parameters),
                SubChnID    = proplists:get_value("sub_chn_id", Parameters),
                Remark      = proplists:get_value("remark", Parameters),
                ID          = roleid_generator:get_already_receive_pay_info_id(),
                AlreadyReceivePayInfo = 
                    #already_receive_pay_info{
                                              id = ID,
                                              order_id    = OrderID,
                                              money       = Money,
                                              server_id   = ServerID,
                                              role_id     = RoleID,
                                              call_back   = CallBack,
                                              openid      = OpenID,
                                              order_status= OrderStatus,
                                              pay_type    = PayType,
                                              pay_time    = PayTime,
                                              chn_id      = ChnID,
                                              sub_chn_id  = SubChnID,
                                              remark      = Remark
                                             },
                case string:tokens(CallBack, ",") of
					[PidTemp, _]   ->
						{Pid,_} = string:to_integer(string:strip(PidTemp)),
                        case ets:lookup(?ETS_SHOP_ITEM, Pid) of
                            [PayItemInfo]   ->
								%{ok, RoleID1} = id_transform_util:role_id_to_internal(string:strip(RoleID)),
								%?INFO_LOG("RoleID1 ... ~p~n",[RoleID1]),
                                case account_to_player_id_db:get_base(RoleID) of
                                  {ok,[Accountnfo]}    ->
                                    case player_info_db:get_base(Accountnfo#account_to_player_id.player_id) of
                                      {ok,[PlayerInfo]}->
                                        Fun =   fun() ->
                                          already_receive_pay_info_db:t_write_already_receive_pay_info(AlreadyReceivePayInfo)
                                                end,
                                        case dal:run_transaction_rpc(Fun) of
                                          {atomic, _} ->
                                            [_, RmbRecharge] = PayItemInfo#base_shop_item.cost_list,
                                            mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n",
                                                "{
                                                     \"ret\":0,
                                                     \"msg\":\"成功\",
                                                     \"diamond_num\":"++ erlang:integer_to_list(RmbRecharge)++"
                                                               }" ]),
                                            InternalRoleID = PlayerInfo#player_info.id,
                                            case role_manager:get_roleprocessor(InternalRoleID) of
                                              {ok, PlayerPID} ->
                                                role_processor_mod:cast(PlayerPID, {'pay_receive_handle', ID});
                                              _ ->
                                                void
                                            end;
                                          _ ->
                                            mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n",
                                              "{
                                                   \"ret\":3,
                                                   \"msg\":\"写数据库出错\"
                                              }" ])
                                        end;
                                      _->
                                        mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n",
                                          "{
                                               \"ret\":6,
                                               \"msg\":\"对应的玩家未找到\"
                                          }" ])
                                    end;
                                    _ ->
                                        mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n", 
                                                                   "{
                                                                        \"ret\":5,
                                                                        \"msg\":\"对应的玩家未找到\"
                                                                   }" ])
                                end;
                            _ ->
                                mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n", 
                                   "{
                                        \"ret\":4,
                                        \"msg\":\"取得对应的钻石出错\"
                                   }" ])
                        end;
                    _ ->
                        mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n", 
                                   "{
                                        \"ret\":3,
                                        \"msg\":\"物品的PID不正确\"
                                   }" ])
                end 
            catch
                Error:Reason ->  
                    ?INFO_LOG("pay handle delivery Error : [~p]~n", [{Error, Reason}]),
                    mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n", 
                                   "{
                                        \"ret\":2,
                                        \"msg\":\"遭遇不明错误，请重新发送\"
                                   }" ])
            end;
        {false, FieldName}   ->  mod_esi:deliver(SessionID, [ "Content-type: text/html; charset=utf-8\r\n\r\n", 
                                               "{
                                                    \"ret\":1,
                                                    \"msg\":" ++ "\"缺少必要参数:" ++ FieldName ++ "\"
                                               }" ])
    end,
    ok.

all_paremeters_is_exist(_Parameters, [])    ->
    {true, "成功"};
all_paremeters_is_exist(Parameters, [FieldName|T]) ->
    case proplists:is_defined(FieldName, Parameters) of
        true    ->  all_paremeters_is_exist(Parameters, T);
        false   ->  {false, FieldName}
    end.

%%解析参数
parse_paremeter(ParamterStr)	->
	ParamterList = string:tokens(ParamterStr, "&"),	
	parse_paremeter(ParamterList, []).	

parse_paremeter([], Acc)	->
	{ ok, lists:reverse(Acc) };

parse_paremeter([ Parameter|Tail], Acc)	->
	case string:tokens(Parameter, "=")	of
		[Name, Value] ->
			parse_paremeter(Tail, [{percent:url_decode(string:strip(Name)), percent:url_decode(string:strip(Value))}|Acc]);
    [Name]        ->
      Value = "",
      parse_paremeter(Tail, [{percent:url_decode(string:strip(Name)), string:strip(Value)}|Acc]);
		_						  ->
			parse_paremeter(Tail, Acc)	
	end. 
