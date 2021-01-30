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

-ifndef(SC_NIU_ROOM_STATE_UPDATE_PB_H).
-define(SC_NIU_ROOM_STATE_UPDATE_PB_H, true).
-record(sc_niu_room_state_update, {
    state_id = erlang:error({required, state_id}),
    end_sec_time = erlang:error({required, end_sec_time}),
    open_card_list = [],
    master_pos,
    last_card_info,
    settle_list
}).
-endif.

-ifndef(CS_NIU_ENTER_ROOM_REQ_PB_H).
-define(CS_NIU_ENTER_ROOM_REQ_PB_H, true).
-record(cs_niu_enter_room_req, {
    room_type = erlang:error({required, room_type})
}).
-endif.

-ifndef(SC_NIU_ENTER_ROOM_REPLY_PB_H).
-define(SC_NIU_ENTER_ROOM_REPLY_PB_H, true).
-record(sc_niu_enter_room_reply, {
    result = erlang:error({required, result}),
    my_pos = erlang:error({required, my_pos})
}).
-endif.

-ifndef(SC_NIU_ENTER_ROOM_PLAYER_INFO_UPDATE_PB_H).
-define(SC_NIU_ENTER_ROOM_PLAYER_INFO_UPDATE_PB_H, true).
-record(sc_niu_enter_room_player_info_update, {
    player_list = []
}).
-endif.

-ifndef(CS_NIU_CHOOSE_MASTER_RATE_REQ_PB_H).
-define(CS_NIU_CHOOSE_MASTER_RATE_REQ_PB_H, true).
-record(cs_niu_choose_master_rate_req, {
    rate_num = erlang:error({required, rate_num})
}).
-endif.

