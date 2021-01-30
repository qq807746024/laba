%% 定义表记录结构
%%
%% --- 表命名规范 ---
%% 基础表：
%% base_
%%
%% 玩家表：
%% player_

-ifndef(MNESIA_TABLE_DEF_HRL).
-define(MNESIA_TABLE_DEF_HRL, true).

-include("../../gate/include/logger.hrl").

%% 账号 玩家id 对应表
-record(account_to_player_id, {
	account = "",
	player_id = 0
}).

%% 自增Id
-record(id_max, {id_type, max_value}).

%% 服务端常量表
-record(const_config, {
	key,
	value,
	desc
}).

%% 玩家信息
-record(player_info, {
	id = 0,                            % Id
	account = "",                    % 帐号
	player_name = "",                % 玩家昵称
	gold = 0,                        % 金币
	diamond = 0,                	% 剩余钻石数
	cash = 0,
	recharge_money = 0,
	vip_level = 0,

	exp = 0,                  		% 当前经验值
	level = 1,                		% 玩家等级
	total_exp = 0,            		% 玩家经验的总数

	icon = "",                		% 玩家头像
	create_time = 0,            	% 帐号创建时间
	sex = 0,		%% 性别

	login_time = 0,            		% 上线时间
	logout_time = 0,            	% 下线时间
	last_login_ip = "",        		% 最后一次登录IP

	is_robot = false	,	%% 是否机器人
	robot_cls = 0,		%% 0=普通 1=百人庄家 2=豪车庄家
	guide_step_id = 0,	%% 新手引导id

	login_forbid_state = 0,	%% 禁登=1
	chat_forbid_state = 0	%% 禁言=1
}).

%% 物品信息
-record(player_items, {
	id = 0,                    % 物品Id
	player_id = 0,
	entry = 0,               % BaseId
	count = 0,

	create_time = 0
}).

%% 物品配置
-record(item_base, {
	id = 0,
	name = "",
	cls = 0,	%% 分类
	limit_num	%% 堆叠大小
}).

%% VIP配置
-record(base_vip, {
	level = 0,
	next_lv = 0,            % 下个等级
	upgrade_exp = 0,        % 升级需求的总经验
	daily_login_reward =[]   %每日登陆赠送
}).

-record(player_vip_daily_reward,{
	player_id,
	daily_reward_draw_time = 946656000 %最后领取每日礼包时间
}).
%% ========================= 充值用表 =========================
%% 已经到达的充值
-record(already_receive_pay_info, {
	id,
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
}).

%% 已经入账户的交易
-record(already_enter_pay_info, {
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
}).

-record(already_player_id_pid_to_count, {
	player_id_pid,
	player_id,
	pid,
	count
}).

%%  充值配置表
-record(base_vip_recharge, {
	p_id,             %% id
	type,             %% 充值类型
	name,             %% 商品名称
	icon,             %% 商品纹理
	price,            %% 售价
	keep_time,        %% 订阅持续时间
	award_base,       %% 基础奖励
	award_everyday,   %% 订阅每日奖励
	first_extra,      %% 首次额外奖励
	not_first_extra,  %% 非首次额外奖励
	first_str,        %% 首次描述
	no_first_str      %% 非首次描述
}).

%% 公告配置
-record(announcement, {
	id,
	type,
	condition,
	content
}).


%%  主角随机名
-record(player_name_random_info, {
	id,                    %%序列
	family_name,        %%姓
	sex                %%名
}).

%% 玩家升级信息表
-record(player_level_upgrade_base, {
	level,                	% 等级
	upgrade_exp            % 升级经验
%% 	award_silver,        	% 升级奖励金币
%% 	award_gold,            	% 升级奖励钻石
%% 	open_function,        	% 开启功能
%% 	award_item_id			% 功能开启领奖礼包
}).

%主角头像表
-record(player_head_icon, {
	id,			%文理
	texture		%开启状态
}).

%% 邮件
-record(mail, {
	mail_id,                  %%  邮件ID
	from_id = 0,              %%  发邮件的player ID( 玩家暂时不能发邮件.  )
	to_id,                    %%  发给谁的player_ID

	mail_cls = 0,			%% 邮件类别
	mail_category = 0,        %%  系统功能Log发送的邮件

	title = "",               %%  邮件标题
	content = "",             %%  邮件内容
	rewards = [],             %%
	read_flag = false,		%% 领取后删除该邮件记录
	expire_time =  0,       %%    到期时间,
	receive_time = 0       %%    接收时间,
}).

%% 牛牛 房间 玩家离线奖励
-record(niu_room_offline_reward, {
	player_id,
	total_offline_reward_gold = 0,
	total_offline_reward_diamond = 0
}).

-record(player_winning_record_info,{
	player_id ,
	win = 0,        %胜
	lose = 0,       %负
	niu_niu_times = 0, %牛牛次数
	si_zha_times = 0,  %四炸次数
	wu_hua_niu_times = 0, %五花牛次数
	wu_xiao_niu_times = 0, %五小牛次数
	san_pai_times = 0,   %散牌次数
	total_gains = 0,    %总盈利
	this_week_gains = 0, %本周盈利
	max_money = 0,   %最大金币
	last_time = 0,   %最近进行牌局时间

	room_level_gold_list = [],	%% {RoomLevel, Num}
	hundred_total_win = 0	%% 百人总盈利
}).
%%------bug反馈----------
-record(bug_info,{
	bug_id,
	player_id ,
	time = 0,
	str_content = []  %内容
}).
%%-------------------------
%% 商店物品随机表(临时) 按时间放入ets表中

