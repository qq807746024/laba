-ifndef(SC_ITEMS_UPDATE_PB_H).
-define(SC_ITEMS_UPDATE_PB_H, true).
-record(sc_items_update, {
    upd_list = []
}).
-endif.

-ifndef(SC_ITEMS_ADD_PB_H).
-define(SC_ITEMS_ADD_PB_H, true).
-record(sc_items_add, {
    add_list = []
}).
-endif.

-ifndef(SC_ITEMS_DELETE_PB_H).
-define(SC_ITEMS_DELETE_PB_H, true).
-record(sc_items_delete, {
    del_list = []
}).
-endif.

-ifndef(SC_ITEMS_INIT_UPDATE_PB_H).
-define(SC_ITEMS_INIT_UPDATE_PB_H, true).
-record(sc_items_init_update, {
    all_list = []
}).
-endif.

-ifndef(PB_ITEM_INFO_PB_H).
-define(PB_ITEM_INFO_PB_H, true).
-record(pb_item_info, {
    uuid = erlang:error({required, uuid}),
    base_id = erlang:error({required, base_id}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_ITEM_USE_REQ_PB_H).
-define(CS_ITEM_USE_REQ_PB_H, true).
-record(cs_item_use_req, {
    item_uuid = erlang:error({required, item_uuid}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(SC_ITEM_USE_REPLY_PB_H).
-define(SC_ITEM_USE_REPLY_PB_H, true).
-record(sc_item_use_reply, {
    result = erlang:error({required, result}),
    err_msg = erlang:error({required, err_msg})
}).
-endif.

-ifndef(PB_REWARD_INFO_PB_H).
-define(PB_REWARD_INFO_PB_H, true).
-record(pb_reward_info, {
    base_id = erlang:error({required, base_id}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(SC_SHOP_ALL_ITEM_BASE_CONFIG_PB_H).
-define(SC_SHOP_ALL_ITEM_BASE_CONFIG_PB_H, true).
-record(sc_shop_all_item_base_config, {
    item_list = []
}).
-endif.

-ifndef(PB_SHOP_ITEM_PB_H).
-define(PB_SHOP_ITEM_PB_H, true).
-record(pb_shop_item, {
    id = erlang:error({required, id}),
    shop_type = erlang:error({required, shop_type}),
    item_id = erlang:error({required, item_id}),
    item_num = erlang:error({required, item_num}),
    item_extra_num = erlang:error({required, item_extra_num}),
    cost_list = [],
    discount = erlang:error({required, discount}),
    special_flag = erlang:error({required, special_flag}),
    start_time = erlang:error({required, start_time}),
    end_time = erlang:error({required, end_time}),
    limit_times = erlang:error({required, limit_times}),
    vip_limit = erlang:error({required, vip_limit}),
    left_times = erlang:error({required, left_times}),
    icon = erlang:error({required, icon}),
    name = erlang:error({required, name}),
    sort = erlang:error({required, sort})
}).
-endif.

-ifndef(PB_COST_TYPE_AND_NUM_PB_H).
-define(PB_COST_TYPE_AND_NUM_PB_H, true).
-record(pb_cost_type_and_num, {
    cost_type = erlang:error({required, cost_type}),
    cost_num = erlang:error({required, cost_num})
}).
-endif.

-ifndef(CS_SHOP_BUY_QUERY_PB_H).
-define(CS_SHOP_BUY_QUERY_PB_H, true).
-record(cs_shop_buy_query, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(SC_SHOP_BUY_REPLY_PB_H).
-define(SC_SHOP_BUY_REPLY_PB_H, true).
-record(sc_shop_buy_reply, {
    result = erlang:error({required, result}),
    err_msg,
    rewards = [],
    left_times = erlang:error({required, left_times}),
    id = erlang:error({required, id})
}).
-endif.

-ifndef(SC_GOLDEN_BULL_INFO_UPDATE_PB_H).
-define(SC_GOLDEN_BULL_INFO_UPDATE_PB_H, true).
-record(sc_golden_bull_info_update, {
    left_times = erlang:error({required, left_times})
}).
-endif.

-ifndef(CS_GOLDEN_BULL_DRAW_REQ_PB_H).
-define(CS_GOLDEN_BULL_DRAW_REQ_PB_H, true).
-record(cs_golden_bull_draw_req, {
    key = erlang:error({required, key})
}).
-endif.

-ifndef(SC_GOLDEN_BULL_DRAW_REPLY_PB_H).
-define(SC_GOLDEN_BULL_DRAW_REPLY_PB_H, true).
-record(sc_golden_bull_draw_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(SC_MONTH_CARD_INFO_UPDATE_PB_H).
-define(SC_MONTH_CARD_INFO_UPDATE_PB_H, true).
-record(sc_month_card_info_update, {
    today_draw_flag = erlang:error({required, today_draw_flag}),
    left_times = erlang:error({required, left_times})
}).
-endif.

-ifndef(CS_MONTH_CARD_DRAW_REQ_PB_H).
-define(CS_MONTH_CARD_DRAW_REQ_PB_H, true).
-record(cs_month_card_draw_req, {
    
}).
-endif.

-ifndef(SC_MONTH_CARD_DRAW_REPLY_PB_H).
-define(SC_MONTH_CARD_DRAW_REPLY_PB_H, true).
-record(sc_month_card_draw_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(SC_PERIOD_CARD_INFO_UPDATE_PB_H).
-define(SC_PERIOD_CARD_INFO_UPDATE_PB_H, true).
-record(sc_period_card_info_update, {
    type = erlang:error({required, type}),
    today_draw_flag = erlang:error({required, today_draw_flag}),
    left_times = erlang:error({required, left_times})
}).
-endif.

-ifndef(CS_PERIOD_CARD_DRAW_REQ_PB_H).
-define(CS_PERIOD_CARD_DRAW_REQ_PB_H, true).
-record(cs_period_card_draw_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_PERIOD_CARD_DRAW_REPLY_PB_H).
-define(SC_PERIOD_CARD_DRAW_REPLY_PB_H, true).
-record(sc_period_card_draw_reply, {
    type = erlang:error({required, type}),
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(CS_CASH_TRANSFORMATION_REQ_PB_H).
-define(CS_CASH_TRANSFORMATION_REQ_PB_H, true).
-record(cs_cash_transformation_req, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(SC_CASH_TRANSFORMATION_REPLY_PB_H).
-define(SC_CASH_TRANSFORMATION_REPLY_PB_H, true).
-record(sc_cash_transformation_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(CS_GOLDEN_BULL_MISSION_PB_H).
-define(CS_GOLDEN_BULL_MISSION_PB_H, true).
-record(cs_golden_bull_mission, {
    
}).
-endif.

-ifndef(SC_GOLDEN_BULL_MISSION_PB_H).
-define(SC_GOLDEN_BULL_MISSION_PB_H, true).
-record(sc_golden_bull_mission, {
    process = erlang:error({required, process})
}).
-endif.

