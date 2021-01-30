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

-ifndef(SC_HUNDRED_NIU_ROOM_STATE_UPDATE_PB_H).
-define(SC_HUNDRED_NIU_ROOM_STATE_UPDATE_PB_H, true).
-record(sc_hundred_niu_room_state_update, {
    state_id = erlang:error({required, state_id}),
    end_sec_time = erlang:error({required, end_sec_time}),
    last_card_info = [],
    settle_list = [],
    reward_pool_num,
    last_win_rec,
    pool_reward = [],
    master_continuous,
    rank_reward_pool_num
}).
-endif.

-ifndef(PB_POOL_REWARD_INFO_PB_H).
-define(PB_POOL_REWARD_INFO_PB_H, true).
-record(pb_pool_reward_info, {
    set_pos = erlang:error({required, set_pos}),
    total_reward_num = erlang:error({required, total_reward_num}),
    seat_reward_num = []
}).
-endif.

-ifndef(HUNDRED_GAME_OVER_SETTLEMENT_PB_H).
-define(HUNDRED_GAME_OVER_SETTLEMENT_PB_H, true).
-record(hundred_game_over_settlement, {
    player_pos = erlang:error({required, player_pos}),
    reward_num = erlang:error({required, reward_num}),
    set_pos_list = []
}).
-endif.

-ifndef(PB_ONE_PLAYER_POKER_CARD_PB_H).
-define(PB_ONE_PLAYER_POKER_CARD_PB_H, true).
-record(pb_one_player_poker_card, {
    seat_pos = erlang:error({required, seat_pos}),
    card_list = [],
    card_type = erlang:error({required, card_type}),
    is_win
}).
-endif.

