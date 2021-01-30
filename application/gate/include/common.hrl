
-include_lib("util/include/util.hrl").
-include("predef.hrl").
-include("record.hrl").
-include("language.hrl").
-include("item.hrl").
-include("hero.hrl").
-include("log.hrl").
-include("logger.hrl").

-define(APP, gate).

-define(P(S), io:format(S)).
-define(P(F, A), io:format(F, A)).

%% -define(P(S), ok).
%% -define(P(F, A), ok).

-define(STACK_TRACE, try throw("") catch _:_ -> io:format("~n Pid:~p, get_stacktrace:~p", [self(), erlang:get_stacktrace()]) end).
-define(MAKE_FUN(Expr), fun() -> Expr end).
-define(RECORD_DEFAULT(R, T), (#R{})#R.T).

-define(HOUR_SECOND,                    3600).      % 一小时秒数

-define(PLAYER_ICON_DEFAULT, 			"").		% 玩家默认头像

%% ----- ETS -----
-define(ETS_ONLINE,                                 ets_online).                                % 在线玩家
-define(ETS_ROLE_PID,                               ets_role_pid).                              % 在线玩家pid
-define(ETS_BASE_ITEM,                              ets_base_item).                             % 物品模板Id

-define(ETS_NIUNIU_ROOM,							ets_niuniu_room).					% 牛牛房间数据
-define(ETS_NIUNIU_PLAYER_IN_GAME, 	ets_niuniu_player_in_game).		%% 玩家在游戏中记录

-define(ETS_SHOP_ITEM ,ets_shop_item).  %%玩家商店物品表
-define(ETS_HUNDRED_ROOM,							ets_hundred_room).					% 百人房间
-define(ETS_HUNDRED_PLAYER_IN_GAME, 	ets_hundred_player_in_game).		%% 玩家在游戏中记录

-define(ETS_DAILY_EARN_GOLD_RANK_REWARD_CONFIG,  ets_daily_earn_gold_rank_reward_config). %% 每日赚金奖励配置
-define(ETS_CAR_EARN_GOLD_RANK_REWARD_CONFIG, ets_car_earn_gold_rank_reward_config). % 豪车赚金排行榜配置
-define(ETS_HUNDRED_NIU_EARN_GOLD_RANK_REWARD_CONFIG, ets_hundred_niu_earn_gold_rank_reward_config). % 百人牛赚金榜配置
-define(ETS_AIRLABA_BET_GOLD_RANK_REWARD_CONFIG, ets_airlaba_bet_gold_rank_reward_config). % 空战 laba 赚金榜配置

%% 排行榜类型
-define(ETS_RANK_GOLD_1,            			ets_rank_gold_1).           			% 金币排行榜
-define(ETS_RANK_PROFIT_2,            				ets_rank_profit_2).           				% 盈利
-define(ETS_RANK_DIAMOND_3,            				ets_rank_cash_3).           				% 钞票

-define(ETS_RANK_HUNDRED_TOTAL,            				ets_rank_hundred_total).           				% 百人排行 总盈利
-define(ETS_RANK_HUNDRED_ONE_ROUND,            				ets_rank_hundred_one_round).           				% 百人排行 单局获利最多
-define(ETS_RANK_HUNDRED_LAST_WEEK,            				ets_rank_hundred_last_week).           				% 上周奖励统计
-define(ETS_RANK_RECHARGE_ACTIVITY,           ets_rank_recharge_activity). % 充值返利活动

%% 奖品库存
-define(ETS_PRIZE_STORAGE_INFO,            				ets_prize_storage_info).
%% 金币库存
-define(ETS_GOLD_DEPOT_INFO,            				ets_depot_info).

-define(ETS_RED_PACK,                        ets_red_pack).            %红包
-define(ETS_PLAYER_RED_PACK_SEARCH_KEY,      ets_player_red_pack_search_key).

-define(ETS_ALL_NORMAL_ROBOT, 				ets_all_normal_robot).				%% 普通机器人
-define(ETS_REDPACK_ROOM_CONFIG, 				ets_redpack_room_config).				%% 红包场配置
-define(ETS_HUNDRED_REROLL_CONFIG, 				ets_hundred_reroll_config).				%% 重摇配置

-define(ETS_CONST_CONFIG, 				ets_const_config).				%% 服务端常量控制
-define(ETS_MISSION_BASE,ets_mission_base).
-define(ETS_ACTIVITY_CHNID_CONFIG,ets_activity_chnid_config). %活动渠道表
-define(ETS_ACTIVITY_GOLD_CHNID_CONFIG,ets_activity_gold_chnid_config). %一本万利活动渠道表

-define(ETS_LAST_WIN_POOL_PLAYER, ets_last_win_pool_player).  %% 水果中奖人
-define(ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER, ets_last_win_pool_super_laba_player). %% 超级水果中奖人


-define(ETS_SHARE_CODE,     ets_share_code).        %%邀请码
%--------豪车--------------
-define(ETS_CAR_ROOM,							ets_car_room).					% 豪车房间数据
-define(ETS_CAR_PLAYER_IN_GAME, 	ets_car_player_in_game).		%% 玩家在游戏中记录
%-------------
-define(ETS_NIU_BLACKLIST, 	ets_niu_blacklist).		%% 看牌黑名单
-define(ETS_HUNDRED_CONTROL_BY_POOL, 	ets_hundred_control_by_pool).		%% 百人控制
-define(ETS_NIU_CONTROL_BY_WINGOLD, 	ets_niu_control_by_wingold).		%% 看牌控制
% ----------------
-define(ETS_LUCKY_BAG, ets_lucky_bag).		                    %% 福袋池
-define(ETS_REDPACK_ROTATION, ets_redpack_rotation).		        %% 红包轮换表
-define(ETS_HUNDRED_CHANGE_CARDS_CONFIG, ets_hundred_change_cards_config). %% 百人结果控制
-define(ETS_SHARE_TIMES_LIMIT, ets_share_times_limit).		                    %% 分享次数限制（添邀请码）
%----------------
-define(ETS_RANK_MOD_TIME_CACHE, ets_rank_mod_time_cache). % 时间计算缓存

%%--------水果--------
-define(ETS_LABA_PLAYER_INFO, 	ets_laba_player_info).		%% 拉拔玩家信息
-define(ETS_SUPER_LABA_PLAYER_INFO, ets_super_laba_player_info).	%% 超级拉霸玩家信息
-define(ETS_LABA_FRUIT_CONFIG, 	ets_laba_fruit_config).		%% 拉吧水果配置
-define(ETS_SUPER_LABA_FRUIT_CONFIG, 	ets_super_laba_fruit_config).		%% 超级拉吧水果配置
-define(ETS_LABA_RATE_LIST_1, ets_laba_rate_list_1).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_2, ets_laba_rate_list_2).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_3, ets_laba_rate_list_3).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_4, ets_laba_rate_list_4).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_5, ets_laba_rate_list_5).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_6, ets_laba_rate_list_6).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_7, ets_laba_rate_list_7).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_8, ets_laba_rate_list_8).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_9, ets_laba_rate_list_9).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_10, ets_laba_rate_list_10).                        %% 水果元素权重
-define(ETS_LABA_RATE_LIST_BLACK_ROOM, ets_laba_rate_list_black_room).        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_1, ets_laba_t2_rate_list_1).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_2, ets_laba_t2_rate_list_2).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_3, ets_laba_t2_rate_list_3).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_4, ets_laba_t2_rate_list_4).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_5, ets_laba_t2_rate_list_5).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_6, ets_laba_t2_rate_list_6).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_7, ets_laba_t2_rate_list_7).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_8, ets_laba_t2_rate_list_8).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_9, ets_laba_t2_rate_list_9).                        %% 水果元素权重
-define(ETS_LABA_T2_RATE_LIST_10, ets_laba_t2_rate_list_10).                        %% 水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_1, ets_super_laba_rate_list_1).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_2, ets_super_laba_rate_list_2).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_3, ets_super_laba_rate_list_3).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_4, ets_super_laba_rate_list_4).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_5, ets_super_laba_rate_list_5).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_6, ets_super_laba_rate_list_6).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_7, ets_super_laba_rate_list_7).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_8, ets_super_laba_rate_list_8).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_9, ets_super_laba_rate_list_9).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_RATE_LIST_10, ets_super_laba_rate_list_10).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_1, ets_super_laba_t2_rate_list_1).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_2, ets_super_laba_t2_rate_list_2).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_3, ets_super_laba_t2_rate_list_3).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_4, ets_super_laba_t2_rate_list_4).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_5, ets_super_laba_t2_rate_list_5).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_6, ets_super_laba_t2_rate_list_6).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_7, ets_super_laba_t2_rate_list_7).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_8, ets_super_laba_t2_rate_list_8).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_9, ets_super_laba_t2_rate_list_9).                  %% 超级水果元素权重
-define(ETS_SUPER_LABA_T2_RATE_LIST_10, ets_super_laba_t2_rate_list_10).                  %% 超级水果元素权重
-define(ETS_LABA_POOL_REWARD_CONFIG_LIST,           ets_laba_pool_reward_config_list).                 %% 水果辅助控制
-define(ETS_LABA_CONST_LIST,                        ets_laba_const_list).                       %% 水果税率和参数
-define(ETS_HUNDRED_NIU_CONST_LIST,                 ets_hundred_niu_const_list).                %% 百人常量
-define(ETS_CAR_CONST_LIST,                         ets_car_const_list).                        %% 豪车常量
-define(ETS_FRUIT_POOL_CONFIG,                      ets_fruit_pool_config).                     %% 水果水池设置
-define(ETS_BET_STICKINESS_REDPACK_CONFIG,          ets_bet_stickiness_redpack_config).         %% 下注粘性红包配置
-define(ETS_BET_LOCK_CONFIG,                        ets_bet_lock_config).                       %% 下注锁配置
-define(ETS_FRUIT_FRESHER_PROTECT_CONFIG,           ets_fruit_fresher_protect_config).          %% 水果新手保护配置
-define(ETS_SUPER_FRUIT_FRESHER_PROTECTED_CONFIG,   ets_super_fruit_fresher_protect_config).    %% 超级水果新手保护配置
-define(ETS_FRUIT_FRESHER_WELFARE_CONFIG,           ets_fruit_fresher_welfare_config).          %% 水果新手福利
-define(ETS_SUPER_FRUIT_FRESHER_WELFARE_CONFIG,     ets_super_fruit_fresher_welfare_config).    %% 水果新手福利
-define(ETS_AIRLABA_PLANE_CONFIG,                   ets_airlaba_plane_config).                  %% 空战 laba 飞机配置
-define(ETS_AIRLABA_ABPOOL_CONFIG,                  ets_airlaba_abpool_config).                 %% 空战 laba 水池配置
-define(ETS_AIRLABA_CONST_CONFIG,                   ets_airlaba_const_config).                  %% 空战 laba 常量配置
-define(ETS_AIRLABA_IMPOV_SUB_CONFIG,               ets_airlaba_impov_sub_config).              %% 空战 laba 破产补助配置
-define(ETS_AIRLABA_ITEM_INFO,                      ets_airlaba_item_info).                     %% 空战 laba 物品配置
-define(ETS_LOTTERY_CONFIG,                         ets_lottery_config).                        %% 抽奖配置
-define(ETS_LOTTERY_CONFIG_PROTO_PACKED,            ets_lottery_config_proto_packed).           %% 抽奖配置（协议缓存）

