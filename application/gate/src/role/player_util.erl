%% @author lsb
%% @doc @todo 玩家功能接口

-module(player_util).

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/shop_pb.hrl").

-define(BIND_PHONE_NUM_REWARD_NUM, 10000).  %%绑定手机奖励金币数量


%% ====================================================================
%% API functions
%% ====================================================================
-export([
	%% 更新procdict
	get_dic_gate_pid/0,                        % 获取网关Pid
	update_dic_gate_pid/1,
	get_dic_player_info/0,                        % 获取玩家信息
	update_dic_player_info/1,

	%% 更新send
	send_player_info/0,
	send_login_relpy_false/2,
	send_login_reconnection_reply/4,
	send_heartbeat_reply/2,
	packet_heartbeat/1,

	send_login_proto_complete/1,

	check_player_name_valid/1,
	package_player_info/1,
	package_login_reply/4,
	package_login_repeat/0,
	package_login_reconnection_reply/3,
	set_gate_proc_handle/4,
	close_gate_proc_handle/1,

	save_player_info/1,
	save_player_info/2,

	is_player_name_exists/1,
	is_account_exists/1,
	is_uid_exists/1,
	check_account_login/1,
	get_online_info/1,
	update_ets_online/1,
	del_ets_online/1,
	check_player_name_valid1/1,
	get_player_account/0,


	update_player_info_level_and_save/2,
	send_player_phone_info/0,
	cs_player_bind_phone_num_draw/0,
	check_init_phone_bind_info/3,
	get_bind_phone_num_reward/0,

	%% 协议处理 %%%%%%%
	cs_player_change_name_req/1,
	cs_player_change_headicon_req/2,
	cs_player_bind_phone_num/1,
	cs_make_name/0,                            % 生成名称
	login_add_offline_reward/0,	%%离线奖励

	get_server_const/1,	%% 常量表

	log_by_player_id/3,		%% 打日志

	get_player_gate_id/1,
	%% 协议处理


	get_player_level_upgrade_base_list/0,		%%获取玩家升级列表
	compute_level_exp_level/2,	%% 计算玩家等级经验
	get_http_room_level_id/0,
	change_name/1,
	cast_rank_player_base_info_change/1,
	real_name_authentication/2,
	cs_real_name_req/0,
	handle_adreward/0
]).

%% ====================================================================
%% Internal functions
%% ====================================================================

%% 获取网关Pid
get_dic_gate_pid() ->
	get(?DIC_GATE_PROCESSOR).

update_dic_gate_pid(GatePid) ->
	put(?DIC_GATE_PROCESSOR, GatePid).

%% 获取玩家数据
get_dic_player_info() ->
	get(?DIC_PLAYER_INFO).

update_dic_player_info(PlayerInfo) ->
	put(?DIC_PLAYER_INFO, PlayerInfo).

get_player_account() ->
	PlayerInfo = player_util:get_dic_player_info(),
	case PlayerInfo of
		undefined ->
			ok;
		_ ->
			PlayerInfo#player_info.account
	end.

%% 发送登录返回
send_login_relpy(_PlayerInfo, ProtyKey) ->
	ReconKey = player_util_procdict:make_login_reconnection_key(),
	ScLoginReply = package_login_reply(1, "", ReconKey, ProtyKey),	% 1成功
	GatePid = get_dic_gate_pid(),
	tcp_client:send_data(GatePid, ScLoginReply).

%% 发送登录失败返回
send_login_relpy_false(GatePid, Reason) ->
	ScLoginReply = package_login_reply(0, Reason, "", <<>>),
	tcp_client:send_data(GatePid, ScLoginReply).

%% 发送重连返回
send_login_reconnection_reply(GatePid, Result, Reason, ProtoKey) ->
	ScLoginReconReply = package_login_reconnection_reply(Result, Reason, ProtoKey),
	tcp_client:send_data(GatePid, ScLoginReconReply).

package_login_reply(Result, Reason, ReconKey, ProtyKey) ->
	#sc_login_reply{
		result = Result,
		reason = Reason,
		reconnect_key = ReconKey,
		proto_key = ProtyKey
	}.


package_login_repeat() ->
	#sc_login_repeat{}.

package_login_reconnection_reply(Result, Reason, ProtoKey) ->
	#sc_login_reconnection_reply{
		result = Result,
		reason = Reason,
		proto_key = ProtoKey
	}.

%% 发送心跳返回
send_heartbeat_reply(GatePid, NowTime) ->
	ScCommonHeartBeatReply = packet_heartbeat(NowTime),
	tcp_client:send_data(GatePid, ScCommonHeartBeatReply).