%%---------商店-----------
%% 商店物品随机表(临时)
-record(base_shop_item, {
	id,                    %编号
	shop_type,            %商城类型
	item_id,            %物品id
	item_num,            %物品数量
	item_extra_num,      %额外获得数量
	cost_list = [],      %[消耗货币类型,消耗货币数]
	discount,        		%折扣
	special_flag = [],  %1-特惠，2-热卖，3-限时
	start_time,          %出现时间
	end_time,             %结束时间
	limit_condition = [],      %限制次数，{num,refresh}num=99没有限制,refreash 0不刷新，1刷新
	name,										%商品名称
	tex,										%商品纹理
	sort,										%商品排序
	vip_limit,               %vip 等级限制
	player_lv_ignore_cost = [] % 和 cost_list 格式一致
}).
%%玩家购买信息
-record(player_buy_info,{
	player_id,
	limit_item = []   %%{key,id,num,refresh,time}
}).
%%---------------------------------
%% 玩家补助信息
-record(player_subsidy_info, {
	player_id,
	last_date_draw_times = 0,  %%破产补助次数
	last_date = 946656000,			%%破产补助领取时间

	special_last_date_draw_time =0, %%破产特别补助次数
	special_last_date = 946656000,  	%%破产特别补助领取时间
	is_share = false                %%是否分享
}).

%%----签到-----
%%玩家每日签到
-record(player_checkin_info,{
	player_id,
	%checkin_card = 0,
  check_list = [],   %%已签到列表
	refresh_check_time = 946656000, %%刷新时间
	last_check_time = 946656000,    %%最后签到时间
	can_checkin_day = 0 %%可签多少天

}).
%%每日签到奖励配置
-record(checkin_base_config,{
	key,            	%%Id
	str,							%%活动描述
	activity_type,		%%活动类型
	condition,				%%数据条件
	rewards						%%奖励物品
}).

%%----------------------
%%-------任务----------
%% 任务基础表
-record(player_mission_base, {
	id,                           % 任务Id
	icon,                         % 图标
	title,												% 标题
	achieve_condition,            % 分别任务标识
	type,                         % 类型：1新手 2日常任务 3每周，4定时
	parameter1,			  						% 参数1 （0.任意场 1.百人大战  2.赏金牛仔 3.水果狂欢）
	parameter2,										% 参数2（0.任意房间 1.新手场 2.初级场 3.中级场 4.高级场 5.贵宾场 6.富豪场）
	condition,     								% 条件
	reward_id1,										%	奖励物品id 1
	reward_num1,					        % 奖励物品数量 1
	reward_id2,										%	奖励物品id 2
	reward_num2,					        % 奖励物品数量 2
	desc,													% 描述
	jump_ui		                    % 跳转
}).
%% 玩家任务历史表
-record(player_mission_history, {
	key,            %%  普通任务直接就是{player_id, mission_id}， 日常任务是{player_id, mission_id, date} date为完成时间,
									%% 每周任务{player_id, mission_id, {year,week_num}},{year,week_num}年份和周数
	key2,           %%  {player_id, mission_id}
	player_id,      %%  用户ID
	mission_id,     %%  任务ID
	accept_time,    %%  接受任务
	achieve_time,   %%  到达时间
	draw_time       %%  获取奖励时间
}).

%% 玩家任务表
-record(player_mission, {
	key,                %%  {player_id, mission_id}
	player_id,          %%  用户ID
	mission_id,         %%  任务ID
	status,             %%  状态, //  0为接受，1为完成
	record,             %%  记录任务的信息
	accept_time,        %%  完成时间
	achieve_time,        %%  完成时间
	other_record = []		%% 其他记录  暂时没用
}).
%%-----------------------------------
%% 牛牛房间配置表
-record(niu_room_config, {
	key,      %编号,
	commision,%佣金,
	score,    %底分,
	doorsill, %门槛,
	taxed     %对应场抽税比例

}).

%% 百人牛牛走势
-record(hundred_niu_winning_record, {
	room_id,
	record_list = []	%% {0,1,0,1} 最大长度50 头最新
}).

%% 百人赢奖池人信息
-record(hundred_niu_pool_win_rec, {
	room_id,
	record_list = [] % {date, win_player_info[]}
}).

% 百人奖池
-record(hundred_niu_reward_pool, {
	key,
	comm_reward_pool,
	rank_reward_pool
}).

%%-----对局宝箱--------------
%%玩家对局宝箱信息
-record(player_niu_room_chest,{
	player_id,
	room_lv = 0,
	times = 0,
	free_diamond_times = 0, %% 领取免费钻石次数
	refresh_time = 1451577600
}).
%%对局宝箱配置信息
-record(niu_room_chest_config,{
	key,              %%room_lv
	name,             %%名称
	min_gold,         %%最低门槛
	condition,        %%领取宝箱需要对局数
	free_get,         %%免费领取金币
	free_get2,        %%领取镖票
	free_get3,        %%领取元宝
	limit_times,			%%当天未购买福袋用户每日免费领取次数限制
	limit_times_fudai %%当天购买福袋用户每日免费领取次数限制
}).

%%玩家百人对局宝箱信息
-record(player_hundred_room_chest,{
	player_id,
	count = 0,
	free_diamond_times = 0, %% 领取免费钻石次数
	refresh_time = 1451577600
}).

%%玩家拉霸对局宝箱信息
-record(player_laba_chest,{
	player_id,
	count = 0,
	free_diamond_times = 0, %% 领取免费钻石次数
	refresh_time = 1451577600
}).

%%玩家超级拉霸对局宝箱信息
-record(player_super_laba_chest,{
	player_id,
	count = 0,
	free_diamond_times = 0, %% 领取免费钻石次数
	refresh_time = 1451577600
}).

