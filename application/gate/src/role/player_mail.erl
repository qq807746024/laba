-module(player_mail).

-export([
		send_player_login/0,
		draw_rewards/2,
		delete/1,
		read/1,
         notify_have_mail/1,


		send_mail_to_me/3,
		send_mail_to_me/4,
		send_system_mail/6,
		gm_test/2
		]).

-ifdef(TEST).
-compile(export_all).
-endif.

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/mail_pb.hrl").

send_player_login() ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			PlayerInfo = player_util:get_dic_player_info(),
			{ok, Mails} = mail_db:load_mail_by_player_id(PlayerInfo#player_info.id),
			Mails2  = util:foldl(fun(Mail, MailsAcc) ->
				case is_mail_expire(Mail) of
					false   ->
						[Mail|MailsAcc];
					true    ->
						delete_exist_mail(Mail),
						MailsAcc
				end
			end, [], Mails),
			SystemMails =
				util:map(fun(Mail) ->
					packet_system_mail(Mail)
				end,
					Mails2),
			ScMails =
				#sc_mails_init_update{
					sys_mails = SystemMails
				},
			%io:format("SystemMails ----------- ~p~n",[SystemMails]),
			tcp_client:send_data(GateProc, ScMails);
		_   ->
			void
	end.

draw_rewards(ProtoMailID, RequestMark)    ->
	case pre_draw_rewards(ProtoMailID) of
		{true, AccDict} ->
			Mail = dict:fetch(mail, AccDict),
			ToBagDBFun = dict:fetch(to_bag_db_fun, AccDict),
			ToBagDBSuccessFun = dict:fetch(to_bag_db_sucess_fun, AccDict),

			UpdateMailDbFun =
				fun() ->
					mail_db:t_delete_mail(Mail#mail.mail_id)
				end,
			UpdateMailDbSuccessFun =
				fun() ->
					skip
				end,

			Transaction =
				fun() ->
					util:foldr(fun(Elem, Acc) ->
						Elem(),
						Acc
					end, ok, [UpdateMailDbFun, ToBagDBFun])
				end,
			DBSuccessFun =
				fun() ->
					util:foldr(fun(Elem, Acc) ->
						Elem(),
						Acc
					end, ok, [UpdateMailDbSuccessFun, ToBagDBSuccessFun])
				end,
			case dal:run_transaction_rpc(Transaction) of
				{atomic, _}	->
					DBSuccessFun(),
					send_success_mail_draw_result(Mail#mail.rewards, RequestMark);
				{aborted, Reason}	->
					?ERROR_LOG("s【~s】!~n", [Reason])
			end;
		{false, Msg} ->
			send_failed_mail_draw_result(Msg, RequestMark)
	end.

pre_draw_rewards(ProtoMailID) ->
	Requires = [check_proto_mail_id,
		check_mail_exist,
		check_mail_owner,
		check_every_limit],
	pre_draw_rewards_check(ProtoMailID, dict:new(), Requires).

pre_draw_rewards_check(_ProtoMailID, AccDict, []) ->
	{true, AccDict};

pre_draw_rewards_check(ProtoMailID, AccDict, [check_proto_mail_id|T]) ->
	case id_transform_util:mail_id_to_internal(ProtoMailID) of
		{ok, MailID}    ->
			AccDict2 = dict:store(mail_id, MailID, AccDict),
			pre_draw_rewards_check(ProtoMailID, AccDict2, T);
		_   ->
			{false, "邮件ID不合法"}
	end;

pre_draw_rewards_check(ProtoMailID, AccDict, [check_mail_exist|T])    ->
	MailID = dict:fetch(mail_id, AccDict),
	case mail_db:get_mail(MailID) of
		{ok, [Mail]}    ->
			case is_mail_expire(Mail) of
				true ->
					{false, "邮件已过期"};
				_ ->
					case Mail#mail.rewards of
						[] ->
							{false, "邮件无奖励"};
						_ ->
							AccDict2 = dict:store(mail, Mail, AccDict),
							pre_draw_rewards_check(ProtoMailID, AccDict2, T)
					end
			end;
		{ok, []}    ->
			{false, "邮件不存在或已过期"};
		_   ->
			{false, "获取邮件访问数据库出错"}
	end;

pre_draw_rewards_check(ProtoMailID, AccDict, [check_mail_owner|T])    ->
	PlayerInfo = player_util:get_dic_player_info(),
	Mail = dict:fetch(mail, AccDict),
	case Mail#mail.to_id == PlayerInfo#player_info.id of
		true    ->
			pre_draw_rewards_check(ProtoMailID, AccDict, T);
		false   ->
			{false, "该邮件不属于你"}
	end;

pre_draw_rewards_check(ProtoMailID, AccDict, [check_every_limit|T]) ->
	Mail        = dict:fetch(mail, AccDict),
	case item_use:transc_items_reward(Mail#mail.rewards, Mail#mail.mail_category) of
		{_NewPlayerInfo, DBFun, DBFunSuccess, PbRewards}   ->
			AccDict2 = util:foldl( fun({Key, Value}, AccDictAcc) ->
				dict:store(Key, Value, AccDictAcc)
			end, AccDict, [{to_bag_db_fun, DBFun}, {to_bag_db_sucess_fun, DBFunSuccess},
				{pb_reward, PbRewards}]),
			pre_draw_rewards_check(ProtoMailID, AccDict2, T);
		_    ->
			{false, "reward error"}
	end;

pre_draw_rewards_check(ProtoMailID, AccDict, [_|T]) ->
	pre_draw_rewards_check(ProtoMailID, AccDict, T).

send_success_mail_draw_result(Rewards, RequestMark)   ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			Reply =     #sc_mail_draw_reply{
				result = 0,
				reward_info_s = item_use:get_pb_reward_info(Rewards),
				request_mark = RequestMark
			},
			%?INFO_LOG("draw_sccuess~p~n",[Reply]),
			tcp_client:send_data(GateProc, Reply);
		_   ->
			void
	end.

send_failed_mail_draw_result(Msg, RequestMark)   ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			Reply =     #sc_mail_draw_reply{
				result = 1,
				err_msg = Msg,
				request_mark = RequestMark
			},
			tcp_client:send_data(GateProc, Reply);
		_   ->
			void
	end.


send_mail_to_me(Title, Content, RewardList) ->
	MailCategory = 0,
	send_mail_to_me(MailCategory, Title, Content, RewardList),
	ok.

%% 发送给自己
send_mail_to_me(_MailCategory, _Title, _Content, _RewardList) ->
	ok.

%% 发系统邮件, 玩家在线则通知 MailCls默认1用于客户端表现, MailCategory功能对应id用于服务器统计
send_system_mail(ToPlayerId, MailCls, MailCategory, Title, Content, RewardList) ->
	{DBFun, DBSuccessFun} = send_mail_handle1(ToPlayerId, MailCls, MailCategory, Title, Content, RewardList),
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("send mail Error ! Info = ~p~n", [{Reason, RewardList}])
	end.

send_mail_handle1(ToPlayerId, MailCls, MailCategory, Title1, Content1, RewardList) ->
	MailId = roleid_generator:get_auto_mail_id(),
	NowSecTime = util:now_seconds(),
	ExpireTime = get_expire_time(NowSecTime, RewardList),	%% 有奖励15天 无奖励15天
	if
		is_list(Title1) ->
			Title = Title1;
		true ->
			Title = "title"
	end,
	if
		is_list(Content1) ->
			Content = Content1;
		true ->
			Content = "content"
	end,
	MailInfo =
		#mail{
			mail_id = MailId,
			to_id = ToPlayerId,
			mail_cls = MailCls,
			mail_category = MailCategory,
			title = Title,
			content = Content,
			rewards = RewardList,
			receive_time = NowSecTime,
			expire_time = ExpireTime
		},
	DBFun =
		fun() ->
			mail_db:t_write_mail(MailInfo)
		end,
	DBSuccessFun =
		fun() ->
			case role_manager:get_roleprocessor(ToPlayerId) of
				{ok, EPlayerPid} ->
					role_processor_mod:cast(EPlayerPid, {'handle', player_mail, notify_have_mail, [MailId]});
				_ ->
					skip
			end,
			RewardStr = lists:foldl(fun({EI,EN},Acc) -> lists:concat([EI,",",EN,";",Acc]) end,"",RewardList),
			http_send_mod:do_cast_http_post_fun(post_emaillog,[ToPlayerId,MailId,Title,RewardStr,MailCategory,util:now_seconds()])
			%log_util:add_mail(Title, Content, MailCategory, MailId, ToPlayerId, RewardList)
		end,
	{DBFun, DBSuccessFun}.