packet_heartbeat(NowTime) ->
	#sc_common_heartbeat_reply{now_time = NowTime}.


%% 发送玩家信息
send_player_info() ->
	GatePid = get_dic_gate_pid(),
	case GatePid of
		undefined ->
			ok;
		_ ->
			PlayerInfo = get_dic_player_info(),
			{ok, ScPlayerBaseInfo} = package_player_info(PlayerInfo),
			tcp_client:send_data(GatePid, ScPlayerBaseInfo)
	end.

package_player_info(PlayerInfo) ->
	PlayerId = PlayerInfo#player_info.id,
	{ok, PlayerUuid} = id_transform_util:role_id_to_proto(PlayerId),
	UidInfo = player_util_procdict:get_dic_player_uid(),
	Account = UidInfo#account_to_player_id.account,
	Icon =
		if
			PlayerInfo#player_info.icon == undefined ->
				?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
				"";
			true ->
				PlayerInfo#player_info.icon
		end,
	ScPlayerBaseInfo =
		#sc_player_base_info{
			player_uuid = PlayerUuid,
			account = Account,
			name = PlayerInfo#player_info.player_name,
			gold = PlayerInfo#player_info.gold,
			cash = PlayerInfo#player_info.cash,
			diamond = trunc(PlayerInfo#player_info.diamond),

			exp = PlayerInfo#player_info.exp,
			level = PlayerInfo#player_info.level,
			icon = Icon,
			sex = PlayerInfo#player_info.sex,
			vip_level = PlayerInfo#player_info.vip_level,
			rmb = PlayerInfo#player_info.recharge_money,
			block = PlayerInfo#player_info.login_forbid_state
		},
	{ok, ScPlayerBaseInfo}.


%% 通知客户端初始协议更新完毕
send_login_proto_complete(IsNewPlayer) ->
	Msg = #sc_login_proto_complete{is_new_player = IsNewPlayer},
	GatePid = get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg).

update_ets_online(PlayerInfo) ->
	GatePid = get_dic_gate_pid(),
	if
		is_pid(GatePid) ->
			#player_info{
				id = PlayerId,
				player_name = PlayerName,
				level = PlayerLevel,
				icon = PlayerIcon,
				login_time = _LoginTime
			} = PlayerInfo,
			NewEtsOnline =
				#ets_online{
					player_id = PlayerId,
					player_name = PlayerName,
					player_pid = self(),
					player_level = PlayerLevel,
					player_icon = PlayerIcon,
					gate_pid = GatePid
				},
			ets:insert(?ETS_ONLINE, NewEtsOnline);
		true ->
			skip
	end,
	ok.

del_ets_online(PlayerId) ->
	ets:delete(?ETS_ONLINE, PlayerId),
	ok.

%% 设置网关处理
set_gate_proc_handle(PlayerInfo, GatePid, ProtyKey, IsNewPlayer) ->
	%% 更新
	update_dic_gate_pid(GatePid),
	update_ets_online(PlayerInfo),
	%% 发送
	send_login_relpy(PlayerInfo, ProtyKey),
	role_processor:initialize(IsNewPlayer,PlayerInfo#player_info.is_robot),
	%% 其他
	close_be_offline_timer(),
	ok.

%% 关闭网关处理
close_gate_proc_handle(PlayerInfo) ->
	#player_info{
		id = PlayerId
	} = PlayerInfo,
	NowSeconds = util:now_seconds(),
	update_dic_gate_pid(undefined),
	player_util_procdict:update_dic_gate_proc_close_time(NowSeconds),
	%% 下线保存
	NewPlayerInfo = logout_save(PlayerInfo),
	%% 在线统计扣除
	del_ets_online(PlayerId),
	%% 其他
	%set_be_offline_timer(),
	NewPlayerInfo.

%% 设置掉线定时器
%% set_be_offline_timer() ->
%% 	close_be_offline_timer(),
%% 	TimerRef = erlang:send_after(?TIME_BE_OFFLINE * 1000, self(), {'timer_be_offline'}),
%% 	PlayerTimer = player_util_procdict:get_dic_player_timer(),
%% 	NewPlayerTimer =
%% 		PlayerTimer#player_timer{
%% 								 be_offline_timer_ref = TimerRef
%% 								},
%% 	player_util_procdict:update_dic_player_timer(NewPlayerTimer).