%%--------------
%% 拉霸玩家信息
-record(player_laba_info, {
	player_id,
	line_num = 1,
	line_set_chips_pos = 1,
	free_num = 0,
	in_room = false,
	lucky_reward_times = 1,
	earn_gold = {0,0}, % {testtype1, testtype2}
	bet_times = 1 % 已经下注的次数
}).

-record(player_super_laba_info, {
	player_id,
	line_num = 1,
	line_set_chips_pos = 1,
	free_num = 0,
	in_room = false,
	earn_gold = {0,0} % {testtype1, testtype2}
}).

%% 拉霸水果概率配置信息
-record(laba_fruit_config, {
	key,
	two_odds,
	three_odds,
	four_odds,
	five_odds,
	rate % 默认依据下注几条线的配置
}).

%%
-record(super_fruit_config, {
	key,
	two_odds,
	three_odds,
	four_odds,
	five_odds,
	rate % 默认依据下注几条线的配置
}).

%% 拉霸单线投注
-record(line_num_config, {
	key,
	gold_bet, %%单线投注
	rate1,    %%3个7彩池
	rate2,		%%4个7彩池
	rate3			%% 5个7彩池
}).

%% 超级拉霸单线投注
-record(super_line_config, {
	key,
	gold_bet, %%单线投注
	rate1,    %%3个7彩池
	rate2,		%%4个7彩池
	rate3			%% 5个7彩池
}).

%% 拉霸中奖人
-record(laba_win_player,{
	key,   %% {时间,类型} 类型 1-拉霸，2- 超级拉霸
	info   %% 基本信息
}).

%% 拉霸中奖控制
-record(fruit_pool_win_control_config,{
	key,
	reward,
	money_lost
}).

%% 玩家拉霸赢金
-record(player_laba_win_gold,{
	player_id,
	laba_win = 0,  %% 拉霸赢金
	super_laba_win = 0 %% 超级拉霸赢金
}).

%% 玩家超级拉霸排行榜奖励
-record(fruit_rank_reward_config,{
	key,
	percent
}).


%% 游戏中任务
-record(laba_game_task_config, {
	key,
	account_level,
	pre_id,
	post_id,
	achieve_conditicon,
	item1_id,
	item1_num
}).

%% 拉霸宝箱
-record(laba_game_box_config, {
	key,
	reward_gold1,
	reward_gold2,
	reward_gold3
}).

%% 拉霸重摇规则
-record(laba_re_roll_config, {
	key,
	do_again,
	max_gold
}).

%% 超级拉霸奖池控制
-record(laba_pool_reroll_config,{
	key, % {laba or super_laba, 1}
	multiple,  %% 疯狂水果彩池低等于该值时
	do_again  	%%概率重摇
}).

% 拉霸水果出现几率配置(覆盖laba_fruit_config.rate)
-record(laba_fruit_rate_config, {
	key,
	small_rate,
	big_rate
}).

-record(slaba_fruit_rate_config, {
	key,
	small_rate,
	big_rate
}).

% laba奖池控制
-record(laba_pool_reward_config, {
	key,
	type,  %%输赢标识，1赢，2输
	limit, %%参数，TYPE=1，赢钱数，TYPE=2输钱数
	rate	 %%参数，TYPE=1，中彩池重摇概率，TYPE=2,额外中彩池概率，十万分比
}).

%% 拉霸税率和参数
-record(laba_const_config,{
	key,
	param  %%参数
}).

%% 当前拉霸使用的元素概率
-record(laba_fruit_activate_config,{
	key,
	value
}).

%% --------------
-record(player_phone_info,{
	player_id,
	phone_num = 0,   %电话号码
	is_draw = false  %是否领取奖励
}).

%% 百人排行信息
-record(player_hundred_rank_info, {
	player_id = 0,
	name = "",
	icon = "",
	vip = 0,
	sex = 1,

	hundred_win_one_round = 0,	%% 百人单局排行
	hundred_win_total = 0,	%% 百人累计排行

	fresh_time_1 = 0,	%% 刷新数据时间1
	fresh_time_2 = 0,	%% 刷新数据时间2

	is_robot = false
}).

%%-------红包系统-----------
%%红包信息
-record(red_pack_info,{
	id ,
	player_name ,
	player_icon ,
	player_id,
	account = "",
	sex = 0,
	min_num ,    %%设置金额最小值
	max_num ,    %% 设置金额最大值
	create_time ,%% 生成时间
	des ,        %% 描述
	set_num      %% 设置金额
}).
%%红包基础配置信息
-record(red_pack_config,{
	key,
	gold_interval,%%红包数额区间
	property_min,     %%身上保留金币最少值
	fee,          %%发红包手续费
	guess_time   %%猜红包时间间隔
}).
%% %% 红包通知信息
%% -record(red_pack_notice,{
%% 	id,       				%红包id
%% 	create_player_id, %发红包的玩家id
%% 	create_time,      %发红包时间
%% 	gold_num,         %金币数
%% 	contect,          %描述
%% 	type = 0,          %1未开启 2已开启 3取消
%% 	open_player_id = 0,   %开启红包的玩家的id
%% 	open_player_name = "" %开启红包的玩家的名字
%% }).
%% 红包通知信息
-record(red_pack_notice,{
	id,       				%自增id

	notice_type = 1,	%% 1 状态类通知 2 请求类通知
	redpack_id,		%%  红包id
	create_player_id, %发红包的玩家id
	create_time,      %发红包时间
	gold_num,         %金币数
	contect,          %描述
	type = 0,          %1未开启 2已开启 3取消
	open_player_id = 0,   %开启红包的玩家的id
	open_player_name = "", %开启红包的玩家的名字
	open_player_account = ""		%%开启红包的玩家的玩家号
}).


