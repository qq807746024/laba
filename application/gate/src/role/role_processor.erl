-module(role_processor).

-behaviour(gen_fsm).

-include("role_processor.hrl").
-include("common.hrl").
-include("item.hrl").

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").

-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([
	start/1,
	start_link/1,
	stop/2,
	set_gate_proc/5,
	close_gate_proc/2,
	close_player_proc/2,
	close_robot_proc/1,
	send_gate_event/2,

	create_role/3,
	init_account_to_id/2,

	initialize/2,
	get_rand_head_icon/0,
	initialize_bag/1,
	generate_player_init_item/1,
	do_check_robot_leave_room/1
]).

%% ------------------------------------------------------------------
%% gen_fsm Function Exports
%% ------------------------------------------------------------------

-export([
	init/1,
	handle_event/3,
	handle_sync_event/4,
	handle_info/3,
	terminate/3,
	code_change/4,

	%% --- Module:StateName ---
	state_name_gaming/2,
	state_name_gaming/3
]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
start_link([PlayerId, Account, IsPlayerNew, ClientIP]) ->
	gen_fsm:start_link(?MODULE, [PlayerId, Account, IsPlayerNew, ClientIP], [{spawn_opt, [{fullsweep_after, 5000}]}]).

start([PlayerId, Account, IsPlayerNew, ClientIP, false]) ->
	gen_fsm:start(?MODULE, [PlayerId, Account, IsPlayerNew, ClientIP], [{spawn_opt, [{fullsweep_after, 1000}]}]);

start([PlayerId, Account, IsPlayerNew, ClientIP, true]) ->
	gen_fsm:start(?MODULE, [PlayerId, Account, IsPlayerNew, ClientIP], [{spawn_opt, [{fullsweep_after, 0}]}]).

stop(PlayerPid, Reason) ->
	role_processor_mod:cast(PlayerPid, {'stop', Reason}).

%% 设置网关
set_gate_proc(PlayerPid, GatePid, ProtyKey, Flag, IsNewPlayer) ->
	if
		is_pid(PlayerPid) ->
			role_processor_mod:cast(PlayerPid, {'set_gate_proc', GatePid, ProtyKey, Flag, IsNewPlayer});
		true ->
			skip
	end.

%% 网关中断
close_gate_proc(PlayerPid, SocketBuffer) ->
	role_processor_mod:cast(PlayerPid, {'close_gate_proc', SocketBuffer}).

%% 网关关闭玩家进程
close_player_proc(PlayerPid, FromGatePid) ->
	%?INFO_LOG("close_player_proc begin ~p~n", [{PlayerPid, FromGatePid, server_time:now_seconds()}]),
	role_processor_mod:call(PlayerPid, {'close_player_proc', FromGatePid}).
	%?INFO_LOG("close_player_proc finish ~p~n", [{PlayerPid, FromGatePid, server_time:now_seconds()}]).

%% 网关关闭机器人进程
close_robot_proc(PlayerPid) ->
	role_processor_mod:cast(PlayerPid, {'close_robot_proc', undefined}).

%% 协议处理
send_gate_event(PlayerPid, Event) ->
	gen_fsm:send_event(PlayerPid, Event).

%% ------------------------------------------------------------------
%% gen_fsm Function Definitions
%% ------------------------------------------------------------------
%% ==================================================
%% Module:init
%% ==================================================
init([PlayerId, IsPlayerNew, ClientIP, RLoginData]) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			?ERROR_LOG("start login second: ~p", [{PlayerPid, PlayerId, IsPlayerNew, ClientIP, RLoginData}]),
			stop(PlayerPid, 0),
			{stop, "start login second!"};
		_ ->
			%process_flag(trap_exit, true),
			ProcessName = misc:get_player_process_name(PlayerId),
			util_process:register_global(ProcessName, self()),
			util:init_rand_seed(),
			PlayerInfo = load_player_info(PlayerId, IsPlayerNew, ClientIP, RLoginData),
			%after_load_player_info(PlayerInfo, IsPlayerNew, ClientIP, RLoginData),
			{StateName, State} = role_processor_mod:do_init(PlayerInfo),
			{ok, StateName, State}
	end.

%% ==================================================
%% Module:handle_event
%% ==================================================
handle_event(Event, StateName, State) ->
	try
		role_processor_mod:do_event(Event, StateName, State)
	catch
		Error:Reason ->
			?ERROR_LOG(" handle event Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, Event, StateName, erlang:get_stacktrace()}]),
			{next_state, StateName, State}
	end.

%% ==================================================
%% Module:handle_sync_event
%% ==================================================
handle_sync_event(Event, From, StateName, State) ->
	try
		role_processor_mod:do_sync_event(Event, From, StateName, State)
	catch
		Error:Reason ->
			?ERROR_LOG(" handle sync_event Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, Event, StateName, erlang:get_stacktrace()}]),
			{next_state, StateName, State}
	end.

%% ==================================================
%% Module:handle_info
%% ==================================================
handle_info(Info, StateName, State) ->
	try
		role_processor_mod:do_info(Info, StateName, State)
	catch
		Error:Reason ->
			?ERROR_LOG(" handle sync_event Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason}, {?MODULE, ?LINE, Info, StateName, erlang:get_stacktrace()}]),
			{next_state, StateName, State}
	end.

terminate(_Reason, _StateName, _State) ->
	PlayerInfo = player_util:get_dic_player_info(),
	unload_player_info(PlayerInfo),
	ok.

code_change(_OldVsn, StateName, State, _Extra) ->
	{ok, StateName, State}.

%% ==================================================
%% Module:StateName
%% ==================================================
%% 主界面
state_name_gaming(Event, State) ->
	try
		state_event_handle(Event, ?STATE_NAME_GAMING, State)
	catch
		Error:Reason ->
			?ERROR_LOG(" gate_event handle Error! ~n exception = ~p, ~n info = ~p~n", [{Error, Reason}, {?MODULE, ?LINE, Event, erlang:get_stacktrace()}]),
			{next_state, ?STATE_NAME_GAMING, State}
	end.

state_name_gaming(Event, From, State) ->
	?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, ?STATE_NAME_GAMING, Event, From, State}]),
	{reply, reply_ok, ?STATE_NAME_GAMING, State}.


%% 状态-事件处理
state_event_handle(Event, NowStateName, State) ->
	case Event of
	%% 玩家操作
		{'gate_event_player', Msg} ->
			NextStateName = ge_player:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_niu_room', Msg} ->
			NextStateName = ge_niu_room:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_hundred', Msg} ->
			NextStateName = ge_hundred_niu:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_laba', Msg} ->
			NextStateName = ge_laba:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_shop', Msg} ->
			NextStateName = ge_shop:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_prize', Msg} ->
			NextStateName = ge_prize:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_redpack',Msg}->
			NextStateName = ge_redpack:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_car',Msg}->
			NextStateName = ge_car:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_share',Msg}->
			NextStateName = ge_share:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		{'gate_event_activity',Msg}->
			NextStateName = ge_activity:handle(Msg, NowStateName),
			{next_state, NextStateName, State};
		_ ->
			?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Event, NowStateName}]),
			{next_state, NowStateName, State}
	end.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------