logout_save(PlayerInfo) ->
	NowSeconds = util:now_seconds(),
	NewPlayerInfo = PlayerInfo#player_info{logout_time = NowSeconds},
	%% 更新
	update_dic_player_info(NewPlayerInfo),
	player_info_db:write_player_info(NewPlayerInfo),
	%% 保存相关状态恢复时间

	NewPlayerInfo.


%% 保存玩家信息
save_player_info(OldPlayerInfo, NewPlayerInfo)
	when is_record(OldPlayerInfo, player_info) andalso is_record(NewPlayerInfo, player_info) ->
	if
		OldPlayerInfo == NewPlayerInfo ->
			skip;
		true ->
			save_player_info(NewPlayerInfo)
	end.

save_player_info(NewPlayerInfo) ->
	DbFun =
		fun() ->
			player_info_db:t_write_player_info(NewPlayerInfo)
		end,
	DbSuccessFun =
		fun() ->
			update_dic_player_info(NewPlayerInfo)
		end,
	case dal:run_transaction_rpc(DbFun) of
		{atomic, _} ->
			DbSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("save player info error! info = ~p stack = ~p", [?MODULE, Reason, erlang:get_stacktrace()])
	end,
	ok.



%% 关闭掉线定时器
close_be_offline_timer() ->
	PlayerTimer = player_util_procdict:get_dic_player_timer(),
	#player_timer{
		be_offline_timer_ref = TimerRef
	} = PlayerTimer,
	if
		erlang:is_reference(TimerRef) ->
			erlang:cancel_timer(TimerRef),
			NewPlayerTimer =
				PlayerTimer#player_timer{
					be_offline_timer_ref = undefined
				},
			player_util_procdict:update_dic_player_timer(NewPlayerTimer);
		true ->
			skip
	end.

%% 获取随机名字
cs_make_name() ->
	%% cd检测
	PlayerName = name_util:make_player_name(),
	Msg =
		#sc_player_base_make_name_back{
			name = PlayerName
		},
	GatePid = get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg),
	ok.

%% 检测名字 0成功 1名称已存在 2非法字符 3道具不足 4名字为空 5名字超过8个字 6跟旧的相同
check_player_name_valid1(NewName, OldName) ->
	if
		NewName =/= OldName ->
			check_player_name_valid(NewName);
		true ->
			5
	end.

%% 检查玩家名称合法性
check_player_name_valid(Name) ->
	LenName = length(Name),
	case check_player_name_valid1(Name) of
	%% 不合法字符
		true ->
			Result = 2;
		_ when Name == "" ->
			Result = 4;
		_ when LenName > 3 * 6 ->
			Result = 5;
		_ ->
			case is_player_name_exists(Name) of
			%% 昵称已存在
				{true, _PlayerInfo} ->
					Result = 1;
				_ ->
					Result = 0
			end
	end,
	Result.

check_player_name_valid1(Name) ->
	FunCheck =
		fun(E, Acc) ->
			% ?INFO_LOG("E---------------~p",[E]),
			case E of
			%% ,
				$, -> true;
			%% 空格
				$& -> true;
				$+ -> true;
				32 -> true;
				_ ->
					Acc
			end
		end,
	Result1 = util:foldl(FunCheck, false, Name),   %返回true代表有非法字符
	NewName = util_sensitive_words:block_sensitive_word(Name),
	SensiveIsExist = string:equal(Name, NewName),   %返回·true代表没有敏感字
	if
	%% 没有非法字符
		Result1 == false andalso SensiveIsExist == true ->
			false;
		true ->
			true
	end.

%% 玩家名称是否存在
is_player_name_exists(PlayerName) ->
	case player_info_db:get_player_info_by_player_name(PlayerName) of
		[PlayerInfo | _] ->
			{true, PlayerInfo};
		_ ->
			false
	end.