%% 红包总数
-record(red_pack_total_info,{
  key,
  all_red_pack_num = 0
}).
%%-----------------------

%% 玩家兑换信息
-record(player_prize_info, {
	player_id,

	exchange_list = [],		%% 已兑换列表
	last_exchange_time = 0,	%% 上次兑换时间

	address_list = [],	%% 地址列表 #pb_prize_address_inf
	vip_limit_exchange_list = [],
	life_time_limit_exchange_list = []
}).

%% 玩家兑换记录
-record(player_prize_exchange_record, {
	id,
	player_id,
	record_type,
	obj_id,
	need_item_id,
	need_item_num,
	second_time,

	card_charge_type = 1,
	card_state = 0,	%%0未充值 1充值了
	card_number,
	card_psd,
	address_info
}).

%% 玩家兑换信息
-record(prize_exchange_config, {
	id,            %%编号,
	name,          %%名称,
	cls,     %%分类
	item_num,      %%物品数,
	cost_info,      %%兑换需要钞票数 {101, 1},

	discount_flag, %%折扣标识,
	dsc,	%% 描述
	exchange,      %%每天每人限定兑换次数,
	stock,         %%总库存,
	stock2,        %%卡密库存,
	vip_lvl,       %%需要VIP等级,
	tex,           %%商品纹理,
	sort,          %%商品排序,
	hot_sell,       %%商品推荐
	vip_limit, % {vip, limit} or no_limit，多少 vip 含以下 limit 次，超过不限制
	life_time_limit % 一个号一生中可以兑换的次数
}).

-record(prize_storage_info, {
	id,            %%编号,
	day_times = 2,
	count, %% 库存
	card_count %% 仅对电话卡密使用
}).

%% 库存 每分钟插入mysql_log 后台修改库存时记录log
-record(gold_depot_info, {
	id,            %%编号,
	total_depot = 0,	%% 总库存
	today_depot = 0,		%% 当天库存
	car_depot = 0,     %%豪车库存
	car_special = {0, 0, 0, 0}, % 豪车库存辅助计算{玩家总支出，已返的税, 微调, 累计盈余}
	hundred_depot = 0,     %%百人库存
	hundred_niu_special_pool = {0,0}, %% 百人牛牛水池和水池回收
	fruit_special_pool = {[], []}, % 水果狂欢水池{试玩场，娱乐场},
	super_fruit_special_pool = {[], []}, % 超级水果水池{试玩，娱乐},
	airlaba_special_pool = {0, 0, [], []}, % 空战 laba 水池{娱乐场，试玩场，娱乐场子水池，试玩场子水池}
	update_second = 0		%% 上次更新库存时间
}).

%% 物品模板Id
-record(ets_base_item, {
	base_id = 0,
	cls = 0
}).

%% 拉霸库存
-record(laba_depot_info, {
	id,            %%编号,
	total_depot = 0	%% 总库存
}).


%% ai概率表（看牌强庄）
-record(ai_config,{
	key,
	weight  %权重
}).

%% ai每日增加经验与金币
-record(robot_daily_reward_config, {
	id,            %%编号,
	add_vip_exp,
	add_gold_num
}).

%% 百人机器人押注
-record(robot_hundred_set_chips_config, {
	id,            %%编号,
	gold_min,
	gold_max,
	set_gold_num,
	set_pos_min,
	set_pos_max
}).

%% ai创建配置表
-record(robot_create_rand_vip, {
	account_key,	%% {min, max}
	vip_level,
	gold
}).

%% 机器人行为记录 仅用于机器人自身进程
-record(robot_behavior_data, {
	player_id,
	behavior_list = [],
	update_date = 946656000
}).

%% 机器人魔法表情
-record(robot_magic_expression_config,{
	key,
	time_rand,          %触发时间上下限
	probability,       %触发几率
	magic_expression,   %魔法表情
	combo_times_list,    %连击次数
	combo_times_weight   %连击概率
}).

%% 玩家金牛数据
-record(player_golden_bull,{
	player_id,
	last_draw_time
}).

%% 玩家金牛配置数据
-record(golden_bull_reward_config,{
	key,
	recharge,
	reward_gold,
	gold_total
}).

%% 玩家金牛任务
-record(player_golden_bull_mission,{
	player_id,
	process = 0, %% 进度
	status = 0,  %% 0 未领奖 ，1 - 领奖
	last_refresh_time = 946656000
}).

%% 月卡
-record(player_id_month_card, {
	player_id,
	begin_datetime = {{2000,1,1}, {0, 0, 0}},
	total_count = 0,
	last_draw_datetime = {{2000,1,1}, {0, 0, 0}}
}).

% 时段卡
-record(player_id_period_card, {
	key, % {player_id, type}
	begin_datetime = {{2000,1,1}, {0, 0, 0}},
	total_count = 0,
	last_draw_datetime = {{2000,1,1}, {0, 0, 0}}
}).

