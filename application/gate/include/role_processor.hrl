%% 玩家模块头文件
%% 定义玩家进程相关的 进程字典、记录结构等，其它模块慎用！

-ifndef(ROLE_PROCESSOR_HRL).
-define(ROLE_PROCESSOR_HRL, true).

-include("predef.hrl").

%% --------------- 玩家状态 ---------------
-define(STATE_NAME_GAMING,                  'state_name_gaming').				% 主界面

%% --------------- 进程字典 ---------------
-define(DIC_GATE_PROCESSOR,  				dic_gate_processor).
-define(DIC_PLAYER_INFO, 					dic_player_info).
-define(DIC_PLAYER_BAG_INFO, 				dic_player_bag_info).
-define(DIC_PLAYER_STATISTICS_INFO,         dic_player_statistics_info).


-define(TIME_BE_OFFLINE,                        600).           % 掉线后关进程的时长
%% --------------- 操作CD进程字典 ---------------
-define(TYPE_OPE_CD_BUG_FEEDBACK,               type_ope_cd_bug_feedback).              % bug反馈

%%-----------任务类型---------------
-define(MISSION_TYPE_CHANGE_HEAD,               mission_type_change_head).				 %   修改头像
-define(MISSION_TYPE_CHANGE_NAME,               mission_type_change_name).         %   修改名字
-define(MISSION_TYPE_FRIEND,                    mission_type_friend).              %   结识朋友
-define(MISSION_TYPE_RECHARGE,                  mission_type_recharge).            %   充值
-define(MISSION_TYPE_NIU_ROOM_EARN,             mission_type_niu_room_earn).       %   牛牛赚钱
-define(MISSION_TYPE_NIU_ROOM_PLAY,             mission_type_niu_room_play).       %   牛牛玩
-define(MISSION_TYPE_NIU_ROOM_LEADER,           mission_type_niu_room_leader).     %   牛牛坐庄
-define(MISSION_TYPE_HUNDRED_WARS_PLAY,         mission_type_hundred_wars_play).   %   在百人大战玩牌
-define(MISSION_TYPE_HUNDRED_WARS_LEADER,       mission_type_hundred_wars_leader). %   百人大战房间坐庄获胜
-define(MISSION_TYPE_HUNDRED_WARS_WIN,          mission_type_hundred_wars_win).    %   百人大战房间赢钱
-define(MISSION_TYPE_HUNDRED_WARS_WIN_TIMES,    mission_type_hundred_wars_win_times).    %   百人大战房间赢钱
-define(MISSION_TYPE_ANY_GAME_PLAY,             mission_type_any_game_play).       %   任意场对局
-define(MISSION_TYPE_TESTTYPE_GAME_PLAY,        mission_type_testtype_game_play).  %   任意场对局
-define(MISSION_TYPE_ANY_GAME_LEADER,           mission_type_leader_win).          %   任意场坐庄赢
-define(MISSION_TYPE_ANY_GAME_EARN,             mission_type_any_game_earn).       %   任意场赚金
-define(MISSION_TYPE_TESTTYPE_GAME_EARN,        mission_type_testtype_game_earn).  %   娱乐场赚金
-define(MISSION_TYPE_FRUIT_CARNIVAL_PLAY,       mission_type_fruit_carnival_play). %   玩水果狂欢
-define(MISSION_TYPE_FRUIT_NORMAL_PLAY,         mission_type_fruit_normal_play).   %   玩水果
-define(MISSION_TYPE_FRUIT_CARNIVAL_EARN,       mission_type_fruit_carnival_earn). %   水果狂欢赚钱
-define(MISSION_TYPE_CAR_EARN,                  mission_type_car_earn). %   老司机
-define(MISSION_TYPE_DAILY_SET_CHIPS_REWARD_1,  mission_type_daily_set_chips_reward_1). %   百人大战每日首次压注100000金币
-define(MISSION_TYPE_DAILY_FUDAI,               mission_type_daily_fudai).         %   钻石福袋每日购
-define(MISSION_TYPE_HUNDRED_NIU_BET,           mission_type_hundred_niu_bet).     %   百人下注
-define(MISSION_TYPE_5_YUAN_REDPACK_PRIZE,      mission_type_5_yuan_redpack_prize).%   每日兑换5元红包
-define(MISSION_TYPE_BUY_FUDAI,                 mission_type_buy_fudai).           %   购买福袋
-define(MISSION_TYPE_LABA_POOL_REWARD_TIMES,    mission_type_laba_pool_reward_times).% 水果中奖次数
-define(MISSION_TYPE_HUNDRED_LEADER,            mission_type_hundred_leader).      %   百人大战房间坐庄
-define(MISSION_TYPE_SHARE_TIMES,               mission_type_share_times).         %   分享
-define(MISSION_TYPE_ONLINE_TIME,               mission_type_online_time).         %   在线时长
-define(MISSION_TYPE_1_YUAN_REDPACK_PRIZE,      mission_type_1_yuan_redpack_prize).%   兑换1元红包
-define(MISSION_TYPE_TESTTYPE_CAR_EARN_REDPACK, mission_type_testtype_car_earn_redpack). % 娱乐场豪车赚金
-define(MISSION_TYPE_TESTTYPE_HUNDRED_NIU_EARN_REDPACK,mission_type_testtype_hundred_niu_earn_redpack). % 娱乐场百人赚金

-define(LAST_ENTER_ROOM_SECOND, last_enter_room_second).        %% 保存进入房间时间戳
-define(ENTER_ROOM_INTERVAL, 3).        %% 进入房间间隔

-define(NOW_ROOM_LEVEL, now_room_level).        %% 房间level
-define(HTTP_POST_LEAVE_GAME, dic_leave_game).	%% 初始化=false =true后不发送离开房间http_post

%%=======================================================================
%% 粘性红包房间类型
-define(STICKINESS_REDPACK_EARN_LABA, 1).
-define(STICKINESS_REDPACK_EARN_SUPER_LABA, 2).
-define(STICKINESS_REDPACK_EARN_HUNDRED_NIU, 3).
-define(STICKINESS_REDPACK_EARN_CAR, 4).
-define(STICKINESS_REDPACK_EARN_AIRLABA, 5).
%%=======================================================================

-endif.