-ifndef(SC_NIU_CHOOSE_MASTER_RATE_REPLY_PB_H).
-define(SC_NIU_CHOOSE_MASTER_RATE_REPLY_PB_H, true).
-record(sc_niu_choose_master_rate_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(SC_NIU_PLAYER_CHOOSE_MASTER_RATE_UPDATE_PB_H).
-define(SC_NIU_PLAYER_CHOOSE_MASTER_RATE_UPDATE_PB_H, true).
-record(sc_niu_player_choose_master_rate_update, {
    pos = erlang:error({required, pos}),
    rate_num = erlang:error({required, rate_num})
}).
-endif.

-ifndef(CS_NIU_CHOOSE_FREE_RATE_REQ_PB_H).
-define(CS_NIU_CHOOSE_FREE_RATE_REQ_PB_H, true).
-record(cs_niu_choose_free_rate_req, {
    rate_num = erlang:error({required, rate_num}),
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_NIU_CHOOSE_FREE_RATE_REPLY_PB_H).
-define(SC_NIU_CHOOSE_FREE_RATE_REPLY_PB_H, true).
-record(sc_niu_choose_free_rate_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(SC_NIU_PLAYER_CHOOSE_FREE_RATE_UPDATE_PB_H).
-define(SC_NIU_PLAYER_CHOOSE_FREE_RATE_UPDATE_PB_H, true).
-record(sc_niu_player_choose_free_rate_update, {
    pos = erlang:error({required, pos}),
    rate_num = erlang:error({required, rate_num})
}).
-endif.

-ifndef(CS_NIU_LEAVE_ROOM_REQ_PB_H).
-define(CS_NIU_LEAVE_ROOM_REQ_PB_H, true).
-record(cs_niu_leave_room_req, {
    
}).
-endif.

-ifndef(SC_NIU_LEAVE_ROOM_REPLY_PB_H).
-define(SC_NIU_LEAVE_ROOM_REPLY_PB_H, true).
-record(sc_niu_leave_room_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_NIU_LEAVE_ROOM_PLAYER_POS_UPDATE_PB_H).
-define(SC_NIU_LEAVE_ROOM_PLAYER_POS_UPDATE_PB_H, true).
-record(sc_niu_leave_room_player_pos_update, {
    leave_pos = erlang:error({required, leave_pos})
}).
-endif.

-ifndef(CS_NIU_SUBMIT_CARD_REQ_PB_H).
-define(CS_NIU_SUBMIT_CARD_REQ_PB_H, true).
-record(cs_niu_submit_card_req, {
    
}).
-endif.

-ifndef(SC_NIU_SUBMIT_CARD_REPLY_PB_H).
-define(SC_NIU_SUBMIT_CARD_REPLY_PB_H, true).
-record(sc_niu_submit_card_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_NIU_PLAYER_SUBMIT_CARD_UPDATE_PB_H).
-define(SC_NIU_PLAYER_SUBMIT_CARD_UPDATE_PB_H, true).
-record(sc_niu_player_submit_card_update, {
    player_pos = erlang:error({required, player_pos}),
    card_type = erlang:error({required, card_type}),
    card_list = []
}).
-endif.

-ifndef(CS_NIU_SYN_IN_GAME_STATE_REQ_PB_H).
-define(CS_NIU_SYN_IN_GAME_STATE_REQ_PB_H, true).
-record(cs_niu_syn_in_game_state_req, {
    
}).
-endif.

-ifndef(CS_NIU_QUERY_PLAYER_ROOM_INFO_REQ_PB_H).
-define(CS_NIU_QUERY_PLAYER_ROOM_INFO_REQ_PB_H, true).
-record(cs_niu_query_player_room_info_req, {
    
}).
-endif.

-ifndef(SC_NIU_PLAYER_ROOM_INFO_UPDATE_PB_H).
-define(SC_NIU_PLAYER_ROOM_INFO_UPDATE_PB_H, true).
-record(sc_niu_player_room_info_update, {
    room_id = erlang:error({required, room_id}),
    enter_end_time = erlang:error({required, enter_end_time})
}).
-endif.

-ifndef(SC_NIU_PLAYER_BACK_TO_ROOM_INFO_UPDATE_PB_H).
-define(SC_NIU_PLAYER_BACK_TO_ROOM_INFO_UPDATE_PB_H, true).
-record(sc_niu_player_back_to_room_info_update, {
    state_id = erlang:error({required, state_id}),
    end_sec_time = erlang:error({required, end_sec_time}),
    player_list = [],
    master_pos,
    my_pos = erlang:error({required, my_pos})
}).
-endif.

-ifndef(PB_POKER_CARD_PB_H).
-define(PB_POKER_CARD_PB_H, true).
-record(pb_poker_card, {
    number = erlang:error({required, number}),
    color = erlang:error({required, color})
}).
-endif.

-ifndef(GAME_OVER_SETTLEMENT_PB_H).
-define(GAME_OVER_SETTLEMENT_PB_H, true).
-record(game_over_settlement, {
    all_player_settle_info = []
}).
-endif.

-ifndef(PB_SETTLE_INFO_PB_H).
-define(PB_SETTLE_INFO_PB_H, true).
-record(pb_settle_info, {
    player_pos = erlang:error({required, player_pos}),
    reward_num = erlang:error({required, reward_num}),
    card_type = erlang:error({required, card_type}),
    card_list = []
}).
-endif.

-ifndef(PB_NIU_PLAYER_INFO_PB_H).
-define(PB_NIU_PLAYER_INFO_PB_H, true).
-record(pb_niu_player_info, {
    pos = erlang:error({required, pos}),
    player_uuid = erlang:error({required, player_uuid}),
    gold_num = erlang:error({required, gold_num}),
    icon_type = erlang:error({required, icon_type}),
    icon_url,
    player_name,
    master_rate,
    free_rate,
    open_card_list = [],
    card_type,
    vip_level = erlang:error({required, vip_level}),
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(SC_REDPACK_ROOM_RESET_TIMES_UPDATE_PB_H).
-define(SC_REDPACK_ROOM_RESET_TIMES_UPDATE_PB_H, true).
-record(sc_redpack_room_reset_times_update, {
    left_reset_times = erlang:error({required, left_reset_times}),
    reset_seconds = erlang:error({required, reset_seconds}),
    reset_mission_is_draw = erlang:error({required, reset_mission_is_draw})
}).
-endif.

-ifndef(SC_REDPACK_ROOM_PLAYER_TIMES_UPDATE_PB_H).
-define(SC_REDPACK_ROOM_PLAYER_TIMES_UPDATE_PB_H, true).
-record(sc_redpack_room_player_times_update, {
    now_play_times = erlang:error({required, now_play_times})
}).
-endif.

-ifndef(SC_REDPACK_ROOM_REDPACK_NOTICE_UPDATE_PB_H).
-define(SC_REDPACK_ROOM_REDPACK_NOTICE_UPDATE_PB_H, true).
-record(sc_redpack_room_redpack_notice_update, {
    close_draw_second = erlang:error({required, close_draw_second}),
    next_open_redpack_second = erlang:error({required, next_open_redpack_second})
}).
-endif.

-ifndef(CS_REDPACK_ROOM_DRAW_REQ_PB_H).
-define(CS_REDPACK_ROOM_DRAW_REQ_PB_H, true).
-record(cs_redpack_room_draw_req, {
    
}).
-endif.

-ifndef(SC_REDPACK_ROOM_DRAW_REPLY_PB_H).
-define(SC_REDPACK_ROOM_DRAW_REPLY_PB_H, true).
-record(sc_redpack_room_draw_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    reward = [],
    next_can_draw_second = erlang:error({required, next_can_draw_second})
}).
-endif.

-ifndef(SC_REDPACK_REDPACK_TIMER_SEC_UPDATE_PB_H).
-define(SC_REDPACK_REDPACK_TIMER_SEC_UPDATE_PB_H, true).
-record(sc_redpack_redpack_timer_sec_update, {
    next_can_draw_second = erlang:error({required, next_can_draw_second}),
    next_open_redpack_second = erlang:error({required, next_open_redpack_second})
}).
-endif.

-ifndef(CS_REDPACK_RELIVE_REQ_PB_H).
-define(CS_REDPACK_RELIVE_REQ_PB_H, true).
-record(cs_redpack_relive_req, {
    
}).
-endif.

-ifndef(SC_REDPACK_RELIVE_REPLY_PB_H).
-define(SC_REDPACK_RELIVE_REPLY_PB_H, true).
-record(sc_redpack_relive_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(SC_REDPACK_RELIVE_TIMES_PB_H).
-define(SC_REDPACK_RELIVE_TIMES_PB_H, true).
-record(sc_redpack_relive_times, {
    times = erlang:error({required, times})
}).
-endif.

-ifndef(SC_FUDAI_POOL_UPDATE_PB_H).
-define(SC_FUDAI_POOL_UPDATE_PB_H, true).
-record(sc_fudai_pool_update, {
    num = erlang:error({required, num})
}).
-endif.

