-ifndef(CS_LABA_ENTER_ROOM_REQ_PB_H).
-define(CS_LABA_ENTER_ROOM_REQ_PB_H, true).
-record(cs_laba_enter_room_req, {
    type = erlang:error({required, type}),
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_LABA_ENTER_ROOM_REPLY_PB_H).
-define(SC_LABA_ENTER_ROOM_REPLY_PB_H, true).
-record(sc_laba_enter_room_reply, {
    line_num = erlang:error({required, line_num}),
    line_set_chips = erlang:error({required, line_set_chips}),
    last_free_times = erlang:error({required, last_free_times}),
    type = erlang:error({required, type}),
    start_time,
    end_time
}).
-endif.

-ifndef(CS_LABA_LEAVE_ROOM_REQ_PB_H).
-define(CS_LABA_LEAVE_ROOM_REQ_PB_H, true).
-record(cs_laba_leave_room_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_LABA_LEAVE_ROOM_REPLY_PB_H).
-define(SC_LABA_LEAVE_ROOM_REPLY_PB_H, true).
-record(sc_laba_leave_room_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_LABA_POOL_NUM_UPDATE_PB_H).
-define(SC_LABA_POOL_NUM_UPDATE_PB_H, true).
-record(sc_laba_pool_num_update, {
    total_pool_num = erlang:error({required, total_pool_num}),
    total_rank_num = erlang:error({required, total_rank_num})
}).
-endif.

-ifndef(PB_POOL_WIN_PLAYER_INFO_PB_H).
-define(PB_POOL_WIN_PLAYER_INFO_PB_H, true).
-record(pb_pool_win_player_info, {
    player_uuid = erlang:error({required, player_uuid}),
    icon_url,
    player_name,
    vip_level = erlang:error({required, vip_level}),
    win_gold,
    c_time
}).
-endif.

-ifndef(CS_LABA_SPIN_REQ_PB_H).
-define(CS_LABA_SPIN_REQ_PB_H, true).
-record(cs_laba_spin_req, {
    line_num = erlang:error({required, line_num}),
    line_set_chips = erlang:error({required, line_set_chips}),
    type = erlang:error({required, type}),
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_LABA_SPIN_REPLY_PB_H).
-define(SC_LABA_SPIN_REPLY_PB_H, true).
-record(sc_laba_spin_reply, {
    total_reward_num = erlang:error({required, total_reward_num}),
    fruit_list = [],
    reward_list = [],
    new_last_free_times = erlang:error({required, new_last_free_times}),
    pool = erlang:error({required, pool}),
    free = erlang:error({required, free})
}).
-endif.

-ifndef(PB_LABA_FRUIT_INFO_PB_H).
-define(PB_LABA_FRUIT_INFO_PB_H, true).
-record(pb_laba_fruit_info, {
    pos_id = erlang:error({required, pos_id}),
    fruit_type = erlang:error({required, fruit_type})
}).
-endif.

-ifndef(PB_LABA_LINE_REWARD_PB_H).
-define(PB_LABA_LINE_REWARD_PB_H, true).
-record(pb_laba_line_reward, {
    line_id = erlang:error({required, line_id}),
    same_num = erlang:error({required, same_num})
}).
-endif.

-ifndef(CS_WIN_PLAYER_LIST_PB_H).
-define(CS_WIN_PLAYER_LIST_PB_H, true).
-record(cs_win_player_list, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_WIN_PLAYER_LIST_PB_H).
-define(SC_WIN_PLAYER_LIST_PB_H, true).
-record(sc_win_player_list, {
    win_players = []
}).
-endif.

-ifndef(CS_AIRLABA_ENTER_ROOM_REQ_PB_H).
-define(CS_AIRLABA_ENTER_ROOM_REQ_PB_H, true).
-record(cs_airlaba_enter_room_req, {
    laba_req = erlang:error({required, laba_req}),
    base_bet_num = erlang:error({required, base_bet_num}),
    base_line_num = erlang:error({required, base_line_num})
}).
-endif.

-ifndef(PB_AIRLABA_ITEM_LIST_ITEM_PB_H).
-define(PB_AIRLABA_ITEM_LIST_ITEM_PB_H, true).
-record(pb_airlaba_item_list_item, {
    item_id = erlang:error({required, item_id}),
    item_num = erlang:error({required, item_num})
}).
-endif.

-ifndef(SC_AIRLABA_ENTER_ROOM_REPLY_PB_H).
-define(SC_AIRLABA_ENTER_ROOM_REPLY_PB_H, true).
-record(sc_airlaba_enter_room_reply, {
    laba_resp = erlang:error({required, laba_resp}),
    item_list = erlang:error({required, item_list})
}).
-endif.

-ifndef(CS_AIRLABA_LEAVE_ROOM_REQ_PB_H).
-define(CS_AIRLABA_LEAVE_ROOM_REQ_PB_H, true).
-record(cs_airlaba_leave_room_req, {
    laba_req = erlang:error({required, laba_req})
}).
-endif.

-ifndef(SC_AIRLABA_LEAVE_ROOM_REPLY_PB_H).
-define(SC_AIRLABA_LEAVE_ROOM_REPLY_PB_H, true).
-record(sc_airlaba_leave_room_reply, {
    laba_resp = erlang:error({required, laba_resp})
}).
-endif.

-ifndef(CS_AIRLABA_FIRE_BET_REQ_PB_H).
-define(CS_AIRLABA_FIRE_BET_REQ_PB_H, true).
-record(cs_airlaba_fire_bet_req, {
    bullet_cost = erlang:error({required, bullet_cost}),
    bullet_num = erlang:error({required, bullet_num}),
    hit_objtype = erlang:error({required, hit_objtype}),
    hit_objid = erlang:error({required, hit_objid}),
    bullet_item_id = erlang:error({required, bullet_item_id})
}).
-endif.

-ifndef(SC_AIRLABA_FIRE_BET_REPLY_PB_H).
-define(SC_AIRLABA_FIRE_BET_REPLY_PB_H, true).
-record(sc_airlaba_fire_bet_reply, {
    result = erlang:error({required, result}),
    desc = erlang:error({required, desc}),
    target_down = erlang:error({required, target_down}),
    earn_gold = erlang:error({required, earn_gold}),
    hit_objid = erlang:error({required, hit_objid})
}).
-endif.

-ifndef(CS_AIRLABA_SWITCH_PHASE_REQ_PB_H).
-define(CS_AIRLABA_SWITCH_PHASE_REQ_PB_H, true).
-record(cs_airlaba_switch_phase_req, {
    
}).
-endif.

-ifndef(SC_AIRLABA_SWITCH_PHASE_REPLY_PB_H).
-define(SC_AIRLABA_SWITCH_PHASE_REPLY_PB_H, true).
-record(sc_airlaba_switch_phase_reply, {
    
}).
-endif.

-ifndef(SC_AIRLABA_POOL_NUM_UPDATE_PB_H).
-define(SC_AIRLABA_POOL_NUM_UPDATE_PB_H, true).
-record(sc_airlaba_pool_num_update, {
    pool_num = erlang:error({required, pool_num}),
    rank_pool_num = erlang:error({required, rank_pool_num})
}).
-endif.

-ifndef(CS_AIRLABA_USE_ITEM_REQ_PB_H).
-define(CS_AIRLABA_USE_ITEM_REQ_PB_H, true).
-record(cs_airlaba_use_item_req, {
    item_id = erlang:error({required, item_id}),
    item_num = erlang:error({required, item_num}),
    order_id = erlang:error({required, order_id})
}).
-endif.

-ifndef(SC_AIRLABA_USE_ITEM_REPLY_PB_H).
-define(SC_AIRLABA_USE_ITEM_REPLY_PB_H, true).
-record(sc_airlaba_use_item_reply, {
    req = erlang:error({required, req}),
    success = erlang:error({required, success}),
    left_num = erlang:error({required, left_num})
}).
-endif.

-ifndef(CS_AIRLABA_IMPOV_SUB_REQ_PB_H).
-define(CS_AIRLABA_IMPOV_SUB_REQ_PB_H, true).
-record(cs_airlaba_impov_sub_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_AIRLABA_IMPOV_SUB_REPLY_PB_H).
-define(SC_AIRLABA_IMPOV_SUB_REPLY_PB_H, true).
-record(sc_airlaba_impov_sub_reply, {
    code = erlang:error({required, code}),
    reward_item_id = erlang:error({required, reward_item_id}),
    reward_item_num = erlang:error({required, reward_item_num})
}).
-endif.

