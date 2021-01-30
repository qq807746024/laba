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

-ifndef(CS_CAR_ENTER_REQ_PB_H).
-define(CS_CAR_ENTER_REQ_PB_H, true).
-record(cs_car_enter_req, {
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_CAR_ENTER_REPLY_PB_H).
-define(SC_CAR_ENTER_REPLY_PB_H, true).
-record(sc_car_enter_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(CS_CAR_EXIT_REQ_PB_H).
-define(CS_CAR_EXIT_REQ_PB_H, true).
-record(cs_car_exit_req, {
    
}).
-endif.

-ifndef(SC_CAR_EXIT_REPLY_PB_H).
-define(SC_CAR_EXIT_REPLY_PB_H, true).
-record(sc_car_exit_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(CS_CAR_MASTER_REQ_PB_H).
-define(CS_CAR_MASTER_REQ_PB_H, true).
-record(cs_car_master_req, {
    flag = erlang:error({required, flag}),
    money = erlang:error({required, money})
}).
-endif.

-ifndef(SC_CAR_MASTER_REPLY_PB_H).
-define(SC_CAR_MASTER_REPLY_PB_H, true).
-record(sc_car_master_reply, {
    result = erlang:error({required, result}),
    err,
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(CS_CAR_BET_REQ_PB_H).
-define(CS_CAR_BET_REQ_PB_H, true).
-record(cs_car_bet_req, {
    index = erlang:error({required, index}),
    money = erlang:error({required, money})
}).
-endif.

-ifndef(SC_CAR_BET_REPLY_PB_H).
-define(SC_CAR_BET_REPLY_PB_H, true).
-record(sc_car_bet_reply, {
    result = erlang:error({required, result}),
    err,
    index = erlang:error({required, index}),
    money = erlang:error({required, money}),
    self = erlang:error({required, self})
}).
-endif.

-ifndef(CS_CAR_REBET_REQ_PB_H).
-define(CS_CAR_REBET_REQ_PB_H, true).
-record(cs_car_rebet_req, {
    list = []
}).
-endif.

-ifndef(SC_CAR_REBET_REPLY_PB_H).
-define(SC_CAR_REBET_REPLY_PB_H, true).
-record(sc_car_rebet_reply, {
    result = erlang:error({required, result}),
    err,
    list = []
}).
-endif.

-ifndef(CS_CAR_MASTER_LIST_REQ_PB_H).
-define(CS_CAR_MASTER_LIST_REQ_PB_H, true).
-record(cs_car_master_list_req, {
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(PB_CAR_MASTER_ITEM_PB_H).
-define(PB_CAR_MASTER_ITEM_PB_H, true).
-record(pb_car_master_item, {
    name = erlang:error({required, name}),
    money = erlang:error({required, money}),
    vip = erlang:error({required, vip})
}).
-endif.

-ifndef(CS_CAR_USER_LIST_REQ_PB_H).
-define(CS_CAR_USER_LIST_REQ_PB_H, true).
-record(cs_car_user_list_req, {
    
}).
-endif.

-ifndef(SC_CAR_USER_LIST_REPLY_PB_H).
-define(SC_CAR_USER_LIST_REPLY_PB_H, true).
-record(sc_car_user_list_reply, {
    flag = erlang:error({required, flag}),
    list = []
}).
-endif.

-ifndef(PB_CAR_USER_ITEM_PB_H).
-define(PB_CAR_USER_ITEM_PB_H, true).
-record(pb_car_user_item, {
    name = erlang:error({required, name}),
    money = erlang:error({required, money}),
    vip = erlang:error({required, vip}),
    head = erlang:error({required, head}),
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(SC_CAR_RESULT_HISTORY_REQ_PB_H).
-define(SC_CAR_RESULT_HISTORY_REQ_PB_H, true).
-record(sc_car_result_history_req, {
    list = []
}).
-endif.

-ifndef(PB_CAR_RESULT_HISTORY_ITEM_PB_H).
-define(PB_CAR_RESULT_HISTORY_ITEM_PB_H, true).
-record(pb_car_result_history_item, {
    open_index = erlang:error({required, open_index}),
    result = erlang:error({required, result}),
    pool = erlang:error({required, pool})
}).
-endif.

-ifndef(SC_CAR_MASTER_WAIT_LIST_REPLY_PB_H).
-define(SC_CAR_MASTER_WAIT_LIST_REPLY_PB_H, true).
-record(sc_car_master_wait_list_reply, {
    flag = erlang:error({required, flag}),
    list = []
}).
-endif.

-ifndef(SC_CAR_MASTER_INFO_REPLY_PB_H).
-define(SC_CAR_MASTER_INFO_REPLY_PB_H, true).
-record(sc_car_master_info_reply, {
    self = erlang:error({required, self}),
    name = erlang:error({required, name}),
    money = erlang:error({required, money}),
    score = erlang:error({required, score}),
    count = erlang:error({required, count}),
    head = erlang:error({required, head}),
    vip = erlang:error({required, vip}),
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(SC_CAR_STATUS_REPLY_PB_H).
-define(SC_CAR_STATUS_REPLY_PB_H, true).
-record(sc_car_status_reply, {
    status = erlang:error({required, status}),
    time = erlang:error({required, time})
}).
-endif.

-ifndef(PB_CAR_BET_ITEM_PB_H).
-define(PB_CAR_BET_ITEM_PB_H, true).
-record(pb_car_bet_item, {
    index = erlang:error({required, index}),
    money = erlang:error({required, money})
}).
-endif.

-ifndef(SC_CAR_ROOM_INFO_REPLY_PB_H).
-define(SC_CAR_ROOM_INFO_REPLY_PB_H, true).
-record(sc_car_room_info_reply, {
    masterinfo = erlang:error({required, masterinfo}),
    list = [],
    listself = [],
    result = erlang:error({required, result}),
    self_num = erlang:error({required, self_num}),
    master_num = erlang:error({required, master_num}),
    pool_sub = erlang:error({required, pool_sub}),
    pool = erlang:error({required, pool}),
    bet_limit
}).
-endif.

-ifndef(SC_CAR_HINT_REPLY_PB_H).
-define(SC_CAR_HINT_REPLY_PB_H, true).
-record(sc_car_hint_reply, {
    msg = erlang:error({required, msg})
}).
-endif.

-ifndef(SC_CAR_RESULT_REPLY_PB_H).
-define(SC_CAR_RESULT_REPLY_PB_H, true).
-record(sc_car_result_reply, {
    result = erlang:error({required, result}),
    resultindex = erlang:error({required, resultindex}),
    selfnum = erlang:error({required, selfnum}),
    masternum = erlang:error({required, masternum}),
    poolsub = erlang:error({required, poolsub}),
    pool = erlang:error({required, pool})
}).
-endif.

-ifndef(SC_CAR_POOL_REPLY_PB_H).
-define(SC_CAR_POOL_REPLY_PB_H, true).
-record(sc_car_pool_reply, {
    result = erlang:error({required, result}),
    rank_result = erlang:error({required, rank_result})
}).
-endif.

-ifndef(CS_CAR_ADD_MONEY_REQ_PB_H).
-define(CS_CAR_ADD_MONEY_REQ_PB_H, true).
-record(cs_car_add_money_req, {
    money = erlang:error({required, money})
}).
-endif.

-ifndef(SC_CAR_ADD_MONEY_REPLY_PB_H).
-define(SC_CAR_ADD_MONEY_REPLY_PB_H, true).
-record(sc_car_add_money_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(CS_CAR_SYN_IN_GAME_STATE_REQ_PB_H).
-define(CS_CAR_SYN_IN_GAME_STATE_REQ_PB_H, true).
-record(cs_car_syn_in_game_state_req, {
    
}).
-endif.

-ifndef(PB_CAR_NIU_PLAYER_INFO_PB_H).
-define(PB_CAR_NIU_PLAYER_INFO_PB_H, true).
-record(pb_car_niu_player_info, {
    player_uuid = erlang:error({required, player_uuid}),
    icon_type = erlang:error({required, icon_type}),
    icon_url,
    player_name,
    vip_level = erlang:error({required, vip_level}),
    gold,
    pos,
    pool_win_gold,
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(PB_CAR_QUERY_POOL_WIN_PLAYER_REPLY_LIST_ELEM_PB_H).
-define(PB_CAR_QUERY_POOL_WIN_PLAYER_REPLY_LIST_ELEM_PB_H, true).
-record(pb_car_query_pool_win_player_reply_list_elem, {
    date = erlang:error({required, date}),
    list = []
}).
-endif.

-ifndef(SC_CAR_QUERY_POOL_WIN_PLAYER_REPLY_PB_H).
-define(SC_CAR_QUERY_POOL_WIN_PLAYER_REPLY_PB_H, true).
-record(sc_car_query_pool_win_player_reply, {
    list = []
}).
-endif.

-ifndef(CS_CAR_QUERY_POOL_WIN_PLAYER_REQ_PB_H).
-define(CS_CAR_QUERY_POOL_WIN_PLAYER_REQ_PB_H, true).
-record(cs_car_query_pool_win_player_req, {
    
}).
-endif.

