-ifndef(NIU_ROOM_HRL).
-define(NIU_ROOM_HRL, true).

-include("predef.hrl").

-define(NIU_ROOM_STATE_IDEL_0, niu_room_state_idel).
-define(NIU_ROOM_STATE_WAITING_PLAYER_ENTER_10, niu_room_state_10).
-define(NIU_ROOM_STATE_WAITING_START_11, niu_room_state_11).

-define(NIU_ROOM_STATE_CHOOSE_MASTER_SEND_CARD_20, niu_room_state_20).
-define(NIU_ROOM_STATE_CHOOSE_MASTER_SET_MASTER_21, niu_room_state_21).

-define(NIU_ROOM_STATE_FREE_USER_SET_RATE_30, niu_room_state_30).
-define(NIU_ROOM_STATE_COMPARE_CARD_40, niu_room_state_40).
-define(NIU_ROOM_STATE_SETTLEMENT_50, niu_room_state_50).

-define(NIU_ROOM_STATE_REDPACK_ROOM_60, niu_room_state_60).

-define(ROOM_TEST_LEVEL_LIST, [1,2,3,4,5,6, 10]).		%% 房间等级 10=红包场
-define(REDPACK_ROOM_LEVEL, 10).		%% 红包场level


-define(ROOM_INIT_PROC_NUM_PER_LEVEL, 3).		%% 每等级初始化n条进程

-define(ROOM_LEVEL_1_TICKET_COST,  100).		%% 消耗
-define(ROOM_LEVEL_2_TICKET_COST,  200).		%% 消耗
-define(ROOM_LEVEL_3_TICKET_COST,  1000).		%% 消耗
-define(ROOM_LEVEL_4_TICKET_COST,  2000).		%% 消耗
-define(ROOM_LEVEL_5_TICKET_COST,  5000).		%% 消耗
-define(ROOM_LEVEL_6_TICKET_COST,  10000).		%% 消耗

-define(ROOM_LEVEL_1_BASE_NUM,  100).		%% 底分
-define(ROOM_LEVEL_2_BASE_NUM,  100).		%% 底分
-define(ROOM_LEVEL_3_BASE_NUM,  500).		%% 底分
-define(ROOM_LEVEL_4_BASE_NUM,  1000).		%% 底分
-define(ROOM_LEVEL_5_BASE_NUM,  2000).		%% 底分
-define(ROOM_LEVEL_6_BASE_NUM,  5000).		%% 底分

%% 赔率
-define(ODDS_NUM_LIST, [{ 0, 1},{ 1, 1},{ 2, 1},{ 3, 1},{ 4, 1},{ 5, 1},{ 6, 1},{ 7, 2},{ 8, 2},{ 9, 2},{10, 3},{11, 4},{12, 5},{13, 8}]).
-define(DRAW_RATE, 0.90).		%% 抽水
%-define(DRAW_RATE, 1).		%% 抽水

%% 房间区间
-define(ROOM_TRRESHOLD_CONFIG,
	[{1,{2000, 50000}},{ 2,{10000, 100000}},{ 3,{50000, 300000}},{ 4,{100000, 500000}},{ 5,{100000, 1000000000}},{ 6,{500000, 1000000000}}]).
%% %% 房间区间
%% -define(ROBOT_ROOM_TRRESHOLD_CONFIG,
%% 	[{0, {0, 2000}}, {1,{2001, 50000}},{ 2,{50001, 100000}},{ 3,{100001, 300000}},{ 4,{300001, 500000}},{ 5,{500001, 1000000}},{ 6,{1000001, 10000000000}}]).

%% 房间区间
-define(ROBOT_ROOM_TRRESHOLD_CONFIG,
	[
		{[true, false, false, false, false, false, false], {0, 2000}},
		{[false, true, false, false, false, false, false], {2001, 10000}}, %% 1
		{[false, true, true, false, false, false, false], {10001, 50000}}, %% 1,2
		{[false, false, true, true, false, false, false], {50001, 100000}}, %% 2,3
		{[false, false, false, true, true, true, false], {100001, 300000}}, %% 3,4,5
		{[false, false, false, false, true, true, false], {300001, 500000}}, %% 4,5
		{[false, false, false, false, false, true, true], {500001, 9999000000}} %% 5,6
	]).

