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

-ifndef(SC_DOUDIZHU_ROOM_STATE_UPDATE_PB_H).
-define(SC_DOUDIZHU_ROOM_STATE_UPDATE_PB_H, true).
-record(sc_doudizhu_room_state_update, {
    state_id = erlang:error({required, state_id}),
    auto_list,
    basescore,
    multiples,
    my_card_list,
    hand_num_list,
    remain_card_list,
    calc_card_list,
    dizhu_pos,
    settlement,
    last_cards_list
}).
-endif.

-ifndef(CS_DOUDIZHU_ENTER_REQ_PB_H).
-define(CS_DOUDIZHU_ENTER_REQ_PB_H, true).
-record(cs_doudizhu_enter_req, {
    level = erlang:error({required, level})
}).
-endif.

-ifndef(SC_DOUDIZHU_ENTER_REPLY_PB_H).
-define(SC_DOUDIZHU_ENTER_REPLY_PB_H, true).
-record(sc_doudizhu_enter_reply, {
    result = erlang:error({required, result}),
    my_pos = erlang:error({required, my_pos})
}).
-endif.

-ifndef(SC_DOUDIZHU_PLAYER_UPDATE_PB_H).
-define(SC_DOUDIZHU_PLAYER_UPDATE_PB_H, true).
-record(sc_doudizhu_player_update, {
    player_list = []
}).
-endif.

-ifndef(CS_DOUDIZHU_BET_REQ_PB_H).
-define(CS_DOUDIZHU_BET_REQ_PB_H, true).
-record(cs_doudizhu_bet_req, {
    rate = erlang:error({required, rate})
}).
-endif.

-ifndef(SC_DOUDIZHU_BET_REPLY_PB_H).
-define(SC_DOUDIZHU_BET_REPLY_PB_H, true).
-record(sc_doudizhu_bet_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(SC_DOUDIZHU_BET_UPDATE_PB_H).
-define(SC_DOUDIZHU_BET_UPDATE_PB_H, true).
-record(sc_doudizhu_bet_update, {
    pos = erlang:error({required, pos}),
    rate = erlang:error({required, rate})
}).
-endif.

-ifndef(CS_DOUDIZHU_LEAVE_REQ_PB_H).
-define(CS_DOUDIZHU_LEAVE_REQ_PB_H, true).
-record(cs_doudizhu_leave_req, {
    
}).
-endif.

-ifndef(SC_DOUDIZHU_LEAVE_REPLY_PB_H).
-define(SC_DOUDIZHU_LEAVE_REPLY_PB_H, true).
-record(sc_doudizhu_leave_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_DOUDIZHU_LEAVE_UPDATE_PB_H).
-define(SC_DOUDIZHU_LEAVE_UPDATE_PB_H, true).
-record(sc_doudizhu_leave_update, {
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(CS_DOUDIZHU_PLAY_CARD_REQ_PB_H).
-define(CS_DOUDIZHU_PLAY_CARD_REQ_PB_H, true).
-record(cs_doudizhu_play_card_req, {
    card_list = []
}).
-endif.

-ifndef(SC_DOUDIZHU_PLAY_CARD_REPLY_PB_H).
-define(SC_DOUDIZHU_PLAY_CARD_REPLY_PB_H, true).
-record(sc_doudizhu_play_card_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_DOUDIZHU_PLAY_CARD_UPDATE_PB_H).
-define(SC_DOUDIZHU_PLAY_CARD_UPDATE_PB_H, true).
-record(sc_doudizhu_play_card_update, {
    pos = erlang:error({required, pos}),
    card_list = []
}).
-endif.

-ifndef(CS_DOUDIZHU_QUERY_GAMING_REQ_PB_H).
-define(CS_DOUDIZHU_QUERY_GAMING_REQ_PB_H, true).
-record(cs_doudizhu_query_gaming_req, {
    
}).
-endif.

-ifndef(SC_DOUDIZHU_QUERY_GAMING_REPLY_PB_H).
-define(SC_DOUDIZHU_QUERY_GAMING_REPLY_PB_H, true).
-record(sc_doudizhu_query_gaming_reply, {
    level = erlang:error({required, level})
}).
-endif.

-ifndef(PB_DOUDIZHU_LAST_CARDS_LIST_PB_H).
-define(PB_DOUDIZHU_LAST_CARDS_LIST_PB_H, true).
-record(pb_doudizhu_last_cards_list, {
    
}).
-endif.

-ifndef(PB_DOUDIZHU_CARD_LIST_PB_H).
-define(PB_DOUDIZHU_CARD_LIST_PB_H, true).
-record(pb_doudizhu_card_list, {
    cards = []
}).
-endif.

-ifndef(PB_DOUDIZHU_CARD_PB_H).
-define(PB_DOUDIZHU_CARD_PB_H, true).
-record(pb_doudizhu_card, {
    number = erlang:error({required, number}),
    color = erlang:error({required, color})
}).
-endif.

-ifndef(PB_DOUDIZHU_CALC_CARD_LIST_PB_H).
-define(PB_DOUDIZHU_CALC_CARD_LIST_PB_H, true).
-record(pb_doudizhu_calc_card_list, {
    cards = []
}).
-endif.

-ifndef(PB_DOUDIZHU_CALC_CARD_PB_H).
-define(PB_DOUDIZHU_CALC_CARD_PB_H, true).
-record(pb_doudizhu_calc_card, {
    number = erlang:error({required, number}),
    remaind = erlang:error({required, remaind})
}).
-endif.

-ifndef(PB_DOUDIZHU_HAND_NUM_LIST_PB_H).
-define(PB_DOUDIZHU_HAND_NUM_LIST_PB_H, true).
-record(pb_doudizhu_hand_num_list, {
    number = []
}).
-endif.

-ifndef(PB_AUTO_LIST_PB_H).
-define(PB_AUTO_LIST_PB_H, true).
-record(pb_auto_list, {
    auto = []
}).
-endif.

-ifndef(PB_DOUDIZHU_SETTLEMENT_PB_H).
-define(PB_DOUDIZHU_SETTLEMENT_PB_H, true).
-record(pb_doudizhu_settlement, {
    special = [],
    basescore = erlang:error({required, basescore}),
    multiples = erlang:error({required, multiples}),
    identity = erlang:error({required, identity}),
    reward = erlang:error({required, reward})
}).
-endif.

-ifndef(PB_SPECIAL_CARD_PB_H).
-define(PB_SPECIAL_CARD_PB_H, true).
-record(pb_special_card, {
    type = erlang:error({required, type}),
    multiples = erlang:error({required, multiples})
}).
-endif.

-ifndef(PB_DOUDIZHU_PLAYER_INFO_PB_H).
-define(PB_DOUDIZHU_PLAYER_INFO_PB_H, true).
-record(pb_doudizhu_player_info, {
    pos = erlang:error({required, pos}),
    player_uuid = erlang:error({required, player_uuid}),
    gold_num = erlang:error({required, gold_num}),
    icon_type = erlang:error({required, icon_type}),
    icon_url,
    player_name,
    vip_level = erlang:error({required, vip_level}),
    sex = erlang:error({required, sex})
}).
-endif.