%% ets名 缓存mysql rec
-define(MLOG_ETS_GM_error,           mlog_ets_gm_error).      % gm命令
-define(MLOG_ETS_GM_success,           mlog_ets_gm_success).      % gm命令
-define(MLOG_ETS_ITEM_USE,           mlog_ets_item_use).      % 物品使用
-define(MLOG_ETS_PRIZE_EXCHANGE,           mlog_ets_prize_exchange).      % 实物
-define(MLOG_ETS_PRIZE_EXCHANGE_ERR,           mlog_ets_prize_exchange_err).      % 实物领取错误日志
-define(MLOG_ETS_HUNDRED_SETTLEMENT,           mlog_ets_hundred_settlement).      % 百人结算
-define(MLOG_ETS_CAR_SETTLEMENT,           mlog_ets_car_settlement).      % 豪车结算

-define(STATISTIC_LOG_ETS_TABLE, 				statistic_log_ets_table).				%% 玩家行为统计 (保留)


%% 服务器类型
-define(SERVER_TYPE_DEV,        0).                         % 开发服
-define(SERVER_TYPE_RELEASE,    1).                         % 正式服

%%const_config的key
-define(CONST_CONFIG_KEY_SUBSIDY_GOLD_NUM,1).        %%救济每次领取金币数量
-define(CONST_CONFIG_KEY_SUBSIDY_DAILY_TIMES,2).    %%每日救济次数
-define(CONST_CONFIG_KEY_CREATE_ROLE_GOLD,3).    %%初始默认金币数量
-define(CONST_CONFIG_KEY_CREATE_ROLE_DIAMOND,4). %%初始默认钻石数量
-define(CONST_CONFIG_KEY_SUBSIDY_CONDITION,5).      %%金币不足XXX时可领取救济
-define(CONST_CONFIG_KEY_BIND_PHONE_REWRAD_NUM,6). %%手机号绑定或注册送额外金币
-define(CONST_CONFIG_KEY_SPE_SUBSIDY_GOLD_NUM,7). %%特别救济每次领取金币数量
-define(CONST_CONFIG_KEY_SPE_SUBSIDY_DAILY_TIMES,8).   %%每日特别救济次数