%% 加载玩家数据
load_player_info(PlayerId, IsPlayerNew, ClientIP, RLoginData) ->
	%tools:eprof_add(self()),
	NowSeconds = util:now_seconds(),
	%% 初始化玩家信息
	PlayerInfo = initialize_player_info(PlayerId, NowSeconds, ClientIP,RLoginData),
	initialize_player_uid(PlayerId, RLoginData#r_login_data.uid),

	%% 生成新帐号背包物品
	if
		IsPlayerNew == true ->
			IsAlreadyRewardPhone =
				case RLoginData#r_login_data.is_phone_login of
					1 ->
						true;
					_ ->
						false
				end,
			log_util:add_item_use(PlayerInfo, ?REWARD_TYPE_NEWBIE_REWARD, PlayerInfo#player_info.id,
				[{?ITEM_ID_GOLD, PlayerInfo#player_info.gold}, {?ITEM_ID_DIAMOND, PlayerInfo#player_info.diamond}]),

			generate_player_init_item(PlayerId),
			player_util_procdict:update_dic_is_new_player(IsPlayerNew);
		true ->
			IsAlreadyRewardPhone = false,
			sip
	end,

	%% 记录渠道
	player_chnid_info_db:write(#player_chnid_info{player_id = PlayerId,chnid = RLoginData#r_login_data.chnid}),
	player_share_binding_info_db:write(#player_share_binding_info{player_id = PlayerId,share_player_id = RLoginData#r_login_data.sub_chnid}),

	%% 初始化背包
	BagDict = initialize_bag(PlayerId),
	item_util:update_dic_player_bag_dict(BagDict),

	%player_niu_room_util:init_player_room_data(PlayerId),
	%胜负记录
	player_winning_record:init_player_winning_record_info(PlayerId),
	%签到
	player_checkin:init_player_checkin_info(PlayerId),
	% vip
	player_vip_util:init_player_vip(PlayerId),
	%player_hundred_niu_util:init_player_room_data(PlayerId),
	player_laba_util:init(PlayerId),
	%player_airlaba_util:init(PlayerId),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		true ->
			%任务
			player_mission:login_initialize(),
			%对局宝箱
			player_niu_room_chest:init_info(PlayerId),
			%商店
			player_shop:init_player_shop(PlayerId),
			%% 兑换奖励
			player_prize_util:init(PlayerId),
			%% 金牛
			player_golden_bull_util:init(PlayerId),
%%			%% 游戏任务
%%			player_game_task_util:init(PlayerId),
			%% 红包任务
			player_pack_task:init(PlayerId),
			%% 绑定手机号
			player_util:check_init_phone_bind_info(PlayerId, RLoginData#r_login_data.is_phone_login, IsAlreadyRewardPhone),
			%% 分享
			player_share_util:init_player_share_info(PlayerId),
			%% 每日兑换红包获得金币
			player_prize_util:init_first_prize_reward(PlayerId),
			%% 7日狂欢
			player_7_day_carnival_util:init_7_day_carnival_info(PlayerId),
			%% 一本万利
			player_pay_activity_util:init_player_pay_activity_info(PlayerId),
			%% 排行榜
			player_rank_util:init_player_rank_info()
	end,

	%% 豪车
	%player_car_util:init_player_room_data(PlayerId),
	%% 红包玩
	%player_redpack_room_util:init_play_redpack_times(PlayerId),
	%% 百人消耗和拉霸
	%player_hundred_niu_util:init_hundred_niu_cost(PlayerId),
	% 玩家统计
	player_statistics_util:init_statistics(PlayerId),
	PlayerInfo.


%after_load_player_info(PlayerInfo, _IsPlayerNew, _ClientIP, _RLoginData) ->
%    PlayerId = PlayerInfo#player_info.id,
%    %% 日志相关
%    %log_util:add_login(PlayerInfo, ClientIP, RLoginData),
%    %log_util:add_player_data_update_new_player(PlayerInfo),
%    %log_util:add_ets_channel_count(PlayerId),
%    %% 注册邮件系统
%    %mail_system_mod:cast_player_login(PlayerId, PlayerInfo#player_info.create_time),
%    %player_util:make_up_for_ios_break_1(PlayerId, IsPlayerNew),
%    ok.

%% 卸载玩家数据
unload_player_info(PlayerInfo) ->
	PlayerId = PlayerInfo#player_info.id,
	role_manager:login_out(PlayerId, self()),

	%% 通知棋牌进程离开房间
%%	do_check_robot_leave_room(PlayerInfo),
	%player_niu_room_util:leave_room(),
	%player_hundred_niu_util:leave_room(),
	%player_car_util:cs_car_exit_req(),

	%% 网关关闭
	case player_util:get_dic_gate_pid() of
	%% 通过注销退出
		GatePid when is_pid(GatePid) ->
			player_util:close_gate_proc_handle(PlayerInfo);
		_ ->
			skip
	end.

do_check_robot_leave_room(PlayerInfo) ->
	if
		PlayerInfo#player_info.is_robot ->
			if
				PlayerInfo#player_info.robot_cls == 0 ->
					gen_server:cast(robot_manager:get_mod_pid(), {'robot_logout', PlayerInfo#player_info.id});
				true ->
					skip
			end;
		true ->
			skip
	end.

create_role(PlayerId, Account, RLoginData) ->
	NowSeconds = util:now_seconds(),
	PlayerName = name_util:make_player_name(),
	Icon = RLoginData#r_login_data.player_icon,

	% 初始化金币
	BindPhoneFlag = RLoginData#r_login_data.is_phone_login,
	if
		BindPhoneFlag == 1 ->
			[{_, AddGold}] = player_util:get_bind_phone_num_reward();
		true ->
			AddGold = 0
	end,
	InitialGold = player_util:get_server_const(?CONST_CONFIG_KEY_CREATE_ROLE_GOLD) + AddGold,

	% 初始化钻石
	InitialDiamond = player_util:get_server_const(?CONST_CONFIG_KEY_CREATE_ROLE_DIAMOND),
	if
		Icon == "0" ->
			PlayerInfo =
				#player_info{
					id = PlayerId,
					account = Account,
					player_name = PlayerName,
					gold = InitialGold,
					diamond = InitialDiamond,

					exp = 0,
					level = 1,
					create_time = NowSeconds
				};
		true ->
			PlayerInfo =
				#player_info{
					id = PlayerId,
					account = Account,
					gold = InitialGold,
					diamond = InitialDiamond,

					exp = 0,
					level = 1,
					icon = Icon,
					player_name = RLoginData#r_login_data.player_name,
					sex = RLoginData#r_login_data.sex,
					create_time = NowSeconds
				}
	end,
	depot_manager_mod:add_to_depot(-InitialGold),
%%	add_to_rank(PlayerInfo),
	player_info_db:write_player_info(PlayerInfo).

init_account_to_id(PlayerId, Uid) ->
	UidInfo =
		#account_to_player_id{
			player_id = PlayerId,
			account = Uid
		},
	account_to_player_id_db:write(UidInfo),
	UidInfo.

initialize(IsNewPlayer,IsRobot) ->
	send_init_role_info(),
	%player_niu_room_util:send_init_msg(),

	if
		IsRobot ->
			player_subsidy_util:send_update_info();
		true ->
			player_shop:send_player_shop_item_info(),
			player_checkin:send_init_msg(),
			player_subsidy_util:send_update_info(),
			player_subsidy_util:send_update_info(),
			player_mail:send_player_login(),
			player_prize_util:send_init_msg(),
			player_redpack_util:send_player_login_red_pack_notice(),
			player_golden_bull_util:send_init_msg(),
			player_guide_util:send_init_msg(),
			player_id_month_card:send_init_msg(),
			player_id_period_card:send_init_msg(),
			player_activity_util:send_init_msg(),
			player_util:send_player_phone_info(),
			player_share_util:send_login_info(),
			player_util:send_login_proto_complete(IsNewPlayer),
			player_7_day_carnival_util:send_init_msg(),

			%% 充值
			pay_util:handle_already_receive_pay_info(),
			%% 离线奖励 ( 正常情况=0 )
			player_util:login_add_offline_reward()
	end,



	%% 机器人操作记录
	%robot_util:init1(),
	ok.


%% 客户端协议更新（初始化需要的协议）
send_init_role_info() ->
	player_util:send_player_info(),
	item_util:send_bag_update(),

	player_mission:send_player_login(),

%%	player_rank_util:send_recharge_info(),
	ok.


%% 初始化玩家信息
initialize_player_info(PlayerId, NowSeconds, ClientIP,RLoginData) ->
	PlayerInfo = player_info_db:get_player_info(PlayerId),

	if
		RLoginData#r_login_data.player_icon == "0"->
			NewPlayerInfo =
				PlayerInfo#player_info{
					login_time = NowSeconds,
					last_login_ip = ClientIP
				};
		true ->
			erlang:send_after(3*1000,self(),'change_player_info'),
			NewPlayerInfo =
				PlayerInfo#player_info{
					login_time = NowSeconds,
					last_login_ip = ClientIP,
					icon = RLoginData#r_login_data.player_icon,
					player_name = RLoginData#r_login_data.player_name,
					sex = RLoginData#r_login_data.sex
				}
	end,
	%% 保存玩家信息
	DbFun =
		fun() ->
			player_info_db:t_write_player_info(NewPlayerInfo)
		end,
	DbSuccessFun =
		fun() ->
			player_util:update_dic_player_info(NewPlayerInfo)
		end,
	case dal:run_transaction_rpc(DbFun) of
		{atomic, _} ->
			DbSuccessFun();
		{aborted, Reason} ->
			?ERROR_LOG("~p initialize player info error! info = ~p~n", [?MODULE, Reason])
	end,
	NewPlayerInfo.

initialize_player_uid(PlayerId, Uid) ->
	case account_to_player_id_db:get_base(PlayerId) of
		{ok, [UidInfo]} ->
			player_util_procdict:update_dic_player_uid(UidInfo);
		_ ->
			UidInfo = init_account_to_id(PlayerId, Uid),
			player_util_procdict:update_dic_player_uid(UidInfo)
	end.


%% 初始化背包信息
initialize_bag(PlayerID) ->
	ItemList = player_items_db:get_player_item_list(PlayerID),
	NewItemList =
		util:foldl(fun(Element, Acc0) ->
			[{Element#player_items.entry, Element} | Acc0]
		end,
			[],
			ItemList),
	dict:from_list(NewItemList).

%% 生成新帐号背包物品
generate_player_init_item(PlayerId) ->
	%List = base_player_init_bag_db:get_list(),
	List = [{?ITEM_ID_CHANGE_NAME_CARD, 1}],
	ItemList =
		lists:map(fun({EntryId, ENum}) ->
			item_util:create_item_info(PlayerId, EntryId, ENum)
		end, List),
	generate_player_init_item1(ItemList).


generate_player_init_item1([]) ->
	ok;
generate_player_init_item1([E | L]) ->
	player_items_db:write_player_items(E),
	generate_player_init_item1(L).

get_rand_head_icon() ->
	TableSize = mnesia:table_info(player_head_icon, size),
	Id = util:rand(1, TableSize),
	case player_head_icon_db:get_base(Id) of
		{ok, [IconInfo]} ->
			IconInfo#player_head_icon.texture;
		_ ->
			?PLAYER_ICON_DEFAULT
	end.


%%add_to_rank(PlayerInfo) ->
%%	if
%%		PlayerInfo#player_info.is_robot ->
%%			skip;
%%		true ->
%% 			FreshTime = 9999999999999 - util:now_long_seconds(),
%% 			DiamondNum =
%% 				case PlayerInfo#player_info.is_robot of
%% 					true ->
%% 						0;
%% 					_ ->
%% 						PlayerRankInfo2 =
%% 							#player_hundred_rank_info{
%% 								player_id = PlayerInfo#player_info.id,			% 玩家ID
%% 								name = PlayerInfo#player_info.player_name,
%% 								icon = PlayerInfo#player_info.icon,
%% 								vip = PlayerInfo#player_info.vip_level,
%% 								sex = PlayerInfo#player_info.sex,
%% 								hundred_win_one_round = 0,
%% 								hundred_win_total = 0,
%% 								fresh_time_1 = FreshTime,	%% 刷新数据时间
%% 								fresh_time_2 = FreshTime,	%% 刷新数据时间
%% 								is_robot = PlayerInfo#player_info.is_robot
%% 							},
%% 						gen_server:cast(hundred_week_board_mod:get_mod_pid(), {'create_player_rank_info', PlayerRankInfo2}),
%% 						PlayerInfo#player_info.diamond
%% 				end,
%%			rank_mod:update_rank(type_gold, PlayerInfo#player_info.id, PlayerInfo#player_info.gold),
%%			rank_mod:update_rank(type_diamond, PlayerInfo#player_info.id, PlayerInfo#player_info.diamond)
%%	end.
