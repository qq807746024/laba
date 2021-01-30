-ifndef(PLAYER_LABA_UTIL_HRL).
-define(PLAYER_LABA_UTIL_HRL, true).


-define(LABA_DATA_DICT, laba_data_dic).    %% 玩家字典
-define(SUPERLABA_DATA_DICT, super_laba_data_dic).    %% 超级水果
-define(PLAYER_LABA_WIN_GOLD,player_laba_win_gold).  %% 拉霸赢金

-define(INIT_LABA_LINE_NUM, 9).    %% 初始设置条数
-define(INIT_LABA_LINE_SET_CHIPS, 1).    %% 初始设置押注索引

-define(MIN_LABA_ANNOUNCEMNET_GOLD, 1000000).

-define(REROOL_RATE_LIST_1, [
	{6, 7},
	{1, 7},
	{11, 7},
	{6, 12},
	{6, 2}
]).    % 重摇使用配置

-define(REROOL_RATE_LIST_2, [
	{1, 2},
	{11, 12}
]).    % 重摇使用配置

-define(S_FRUIT_BANANA, 1).    %% 香蕉
-define(S_FRUIT_WILD, 9).    %% 特殊水果 wild
-define(S_FRUIT_BONUS, 10).    %% 特殊水果 橙子
-define(S_FRUIT_777, 11).    %% 特殊水果 7

-ifdef(__COMPILE_SUPERFRUIT).
-define(SET_CHIPS_LIST, [500, 1000, 2500, 5000, 10000, 25000, 50000, 100000, 250000, 500000]).    %% 押注列表
-else.
-define(SET_CHIPS_LIST, [100,500, 2500, 5000, 25000, 50000, 250000, 500000]).    %% 押注列表
-endif.

-ifdef(__COMPILE_SUPERFRUIT).
-define(SET_CHIPS_LIST_SUPER_LABA, [500, 1000, 2500, 5000, 10000, 25000, 50000, 100000, 250000, 500000]).    %% 押注列表
-else.
-define(SET_CHIPS_LIST_SUPER_LABA, [500, 2500, 5000, 25000, 50000, 250000, 500000]).    %% 押注列表
-endif.

%%15条线
-define(LINE_CONFIG_15, [
	{1, 6, 7, 8, 9, 10},
	{2, 1, 2, 3, 4, 5},
	{3, 11, 12, 13, 14, 15},
	{4, 1, 7, 13, 9, 5},
	{5, 11, 7, 3, 9, 15},
	{6, 1, 2, 8, 14, 15},
	{7, 11, 12, 8, 4, 5},
	{8, 6, 12, 8, 4, 10},
	{9, 6, 2, 8, 14, 10},
	{10, 1, 7,	8, 9, 5},
	{11, 6, 2, 3, 4, 10},
	{12, 6, 12, 13, 14,	10},
	{13, 11, 7, 8, 9, 15},
	{14, 1, 12, 3, 14, 5},
	{15, 11, 2, 13, 4, 15}]).
%% 5列
-define(COL_LIST_CONFIG, [{1, 6, 11}, {2, 7, 12}, {3, 8, 13}, {4, 9, 14}, {5, 10, 15}]).
-define(FIX_WIN_POOL_LIST, [{1, 6}, {2, 1}, {3, 11}, {4, 10}, {5, 5}, {6, 11}, {7, 11}, {8, 11}, {9, 1}, {10, 2}, {11, 3}, {12, 1}, {13, 9}, {14, 9}, {15, 5}]).   %% 固定奖池列表

-endif.