-define(CONST_CONFIG_KEY_FRUIT_TAX_RATE,9).   %%水果抽税
-define(CONST_CONFIG_KEY_POOL_RATE,10).   %%水果进入奖池

-define(CONST_CONFIG_KEY_MONTH_CARD_DAILY_GEN,11).   %%月卡每日获取奖品
-define(CONST_CONFIG_KEY_FRUIT_FREE_RESET_RATE,12).   %%水果重摇
-define(CONST_CONFIG_KEY_FRUIT_MAX_REWARD,13).   %%水果最大获奖
-define(CONST_CONFIG_KEY_FRUIT_INIT_POOL_NUM,14).   %%水果奖池初始值
-define(CONST_CONFIG_KEY_SHARE_CODE_NEWBEE_REWARD,17).   %%新人奖励得1000金币
-define(CONST_CONFIG_KEY_CAR_POOL_REWARD_BASE_NUM,21).   %%豪车每股压线
-define(CONST_CONFIG_KEY_HUNDRED_ONE_ROUND_WIN_LIMIT,22). %% 百人每日榜上榜条件
-define(CONST_CONFIG_KEY_REDPACK_RELIVE_COST,23). %% 千人抢红包花费1W金币复活
-define(CONST_CONFIG_KEY_FUDAI_POOL_REWARD_LIMIT,24). %% 福袋发放条件：袋里大等于6块才会发放
-define(CONST_CONFIG_KEY_FUDAI_REWARD_RATE,25).   %% 福袋发放概率
-define(CONST_CONFIG_KEY_CASH_TO_GOLD,26).   %% 1奖券兑换金币
-define(CONST_CONFIG_KEY_REAL_NAME,27).   %% 实名制奖励
-define(CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD,28).   %% 首充红包奖励
-define(CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD_2, 29). %% 首充红包奖励
-define(CONST_CONFIG_KEY_CUSTOMER_SERVICE_QQ, 30). %% 客服 QQ
-define(CONST_CONFIG_KEY_PERIOD_CARD_WEEK_DAILY_GEN, 31).   %%周卡每日获取奖品
-define(CONST_CONFIG_KEY_DIAMOND_FUDAI_DAILY, 32).   %% 每日限购一次的钻石福袋奖励
-define(CONST_CONFIG_KEY_HUNDRED_NIU_POOL_REWARD_LIMIT_NUM, 33). % 百人牛分奖池每股压线
-define(CONST_CONFIG_KEY_CARPOOL_DIV_MIN_LIMIT, 34). % 豪车奖池瓜分下限
-define(CONST_CONFIG_KEY_HUNDRED_NIU_POOL_DIV_PERCENT, 35). % 百人牛奖池瓜分百分比
-define(CONST_CONFIG_KEY_DAILY_SALARY_EARN_PEC, 36). % 工资和昨日累赢的百分比
-define(CONST_CONFIG_KEY_ADREWARD_ITEM, 37). % 看广告视频奖励配置
-define(CONST_CONFIG_KEY_1YUAN_RANDOM_REWARD, 38). % 1 元随机红包
-define(CONST_CONFIG_NEWPLAYER_GUIDE_REWARD, 39). % 新手引导奖励
-define(CONST_CONFIG_LABA_FIRST_ROLL_BETSTICKINESS_OFFSET, 40). % 拉霸第一次下注
-define(CONST_CONFIG_KEY_FIRST_BUY_REDPACK_REWARD_3, 41). % 首充第三档
-define(CONST_CONFIG_KEY_PLAYER_MISSION_CLEAN_TIME, 42). % 玩家任务记录清楚配置（时间）
-define(CONST_CONFIG_KEY_AIRLABA_POOL_DEFAULT_VAL, 43). % 空战 laba 奖池默认值{奖池，排行榜}
-define(CONST_CONFIG_KEY_AIRLABA_TMP_DBBUF_SYNC_DELAY, 44). %% 空战 laba 用户小数据同步延迟
-define(CONST_CONFIG_KEY_AIRLABA_NEW_PLAYER_PERSONAL_POOL, 45). % 空战 laba 新手用户个人水池福利
-define(CONST_CONFIG_KEY_LOTTERY_CONFIG, 46). % 抽奖配置
-define(CONST_CONFIG_KEY_LABA_BLACK_ROOM, 47). % laba小黑屋


