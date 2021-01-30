%% 定义临时数据结构

-ifndef(RECORD_HRL).
-define(RECORD_HRL, true).

-include("predef.hrl").

%% 在线玩家(gate_pid有效)
-record(ets_online, {
	player_id = 0,
	player_name = "",
	player_pid = undefined,
	player_level = 0,
	player_icon = "",
	gate_pid = undefined,
	gate_time = 0
}).

%% 在线玩家pid
-record(ets_role_pid, {
	player_id = 0,
	player_pid = undefined
}).

%% 客户端登陆数据
-record(r_login_data, {
	platform_flag = 0,
	openid = "",
	uid = "",
	version = "",
	network_type = "",
	sys_type = 0,
	chnid = 0,
	sub_chnid = 0,
	ios_idfa = "",
	ios_idfv = "",
	mac_address = "",
	device_type = "",
	is_phone_login = 0,
	player_name = "",
	player_icon = "0",
	sex =0
}).

%% 数据库服务器信息结构体
-record(mysql_server_info, {
	host = "127.0.0.1",                   %服务器地址
	port = 3306,                          %端口
	user = "root",                        %账号
	password = "root",                    %密码
	database = "statistics"               %数据库
}).

%% 玩家进程定时器
-record(player_timer, {
	be_offline_timer_ref = undefined

}).

%% 玩家牛牛房间相关信息
-record(player_niu_room_info, {
	player_id = 0,
	room_id = 0,
	room_pid,
	is_robot = false
}).

%% 玩家牛牛房间相关信息
-record(niu_room_info, {
	room_id = 0,
	room_level = 0,
	room_pid,

	player_list = [],        %% niu_room_player_rec {user_id,pos, []}
	master_id = 0,
	ticket_cost = 0,        %% 入场费用
	threshold_info = {0, 0},    %% 门槛

	state = 0, %% 0=idle
	end_sec_time = 0        %% 结束时间
}).


%% 玩家结构 注意结构不能改变
-record(niu_room_player_rec, {
	player_id,
	pos,
	card_list = [],    %% { number , color}
	rate_master = 0,    %% 设置的倍率
	rate_master_set_flag = false,        %% 已设置的标记

	rate_free = 0,
	rate_free_set_flag = false,


	show_card_flag = false,        %% 是否已出牌型
	show_card_list = [],        %%玩家布置的牌型
	biggest_card_info = {0, 0},        %% 最大牌
	card_type = 0,        %% 牌型

	last_reward_num = 0,        %% 上把奖的金币数
	now_gold_num = 0,

	last_reward_diamond_num = 0,        %% 上把奖的钻石数
	tax  = 0,    %%税
	now_diamond_num = 0,  %% 当前钻石
	continue_play_times = 0,		%% 红包场使用 连玩次数

	icon_str = "",
	player_name = "",
	vip_level = 0,
	sex = 0,

	leave_flag = false,    %%是否退出 或 离线( 在游戏中只标记 结算时踢出)
	is_robot = false, %% 是否机器人
  	test_type = 0 %% 是否试玩场
}).

%% 创建机器人需要的数据
-record(niu_room_robot_data, {
	player_id,
	name,
	level,
	gold_num,
	diamod_num,
	icon,
	vip_level,
	recharge_rmb = 0,
	account_id,
	cls = 0,    %% 0=普通 1=百人庄家机器人(不载入分配机器人容器中)
	sex = 1
}).

-record(ets_mission_base, {
	key,
	mision_base_list = []
}).

%%%%%%%%%%%%%
%% 百人牛牛房间相关信息
-record(hundred_niu_room_info, {
	room_id = 0,
	room_pid,

	player_count = 0,   %% 玩家总数
	reward_pool_num = 0,
	rank_reward_pool_num = 0,

	master_id = 0,  %% 庄家
	last_master_id = 0,        %% 上次庄家id
	master_continuous = 0,        %% 连庄次数

	total_set_chips_list = [],        %% 总押注列表
	card_list = [],    %% 5个位置牌信息
	card_win_list = [],    %% 4个位置 输赢信息
	settlement_data = [],        %% 结算数据 [{0, xx}, {1,xx}, ........    {7,xx}    ]
	pool_reward_info = [],    %% 奖池奖励数据 当中奖时有用

	state = 0, %% 0=idle
	end_sec_time = 0        %% 结束时间
}).

%% 百人玩家ets数据结构
-record(ets_hundred_niu_player_info, {
	player_id,
	account_id = "",
	player_icon,
	player_level,
	player_vip_level,
	player_name,
	sex = 0,        %% 0男1女
	seat_pos,    %% 1-7闲家 0庄家
	is_on_seat,    %% 是否在座位上 0-6

	in_master_list = false,    %% 是否庄家列表中的
	enter_master_list_time = 0,        %% 进入上庄列表时间

	gold = 0,        %% 金币
	set_chips = [],    %% {pos, num}
	set_1_flag = false,        %% 一局中押了1位置便置true
	set_2_flag = false,
	set_3_flag = false,
	set_4_flag = false,

	win_settle_num = 0,    %% 上次结算赢钱
	last_settle_profit = 0,    %% 上次盈利 用于统计排行榜
	win_pool_num = 0,    %% 上次赢奖池钱数
	tax = 0, 					% 税（用作后台统计）

	leave_flag = false,
	is_robot = false,
	robot_cls = 0,

	master_use_gold = 0,  %% 上庄携带金额
	master_save_gold = 0,    %% 庄家没压下的部分金币
	
  	test_type = 0 %% 是否是试玩场玩家
}).

