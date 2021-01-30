-ifndef(LOG_HRL).
-define(LOG_HRL, true).

-include("predef.hrl").

%% 奖励产出/消耗类型
%% 牛牛
-define(REWARD_TYPE_NIU_NIU_SETTLEMENT,								10).			% 结算
-define(REWARD_TYPE_NIU_NIU_ENTER_COST,								11).			% 入场费

%% 百人
-define(REWARD_TYPE_HUNDRED_NIU_SETTLEMENT,								20).			% 结算
-define(REWARD_TYPE_HUNDRED_NIU_OPEN_POOL,								21).			% 开奖池奖励
-define(REWARD_TYPE_HUNDRED_NIU_SET_CHIPS,								22).			% 百人下注
% 结算
%% 红包场
-define(REWARD_TYPE_REDPACK_SETTLEMENT,								30).

-define(REWARD_TYPE_ROBOT,								99).			% 机器人相关
-define(REWARD_TYPE_BY_CMD,								100).			% gm命令
-define(REWARD_TYPE_CHAT_MAGIC_COST,			101).			% 魔法表情消耗
-define(REWARD_TYPE_MAIL,								102).			% 邮件奖励
-define(REWARD_TYPE_MISSION,								103).			% 任务奖励
-define(REWARD_TYPE_SHOP,								104).			% 商城
-define(REWARD_TYPE_SUBSIDY,								105).			% 救助
-define(REWARD_TYPE_RECHARGE_DIAMOND,								106).			% 充值钻石
-define(REWARD_TYPE_LABA,								107).			% 拉霸
-define(REWARD_TYPE_RED_PACK,           108).      %红包
-define(REWARD_TYPE_CHECKIN,           109).      %签到
-define(REWARD_TYPE_VIP_SEPCIAL_REWARD, 110).      %vip特别奖励
-define(REWARD_TYPE_CHANGE_NAME, 111).      %改名
-define(REWARD_TYPE_BINDING_PHONE, 112).      %绑定手机
-define(REWARD_TYPE_PRIZE_EXCHANGE, 113).      %实物兑换
-define(REWARD_TYPE_ROBOT_MASTER_SUPPLY_ADD,								114).			% 机器人金币补充
-define(REWARD_TYPE_ROBOT_MASTER_SUPPLY_DEDUCE,								115).			% 机器人金币减少
-define(REWARD_TYPE_NIU_ROOM_CHEST,           116).      %对局宝箱
-define(REWARD_TYPE_GUIDE_DRAW,           117).      % 新手引导领奖
%-define(REWARD_TYPE_GAME_TASK,           118).      % 游戏中任务
-define(REWARD_TYPE_RED_PACK_TASK,           119).      % 红包任务
-define(REWARD_TYPE_RED_PACK_ROOM_DRAW,           120).      % 红包场领红包
-define(REWARD_TYPE_RED_PACK_ROOM_REWARD_DIAMOND,           121).      % 红包场奖励钻石
-define(REWARD_TYPE_RED_PACK_ROOM_DIAMOND_RESET,           122).      % 重置钻石数

-define(REWARD_TYPE_LOGIN_OFFLINE_REWARD,           123).      % 离线房间奖励
-define(REWARD_TYPE_ROBOT_GOLD_LIMIT,           124).      % 机器人超出上限扣钱
-define(REWARD_TYPE_ROBOT_DIAMOND_SUBSIDY,           125).      % 机器人 钻石补充


-define(REWARD_TYPE_GAME_TASK_LABA_MISSION,           126).      % 拉霸任务
-define(REWARD_TYPE_GAME_TASK_LABA_BOX,           127).      % 拉霸宝箱
-define(REWARD_TYPE_GAME_TAST_NIU_MISSION,           128).      % 牛牛任务
-define(REWARD_TYPE_GAME_TAST_NIU_BOX,           129).      % 牛牛宝箱