%%玩家游戏中任务
-record(player_game_task_info,{
	player_id,
	update_init_mission_date = {2016,1,1}, %% 更新数据时间
	update_vip_level = 0,		%% 更新数据时vip等级

	hundred_today_mission_id = 0, %% 当前任务id
	hundred_today_mission_process = 0,  %% 该任务完成进度
	hundred_today_mission_process_over = false,  %% 该任务完成进度
	hundred_today_mission_achieve_num = 0,  %% 今日任务完成数量
	hundred_today_mission_complete_flag = false,  %% 所有任务完成=true
	hundred_today_mission_condition = [],  %% 任务完成条件
	hundred_box_draw_info = [],  %% 宝箱领奖情况 1，2，3
	hundred_today_all_mission_id_list = [],  %% 所有任务列表

	fruit_today_mission_id = 0, %% 当前任务id
	fruit_today_mission_process = 0,  %% 该任务完成进度
	fruit_today_mission_process_over = false,  %% 该任务完成进度
	fruit_today_mission_achieve_num = 0,  %% 今日任务完成数量
	fruit_today_mission_complete_flag = false,  %% 所有任务完成=true
	fruit_today_mission_condition = [],  %% 任务完成条件
	fruit_box_draw_info = []
}).

%% 游戏中任务
-record(hundred_game_task_config, {
	key,
	account_level,
	pre_id,
	post_id,
	achieve_conditicon,
	item1_id,
	item1_num
}).


%% 百人宝箱
-record(hundred_game_box_config, {
	key,
	reward_gold1,
	reward_gold2,
	reward_gold3
}).

%% 百人宝箱
-record(game_task_box_config, {
	key,	%% {1,1} = 百人 1
	reward_gold1,
	reward_gold2,
	reward_gold3
}).

%% 红包任务
-record(player_pack_task_info, {
	player_id,
	task_info_list = []	%% {TYpe, GOLD,DrawList}
}).

%% 红包任务奖励表
-record(redpack_task_reward_config, {
	key,
	type, %% 游戏类型 1牛牛 2水果
	need_gold,	%% 需求金币
	reward_pack_num		%% 奖励红包数
}).

%% 活动配置
-record(activity_config, {
	key,
	name,
	pos
}).

%% 玩家红包场信息
-record(player_redpack_room_info,{
	player_id,
	reset_times = 0,	%% 已重置次数
	last_reset_date = {2000,1,1},	%% 上次重置时间

	left_reset_times = 0,		%% 今天已奖励的重置次数
	last_get_reset_time_date = {2000,1,1}	%% 上次获得重置次数时间
}).

%% 机器人数显示
-record(robot_num_config,{
	key,        %ID
	begin_time, %开始时间
	end_time,   %结束时间
	robot_num  %更换机器人数
}).
%% 红包场配置
-record(redpack_room_config, {
	key,
	rand_reward,
	interval,	%% 时间间隔
	draw_interval,	%% 领奖时间间隔
	need_times,	%% 时间段内完成次数
	daily_return_num,		%% 每日恢复钻石
	base_num,		%% 底分
	game_limit, %游戏下限
	tax,       	%税  （百分数）
    round_fee,   % 每局的费用
	pool_tax % 玩家赢取钻石进奖池的百分比
}).

%% %% 百人场 牌重摇控制
%% -record(hundred_reroll_config, {
%% 	key,
%% 	storage_limit,	%% 库存范围
%% 	reroll_rand	%% 重摇概率
%% }).
%% 百人场 牌重摇控制
-record(hundred_reroll_config, {
	key,
	storage_limit,	%% 库存范围
	condition = [0,0],		%% 累计赢钱大等于充值金额系数 A*rmb+B [A,B]
	one_pos_gold_chips,		%% 下注区单人单局最高压注额区间
	triger_rand,	%% 触发概率
	trend,	%% -1需求输钱 1需求回收 当原来的牌不=该趋势时判断是否触发概率
	type	%% 1库存 2充值类 3最高
}).


%% 钻石福袋玩家列表
-record(diamond_fudai_reward_player, {
	key,
	player_id_list = [],	%% 总已购买福袋玩家列表
	already_reward_player_list = [],		%% 已奖励的
	update_second = {2000,1,1}	%% 更新时间
}).

%% 钻石福袋配置
-record(diamond_fudai_config, {
	id,
	man_need,		%% 累计人数
	draw_man_num,	%% 抽奖人数
	reward_diamond
}).

%% 玩家分享信息（邀请码相关）
-record(player_share_info,{
  player_id,
  my_code = 0, 						%我的邀请码
  obj_player_id = 0, 			%分享给我邀请码的玩家id
	obj_code = 0,  					% 分享给我的邀请码
  share_player_num = 0, 	%我分享的人数
  is_newbee_reward_draw = false, %是否领取新人奖励
  share_mission_list = []  	%邀请的任务 {FriendId, Type}, Status
}).

-record(share_reward_config,{
  key,
  descirbe,   %%描述
  condition,  %%条件
  reward      %%奖励
}).
%%--------豪车-----------
%% 豪车开奖结果AI
-record(car_result_config,{
  key,
  plus,           %%库存输赢
  stock,          %%库存输钱真?
  weight_list,    %%权重
  do_chance,      %%概率触发
  target,    	  %%针对的玩家组
  master_type	  %%针对的庄家
}).

%%豪车机器人下庄AI
-record(car_master_config,{
  key,
  type,           %%类型
  condition,      %%判断参数
  chance          %%机器人下庄几率
}).

%%豪车机器人押注AI
-record(car_bet_config,{
  key,
  poples,         %%机器人押注人数区间
  weight_list,    %%押注倍率区间和概率控制
  weight_list2    %%机器人押注次数区间和概率
}).

%%下注限制
-record(car_bet_limit_config,{
  key,
  chip_limit,    %%下注区域限制
  person_limit,  %%个人下注限制
  total_limit    %%个人下注限制
}).

%%坐庄控制
-record(car_master_limit_config,{
  key,
  guys,       %%庄人数
  gold_limit  %%坐庄金币限制
}).

%%豪车倍率表
-record(car_rate_config,{
  key,
  name,       %%名称
  power,      %%倍率
  weight,     %%权重
  icon        %%图标
}).

