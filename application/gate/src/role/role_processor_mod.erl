%% @author zouv
%% @doc @todo 玩家进程event逻辑分离

-module(role_processor_mod).

-include("common.hrl").
-include("role_processor.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(TIMER_TIME, 60000).        % 玩家进程定时器

-record(state, {
	gate_pid = undefined,
	player_id = 0,
	login_time = 0,
	login_repeat_time = 0
}).

-export([
	do_init/1,
	do_event/3,
	do_sync_event/4,
	do_info/3,

	cast/2,
	call/2,
	call/3,
	garbage_collect/1,
	check_timer_count/0
]).

do_init(PlayerInfo) ->
	NowSeconds = util:now_seconds(),
	#player_info{
		id = PlayerId
	} = PlayerInfo,
	erlang:send_after(1000, self(), {'timer', true, NowSeconds}),
	%% 改为登入后延迟发送后台数据
	erlang:send_after(1000, self(), {'http_syn_player_info', 1}),
	State =
		#state{
			player_id = PlayerId
		},
	{?STATE_NAME_GAMING, State}.

%% cast
cast(PlayerPid, Event) ->
	gen_fsm:send_all_state_event(PlayerPid, Event).

%% call
call(PlayerPid, Event) ->
	gen_fsm:sync_send_all_state_event(PlayerPid, Event).

call(PlayerPid, Event, Timeout) ->
	gen_fsm:sync_send_all_state_event(PlayerPid, Event, Timeout).

%% ------------------------------------------------------------------
%% do_event
%% ------------------------------------------------------------------
%% 异步逻辑处理
do_event({'handle', Module, Function, Args}, StateName, State) ->
	erlang:apply(Module, Function, Args),
	{next_state, StateName, State};

%% 设置网关进程：初始化GatePid
do_event({'set_gate_proc', GatePid, ProtyKey, _Flag, IsNewPlayer}, _StateName, #state{gate_pid = undefined} = State) ->
	NowSeconds = util:now_seconds(),
	PlayerInfo = player_util:get_dic_player_info(),
	player_util:set_gate_proc_handle(PlayerInfo, GatePid, ProtyKey, IsNewPlayer),
	NewState =
		State#state{
			gate_pid = GatePid,
			login_time = NowSeconds
		},
	{next_state, ?STATE_NAME_GAMING, NewState};

