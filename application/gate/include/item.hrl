-ifndef(ITEM_HRL).
-define(ITEM_HRL, true).

-include("predef.hrl").

-define(GOLD_NUM_LIMIT, 9999999999).	%% 金币最大堆叠
-define(ITEM_NUM_LIMIT, 999999999).	%% 物品(非金币)最大堆叠

-define(ITEM_ID_GOLD, 101).	%% 金币
-define(ITEM_ID_DIAMOND,  102).	%% 钻石
-define(ITEM_ID_CASH,  103).		%% 现金
-define(ITEM_ID_PHONE_CARD_100,  107).  %% 花费券
-define(ITEM_ID_RED_PACK,  109).	%% 红包Id
-define(ITEM_ID_PLAYER_EXP,  201).		%% 玩家经验
-define(ITEM_ID_RMB,  202).		%% 充值人民币
-define(ITEM_ID_AIRLABA_RAGE, 301). % 狂暴
-define(ITEM_ID_AIRLABA_AUTOAIM, 302). % 自动瞄准
-define(ITEM_ID_AIRLABA_CAPTAINSHIELD, 303). % 美队
-define(ITEM_ID_AIRLABA_STARBURST, 304). % 星爆
-define(ITEM_ID_AIRLABA_CARPETBOMB, 305). % 轰炸

-define(AIRLABA_ITEM_IDS, [?ITEM_ID_AIRLABA_RAGE, ?ITEM_ID_AIRLABA_AUTOAIM,
    ?ITEM_ID_AIRLABA_CAPTAINSHIELD, ?ITEM_ID_AIRLABA_STARBURST, ?ITEM_ID_AIRLABA_CARPETBOMB]). % airlaba相关物品 id

-define(PERIOD_CARD_TYPE_WEEK, 0). % 周卡


-define(ITEM_ID_CHANGE_NAME_CARD,  100001).	%% 改名卡

-define(SHOP_ITEM_ID_1YUAN_RANDOM_REWARD, 10015). % 1 元随机金币
-define(SHOP_ITEM_ID_FIRST_RECHARGE_BAG, 50001).		%% 首充礼包
-define(SHOP_ITEM_ID_FIRST_RECHARGE_BAG_2, 50002).		%% 首充礼包
-define(SHOP_ITEM_ID_FIRST_RECHARGE_BAG_3, 50003).      %% 首充礼包
-define(SHOP_ITEM_ID_MONTH_CARD, 60001).		%% 月卡商品id
-define(SHOP_ITEM_ID_WEEK_CARD, 60002). % 周卡 id
-define(SHOP_ITEM_ID_SALARY, 60003). % 工资
-define(SHOP_ITEM_ID_DIAMOND_FUDAI, 70001).		%% 钻石福袋
-define(SHOP_ITEM_ID_DIAMOND_FUDAI_DAILY, 70002).		%% 钻石福袋
-endif.