-define(MIN_ANNOUNCEMNET_GOLD, 1000000).	%% 百人 水果 上公告的最小赢钱数 ---》 大哥，你这个注释是认真的吗

%%% 活动配置
-define(ACTIVITY_TYPE_NIU, 1).	%% 牛牛
-define(ACTIVITY_TYPE_FRUIT, 2).	%% 水果


%% httplog 房间类型id
-define(HTTP_LOG_ROOM_TYPE_NIU, 10).	%% 抢庄
-define(HTTP_LOG_ROOM_TYPE_HUNDRED, 2).	%% 百人
-define(HTTP_LOG_ROOM_TYPE_FRUIT, 3).	%% 水果
-define(HTTP_LOG_ROOM_TYPE_HAOCAR, 4).	%% 豪车
-define(HTTP_LOG_ROOM_TYPE_REDPACK, 5).	%% 千人红包场
-define(HTTP_LOG_ROOM_TYPE_SUPER_LABA, 6).	%% 超级水果
-define(HTTP_LOG_ROOM_TYPE_AIRLABA, 7). %% airlaba
-define(HTTP_LOG_ROOM_TYPE_SUPER_AIRLABA, 8). %% 超级 airlaba

-define(TEST_TYPE_UNIFIED, 0). % 房间类型--无差别
-define(TEST_TYPE_TRY_PLAY, 1). % 试玩
-define(TEST_TYPE_ENTERTAINMENT, 2). % 娱乐
-define(TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM, 1000000). % 渠道数据最小值
-define(TEST_TYPE_TRY_PLAY_CHNL_MAX_NUM, 9999999). % 渠道数据最大值

-define(RANK_TYPE_GOLD, 1). % 金币排行榜类似
-define(RANK_TYPE_WIN_GOLD, 2). % 赚金排行榜类型
-define(RANK_TYPE_DIAMOND, 3). % 钻石排行榜类型
-define(RANK_TYPE_FRUIT, 6). % 水果排行榜类型
-define(RANK_TYPE_FRUIT_YL, 7). % 水果排行榜类型[2020-11-10新增娱乐场排行]
-define(RANK_TYPE_CAR, 8). % 豪车赚金排行榜
-define(RANK_TYPE_HUNDRED_NIU, 9). % 百人牛牛赚金排行榜
-define(RANK_TYPE_REDPACK, 10). % 红包排行榜类型
-define(RANK_TYPE_AIRLABA_EARN, 11). % 空战 laba 赚金排行榜类型
-define(RANK_TYPE_AIRLABA_BET, 12). % 空战 laba 下注排行榜