%% 百人玩家ets数据结构
-record(ets_hundred_win_rec, {
	id,
	record = [],
	win_pool_pos_list = []
}).

%% 玩家拉霸相关信息
-record(ets_laba_player_info, {
	player_id = 0,
	is_robot = false,%,
	is_in_airlaba = false,
	test_type = 0
	%name = "",
	%icon = "",
	%vip = 0,
	%gold_num = 0
}).

%% 排行榜
-record(ets_rank_player_info, {
	key, %% {data, fresh_time, player_id}
	player_id = 0,
	name = "",
	icon = "",
	vip = 0,
	sex = 1,
	account = "",

	gold_num = 0,
	win_gold = 0,
	diamond_num = 0,

	hundred_total_win = 0,	%% 总盈利
	hundred_one_round_win = 0,	%%单局盈利

	rank = 0,
	is_robot = false
}).

-record(ets_player_red_pack_search_key, {
	player_id,
	key
}).

%% 统计用
-record(log_item_r, {
	player_id,
	item_id,
	place,
	num
}).

%% 百人机器人
-record(ets_robot_data, {
	robot_id,            %% = playerid
	is_on_line = false,    %% true=在线
	is_in_room = false,        %% true=在房间
	is_in_entering = false,        %% 被选中后设置成true
	last_enter_second = 0,    %% 5分钟回收一次超时10s
	gold_level = 0,    %% 金币等级

	%% 机器人离开房间后修改金币等级 和 flag
	gold_level_0 = false,
	gold_level_1 = false,
	gold_level_2 = false,
	gold_level_3 = false,
	gold_level_4 = false,
	gold_level_5 = false,
	gold_level_6 = false
}).

%% 百人 游戏任务数据
-record(game_task_data, {
	reward_num,
	set_chips,
	card_type_list,
	rate_list = []
}).

%% 红包任务信息结构
-record(pack_task_info, {
	game_type,
	toal_gold = 0,
	draw_list = []
}).

%%%%%%%%%%%%%%
%% mysql log
-record(ets_mysql_log_gm_oprate, {
	log_type = "",    %% log类型
	time_date,        %% 日期
	dsc = ""
}).

-record(ets_mysql_log_item_use, {
	log_type = "",    %% log类型
	time_date,        %% 日期
	role_id = 0,
	item_id = 0,
	item_num = 0
}).
%%%%%%%%%%%%%%

-record(ets_share_code,{
	code = 0,
	player_id = 0
}).

%%%%%%%%%%%%%
%% 豪车房间相关信息
-record(car_room_info, {
	room_id = 0,
	room_pid,

	player_count = 0,   %% 玩家总数
	reward_pool_num = 0,
%%
	master_id = 0,  %% 庄家
%%	last_master_id = 0,        %% 上次庄家id
	master_continus = 0,        %% 连庄次数
	master_score = 0,
%%	master_waiting_list = [],    %%排庄列表
%%
	total_bet_list = [],        %% 总押注列表
	player_bet_list = [],    %% 玩家压注列表
	robot_bet_list = [], %%机器人
	result = {0,0},
%%	card_list = [],    %% 5个位置牌信息
%%	card_win_list = [],    %% 4个位置 输赢信息
%%	settlement_data = [],        %% 结算数据 [{0, xx}, {1,xx}, ........    {7,xx}    ]
%%	pool_reward_info = [],    %% 奖池奖励数据 当中奖时有用
%%
	state = 0, %% 0=wait,1 = start, 2 = bet, 3 = cal
	time = 0        %% 结束时间
}).

%% 豪车玩家ets数据结构
-record(ets_car_player_info, {
	player_id,
	account_id = "",
	player_icon,
	player_level,
	player_vip_level,
	player_name,
	seat_pos = 1,  % 0 - 庄，1-闲
	sex = 0,        %% 0男1女
	in_master_list = false,    %% 是否庄家列表中的
	enter_master_list_time = 0,        %% 进入上庄列表时间

	gold = 0,        %% 金币
	bet_list = [],    %% {pos, num}
	gold_use = 0,
	gold_get = 0,
	pool_get = 0, % !FIXME 奖池排行榜有用到该字段，如果修改了 record 的顺序，请修改对应代码！
	pool_add = 0,
	rank_pool_add = 0,
	tax = 0,

	leave_master_flag = false,
	leave_flag = false,
	is_robot = false,
 	robot_cls = 0,

	master_save_gold = 0,    %% 庄家没压下的部分金币
  	master_up_gold = 0,    %% 庄家压下的部分金币
	test_type = 0 % 场次类型
}).

%% 豪车ets胜负数据结构
-record(ets_car_win_rec, {
	id,
	result = 0,
	pool = 0
}).

%% ets福袋池结构
-record(ets_lucky_bag, {
	id,
	num = 0
}).

%%
-record(ets_data, {
	key,
	value = 0
}).

-record(ets_lottery_reward_items, {
	index, reward_items
}).

-endif.