-ifndef(CS_HUNDRED_NIU_ENTER_ROOM_REQ_PB_H).
-define(CS_HUNDRED_NIU_ENTER_ROOM_REQ_PB_H, true).
-record(cs_hundred_niu_enter_room_req, {
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_HUNDRED_NIU_ENTER_ROOM_REPLY_PB_H).
-define(SC_HUNDRED_NIU_ENTER_ROOM_REPLY_PB_H, true).
-record(sc_hundred_niu_enter_room_reply, {
    result = erlang:error({required, result}),
    err,
    game_data
}).
-endif.

-ifndef(PB_HUNDRED_NIU_ROOM_DATA_PB_H).
-define(PB_HUNDRED_NIU_ROOM_DATA_PB_H, true).
-record(pb_hundred_niu_room_data, {
    state_id = erlang:error({required, state_id}),
    end_sec_time = erlang:error({required, end_sec_time}),
    reward_pool_num,
    my_set_chips_info = []
}).
-endif.

-ifndef(CS_HUNDRED_NIU_PLAYER_LIST_QUERY_REQ_PB_H).
-define(CS_HUNDRED_NIU_PLAYER_LIST_QUERY_REQ_PB_H, true).
-record(cs_hundred_niu_player_list_query_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_HUNDRED_NIU_PLAYER_LIST_QUERY_REPLY_PB_H).
-define(SC_HUNDRED_NIU_PLAYER_LIST_QUERY_REPLY_PB_H, true).
-record(sc_hundred_niu_player_list_query_reply, {
    type = erlang:error({required, type}),
    list = []
}).
-endif.

-ifndef(PB_HUNDRED_NIU_PLAYER_INFO_PB_H).
-define(PB_HUNDRED_NIU_PLAYER_INFO_PB_H, true).
-record(pb_hundred_niu_player_info, {
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

-ifndef(CS_HUNDRED_NIU_FREE_SET_CHIPS_REQ_PB_H).
-define(CS_HUNDRED_NIU_FREE_SET_CHIPS_REQ_PB_H, true).
-record(cs_hundred_niu_free_set_chips_req, {
    pos = erlang:error({required, pos}),
    chips_num = erlang:error({required, chips_num}),
    test_type = erlang:error({required, test_type})
}).
-endif.

-ifndef(SC_HUNDRED_NIU_FREE_SET_CHIPS_REPLY_PB_H).
-define(SC_HUNDRED_NIU_FREE_SET_CHIPS_REPLY_PB_H, true).
-record(sc_hundred_niu_free_set_chips_reply, {
    result = erlang:error({required, result}),
    err,
    pos = erlang:error({required, pos}),
    total_chips_num = erlang:error({required, total_chips_num})
}).
-endif.

-ifndef(SC_HUNDRED_NIU_FREE_SET_CHIPS_UPDATE_PB_H).
-define(SC_HUNDRED_NIU_FREE_SET_CHIPS_UPDATE_PB_H, true).
-record(sc_hundred_niu_free_set_chips_update, {
    upd_list = [],
    upd_flag
}).
-endif.

-ifndef(PB_SET_CHIPS_INFO_PB_H).
-define(PB_SET_CHIPS_INFO_PB_H, true).
-record(pb_set_chips_info, {
    pos = erlang:error({required, pos}),
    total_chips = erlang:error({required, total_chips}),
    seat_pos_list = []
}).
-endif.

-ifndef(PB_SEAT_SET_INFO_PB_H).
-define(PB_SEAT_SET_INFO_PB_H, true).
-record(pb_seat_set_info, {
    seat_pos = erlang:error({required, seat_pos}),
    set_chips_num = erlang:error({required, set_chips_num})
}).
-endif.

-ifndef(CS_HUNDRED_NIU_SIT_DOWN_REQ_PB_H).
-define(CS_HUNDRED_NIU_SIT_DOWN_REQ_PB_H, true).
-record(cs_hundred_niu_sit_down_req, {
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(SC_HUNDRED_NIU_SIT_DOWN_REPLY_PB_H).
-define(SC_HUNDRED_NIU_SIT_DOWN_REPLY_PB_H, true).
-record(sc_hundred_niu_sit_down_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(SC_HUNDRED_NIU_SEAT_PLAYER_INFO_UPDATE_PB_H).
-define(SC_HUNDRED_NIU_SEAT_PLAYER_INFO_UPDATE_PB_H, true).
-record(sc_hundred_niu_seat_player_info_update, {
    seat_list = [],
    delete_seat_pos
}).
-endif.

-ifndef(CS_HUNDRED_BE_MASTER_REQ_PB_H).
-define(CS_HUNDRED_BE_MASTER_REQ_PB_H, true).
-record(cs_hundred_be_master_req, {
    flag = erlang:error({required, flag}),
    set_max = erlang:error({required, set_max})
}).
-endif.

-ifndef(SC_HUNDRED_BE_MASTER_REPLY_PB_H).
-define(SC_HUNDRED_BE_MASTER_REPLY_PB_H, true).
-record(sc_hundred_be_master_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(CS_HUNDRED_QUERY_MASTER_LIST_REQ_PB_H).
-define(CS_HUNDRED_QUERY_MASTER_LIST_REQ_PB_H, true).
-record(cs_hundred_query_master_list_req, {
    
}).
-endif.

-ifndef(SC_HUNDRED_QUERY_MASTER_LIST_REPLY_PB_H).
-define(SC_HUNDRED_QUERY_MASTER_LIST_REPLY_PB_H, true).
-record(sc_hundred_query_master_list_reply, {
    list = []
}).
-endif.

-ifndef(CS_HUNDRED_NIU_IN_GAME_SYN_REQ_PB_H).
-define(CS_HUNDRED_NIU_IN_GAME_SYN_REQ_PB_H, true).
-record(cs_hundred_niu_in_game_syn_req, {
    
}).
-endif.

-ifndef(CS_HUNDRED_LEAVE_ROOM_REQ_PB_H).
-define(CS_HUNDRED_LEAVE_ROOM_REQ_PB_H, true).
-record(cs_hundred_leave_room_req, {
    
}).
-endif.

-ifndef(SC_HUNDRED_LEAVE_ROOM_REPLY_PB_H).
-define(SC_HUNDRED_LEAVE_ROOM_REPLY_PB_H, true).
-record(sc_hundred_leave_room_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(CS_HUNDRED_QUERY_WINNING_REC_REQ_PB_H).
-define(CS_HUNDRED_QUERY_WINNING_REC_REQ_PB_H, true).
-record(cs_hundred_query_winning_rec_req, {
    
}).
-endif.

-ifndef(SC_HUNDRED_QUERY_WINNING_REC_REPLY_PB_H).
-define(SC_HUNDRED_QUERY_WINNING_REC_REPLY_PB_H, true).
-record(sc_hundred_query_winning_rec_reply, {
    list = []
}).
-endif.

-ifndef(PB_HUNDRED_WIN_REC_PB_H).
-define(PB_HUNDRED_WIN_REC_PB_H, true).
-record(pb_hundred_win_rec, {
    win_1 = erlang:error({required, win_1}),
    win_2 = erlang:error({required, win_2}),
    win_3 = erlang:error({required, win_3}),
    win_4 = erlang:error({required, win_4}),
    pool_win = []
}).
-endif.

-ifndef(SC_HUNDRED_PLAYER_GOLD_CHANGE_UPDATE_PB_H).
-define(SC_HUNDRED_PLAYER_GOLD_CHANGE_UPDATE_PB_H, true).
-record(sc_hundred_player_gold_change_update, {
    alter_num = erlang:error({required, alter_num})
}).
-endif.

-ifndef(CS_HUNDRED_QUERY_POOL_WIN_PLAYER_REQ_PB_H).
-define(CS_HUNDRED_QUERY_POOL_WIN_PLAYER_REQ_PB_H, true).
-record(cs_hundred_query_pool_win_player_req, {
    
}).
-endif.

-ifndef(PB_HUNDRED_QUERY_POOL_WIN_PLAYER_REPLY_LIST_ELEM_PB_H).
-define(PB_HUNDRED_QUERY_POOL_WIN_PLAYER_REPLY_LIST_ELEM_PB_H, true).
-record(pb_hundred_query_pool_win_player_reply_list_elem, {
    date = erlang:error({required, date}),
    list = []
}).
-endif.

-ifndef(SC_HUNDRED_QUERY_POOL_WIN_PLAYER_REPLY_PB_H).
-define(SC_HUNDRED_QUERY_POOL_WIN_PLAYER_REPLY_PB_H, true).
-record(sc_hundred_query_pool_win_player_reply, {
    list = []
}).
-endif.