%%豪车奖金分配
-record(car_pool_config,{
  key,
  bonus,          %%奖池金额
  bonus_chance,   %%该阶段分红概率
  bonus_rate1,    %%庄家可得奖池比例
  bonus_rate2,    %%下庄所有玩家比例
  least_gold,     %%每股至少压线
  min_sum   	  %%当前最少下注多少
}).

%%豪车机器人更换
-record(car_robot_change_config,{
  key,
  robot_num,       %%更换机器人数总数
  change_time,     %%上限机器人轮换时间隔
  change_time2,    %%单个机器人轮换时间隔
  begin_time,      %%开始时间
  end_time         %%结束时间
}).
%%豪车机器人身上金数

%% 豪车走势
-record(car_winning_record, {
  room_id,
  record_list = []	%% {pos,time} 最大长度10
}).
%% 豪车库存
-record(car_pool,{
	id,
	pool_num = 0,
	rank_pool_num = 0
}).

%% 牛黑名单	玩家进程处理该数据
-record(niu_blacklist, {
	player_id = 0,
	flag = 0,	%% 1黑名单中 0不在
	rand = 0,

	room_level_gold_list = []	%% 直接在玩家进程中修改该值
}).

%% 百人上周排行统计
-record(player_hundred_last_week_rank, {
	rank,
	reward_config,
	player_id_1_round,	%% 单局
	name1,

	player_id_2_total,	%% 总盈利
	name2
}).

%% 百人排行奖励
-record(hundred_rank_reward, {
	key,
	rank,
	reward_num
}).

%% 百人累计排行周榜
-record(hundred_total_rank_reward,{
	key,
	rank,
	reward_num
}).

%% 百人奖池控制
-record(hundred_control_by_pool, {
	key,
	range_list,
	reroll_rand,
	reroll_gold_condition % 小于该金额会触发重摇
}).

%% 看牌抢庄控制
-record(niu_control_by_wingold, {
	key,
	room_level,
	win_total,		%% 总赢钱
	rand		%% 开启控制
}).

%% 充值返利排行信息
-record(player_recharge_activity_rank_info, {
	player_id = 0,
	account = "",
	name = "",
	icon = "",
	vip = 0,
	sex = 1,

	recharge = 0,	%%

	fresh_time_1 = 0,	%% 刷新数据时间1

	is_robot = false
}).

%% 充值返利奖池
-record(recharge_activity_info,{
	key,  % 默认1
	gold = 0, % 奖池
	last_time % 最后时间
}).

%% 充值返利奖励配置表
-record(recharge_activity_reward_config,{
	rank,
	precent
}).

%% 机器人金币
-record(robot_gold_config,{
	key,
	gold_min,
	gold_max,
	diamond_min,
	diamond_max
}).