-define(TIMER_SEC_IN_WAITING_PLAYER_ENTER_10, 5).		%% 1人时等待其他人进入
-define(TIMER_SEC_IN_WAITING_WAITING_START_11, 5).		%% 等待开始
-define(TIMER_SEC_IN_CHOOSE_MASTER_SEND_CARD_20, 8).		%% 发牌
-define(TIMER_SEC_IN_CHOOSE_MASTER_SET_MASTER_21, 5).		%% 抢庄
-define(TIMER_SEC_IN_FREE_USER_SET_RATE_30, 5).		%% 闲家下注
-define(TIMER_SEC_IN_COMPARE_CARD_40, 8).		%% 比牌
-define(TIMER_SEC_IN_SETTLEMENT_50, 8).		%% 结算

-define(CARD_TYPE_LIST, [
	{ 1 , {1 ,1}},{ 2 , {2 ,1}},{ 3 , {3 ,1}},{ 4 , {4 ,1}},{ 5 , {5 ,1}},{ 6 , {6 ,1}},{ 7 , {7 ,1}},{ 8 , {8 ,1}},{ 9 , {9 ,1}},{ 10, {10,1}},{ 11, {11,1}},{ 12, {12,1}},{ 13, {13,1}},
	{ 14, {1 ,2}},{ 15, {2 ,2}},{ 16, {3 ,2}},{ 17, {4 ,2}},{ 18, {5 ,2}},{ 19, {6 ,2}},{ 20, {7 ,2}},{ 21, {8 ,2}},{ 22, {9 ,2}},{ 23, {10,2}},{ 24, {11,2}},{ 25, {12,2}},{ 26, {13,2}},
	{ 27, {1 ,3}},{ 28, {2 ,3}},{ 29, {3 ,3}},{ 30, {4 ,3}},{ 31, {5 ,3}},{ 32, {6 ,3}},{ 33, {7 ,3}},{ 34, {8 ,3}},{ 35, {9 ,3}},{ 36, {10,3}},{ 37, {11,3}},{ 38, {12,3}},{ 39, {13,3}},
	{ 40, {1 ,4}},{ 41, {2 ,4}},{ 42, {3 ,4}},{ 43, {4 ,4}},{ 44, {5 ,4}},{ 45, {6 ,4}},{ 46, {7 ,4}},{ 47, {8 ,4}},{ 48, {9 ,4}},{ 49, {10,4}},{ 50, {11,4}},{ 51, {12,4}},{ 52, {13,4}}
]).		% 牌型


-define(SEND_ALL_PLAYER_INFO_UPDATE_FLAG, send_all_player_info_update_flag).	%% 每轮的同步玩家信息标志

%% 红包场
-define(REDPACK_SEC_IN_WAITING_PLAYER_ENTER_10, 4).		%% 1人时等待其他人进入
-define(REDPACK_SEC_IN_WAITING_START_11, 2).		%% 准备开始
-define(REDPACK_SEC_IN_CHOOSE_MASTER_SEND_CARD_20, 7).		%% 发牌
-define(REDPACK_SEC_IN_CHOOSE_MASTER_SET_MASTER_21, 5).		%% 抢庄
-define(REDPACK_SEC_IN_COMPARE_CARD_40, 8).		%% 比牌
-define(REDPACK_SEC_IN_SETTLEMENT_50, 8).		%% 结算

-define(REDPACK_ODDS_NUM_LIST, [{ 0, 1},{ 1, 1},{ 2, 1},{ 3, 1},{ 4, 1},{ 5, 2},{ 6, 2},{ 7, 2},{ 8, 2},{ 9, 3},{10, 3},{11, 3},{12, 3},{13, 3}]).


-endif.