-define(REWARD_TYPE_MONTHCARD_DRAW,           130).      % 月卡领奖
-define(REWARD_TYPE_NEWBIE_REWARD,           131).      % 注册奖励
-define(REWARD_TYPE_SHARE,           132).      % 分享
-define(REWARD_TYPE_CAR,      133).       %豪车
-define(REWARD_TYPE_GOLDEN_BULL,      134).       %金牛
-define(REWARD_TYPE_REDPACK_RELIVE,      135).       %红包场复活
-define(REWARD_TYPE_NIU_ROOM_CHEST_TYPE_2,           136).      %对局宝箱
-define(REWARD_TYPE_NIU_ROOM_CHEST_TYPE_3,           137).      %对局宝箱
-define(REWARD_TYPE_CASH_TRANSFORMATION,             138).      %奖券兑换成金币
-define(REWARD_TYPE_7_DAY_CARNIVAL,                  139).      %7日狂欢
-define(REWARD_TYPE_SHARE_LUCKY_WHEEL,               140).      %分享转盘
-define(REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_1,       141).      %百人对局宝箱
-define(REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_2,       142).      %百人对局宝箱
-define(REWARD_TYPE_HUNDRED_ROOM_CHEST_TYPE_3,       143).      %百人对局宝箱
-define(REWARD_TYPE_LABA_CHEST_TYPE_1,               144).      %拉霸对局宝箱
-define(REWARD_TYPE_LABA_CHEST_TYPE_2,               145).      %拉霸对局宝箱
-define(REWARD_TYPE_LABA_CHEST_TYPE_3,               146).      %拉霸对局宝箱
-define(REWARD_TYPE_REAL_NAME,                       147).      %实名认证
-define(REWARD_TYPE_PAY_ACTIVITY_REWARD,             148).      %一本万利
-define(REWARD_TYPE_SUPER_LABA_CHEST_TYPE_1,         149).      %超级拉霸对局宝箱
-define(REWARD_TYPE_SUPER_LABA_CHEST_TYPE_2,         150).      %超级拉霸对局宝箱
-define(REWARD_TYPE_SUPER_LABA_CHEST_TYPE_3,         151).      %超级拉霸对局宝箱
-define(REWARD_TYPE_SUPER_LABA,						 152).	    % 超级拉霸
-define(REWARD_TYPE_REDPACK_DIRECT_TO_GOLD,          153).      %红包直接兑换成金币
% 当 TEST_TYPE 是渠道 ID 的时候，对应粘性红包的 REWARD_TYPE 是 REWARD_TYPE * 1000000 + 渠道 ID
-define(REWARD_TYPE_STICKINESS_REDPACK_LABA_TESTTYPE1, 154).     % 粘性红包试玩场拉霸
-define(REWARD_TYPE_STICKINESS_REDPACK_LABA_TESTTYPE2, 155).     % 粘性红包娱乐场拉霸
-define(REWARD_TYPE_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE1, 156).     % 粘性红包试玩场超级拉霸
-define(REWARD_TYPE_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE2, 157).     % 粘性红包娱乐场超级拉霸
-define(REWARD_TYPE_STICKINESS_REDPACK_HUNDRED_TESTTYPE1, 158).     % 粘性红包试玩场百人牛牛
-define(REWARD_TYPE_STICKINESS_REDPACK_HUNDRED_TESTTYPE2, 159).     % 粘性红包娱乐场百人牛牛
-define(REWARD_TYPE_STICKINESS_REDPACK_CAR_TESTTYPE2, 160).     % 粘性红包试玩场豪车
-define(REWARD_TYPE_STICKINESS_REDPACK_CAR_TESTTYPE1, 161). % 粘性红包试玩场豪车
-define(REWARD_TYPE_PERIODCARD_DRAW_UNKNOWN, 162). % 周卡领取
-define(REWARD_TYPE_PERIODCARD_DRAW_WEEK, 163). % 周卡领取
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_LABA_TESTTYPE1, 164). % 下注红包 laba 试玩场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_LABA_TESTTYPE2, 165). % 下注红包 laba 娱乐场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE1, 166). % 下注红包超级 laba 试玩场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_SUPER_LABA_TESTTYPE2, 167). % 下注红包超级 laba 娱乐场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_HUNDRED_TESTTYPE1, 168). % 下注红包百人试玩场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_HUNDRED_TESTTYPE2, 169). % 下注红包百人娱乐场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_CAR_TESTTYPE1, 170). % 下注红包豪车试玩场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_CAR_TESTTYPE2, 171). % 下注红包豪车娱乐场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_UNKNOWN, 172). % 未知场
-define(REWARD_TYPE_STICKINESS_REDPACK_CONFIGERR, 173). % 粘性红包配置错误
-define(REWARD_TYPE_ADREWARD, 174). % 视频广告奖励
-define(REWARD_TYPE_SHOP_RANDOM_REWARD, 175). % 商城随机奖励
-define(REWARD_TYPE_DAILY_SALARY, 176). % 每日工资
-define(REWARD_TYPE_AIRLABA_SYNC, 177). % laba 空战同步金币
-define(REWARD_TYPE_LOTTERY, 178). % 抽奖
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_AIRLABA_TESTTYPE1, 179). % 下注红包空战 laba 试玩场
-define(REWARD_TYPE_BET_STICKINESS_REDPACK_AIRLABA_TESTTYPE2, 180). % 下注红包空战 laba 娱乐场
-define(REWARD_TYPE_AIRLABA_SYNC_TESTTYPE1, 181). % 试玩场飞机金币、红包同步
-define(REWARD_TYPE_AIRLABA_SYNC_TESTTYPE2, 182). % 娱乐场飞机金币、红包同步

%% 奖励产出/消耗类型

%% 邮件log类型
-define(MAIL_TYPE_GM_SEND_TO_ALL,           1001).      % 群发邮件
-define(MAIL_TYPE_GM_SEND_TO_SINGLE,           1002).      % 发单人邮件

-define(MAIL_TYPE_RED_PACK_DRAW_NOTICE,           1003).      % 通知拆红包邮件
-define(MAIL_TYPE_DIAMOND_FUDAI,           1004).      %  福袋
-define(MAIL_TYPE_CANCEL_REDPACK_MAIL,           1005).      %  取消红包邮件
-define(MAIL_TYPE_REDPACK_TIMEOUT_MAIL,           1006).      %  红包超时

-define(MAIL_TYPE_HUNDRED_RANK_REWARD_ROUND,           1007).      %  百人 单局
-define(MAIL_TYPE_HUNDRED_RANK_REWARD_TOTAL,           1008).      %  百人 总
-define(MAIL_TYPE_RECHARGE_ACTIVITY_RANK_REWARD,       1009).      %  每周充值奖励
-define(MAIL_TYPE_PRIZE,                               1010).      %  兑换
-define(MAIL_TYPE_SUPER_LABA_RANK_REWARD,              1011).      %  每周超级拉霸排行榜
-define(MAIL_TYPE_CAR_RANK_REWARD,                     1012).      %  豪车排行榜每日奖励
-define(MAIL_TYPE_HUNDRED_NIU_RANK_REWARD,             1013).      %  百人排行榜奖励
-define(MAIL_TYPE_AIRLABA_BET_RANK_REWARD,             1014).      %  空战 laba 排行榜奖励
-define(MAIL_TYPE_DAILY_RANK_REWARD,                   1020). % 每日排行榜邮件

%% 邮件log类型

-endif.