%% 看牌抢庄1场机器人
-record(robot_kana_config,{
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 看牌抢庄2场机器人
-record(robot_kanb_config,{
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 看牌抢庄3场机器人
-record(robot_kanc_config,{
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 百人机器人
-record(robot_hundred_config,{
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 豪车机器人
-record(robot_car_config,{ 
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 豪车系统庄
-record(robot_car_system_master_config, {
	enable_system_master,
	mode, % rate_ctrl -- 概率控制（废弃）,auto_balance -- 自动平衡
	ab_x5_adjust, % 自平衡下 5 倍修改值
	ab_x20_adjust, % 自平衡下 20 倍修改值
	ab_give_back_rate_mode, % 返税率模式，according_to_pool 依据水池设置，according_to_base 依据大盘收入
	ab_give_back_rate, % 返税率
	ab_bet_deduct_rate, % 压住扣除率
	ab_pool_max_hint, % 水池最大参考值，当大于最大参考值会优先返利
	ab_pool_max_give_back_hint, % 水池到达最大时候的强行返税几率
	ab_x20_rate_hint, % 在水池许可的情况下，优先开出 20 倍赔率的参考值
	ab_earn_step_limit, % 在水池需要吸金币的时候一次吸入金币的最大值百分比（依据当轮玩家总下注）
	ab_defense_hack_rate_shift_hint_min, % 防刷 概率偏移 最小值 ==> 最小，最大值差值小于ab_x20_adjust
	ab_defense_hack_rate_shift_hint_max, % 防刷 概率偏移 最大值
	ab_defense_hack_rate_shift_round_hint, % 防刷 随机切换局数参考值 实际完全刷新是 2 倍该数值
	ab_defense_hack_continuous_x20_rate, % 触发连续开 x20 的概率
	ab_defense_hack_continuous_x20_round_hint_min, % 连续触发 x20 的次数提示
	ab_defense_hack_continuous_x20_round_hint_max, % 连续触发 x20 的次数提示
	ab_ignore_player_ids % 水池不统计的用户角色 id
}).

%% 红包场器人
-record(robot_redpack_config,{
	key,   %%机器人id
	name,  %% 名字
	vip,   %% vip等级
	image_id,  %% 头像
	frame_id   %% 头像框
}).

%% 红包场复活次数
-record(player_redpack_relive_info,{
	player_id,
	times,
	last_time
}).

% 福袋奖池
-record(lucky_bag_pool,{
	id,
	num  %
}).

% 福袋概率表
-record(diamond_fudai_rate_config,{
	id,  %%次数
	chance  % 概率
}).

% 红包场次数
-record(player_redpack_game_times,{
	player_id,
	times = 0
}).

%% 玩红包场次记录（到8场为止）
-record(play_redpack_times,{
	player_id,
	times = 0
}).

%% 百人消耗
-record(hundred_niu_cost,{
	player_id,
	num = 0
}).

% 百人换牌概率
-record(hundred_change_cards_config,{
	key,
	weight_list  % 随机列表
}).

% 百人水池控制
-record(hundred_niu_ab_pool_ctrl, {
	mode,
	ab_give_back_rate_mode, % 返税率模式
	ab_give_back_rate, % 返税率
	ab_pool_max_hint, % 水池最大参考值，当大于最大参考值会优先返利
	ab_pool_max_give_back_hint % 水池到达最大时候的强行返税几率
}).

% 百人常量
-record(hundred_niu_const, {
	key,
	value,
	desc
}).

% 首次兑换红包额外奖励（首次，不刷新）
-record(player_first_prize_reward,{
	player_id,
	times = 0,   % 次数
	refresh_time  %刷新时间
}).

% 首次兑换红包额外奖励配置表
-record(first_prize_reward_config,{
	key,
	descirbe,  % 描述
	condition, % 条件
	weight_list  % 随机列表
}).

% 七日狂欢
-record(player_seven_days_carnival_info,{
	player_id,
	now_task_id = 0,
	process = 0,
	status = 0,
	condition = [],
	draw_list = [],
	draw_time = 1514736000
}).

% 红包留存任务
-record(share_task_redpack_config,{
	key,
	icon,
	pre_id,
	post_id,
	title,
	condition,
	achieve_type,
	parameter1,
	parameter2,
	parameter3,
	item1_id,
	item1_num,
	item2_id,
	item2_num,
	desc,
	skip_id,
	diamond_mark,
	order_mark
}).

% 活动用渠道表
-record(activity_chnid_config,{
	key,
	chnid_list = [], %% 渠道 {渠道号，是否为老玩家开启}
	time  %% 更新时间

}).

% 玩家渠道
-record(player_chnid_info,{
	player_id,
	chnid
}).

% 玩家分享转盘信息
-record(player_share_lucky_wheel_info,{
	player_id,
	all_times_1 = 0,
	draw_times_1 = 0,
	fresh_time_1 = 1514736000,
	all_times_3 = 0,
	draw_times_3 = 0,
	fresh_time_3 = 1514736000,
	all_times_7 = 0,
	draw_times_7 = 0,
	fresh_time_7 = 1514736000
}).

% 玩家分享转盘奖励
-record(share_redpack_config,{
	key,
	reward
}).

% 实名认证
-record(player_real_name_info,{
	player_id,
	type = 0
}).

%% 分享活动绑定
-record(player_share_binding_info,{
	player_id,
	share_player_id
}).

%% 一本万利充值活动
-record(player_pay_activity_info,{
	player_id,
	task_id = 0,  %% 任务id
	process =0,  %% 进度
	status = [],  %% 完成状态
	open = 0   %% 是否开启
}).

%% 一本万利配置表
-record(act_golding_config,{
	key,
	task_id,   %%% 任务id
	total_gold, %% 累计赢金
	reward   %%奖励
}).

%% 一本万利渠道信息
-record(activity_gold_chnid_config,{
	key,
	chnid_list = [], %% 渠道 {渠道号，是否为老玩家开启}
	time  %% 更新时间
}).

-record(fruit_rank_history, {
	date, %% 每周一日期，格式如"YYYY-MM-DD"
	rank = []
}).

-record(activity_time_config,{
	key,  %% 活动ID
	time1, %% 开启时间
	time2,  %% 结束时间
	time3  %% 循环机制
}).
-endif.

%% 每日赚金排行榜奖励
-record(daily_earn_gold_rank_reward_config, {
	key, %% 排名
	gold %% 赠送的金币
}).

% 每日赚金明细配置
-record(daily_earn_gold_rank_detail_config, {
	period, % 揭榜周期（天数）
	title, % 邮件通知标题
	context_tmpl % 邮件内容模板
}).

%% 游戏排行榜奖励
-record(game_earn_gold_rank_reward_config, {
	key, % {游戏类型, 排名}
	gold, %% 赠送的金币
	winpool_divide % 奖池瓜分
}).

% 游戏赚金明细配置
-record(game_earn_gold_rank_detail_config, {
	type, % 游戏类型
	period, % 揭榜周期（天数）
	special_time_of_day, % 每天指定小时{H,M,S}
	title, % 邮件通知标题
	context_tmpl % 邮件内容模板
}).

%% 每日排行奖励历史记录（目前只记录前一天）
-record(daily_rank_reward_history, {
	type, %% profit -- 每日赚金
	date, %% 记录时间
	reward_records %% 奖励记录
}).

%% 粘性红包任务配置
-record(stickiness_redpack_level_config, {
	key, %% {room_type, test_type, level}
	single_reward_item_type, %% 单次可以获得的物品类型
	signle_reward_item_amount, %% 单次可以获得的物品数量
	next_level_trigger, %% 累计赚金到达下一等级的金币数量
	gold_cov_to_reward_item_rate, %% 多少金币换算成一个这个物品
	reset_argv_array = [], %  任务重置的参数，依据reset_mode定义
	reset_mode = server_side_by_day % {server_side_by_day -- 服务器定时更新, user_side -- 用户开始第一次开始更新}
}).

%% 每个玩家粘性红包配置
-record(player_stickiness_redpack_level_info, {
	key, %% 对应玩家的记录, PlayerId
	proj_list = [] %% 任务列表
}).

% player_stickiness_redpack_level_info.proj_list
-record(player_stickiness_redpack_level_info_proj_elem, {
	key, %% {room_type, test_type, level}
	%single_reward_item_type, %% 单次可以获得的物品类型
	%signle_reward_item_amount, %% 单次可以获得的物品数量
	cur_total_amount, %% 当前总兑换数
	cur_earn_gold, %% 当前可以兑换的赚金数量
	end_time, % 任务结束时间
	activate_time, % 激活本次任务的时间
	holding, % 任务重置前以领取
	total_gold % 总获取的金币
}).

% 豪车常量配置
-record(car_const_config, {
	key,
	value,
	desc
}).

%%  豪车水池中奖磅单
-record(car_pool_win_rec, {
	room_id,
	record_list = []
}).

% 玩家下注锁配置
-record(player_bet_lock_config, {
	key, % {game_type, test_type, level}... ...
	bet_limit, % 下注限制
	bet_num, % 下一级金额配置
	vip_num, % 下一级 vip 配置
	next_key % 下一级的配置key
}).

% 玩家下注锁
-record(player_bet_lock, {
	player_id,
	car, % {试玩， 娱乐}
	hundred_niu, % {试玩， 娱乐}
	laba, % {试玩， 娱乐}
	super_laba, % {试玩， 娱乐}
	airlaba % {试玩， 娱乐}
}).

% 水果水池配置
-record(fruit_pool_config, {
	key, % {laba/super_laba, 1试玩2 娱乐}
	bet_retrieve, % 下注回收{分子， 分母},
	earn_retrieve, % 系统赢取的回收{分子， 分母}
	pool_config % 水池配置 [{1, [1,2,3]},{2, [1,2,3,4]}, {..}, ]
}).

% 下注粘性红包配置
-record(bet_stickiness_redpack_config, {
	key, % {gametype, testtype, level}
	bet_num, % 下注触发红包的金额，并转向下一级（如果有）
	redpack_weight, % 获得红包的权重配置
	next_key, % 下一级的key
	% 下面可能是预留字段
	curlevel_reset_time, % 当前级重制时间
	alllevel_reset_time % 所有等级重制时间
}).

% 玩家下注粘性红包配置
-record(player_bet_stickiness_redpack, {
	player_id, % 玩家ID
	laba, % {试玩，娱乐}
	super_laba, % {试玩，娱乐}
	hundred_niu, % {试玩，娱乐}
	car, % {试玩，娱乐}
	airlaba % {试玩, 娱乐}
}).

% 玩家统计数据
-record(player_statistics, {
	player_id, % 玩家 ID
	et_prev_daily_bet, % {laba, super_laba, hundred_niu, car}
	et_prev_daily_bet_update_date, % 最近一次更新时间 {YYYY, MM, DD}
	et_last_daily_bet, % {laba, super_laba, hundred_niu, car}
	et_last_daily_bet_update_date, % 最近一次更新时间
	et_prev_daily_earn, % {laba, super_laba, hundred_niu, car}
	et_prev_daily_earn_update_date, % 最近一次更新时间 {YYYY, MM, DD}
	et_last_daily_earn, % {laba, super_laba, hundred_niu, car}
	et_last_daily_earn_update_date, % 最近一次更新时间
	daily_earn_draw_time % 奖励领取时间 {YYYY, MM, DD}
}).

% 抽奖配置
-record(lottery_config, {
	id,
	cost_item_info, % {item_id, item_num}
	random_reward_list % []
}).

% 玩家抽奖信息
-record(player_lottery_info, {
	player_id, % 玩家 id
	period_times, % 周期内已经抽奖的次数
	last_draw_time % 最后一次抽奖时间
}).

% 水果新人保护配置
-record(fruit_fresher_protect_config, {
	id, % {laba/super_laba, 1}
	bet_index, % 下注金额
	set_line_min, % 最少压线
	max_allfall_times, % 最大连输概率
	reroll_perc, % 没赢的重摇概率
	win_rate % 触发保护的最大中奖倍数
}).

% 水果新人福利
-record(fruit_fresher_welfare_config, {
	key, % {laba/super_laba, bet_index, bet_times}
	reward_range % [min, max]
}).

% 空战 laba 信息
-record(player_airlaba_info, {
	player_id,
	bet_pool, % 玩家未返奖的金额{试玩，娱乐}
	hit_rate_adj = 0, % 爆率调整
	fire_miss_amendment = 0, % 防止长期没有命中的修正参数
	curday_impoverished_subsidy_count = 0, % 当天破产补助次数
	curday_impoverished_subsidy_time = 0 % 最近一次破产补助时间
}).

% 空战 laba 飞机类型
-record(airlaba_plane_config, {
	id,
	name,
	hit_rate, % 默认情况下的命中概率
	earn_rate, % 奖励倍数
	redpack_num,% 奖励的红包数量
	comm_pool_support_rate % 水池支援的金额百分比{random_weight,[百分比],[权值]}
}).

% 空战 laba 水池控制
-record(airlaba_ab_pool_config, {
	id,
	personal_pool_rate, % 个人水池比例
	common_pool_rate % 公共水池比例 {当级水池，共享水池}
}).

% 空战 laba 常量配置
-record(airlaba_const_config, {
	key,
	value,
	desc
}).

% 空战 laba 奖池
-record(airlaba_pool, {
	id,
	pool_num, % 中奖奖池
	rank_pool_num % 排行榜奖池
}).

% 破产补助配置
-record(airlaba_impoverished_subsidy_config, {
	id,
	rand_reward_config % 配置
}).

% 物品信息
-record(airlaba_item_info, {
	item_type_id, % 物品 id
	user_pool_modify, % 用户水池修改数量
	tmp_hit_rate_modify, % 临时命中率修改
	tmp_gold, % 临时命中的金币本金
	effect_times % 一轮最大激活次数
}).
