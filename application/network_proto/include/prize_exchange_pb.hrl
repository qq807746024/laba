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

-ifndef(SC_PRIZE_CONFIG_UPDATE_PB_H).
-define(SC_PRIZE_CONFIG_UPDATE_PB_H, true).
-record(sc_prize_config_update, {
    list = []
}).
-endif.

-ifndef(PB_PRIZE_INFO_PB_H).
-define(PB_PRIZE_INFO_PB_H, true).
-record(pb_prize_info, {
    obj_id = erlang:error({required, obj_id}),
    name = erlang:error({required, name}),
    need_item_id = erlang:error({required, need_item_id}),
    need_item_num = erlang:error({required, need_item_num}),
    need_vip_level = erlang:error({required, need_vip_level}),
    icon = erlang:error({required, icon}),
    tag = erlang:error({required, tag}),
    cls = erlang:error({required, cls}),
    dsc = erlang:error({required, dsc}),
    today_buy_times = erlang:error({required, today_buy_times}),
    sort_id = erlang:error({required, sort_id}),
    special_left_times = erlang:error({required, special_left_times})
}).
-endif.

-ifndef(CS_PRIZE_QUERY_ONE_REQ_PB_H).
-define(CS_PRIZE_QUERY_ONE_REQ_PB_H, true).
-record(cs_prize_query_one_req, {
    obj_id = erlang:error({required, obj_id})
}).
-endif.

-ifndef(SC_PRIZE_QUERY_ONE_REPLY_PB_H).
-define(SC_PRIZE_QUERY_ONE_REPLY_PB_H, true).
-record(sc_prize_query_one_reply, {
    obj_id = erlang:error({required, obj_id}),
    day_times_config = erlang:error({required, day_times_config}),
    today_exchange_times = erlang:error({required, today_exchange_times}),
    store_num = erlang:error({required, store_num}),
    crad_num = erlang:error({required, crad_num}),
    special_left_times = erlang:error({required, special_left_times}),
    need_vip_level = erlang:error({required, need_vip_level})
}).
-endif.

-ifndef(CS_PRIZE_EXCHANGE_REQ_PB_H).
-define(CS_PRIZE_EXCHANGE_REQ_PB_H, true).
-record(cs_prize_exchange_req, {
    obj_id = erlang:error({required, obj_id}),
    phone_card_charge_type,
    phone_number,
    address_id
}).
-endif.

-ifndef(SC_PRIZE_EXCHANGE_REPLY_PB_H).
-define(SC_PRIZE_EXCHANGE_REPLY_PB_H, true).
-record(sc_prize_exchange_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    reward = [],
    obj_id = erlang:error({required, obj_id})
}).
-endif.

-ifndef(SC_PRIZE_EXCHANGE_RECORD_UPDATE_PB_H).
-define(SC_PRIZE_EXCHANGE_RECORD_UPDATE_PB_H, true).
-record(sc_prize_exchange_record_update, {
    list = []
}).
-endif.

-ifndef(PB_PRIZE_EXCHANGE_RECORD_PB_H).
-define(PB_PRIZE_EXCHANGE_RECORD_PB_H, true).
-record(pb_prize_exchange_record, {
    id = erlang:error({required, id}),
    record_type = erlang:error({required, record_type}),
    obj_id = erlang:error({required, obj_id}),
    need_item_id = erlang:error({required, need_item_id}),
    need_item_num = erlang:error({required, need_item_num}),
    second_time = erlang:error({required, second_time}),
    recharge_type,
    recharge_state,
    card_number,
    card_psd
}).
-endif.

-ifndef(SC_PRIZE_ADDRESS_INFO_UPDATE_PB_H).
-define(SC_PRIZE_ADDRESS_INFO_UPDATE_PB_H, true).
-record(sc_prize_address_info_update, {
    list = []
}).
-endif.

-ifndef(PB_PRIZE_ADDRESS_INFO_PB_H).
-define(PB_PRIZE_ADDRESS_INFO_PB_H, true).
-record(pb_prize_address_info, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    sex = erlang:error({required, sex}),
    province_name = erlang:error({required, province_name}),
    city_name = erlang:error({required, city_name}),
    address = erlang:error({required, address}),
    phone_number = erlang:error({required, phone_number})
}).
-endif.

-ifndef(CS_PRIZE_ADDRESS_CHANGE_REQ_PB_H).
-define(CS_PRIZE_ADDRESS_CHANGE_REQ_PB_H, true).
-record(cs_prize_address_change_req, {
    new_info = erlang:error({required, new_info})
}).
-endif.

-ifndef(SC_PRIZE_ADDRESS_CHANGE_REPLY_PB_H).
-define(SC_PRIZE_ADDRESS_CHANGE_REPLY_PB_H, true).
-record(sc_prize_address_change_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(SC_PRIZE_STORAGE_RED_POINT_UPDATE_PB_H).
-define(SC_PRIZE_STORAGE_RED_POINT_UPDATE_PB_H, true).
-record(sc_prize_storage_red_point_update, {
    list = []
}).
-endif.

-ifndef(PB_PRIZE_QUERY_ONE_PB_H).
-define(PB_PRIZE_QUERY_ONE_PB_H, true).
-record(pb_prize_query_one, {
    obj_id = erlang:error({required, obj_id}),
    store_num = erlang:error({required, store_num}),
    crad_num = erlang:error({required, crad_num})
}).
-endif.

-ifndef(CS_PRIZE_QUERY_PHONECARD_KEY_REQ_PB_H).
-define(CS_PRIZE_QUERY_PHONECARD_KEY_REQ_PB_H, true).
-record(cs_prize_query_phonecard_key_req, {
    rec_id = erlang:error({required, rec_id})
}).
-endif.

-ifndef(SC_PRIZE_QUERY_PHONECARD_KEY_REPLY_PB_H).
-define(SC_PRIZE_QUERY_PHONECARD_KEY_REPLY_PB_H, true).
-record(sc_prize_query_phonecard_key_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    state = erlang:error({required, state}),
    key = erlang:error({required, key})
}).
-endif.