%% 设置网关进程：设置GatePid
do_event({'set_gate_proc', GatePid, ProtyKey, Flag, _}, StateName, State) ->
	NowSeconds = util:now_seconds(),
	PlayerInfo = player_util:get_dic_player_info(),
	player_util:update_dic_gate_pid(GatePid),
	player_util:update_ets_online(PlayerInfo),
	#state{
		gate_pid = OldGatePid
	} = State,
	case is_pid(OldGatePid) andalso erlang:is_process_alive(OldGatePid) of
		true when OldGatePid /= GatePid ->
			SocketBuffer = gen_fsm:sync_send_all_state_event(OldGatePid, {'close_old_gate_proc', PlayerInfo#player_info.last_login_ip, Flag}, 10000),
			gen_fsm:send_all_state_event(GatePid, {'update_socket_buffer', SocketBuffer});
		false ->
			SocketBuffer = player_util_procdict:get_dic_socket_buffer(),
			gen_fsm:send_all_state_event(GatePid, {'update_socket_buffer', SocketBuffer});
		_ ->
			skip
	end,
	player_util:send_login_reconnection_reply(GatePid, 1, "", ProtyKey),
	NewState =
		State#state{
			gate_pid = GatePid,
			login_repeat_time = NowSeconds
		},
	{next_state, StateName, NewState};

%% 网关中断
do_event({'close_gate_proc', SocketBuffer}, StateName, State) ->
	player_util_procdict:update_dic_socket_buffer(SocketBuffer),
	PlayerInfo = player_util:get_dic_player_info(),
	player_util:close_gate_proc_handle(PlayerInfo),
	player_laba_util:check_have_leave_room(),
	player_airlaba_util:set_leave(),
	%% 结束时也同步一次
	erlang:send(self(), {'http_syn_player_info', 0}),
	{next_state, StateName, State};

do_event({'stop', _Reason}, _StateName, State) ->
	{stop, normal, State};

%% 测试用
do_event({'test_event', Module, Function, Args}, StateName, State) ->
	erlang:apply(Module, Function, Args),
	{next_state, StateName, State};

%% 发消息
do_event({'send_data', Msg}, StateName, State) ->
	GatePid = player_util:get_dic_gate_pid(),
	tcp_client:send_data(GatePid, Msg),
	{next_state, StateName, State};

%% 通知有新邮件
do_event({'notify_have_mail', MailID}, StateName, State) ->
	player_mail:notify_have_mail(MailID),
	{next_state, StateName, State};


%% 玩家任务更新
do_event({'player_mission_update', MissionEvent}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			player_mission:handle_event(MissionEvent)
	end,
	{next_state, StateName, State};

%% 粘性红包更新
do_event({'player_stickiness_redpack_update', RoomType, TestType, Count}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			%?INFO_LOG("aaaaaaaaaaaa~p~n", [{RoomType, TestType, Count}]),
			player_stickiness_redpack:update(RoomType, TestType, Count)
	end,
	{next_state, StateName, State};

do_event({'player_bet_stickiness_update', RoomType, TestType, Count}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			player_bet_stickiness_redpack:update(RoomType, TestType, Count)
	end,
	{next_state, StateName, State};

do_event({'player_bet_lock_update', RoomType, TestType, Count}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			player_bet_lock:update(RoomType, TestType, Count)
	end,
	{next_state, StateName, State};

%%玩家商店更新
do_event({'player_shop_update'}, StateName, State) ->
	player_shop:send_player_shop_item_info(),
	{next_state, StateName, State};

%% 猜红包
do_event({'player_red_pack_notice_update', Id}, StateName, State) ->
	case red_pack_notice_db:get(Id) of
		{ok, [Info]} ->
			Info1 = player_redpack_util:packet_pb_notice(Info),
			player_redpack_util:send_red_pack_notice_update([Info1], []);
		_ ->
			skip
	end,
	{next_state, StateName, State};

%%发送魔法表情
do_event({'robot_send_magic_expression', {Time, RoomType, ContentType, Content, ObjPlayerId}}, StateName, State) ->
	erlang:send_after(Time * 1000, self(), {'robot_send_magic_expression_delay', RoomType, ContentType, Content, ObjPlayerId}),
	%{ok,Uid} = id_transform_util:item_id_to_proto(ObjPlayerId),
	%player_chat:cs_chat(RoomType, ContentType,Content,Uid),
	{next_state, StateName, State};

%% 充值
do_event({'pay_receive_handle', Id}, StateName, State) ->
	pay_util:pay_receive_handle(Id),
	{next_state, StateName, State};

% 看视频奖励
do_event({'handle_adreward'}, StateName, State) ->
	player_util:handle_adreward(),
	{next_state, StateName, State};

%% 同步红包检测
do_event({'check_redpack', EndSecond, NextOpenSecond}, StateName, State) ->
	player_redpack_room_util:do_update_redpack_draw_data(EndSecond, NextOpenSecond),
	{next_state, StateName, State};

%% 禁登
do_event({'login_forbid_state', Flag}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	NewPlayerInfo = PlayerInfo#player_info{login_forbid_state = Flag},
	DBFun = fun() -> player_info_db:t_write_player_info(NewPlayerInfo) end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			player_util:update_dic_player_info(NewPlayerInfo),
			case Flag of
				1 ->
					tcp_client:login_out(player_util:get_dic_gate_pid());
				_ ->
					skip
			end;
		_ ->
			?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}])
	end,
	{next_state, StateName, State};

%% 禁言
do_event({'chat_forbid_state', Flag}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	NewPlayerInfo = PlayerInfo#player_info{login_forbid_state = Flag},
	DBFun = fun() -> player_info_db:t_write_player_info(NewPlayerInfo) end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			player_util:update_dic_player_info(NewPlayerInfo);
		_ ->
			?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}])
	end,
	{next_state, StateName, State};

%% 同步红包检测
do_event({'syn_redpack_play_times', PlayTimes}, StateName, State) ->
	player_redpack_room_util:syn_redpack_play_times(PlayTimes),
	{next_state, StateName, State};

%% 分享任务
do_event({'send_share_mission_update', KeyList},StateName, State)->
	player_share_util:send_share_mission_done(KeyList),
	{next_state, StateName, State};

%% 分享任务-兑换
do_event({'do_share_mission',Type,Num},StateName, State)->
	case Type of
		'type_prize' ->
			PlayerInfo = player_util:get_dic_player_info(),
			player_share_util:do_share_mission_type_prize(PlayerInfo#player_info.id,Num);
		_->
			skip
	end,

	{next_state, StateName, State};

do_event({'send_share_mission_update_2', Missions},StateName, State)->
	player_share_util:send_share_mission_done_2(Missions),
	{next_state, StateName, State};

%%
do_event({'notice_robot_car_event', RoomState, Event, Date}, StateName, State) ->
  player_car_util:do_robot_behavior(RoomState, Event, Date),
  {next_state, StateName, State};

do_event({'car_player_enter', Content}, StateName, State) ->
  {ok, Uid} = id_transform_util:item_id_to_proto(0),
  player_chat:cs_chat(3, 4, Content, Uid),
  {next_state, StateName, State};

%% 设置黑名单
do_event({'set_niu_blacklist', NewPlayerData}, StateName, State) ->
	DBFun = fun() ->
		niu_blacklist_db:t_write(NewPlayerData)
	end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			ets:insert(?ETS_NIU_BLACKLIST, NewPlayerData);
		_ ->
			?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE}])
	end,
	{next_state, StateName, State};