%% 帐号是否存在
is_account_exists(Account) ->
	case account_to_player_id_db:get_base(Account) of
		{ok, [AccountInfo]} ->
			{true, AccountInfo#account_to_player_id.account};
		_ ->
			false
	end.

%% 帐号是否存在
is_uid_exists(Uid) ->
	case account_to_player_id_db:get_base(Uid) of
		{ok, [UidInfo]} ->
			{true, UidInfo#account_to_player_id.player_id};
		_ ->
			false
	end.

check_account_login(Account) ->
	case account_to_player_id_db:get_base(Account) of
		{ok, [AccountInfo]} ->
			PlayerId = AccountInfo#account_to_player_id.player_id,
			%ForbidLoginLeftTime = player_forbid_state:get_forbid_left_time(PlayerId, ?FORBID_STATE_BAN_LOGIN),
			{true, PlayerId, 0};
		_ ->
			false
	end.



get_online_info(PlayerId) ->
	case ets:lookup(?ETS_ONLINE, PlayerId) of
		[OnlineInfo] ->
			OnlineInfo;
		[] ->
			[]
	end.


%% %% 生成玩家昵称
%% make_player_name() ->
%% 	%name_util:make_player_name().
%% 	make_player_name(0).
%%
%% make_player_name(Index) ->
%% 	TempPlayerName = name_util:make_player_name(),
%% 	case is_player_name_exists(TempPlayerName) of
%% 	%% 昵称已存在
%% 		{true, _PlayerInfo} ->
%% 			if
%% 				Index < 10 ->
%% 					make_player_name(Index + 1);
%% 				true ->
%% 					?ERROR_LOG("make player name Overflow ! ~p~n", [erlang:localtime()]),
%% 					erlang:integer_to_list(util:now_seconds() * 10)
%% 			end;
%% 		_ ->
%% 			TempPlayerName
%% 	end.


%% 更新玩家等级信息
update_player_info_level_and_save(OldPlayerInfo, NewPlayerInfo) ->
	case OldPlayerInfo == NewPlayerInfo of
		true    ->
			{NewPlayerInfo, fun() -> void end, fun() -> void end};
		false   ->
			{NewPlayerInfo2, DbFun, DbSuccessFun} = upgrade_player_level(OldPlayerInfo, NewPlayerInfo),
			%% 金币变动更新
			if
				NewPlayerInfo#player_info.gold == OldPlayerInfo#player_info.gold ->
					MaxGoldDBFun = fun() -> skip end,
					MaxGoldSuccessFun = fun() -> skip end;
				true ->
					{MaxGoldDBFun, MaxGoldSuccessFun} = player_winning_record:change_max_money(NewPlayerInfo#player_info.gold)
			end,
			if
				NewPlayerInfo#player_info.vip_level == OldPlayerInfo#player_info.vip_level ->
					VipDBFun = fun() -> skip end;
				true ->
					VipDBFun = fun() ->
						cast_rank_player_base_info_change(NewPlayerInfo2),
						announcement_server:vip_level_change(NewPlayerInfo#player_info.player_name, NewPlayerInfo#player_info.vip_level)
					end
			end,

			if
				NewPlayerInfo2#player_info.is_robot andalso NewPlayerInfo2#player_info.robot_cls == 0 ->
					if
						NewPlayerInfo2#player_info.diamond < 26 ->
							RobotSubsidyFun1 = fun() ->
								%?INFO_LOG("Add Robot Diamond ~p~n",[NewPlayerInfo#player_info.id]),
								item_use:imme_items_reward([{?ITEM_ID_DIAMOND, 495}, {?ITEM_ID_RMB, 98}],
							?REWARD_TYPE_ROBOT_DIAMOND_SUBSIDY) end;
						true ->
							RobotSubsidyFun1 = fun() -> skip end
					end,
					if
						NewPlayerInfo2#player_info.gold < 2000 ->
							RobotSubsidyFun = fun() ->
								RobotSubsidyFun1() end;
						true ->
							RobotSubsidyFun = fun() ->RobotSubsidyFun1() end
					end;
				true ->
					RobotSubsidyFun = fun() ->skip end
			end,

			UpdatePlayerInfoDBFun =
				fun() ->
					player_info_db:t_write_player_info(NewPlayerInfo2),
					DbFun(),
					MaxGoldDBFun()
				end,
			UpdatePlayerInfoDBSuccessFun =
				fun() ->
					player_util:update_dic_player_info(NewPlayerInfo2),
					player_util:send_player_info(),
					DbSuccessFun(),
					MaxGoldSuccessFun(),
					VipDBFun(),
					RobotSubsidyFun()
				end,
			{NewPlayerInfo2, UpdatePlayerInfoDBFun, UpdatePlayerInfoDBSuccessFun}
	end.

%% 玩家升级计算
upgrade_player_level(OldPlayerInfo,  NewPlayerInfo) ->
	case OldPlayerInfo#player_info.total_exp =/= NewPlayerInfo#player_info.total_exp of
		true ->
			PlayerLevelUpgradeBaseList = get_player_level_upgrade_base_list(),
			{Level, Exp} = compute_level_exp_level(NewPlayerInfo#player_info.total_exp, PlayerLevelUpgradeBaseList),
			NewPlayerInfo3  = NewPlayerInfo#player_info{exp = Exp, level = Level},

			DbFun = fun() ->
				skip
			end,
			DBSuccessFun =  fun() ->
				skip
			end,
			{NewPlayerInfo3, DbFun, DBSuccessFun};
		false ->
			{NewPlayerInfo, fun() -> void end, fun() -> void end}
	end.

get_player_level_upgrade_base_list() ->
	{ok, PlayerLevelUpgradeBaseList} = player_level_upgrade_base_db:load_player_level_upgrade_base(),
	lists:sort( fun(A, B) ->
		A#player_level_upgrade_base.level < B#player_level_upgrade_base.level
	end,
		PlayerLevelUpgradeBaseList).

compute_level_exp_level(_Exp, [PlayerLevelUpgradeBase]) ->
	{PlayerLevelUpgradeBase#player_level_upgrade_base.level, PlayerLevelUpgradeBase#player_level_upgrade_base.upgrade_exp};

compute_level_exp_level(Exp, [PlayerLevelUpgradeBase | T]) ->
	case PlayerLevelUpgradeBase#player_level_upgrade_base.upgrade_exp > Exp of
		false    ->
			Exp1 = Exp - PlayerLevelUpgradeBase#player_level_upgrade_base.upgrade_exp,
			compute_level_exp_level(Exp1, T);
		true   ->
			{PlayerLevelUpgradeBase#player_level_upgrade_base.level, Exp}
	end.

%% 改名
cs_player_change_name_req(Name) ->
	Name1 = unicode:characters_to_binary(Name),
	NewName = string:strip(lists:flatten(erlang:binary_to_list(Name1))),
	PlayerInfo = get_dic_player_info(),
	#player_info{
		player_name = OldPlayerName
	} = PlayerInfo,

	Flag = check_player_name_valid1(NewName, OldPlayerName),
	case Flag of
		0 ->
			DeductList = [{?ITEM_ID_CHANGE_NAME_CARD, -1}],
			case item_use:check_item_enough(DeductList) of
				true ->
					Flag1 = 0,
					item_use:imme_items_reward(DeductList, ?REWARD_TYPE_CHANGE_NAME),
					NewPlayerInfo = PlayerInfo#player_info{player_name = NewName},
					%% player_mission:change_name(1),
					save_player_info(NewPlayerInfo),
					update_ets_online(NewPlayerInfo),
					cast_rank_player_base_info_change(NewPlayerInfo),
					check_update_room_player_info(PlayerInfo#player_info.id, [{'name', NewName}]),
					send_player_info();
				_ ->
					Flag1 = 3
			end;
		_ ->
			Flag1 = Flag
	end,
	Msg = #sc_player_change_name_reply{result = Flag1},
	GatePid = get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg).

%% 改头像
cs_player_change_headicon_req(Icon, Sex) ->
	PlayerInfo = get_dic_player_info(),
	Sex1 =
		if
			Sex >= 0 andalso Sex =< 1 ->
				Sex;
			true ->
				0
		end,
	Icon1 =
		if
			Icon == undefined ->
				"";
			true ->
				Icon
		end,
	PlayerInfo1 = PlayerInfo#player_info{sex = Sex1, icon= Icon1},
	if
		PlayerInfo#player_info.icon =/= Icon1 ->
			check_update_room_player_info(PlayerInfo#player_info.id, [{'icon', Icon1}]);
%%			player_mission:change_head(1);
		true ->
			skip
	end,
	if
		PlayerInfo1 =/= PlayerInfo ->
			save_player_info(PlayerInfo1),
			update_ets_online(PlayerInfo1),
			send_player_info(),
			cast_rank_player_base_info_change(PlayerInfo1);
		true ->
			skip
	end,

	Msg = #sc_player_change_headicon_reply{result = 0},
	GatePid = get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg).

%% 发送玩家手机号信息
send_player_phone_info()->
	PlayerInfo = get_dic_player_info(),
	case player_phone_info_db:get(PlayerInfo#player_info.id) of
		{ok,[PhoneInfo]}->
			send_player_phone_num_info_update(PhoneInfo);
		_->
			PhoneInfo = #player_phone_info{
				player_id = PlayerInfo#player_info.id,
				phone_num = 0,
				is_draw = false
			},
			send_player_phone_num_info_update(PhoneInfo)
	end.

send_player_phone_num_info_update(PhoneInfo)->
	Msg = #sc_player_phone_num_info_update{
		phone_num = integer_to_list(PhoneInfo#player_phone_info.phone_num),
		is_draw = PhoneInfo#player_phone_info.is_draw
	},
	tcp_client:send_data(get_dic_gate_pid(),Msg).

check_init_phone_bind_info(PlayerId, PhoneBindFlag, IsAlreadyRewardPhone) ->
	case player_phone_info_db:get(PlayerId) of
		{ok,[PhoneInfo]}->
			if
				PhoneInfo#player_phone_info.phone_num == 1 ->
					skip;
				PhoneInfo#player_phone_info.phone_num == PhoneBindFlag ->
					skip;
				true ->
					NewPhoneInfo = PhoneInfo#player_phone_info{
						phone_num = PhoneBindFlag
					},

					DBFun = fun() ->
						player_phone_info_db:t_write(NewPhoneInfo)
					end,
					dal:run_transaction_rpc(DBFun)
			end;
		_ ->
			NewPhoneInfo = #player_phone_info{
				player_id = PlayerId,
				phone_num = PhoneBindFlag,
				is_draw = IsAlreadyRewardPhone
			},
			DBFun = fun() ->
				player_phone_info_db:t_write(NewPhoneInfo)
			end,
			dal:run_transaction_rpc(DBFun)
	end.

%% 绑定手机号 后台调用
cs_player_bind_phone_num(AccountId)->
	PlayerInfo = ntools:get_player_info_by_account(AccountId),
	case PlayerInfo of
		false ->
			{false,"玩家不存在"};
		_ ->
			PlayerId = PlayerInfo#player_info.id,
			case player_phone_info_db:get(PlayerId) of
				{ok,[PhoneInfo]}->
					NewPhoneInfo = PhoneInfo#player_phone_info{
						phone_num = 1
					},
					DBFun = fun() ->
						player_phone_info_db:t_write(NewPhoneInfo)
					end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							{true, "绑定成功"};
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p", [{Reason, ?STACK_TRACE}]),
							{false,"数据库错误"}
					end;
				_->
					{false,"查询数据错误"}
			end
	end.


cs_player_bind_phone_num_draw()->
	PlayerInfo = get_dic_player_info(),
	case player_phone_info_db:get(PlayerInfo#player_info.id) of
		{ok,[PhoneInfo]}->
			if
				PhoneInfo#player_phone_info.is_draw ->
					send_player_bind_phone_num_draw_back(1,"已领取",[]);
				PhoneInfo#player_phone_info.phone_num == 0 ->
					send_player_bind_phone_num_draw_back(1,"未绑定",[]);
				true ->
					NewPhoneInfo = PhoneInfo#player_phone_info{
						is_draw = true
					},
					Rewards = get_bind_phone_num_reward(),
					{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
						item_use:transc_items_reward(Rewards, ?REWARD_TYPE_BINDING_PHONE),

					DBFun = fun() ->
						DBFun1(),
						player_phone_info_db:t_write(NewPhoneInfo)
									end,
					DBSccussFun = fun() ->
						SuccessFun1(),
						send_player_bind_phone_num_draw_back(0,"",item_use:get_pb_reward_info(Rewards))
												end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSccussFun();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p", [{Reason, ?STACK_TRACE}]),
							send_player_bind_phone_num_draw_back(1,"数据库错误",[])
					end
			end;
		_->
			send_player_bind_phone_num_draw_back(1,"查询绑定号码数据错误",[])
	end.
send_player_bind_phone_num_draw_back(Result,Err,Rewards)->
	Msg =#sc_player_bind_phone_num_draw_reply{
		result = Result,
		err =  Err,
		rewards = Rewards
	},
%	?INFO_LOG("send_player_bind_phone_num_draw_back~p~n",[Msg]),
	tcp_client:send_data(get_dic_gate_pid(),Msg).

get_bind_phone_num_reward()->
	[{?ITEM_ID_GOLD, player_util:get_server_const(?CONST_CONFIG_KEY_BIND_PHONE_REWRAD_NUM)}].


cast_rank_player_base_info_change(PlayerInfo) ->
	%gen_server:cast(hundred_week_board_mod:get_mod_pid(), {'player_base_info_change', PlayerInfo}),
%%	gen_server:cast(recharge_activity_mod:get_mod_pid(), {'player_base_info_change', PlayerInfo}),
	gen_server:cast(rank_mod:get_mod_pid(), {'player_base_info_change', PlayerInfo}).

check_update_room_player_info(PlayerId, ChangeList) ->
	case check_room_pid() of
		{true, RoomType, RoomId, RoomPid} ->
			case RoomType of
				'hundred' ->
					case get_ets_rec_by_hundred_room_id(RoomId, PlayerId) of
						false ->
							skip;
						SeatNum ->
							case hundred_niu_processor:check_pos_in_seat(SeatNum) orelse SeatNum == 0 of
								true ->
									send_to_room_pid_msg(RoomPid, PlayerId, ChangeList);
								_ ->
									skip
							end
					end;
				_ ->
					send_to_room_pid_msg(RoomPid, PlayerId, ChangeList)
			end;
		_ ->
			skip
	end.

get_ets_rec_by_hundred_room_id(RoomId, PlayerId) ->
	case ets:lookup(hundred_niu_processor:get_hundred_player_ets_name(RoomId), PlayerId) of
		[PlayerRec] ->
			PlayerRec#ets_hundred_niu_player_info.seat_pos;
		_ ->
			false
	end.

send_to_room_pid_msg(RoomPid, PlayerId, ChangeList) ->
	case erlang:is_pid(RoomPid) of
		true ->
			case erlang:is_process_alive(RoomPid) of
				true ->
					gen_fsm:send_all_state_event(RoomPid, {'player_base_info_change', PlayerId, ChangeList});
				_ ->
					skip
			end;
		_ ->
			skip
	end.

%% 检测是否在五人场 and 百人场是否有押注
check_room_pid() ->
	false.
	% NiuRoomInfo = player_niu_room_util:get_player_room_info(),
	% NiuRoomId = NiuRoomInfo#player_niu_room_info.room_id,
	% if
	% 	NiuRoomId == 0 ->
	% 		HundredRoomInfo = player_hundred_niu_util:get_player_room_info(),
	% 		HundredRoomId = HundredRoomInfo#player_niu_room_info.room_id,
	% 		if
	% 			HundredRoomId > 0 ->
	% 				{true, 'hundred', HundredRoomId, HundredRoomInfo#player_niu_room_info.room_pid};
	% 			true ->
	% 				false
	% 		end;
	% 	true ->
	% 		{true, 'niu', 0, NiuRoomInfo#player_niu_room_info.room_pid}
	% end.

log_by_player_id(PlayerId, Str, Param) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.id == PlayerId ->
			?INFO_LOG(Str, Param);
		true ->
			skip
	end.

%% 服务端常量表
get_server_const(Key) ->
	case ets:lookup(?ETS_CONST_CONFIG, Key) of
		[ConstInfo] ->
			ConstInfo#const_config.value;
		_ ->
			0
	end.

login_add_offline_reward() ->
	PlayerInfo = get_dic_player_info(),
	PlayerOfflineReward = niu_room_tool:get_player_offline_reward(PlayerInfo#player_info.id),
	if
		PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_diamond == 0 andalso
			PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_gold == 0 ->
			skip;
		true ->
			try
				RewardList1 = [{?ITEM_ID_GOLD, PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_gold},
					{?ITEM_ID_DIAMOND, PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_diamond}],
				RewardList = lists:filter(fun({_, Num}) -> Num =/= 0 end, RewardList1),

				{_, DBRewardFun, DBRewardSuccessFun, _} = item_use:transc_items_reward(RewardList, ?REWARD_TYPE_LOGIN_OFFLINE_REWARD),
				DBFun = fun() ->
					NewPlayerOfflineReward = PlayerOfflineReward#niu_room_offline_reward{
						total_offline_reward_gold = 0,
						total_offline_reward_diamond = 0
					},
					niu_room_offline_reward_db:t_write(NewPlayerOfflineReward),
					DBRewardFun()
								end,
				case dal:run_transaction_rpc(DBFun) of
					{atomic, _} ->
						DBRewardSuccessFun();
					_ ->
						?INFO_LOG("Error ~p", [{?MODULE, ?LINE}])
				end
			catch
				Error:Reason ->
					?ERROR_LOG(" handle event Error! ~n exception = ~p, ~n info = ~p~n",
						[{Error, Reason}, {?MODULE, ?LINE, PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_diamond, PlayerOfflineReward#niu_room_offline_reward.total_offline_reward_gold, erlang:get_stacktrace()}])
			end
	end.

get_player_gate_id(PlayerId) ->
	case ets:lookup(?ETS_ONLINE, PlayerId) of
		[EInfo] ->
			#ets_online{
				gate_pid = GatePid
			} = EInfo,
			GatePid;
		_ ->
			undefined
	end.

get_http_room_level_id() ->
	PreLevel = get(?NOW_ROOM_LEVEL),
	if
		PreLevel == undefined ->
			0;
		PreLevel > 0 andalso PreLevel =< 6 ->
			?HTTP_LOG_ROOM_TYPE_NIU + PreLevel;
		PreLevel == 10 ->
			?HTTP_LOG_ROOM_TYPE_REDPACK;
		PreLevel == 20 ->
			?HTTP_LOG_ROOM_TYPE_HUNDRED;
		PreLevel == 30 ->
			?HTTP_LOG_ROOM_TYPE_FRUIT;
		PreLevel == 31 ->
			?HTTP_LOG_ROOM_TYPE_SUPER_LABA;
		true ->
			0
	end.

change_name(Name) ->
	PlayerInfo = get_dic_player_info(),
	Name1 = unicode:characters_to_binary(Name),
	NewName = string:strip(lists:flatten(erlang:binary_to_list(Name1))),
	NewPlayerInfo = PlayerInfo#player_info{player_name = NewName},
	save_player_info(NewPlayerInfo),
	update_ets_online(NewPlayerInfo),
	cast_rank_player_base_info_change(NewPlayerInfo),
	check_update_room_player_info(PlayerInfo#player_info.id, [{'name', NewName}]),
	send_player_info().

real_name_authentication(Name,IdCardNum)->
	%%	?INFO_LOG("real_name_authentication"),
	PlayerInfo = get_dic_player_info(),
	OldInfo =
	case player_real_name_info_db:get(PlayerInfo#player_info.id) of
		{ok,[Info]}->
			Info;
		_->
			#player_real_name_info{
				player_id = PlayerInfo#player_info.id,
				type = 0
			}
	end,

	if
		OldInfo#player_real_name_info.type == 1 ->
			send_sc_real_name_update(1,"已实名认证过",[]);
		true ->
			NewInfo = OldInfo#player_real_name_info{
				type = 1
			},

			RewardNum = player_util:get_server_const(?CONST_CONFIG_KEY_REAL_NAME),
			{_NewPlayerInfo, DBFun1, SuccessFun1, PbReward} =
				item_use:transc_items_reward([{?ITEM_ID_GOLD, RewardNum}], ?REWARD_TYPE_REAL_NAME),
			%% ?INFO_LOG("real_name_authentication~p~n",[PbReward]),
			DbFun =
				fun() ->
					DBFun1(),
					player_real_name_info_db:t_write(NewInfo)
				end,
			DbSuccessFun =
				fun() ->
					SuccessFun1(),
					send_sc_real_name_update(0,"",PbReward),
					Msg = #sc_real_name_req{
						type = 1
					},
					tcp_client:send_data(get_dic_gate_pid(),Msg),
					http_static_util:post_verified(PlayerInfo,binary_to_list(Name),IdCardNum)
				end,
			case dal:run_transaction_rpc(DbFun) of
				{atomic, _} ->
					DbSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("save player info error! info = ~p stack = ~p", [?MODULE, Reason, erlang:get_stacktrace()]),
					send_sc_real_name_update(1,"数据库错误",[])
			end
	end.

send_sc_real_name_update(Result,Err,Rewards)->
	Msg = #sc_real_name_update{
		result = Result,
		err = Err,
		rewards = Rewards
	},
	tcp_client:send_data(get_dic_gate_pid(),Msg).

cs_real_name_req()->
	PlayerInfo = get_dic_player_info(),
	Type =
	case player_real_name_info_db:get(PlayerInfo#player_info.id) of
		{ok,[Info]}->
			Info#player_real_name_info.type;
		_->
			0
	end,
	Msg = #sc_real_name_req{
		type =Type
	},
	tcp_client:send_data(get_dic_gate_pid(),Msg).

handle_adreward() ->
	RewardItems = get_server_const(?CONST_CONFIG_KEY_ADREWARD_ITEM),
	{_NewPlayerInfo, DBFun, SuccessFun1, PbRewardInfo} = item_use:transc_items_reward(
		RewardItems, ?REWARD_TYPE_ADREWARD),
	SuccessFun = fun() ->
		SuccessFun1(),
		Msg = #sc_shop_buy_reply{
			result = 0,
			err_msg = "",
			rewards = PbRewardInfo,
			left_times = 99,
			id = 0
		},
		tcp_client:send_data(get_dic_gate_pid(), Msg)
	end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _}	->
			SuccessFun();
		{aborted, Reason}	->
			?ERROR_LOG("handle_adreward transc_items_reward FAIL!!! ~p~n", [{?MODULE, Reason}]),
			?INFO_LOG("handle_adreward transc_items_reward FAIL!!! ~p~n", [player_util:get_dic_player_info()]),
			Msg = #sc_shop_buy_reply{
				result = -1,
				err_msg = "DB failed",
				rewards = [],
				left_times = 0,
				id = 0
			},
			tcp_client:send_data(get_dic_gate_pid(), Msg)
	end.