get_expire_time(NowTime, DrawInfo) ->
	if
		DrawInfo == [] ->
			DayTimes = 15;
		true ->
			DayTimes = 15
	end,
	%ExpireTime = util:seconds_to_datetime(NowTime+24*3600*DayTimes),
	%ExpireTime.
	NowTime+24*3600*DayTimes.

notify_have_mail(MailID) ->
	case mail_db:get_mail(MailID) of
		{ok, [Mail]}    ->
			case is_mail_expire(Mail) of
				true    ->
					%?INFO_LOG("is_mail_expire ......... MailId ~p~n",[Mail#mail.mail_id]),
					delete_exist_mail(Mail);
				false   ->
					case player_util:get_dic_gate_pid() of
						GateProc when GateProc =/= undefined ->
							send_new_mail(GateProc, Mail);
						_   ->
							void
					end
			end;
		_   ->
			void
	end.

is_mail_expire(Mail) ->
	Mail#mail.expire_time < util:now_seconds().

delete_exist_mail(Mail)   ->
	Transaction = delete_exist_mail_db_fun(Mail),
	{atomic,_ } = dal:run_transaction_rpc(Transaction).

delete_exist_mail_db_fun(Mail) ->
	MailID = Mail#mail.mail_id,
	fun() ->
		mail_db:t_delete_mail(MailID)
	end.

%% 发系统邮件
send_new_mail(GateProc, Mail) ->
	tcp_client:send_data(GateProc, #sc_mail_add{add_sys_mail = packet_system_mail(Mail)}).


packet_system_mail(Mail) ->
	%?INFO_LOG("mail~p~n",[Mail]),
	{ok, MailUuid} = id_transform_util:mail_id_to_proto(Mail#mail.mail_id),
	#pb_mail{
		mail_id = MailUuid,
		cls = Mail#mail.mail_cls,

		title = Mail#mail.title,
		content = Mail#mail.content,
		read = Mail#mail.read_flag,
		receive_date = Mail#mail.receive_time,
		expire_date = Mail#mail.expire_time,
		reward_list = item_use:get_pb_reward_info(Mail#mail.rewards)
	}.

delete(Msg) ->
	#cs_mail_delete_request{mail_id = ProtoMailID, request_mark = RequestMark} = Msg,
	case  pre_delete(ProtoMailID) of
		{true, AccDict} ->
			Mail            = dict:fetch(mail, AccDict),
			DeleteMailDbFun = delete_exist_mail_db_fun(Mail),
			case dal:run_transaction_rpc(DeleteMailDbFun) of
				{atomic, _}	->
					send_success_mail_delete_result(RequestMark);
				{aborted, Reason}   ->
					send_failed_mail_delete_result("数据库操作失败:-2", RequestMark),
					?ERROR_LOG("删除邮件失败【~s】!~n", [Reason])
			end;
		{false, ErrDesc}    ->
			send_failed_mail_delete_result(ErrDesc, RequestMark)
	end.

send_success_mail_delete_result(RequestMark)   ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			Reply =     #sc_mail_delete_reply{
				result = 0,
				request_mark = RequestMark
			},
			%?INFO_LOG("delet~p~n",[Reply]),
			tcp_client:send_data(GateProc, Reply);
		_   ->
			void
	end.

send_failed_mail_delete_result(Msg, RequestMark)   ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			Reply =     #sc_mail_delete_reply{
				result = 1,
				err_msg = Msg,
				request_mark = RequestMark
			},
			%?INFO_LOG("delet_fail~p~n",[Reply]),
			tcp_client:send_data(GateProc, Reply);
		_   ->
			void
	end.


pre_delete(ProtoMailID)  ->
	Requires = [
		check_proto_mail_id,
		check_mail_exist,
		check_mail_owner,
		check_mail_status,
		void],
	AccDict  = dict:new(),
	pre_delete(ProtoMailID, AccDict, Requires).

pre_delete(_ProtoMailID, AccDict, [])   ->
	{true, AccDict};

pre_delete(ProtoMailID, AccDict, [check_proto_mail_id|T]) ->
	case id_transform_util:mail_id_to_internal(ProtoMailID) of
		{ok, MailID}    ->
			AccDict2 = dict:store(mail_id, MailID, AccDict),
			pre_delete(ProtoMailID, AccDict2, T);
		_   ->
			{false, "邮件ID不合法"}
	end;
pre_delete(ProtoMailID, AccDict, [check_mail_exist|T])    ->
	MailID = dict:fetch(mail_id, AccDict),
	case mail_db:get_mail(MailID) of
		{ok, [Mail]}    ->
			AccDict2 = dict:store(mail, Mail, AccDict),
			pre_delete(ProtoMailID, AccDict2, T);
		{ok, []}    ->
			{false, "邮件不存在或已过期"};
		_   ->
			{false, "获取邮件访问数据库出错"}
	end;

pre_delete(ProtoMailID, AccDict, [check_mail_owner|T])    ->
	PlayerInfo = player_util:get_dic_player_info(),
	Mail = dict:fetch(mail, AccDict),
	case Mail#mail.to_id == PlayerInfo#player_info.id of
		true    ->
			pre_delete(ProtoMailID, AccDict, T);
		false   ->
			{false, "该邮件不属于你"}
	end;

pre_delete(ProtoMailID, AccDict, [check_mail_status|T])    ->
	Mail = dict:fetch(mail, AccDict),
	case length(Mail#mail.rewards) /= 0 of
		true    ->
			{false, "有附件的新邮件不能删除掉"};
		false   ->
			pre_delete(ProtoMailID, AccDict, T)
	end;

pre_delete(ProtoMailID, AccDict, [_|T])   ->
	pre_delete(ProtoMailID, AccDict, T).

read(MailID) ->
	case mail_db:get_mail(MailID) of
		{ok, [Mail]}    ->
			NewMail = Mail#mail{
				read_flag = true
			},
			mail_db:write_mail(NewMail);
		_   ->
			?ERROR_LOG("mail_db FIND MAIL ERROR id:~p~n",[MailID])
	end.


gm_test(Type1,Key1)->
	if
		Type1 == 1->
			send_player_login();
		Type1 == 2 ->
			PlayerInfo = player_util:get_dic_player_info(),
			?INFO_LOG("PlayerInfo~p~n",[PlayerInfo#player_info.id]);
		Type1 == 3->
			PlayerInfo = player_util:get_dic_player_info(),
			send_system_mail(PlayerInfo#player_info.id, 1, 0, "我的邮件", "恭喜你，你发财啦", [{?ITEM_ID_GOLD, 9999999},{?ITEM_ID_CASH, 999999}]),
			ok;
		Type1 == 4->
			A = #cs_mail_delete_request{mail_id = [131,98,0,15,66,68], request_mark = "删除"},
			delete(A);
		Type1 == 5->
			draw_rewards([131,98,0,15,66,67], "领取");
		Type1 == 6 ->
			read(Key1);
		true ->
			ok
	end.