do_event({'cs_rank_query_req',Type},StateName,State)->
	player_rank_util:cs_rank_query_req(Type),
	{next_state, StateName, State};

do_event({'close_robot_proc',undefined},_StateName,State)->
	{stop, normal, State};

do_event({'close_robot_proc',FromGatePid},StateName,State)->
	#state{
		gate_pid = OldGatePid
	} = State,
	case is_pid(OldGatePid) andalso erlang:is_process_alive(OldGatePid) andalso OldGatePid /= FromGatePid of
		true ->
			PlayerInfo = player_util:get_dic_player_info(),
			gen_fsm:sync_send_all_state_event(OldGatePid, {'close_old_gate_proc', PlayerInfo#player_info.last_login_ip, 'close_player_proc'});
		_ ->
			skip
	end,
	{next_state, StateName, State};

do_event({'update_7_day_carnival_mission',TaskId,Count},StateName,State)->
	player_7_day_carnival_util:update_7_day_carnival_mission(TaskId,Count),
	{next_state, StateName, State};

%% 玩家排行榜数据变动
do_event({'rank_change',PlayerId, RankType, NewData},StateName,State)->
	player_rank_util:rank_change(PlayerId, RankType, NewData),
	{next_state, StateName, State};

% 玩家下注工资变动
do_event({'et_statistics_bet', GameType, BetNum}, StateName, State) ->
	player_daily_salary:update_last_bet(GameType, BetNum),
	{next_state, StateName, State};
% 玩家累赢工资变动
do_event({'et_statistics_earn', GameType, EarnNum}, StateName, State) ->
	player_daily_salary:update_last_earn(GameType, EarnNum),
	{next_state, StateName, State};

%%#state{

%%{stop, normal, true, State};

%%
do_event(Event, StateName, State) ->
	?ERROR_LOG("~p event no match = ~p~n", [?MODULE, Event]),
	{next_state, StateName, State}.


%% ------------------------------------------------------------------
%% do_sync_event
%% ------------------------------------------------------------------
%% 同步逻辑处理
do_sync_event({'handle', Module, Function, Args}, _From, StateName, State) ->
	R = erlang:apply(Module, Function, Args),
	{reply, R, StateName, State};


%% 关闭玩家进程
%% 情况1：玩家断线后的N小时内，发起了第二次登录（此时，旧gate_proc已关闭）
%% 情况2：玩家异地重登（此时，旧gate_proc未关闭，需要通知被重复登陆）
do_sync_event({'close_player_proc', FromGatePid}, _From, _StateName, State) ->
	#state{
		gate_pid = OldGatePid
	} = State,
	case is_pid(OldGatePid) andalso is_pid(FromGatePid) andalso erlang:is_process_alive(OldGatePid) andalso OldGatePid /= FromGatePid of
		true ->
			PlayerInfo = player_util:get_dic_player_info(),
			gen_fsm:sync_send_all_state_event(OldGatePid, {'close_old_gate_proc', PlayerInfo#player_info.last_login_ip, 'close_player_proc'});
		_ ->
			skip
	end,
	{stop, normal, true, State};

%% 重连密码验证
do_sync_event({'check_reconnection_key', ClientReconnectKey}, _From, StateName, State) ->
	ReconnectKey = player_util_procdict:get_login_reconnection_key(),
	IsValid = ClientReconnectKey == ReconnectKey,
	PlayerInfo = player_util:get_dic_player_info(),
	Account = PlayerInfo#player_info.account,
	Reply = {IsValid, Account},
	{reply, Reply, StateName, State};

do_sync_event(Event, From, StateName, State) ->
	?ERROR_LOG("~p sync_event no match =~p ~p ~n", [?MODULE, Event, From]),
	{reply, ok, StateName, State}.

%% ------------------------------------------------------------------
%% do_info
%% ------------------------------------------------------------------
%% 定时器
do_info({'timer', IsInit, OldSeconds}, StateName, State) ->
	NowSeconds = util:now_seconds(),
	erlang:send_after(?TIMER_TIME, self(), {'timer', false, NowSeconds}),
	PlayerInfo = player_util:get_dic_player_info(),
	%% 隔天需刷新的操作通过其他管理进程通知处理
	if
		PlayerInfo#player_info.is_robot ->
			{_, {OldHour, _, _}} = util:seconds_to_datetime(OldSeconds),
			{_, {NewHour, _, _}} = util:seconds_to_datetime(NowSeconds),
			robot_util:check_beyond_robot_limit(OldHour, NewHour);
		true ->
			player_mission:handle_time(OldSeconds, NowSeconds),
			player_checkin:handle_time(OldSeconds, NowSeconds),
			player_shop:handle_time(OldSeconds, NowSeconds),
			player_winning_record:handle_time(OldSeconds, NowSeconds),
			player_golden_bull_util:handle_time(OldSeconds, NowSeconds),
			%% player_game_task_util:handle_timer(OldSeconds, NowSeconds),
			player_id_month_card:handle_timer(OldSeconds, NowSeconds),
			player_id_period_card:handle_timer(OldSeconds, NowSeconds),
			player_redpack_room_util:handle_time(OldSeconds, NowSeconds),
			%% player_prize_util:handle_time(OldSeconds, NowSeconds),
			player_subsidy_util:handle_time(OldSeconds, NowSeconds),
			player_niu_room_util:handle_timer(OldSeconds,NowSeconds),
			player_niu_room_chest:handle_timer(OldSeconds,NowSeconds),
			player_daily_salary:handle_time(IsInit, OldSeconds, NowSeconds),
			player_airlaba_util:handle_time(OldSeconds, NowSeconds),
			player_lottery_util:handle_time(OldSeconds, NowSeconds),
			check_timer_count()
	end,

	%% 离线检测

	if
		not PlayerInfo#player_info.is_robot ->
			check_offline_state();
		true ->
			skip
	end,

	%% 垃圾回收
	role_processor_mod:garbage_collect(NowSeconds),
	{next_state, StateName, State};

%% 延迟发送后台登入数据
do_info({'http_syn_player_info', Type}, StateName, State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	RedBagNum = item_use:get_player_item_num(?ITEM_ID_RED_PACK),
	PlayerWin = player_winning_record:get_player_winning_record_info_by_key('total_gains'),
	http_static_util:post_user_info(PlayerInfo, RedBagNum, Type, PlayerWin),
	Times = player_redpack_room_util:get_play_redpack_times(),
	CostNum = player_hundred_niu_util:get_hundred_niu_cost(),
	http_static_util:post_get_play_info(PlayerInfo,Times,CostNum),
	if
		Type == 1 ->
			http_static_util:post_inituser(PlayerInfo);
		true ->
			skip
	end,
	{next_state, StateName, State};

%% 机器人处理
do_info({'handle_robot_respond', Msg}, StateName, State) ->
	player_niu_room_util:send_msg_to_my_room(Msg),
	{next_state, StateName, State};

%% 机器人操作
do_info({'robot_behavior', 'set_chips', Data}, StateName, State) ->
	erlang:apply(player_hundred_niu_util, cs_hundred_niu_free_set_chips_req, Data),
	{next_state, StateName, State};

%% 延迟发送后台登入数据
do_info({'http_send_player_id_info_by_login'}, StateName, State) ->
	%PlayerInfo = player_util:get_dic_player_info(),
	%tools_operation:http_send_player_id_info_by_login(PlayerInfo#player_info.account, PlayerInfo#player_info.id, PlayerInfo#player_info.create_time),
	{next_state, StateName, State};

%% 延迟发送魔法表情
do_info({'robot_send_magic_expression_delay', RoomType, ContentType, Content, ObjPlayerId}, StateName, State) ->
	{ok, Uid} = id_transform_util:item_id_to_proto(ObjPlayerId),
	player_chat:cs_chat(RoomType, ContentType, Content, Uid),
	{next_state, StateName, State};

%% %% 补发一次统计
%% do_info({'do_http_request', ParamList}, StateName, State)->
%% 	%erlang:apply(http_static_util, post_url_base_one_time, ParamList),
%% 	{next_state, StateName, State};

%% 补发一次统计
do_info({http, {_RequestId, Result}}, StateName, State) ->
	case Result of
		{{_, 200, _}, _, Content} ->
			{ok, JsonData, _} = rfc4627:decode(Content),
			{ok, Code} = rfc4627:get_field(JsonData, "code"),
			case Code of
				1 ->
					{ok, Msg} = rfc4627:get_field(JsonData, "msg"),
					%PlayerInfo = player_util:get_dic_player_info(),
					io:format("Post Url ~p~n", [Msg]);
				_ ->
					skip
			end;
		_ ->
			skip
	end,
	%erlang:apply(http_static_util, post_url_base_one_time, ParamList),
	{next_state, StateName, State};

%%
do_info({'robot_bet', Pos, Gold}, StateName, State) ->
  player_car_util:cs_car_bet_req(Pos, Gold),
  {next_state, StateName, State};

do_info({'hundred_sitdown', SeatPos}, StateName, State) ->
	%?INFO_LOG("hundred_sitdown"),
	player_hundred_niu_util:cs_hundred_niu_sit_down_req(SeatPos),
	{next_state, StateName, State};


do_info('change_player_info',StateName,State)->
	PlayerInfo = player_util:get_dic_player_info(),
	gen_server:cast(rank_mod:get_mod_pid(), {'player_base_info_change', PlayerInfo}),
	{next_state, StateName, State};

do_info({priv_do_sync_state_db_buf}, StateName, State) ->
	player_airlaba_util:do_sync_state_db_buf(false),
	{next_state, StateName, State};

do_info(Info, StateName, State) ->
	?ERROR_LOG("~p info no match =~p ~p", [?MODULE, Info, StateName]),
	{next_state, StateName, State}.

% --------------------------------------------------------------------------------

garbage_collect(NowSeconds) ->
	MemoryLimit = 100000,
	{memory, Memory} = erlang:process_info(self(), memory),
	PlayerInfo = player_util:get_dic_player_info(),

%% 	if
%% 		PlayerInfo#player_info.id == 1000001->
%% 			?INFO_LOG("memory_num~p~n",[Memory]);
%% 		true->
%% 			skip
%% 	end,

	case Memory > MemoryLimit of
		true ->
%% 			if
%% 				PlayerInfo#player_info.is_robot ->
%% 					skip;
%% 				true ->
%% 					?INFO_LOG("~p~n",[erlang:process_info(self())])
%% 			end,
			player_util_procdict:update_dic_garbage_collect_time(NowSeconds),
			erlang:garbage_collect(self()),
			PlayerInfo = player_util:get_dic_player_info(),
			{memory, _NewMemory} = erlang:process_info(self(), memory);
%% 			?INFO_LOG("User_Process  garbage_collect >>>>>> PlayerId:~p ~n Old Memory: ~p ~n Now Memory: ~p", [PlayerInfo#player_info.id,
%% 				Memory, NewMemory]);
		_ ->
			skip
	end.

check_offline_state() ->
	NowSeconds = util:now_seconds(),
	GatePid = player_util:get_dic_gate_pid(),
	FunCheckGatePid =
		fun() ->
			if
				is_pid(GatePid) ->
					is_process_alive(GatePid);
				true ->
					false
			end
		end,
	%?INFO_LOG("check_offline_state !!!!!!!! ~p~n",[FunCheckGatePid()]),
	case player_util_procdict:get_dic_gate_proc_close_time() of
		Time when is_integer(Time) ->
			case FunCheckGatePid() of
				true ->
					player_util_procdict:update_dic_gate_proc_close_time(undefined);
				_ ->
					if
						NowSeconds > Time + ?TIME_BE_OFFLINE ->
							role_processor:stop(self(), 0);
						true ->
							skip
					end
			end;
		_ ->
			case FunCheckGatePid() of
				true ->
					skip;
				_ ->
					player_util_procdict:update_dic_gate_proc_close_time(NowSeconds)
			end
	end.


%% 同步玩家数据
check_timer_count() ->
	MinutesNum = 5,
	case get(timer_count) of
		MinutesNum ->
			erlang:send(self(), {'http_syn_player_info', 2});	%%2=同步数据
		_ ->
			skip
	end,
	NewCount =
		case get(timer_count) of
			undefined ->
				1;
			Count ->
				if
					Count+1 > MinutesNum ->
						1;
					true ->
						Count+1
				end
		end,
	put(timer_count, NewCount).