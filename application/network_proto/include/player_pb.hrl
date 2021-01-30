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

-ifndef(SC_PLAYER_BASE_INFO_PB_H).
-define(SC_PLAYER_BASE_INFO_PB_H, true).
-record(sc_player_base_info, {
    player_uuid = erlang:error({required, player_uuid}),
    account = erlang:error({required, account}),
    name = erlang:error({required, name}),
    gold = erlang:error({required, gold}),
    diamond = erlang:error({required, diamond}),
    cash = erlang:error({required, cash}),
    exp = erlang:error({required, exp}),
    level = erlang:error({required, level}),
    icon = erlang:error({required, icon}),
    sex = erlang:error({required, sex}),
    vip_level = erlang:error({required, vip_level}),
    rmb = erlang:error({required, rmb}),
    block = erlang:error({required, block})
}).
-endif.

-ifndef(CS_PLAYER_CHANGE_NAME_REQ_PB_H).
-define(CS_PLAYER_CHANGE_NAME_REQ_PB_H, true).
-record(cs_player_change_name_req, {
    name = erlang:error({required, name})
}).
-endif.

-ifndef(SC_PLAYER_CHANGE_NAME_REPLY_PB_H).
-define(SC_PLAYER_CHANGE_NAME_REPLY_PB_H, true).
-record(sc_player_change_name_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(CS_PLAYER_CHANGE_HEADICON_REQ_PB_H).
-define(CS_PLAYER_CHANGE_HEADICON_REQ_PB_H, true).
-record(cs_player_change_headicon_req, {
    icon = erlang:error({required, icon}),
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(SC_PLAYER_CHANGE_HEADICON_REPLY_PB_H).
-define(SC_PLAYER_CHANGE_HEADICON_REPLY_PB_H, true).
-record(sc_player_change_headicon_reply, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(CS_PLAYER_CHAT_PB_H).
-define(CS_PLAYER_CHAT_PB_H, true).
-record(cs_player_chat, {
    room_type = erlang:error({required, room_type}),
    content_type = erlang:error({required, content_type}),
    content = erlang:error({required, content}),
    obj_player_uuid = erlang:error({required, obj_player_uuid})
}).
-endif.

-ifndef(SC_PLAYER_CHAT_PB_H).
-define(SC_PLAYER_CHAT_PB_H, true).
-record(sc_player_chat, {
    room_type = erlang:error({required, room_type}),
    content_type = erlang:error({required, content_type}),
    content = erlang:error({required, content}),
    player_uuid = erlang:error({required, player_uuid}),
    player_name = erlang:error({required, player_name}),
    player_icon = erlang:error({required, player_icon}),
    player_vip = erlang:error({required, player_vip}),
    player_seat_pos = erlang:error({required, player_seat_pos}),
    send_time = erlang:error({required, send_time}),
    des_player_uuid,
    des_player_name
}).
-endif.

-ifndef(SC_PLAYER_SYS_NOTICE_PB_H).
-define(SC_PLAYER_SYS_NOTICE_PB_H, true).
-record(sc_player_sys_notice, {
    flag = erlang:error({required, flag}),
    content = erlang:error({required, content})
}).
-endif.

-ifndef(SC_TIPS_PB_H).
-define(SC_TIPS_PB_H, true).
-record(sc_tips, {
    type = erlang:error({required, type}),
    text = erlang:error({required, text})
}).
-endif.

-ifndef(CS_QUERY_PLAYER_WINNING_REC_REQ_PB_H).
-define(CS_QUERY_PLAYER_WINNING_REC_REQ_PB_H, true).
-record(cs_query_player_winning_rec_req, {
    obj_player_uuid
}).
-endif.

-ifndef(SC_QUERY_PLAYER_WINNING_REC_REPLY_PB_H).
-define(SC_QUERY_PLAYER_WINNING_REC_REPLY_PB_H, true).
-record(sc_query_player_winning_rec_reply, {
    win_rate = erlang:error({required, win_rate}),
    win_count = erlang:error({required, win_count}),
    defeated_count = erlang:error({required, defeated_count}),
    max_property = erlang:error({required, max_property}),
    total_profit = erlang:error({required, total_profit}),
    week_profit = erlang:error({required, week_profit}),
    niu_10 = erlang:error({required, niu_10}),
    niu_11 = erlang:error({required, niu_11}),
    niu_12 = erlang:error({required, niu_12}),
    niu_13 = erlang:error({required, niu_13}),
    niu_0_win = erlang:error({required, niu_0_win}),
    obj_player_uuid,
    obj_name,
    sex,
    gold,
    icon,
    level,
    vip_level,
    account
}).
-endif.

-ifndef(CS_NIU_QUERY_IN_GAME_PLAYER_NUM_REQ_PB_H).
-define(CS_NIU_QUERY_IN_GAME_PLAYER_NUM_REQ_PB_H, true).
-record(cs_niu_query_in_game_player_num_req, {
    game_type = erlang:error({required, game_type})
}).
-endif.

-ifndef(PB_ROOM_PLAYER_NUM_PB_H).
-define(PB_ROOM_PLAYER_NUM_PB_H, true).
-record(pb_room_player_num, {
    room_level = erlang:error({required, room_level}),
    player_num = erlang:error({required, player_num})
}).
-endif.

-ifndef(SC_NIU_QUERY_IN_GAME_PLAYER_NUM_REPLY_PB_H).
-define(SC_NIU_QUERY_IN_GAME_PLAYER_NUM_REPLY_PB_H, true).
-record(sc_niu_query_in_game_player_num_reply, {
    list = []
}).
-endif.

-ifndef(CS_NIU_SUBSIDY_REQ_PB_H).
-define(CS_NIU_SUBSIDY_REQ_PB_H, true).
-record(cs_niu_subsidy_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_NIU_SUBSIDY_REPLY_PB_H).
-define(SC_NIU_SUBSIDY_REPLY_PB_H, true).
-record(sc_niu_subsidy_reply, {
    result = erlang:error({required, result}),
    err
}).
-endif.

-ifndef(SC_NIU_SUBSIDY_INFO_UPDATE_PB_H).
-define(SC_NIU_SUBSIDY_INFO_UPDATE_PB_H, true).
-record(sc_niu_subsidy_info_update, {
    left_times = erlang:error({required, left_times}),
    subsidy_gold = erlang:error({required, subsidy_gold})
}).
-endif.

-ifndef(CS_NIU_SPECIAL_SUBSIDY_SHARE_PB_H).
-define(CS_NIU_SPECIAL_SUBSIDY_SHARE_PB_H, true).
-record(cs_niu_special_subsidy_share, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(SC_NIU_SPECIAL_SUBSIDY_SHARE_PB_H).
-define(SC_NIU_SPECIAL_SUBSIDY_SHARE_PB_H, true).
-record(sc_niu_special_subsidy_share, {
    
}).
-endif.

-ifndef(CS_PLAYER_BASE_MAKE_NAME_PB_H).
-define(CS_PLAYER_BASE_MAKE_NAME_PB_H, true).
-record(cs_player_base_make_name, {
    
}).
-endif.

-ifndef(SC_PLAYER_BASE_MAKE_NAME_BACK_PB_H).
-define(SC_PLAYER_BASE_MAKE_NAME_BACK_PB_H, true).
-record(sc_player_base_make_name_back, {
    name = erlang:error({required, name})
}).
-endif.

-ifndef(CS_DAILY_CHECKIN_REQ_PB_H).
-define(CS_DAILY_CHECKIN_REQ_PB_H, true).
-record(cs_daily_checkin_req, {
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(SC_DAILY_CHECKIN_REPLY_PB_H).
-define(SC_DAILY_CHECKIN_REPLY_PB_H, true).
-record(sc_daily_checkin_reply, {
    result = erlang:error({required, result}),
    err,
    rewards = [],
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(SC_DAILY_CHECKIN_INFO_UPDATE_PB_H).
-define(SC_DAILY_CHECKIN_INFO_UPDATE_PB_H, true).
-record(sc_daily_checkin_info_update, {
    list = [],
    all_checkin_day = erlang:error({required, all_checkin_day}),
    is_checkin_today = erlang:error({required, is_checkin_today}),
    vip_is_draw = erlang:error({required, vip_is_draw})
}).
-endif.

-ifndef(PB_CHECKIN_INFO_PB_H).
-define(PB_CHECKIN_INFO_PB_H, true).
-record(pb_checkin_info, {
    day = erlang:error({required, day}),
    rewards = [],
    is_draw = erlang:error({required, is_draw})
}).
-endif.

-ifndef(CS_MAKE_UP_FOR_CHECKIN_REQ_PB_H).
-define(CS_MAKE_UP_FOR_CHECKIN_REQ_PB_H, true).
-record(cs_make_up_for_checkin_req, {
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(SC_PLAYER_PHONE_NUM_INFO_UPDATE_PB_H).
-define(SC_PLAYER_PHONE_NUM_INFO_UPDATE_PB_H, true).
-record(sc_player_phone_num_info_update, {
    phone_num = erlang:error({required, phone_num}),
    is_draw = erlang:error({required, is_draw})
}).
-endif.

-ifndef(SC_PLAYER_BIND_PHONE_NUM_PB_H).
-define(SC_PLAYER_BIND_PHONE_NUM_PB_H, true).
-record(sc_player_bind_phone_num, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(CS_PLAYER_BIND_PHONE_NUM_DRAW_PB_H).
-define(CS_PLAYER_BIND_PHONE_NUM_DRAW_PB_H, true).
-record(cs_player_bind_phone_num_draw, {
    
}).
-endif.

-ifndef(SC_PLAYER_BIND_PHONE_NUM_DRAW_REPLY_PB_H).
-define(SC_PLAYER_BIND_PHONE_NUM_DRAW_REPLY_PB_H, true).
-record(sc_player_bind_phone_num_draw_reply, {
    result = erlang:error({required, result}),
    err,
    rewards = []
}).
-endif.

-ifndef(SC_NIU_SPECIAL_SUBSIDY_INFO_UPDATE_PB_H).
-define(SC_NIU_SPECIAL_SUBSIDY_INFO_UPDATE_PB_H, true).
-record(sc_niu_special_subsidy_info_update, {
    left_times = erlang:error({required, left_times}),
    subsidy_gold = erlang:error({required, subsidy_gold}),
    is_share = erlang:error({required, is_share})
}).
-endif.

-ifndef(CS_RANK_QUERY_REQ_PB_H).
-define(CS_RANK_QUERY_REQ_PB_H, true).
-record(cs_rank_query_req, {
    rank_type = erlang:error({required, rank_type})
}).
-endif.

-ifndef(SC_RANK_QUREY_REPLY_PB_H).
-define(SC_RANK_QUREY_REPLY_PB_H, true).
-record(sc_rank_qurey_reply, {
    rank_type = erlang:error({required, rank_type}),
    my_rank = erlang:error({required, my_rank}),
    rank_info_list = [],
    pool,
    my_recharge_money,
    start_time,
    end_time
}).
-endif.

-ifndef(PB_RANK_INFO_PB_H).
-define(PB_RANK_INFO_PB_H, true).
-record(pb_rank_info, {
    rank = erlang:error({required, rank}),
    player_uuid = erlang:error({required, player_uuid}),
    player_name = erlang:error({required, player_name}),
    player_icon = erlang:error({required, player_icon}),
    player_vip = erlang:error({required, player_vip}),
    gold_num,
    win_gold_num,
    cash_num,
    sex,
    hundred_win,
    account = erlang:error({required, account}),
    redpack
}).
-endif.

-ifndef(CS_VIP_DAILY_REWARD_PB_H).
-define(CS_VIP_DAILY_REWARD_PB_H, true).
-record(cs_vip_daily_reward, {
    
}).
-endif.

-ifndef(SC_VIP_DAILY_REWARD_PB_H).
-define(SC_VIP_DAILY_REWARD_PB_H, true).
-record(sc_vip_daily_reward, {
    result = erlang:error({required, result}),
    err,
    rewards = []
}).
-endif.

-ifndef(SC_GUIDE_INFO_UPDATE_PB_H).
-define(SC_GUIDE_INFO_UPDATE_PB_H, true).
-record(sc_guide_info_update, {
    step_id = erlang:error({required, step_id})
}).
-endif.

-ifndef(CS_GUIDE_NEXT_STEP_REQ_PB_H).
-define(CS_GUIDE_NEXT_STEP_REQ_PB_H, true).
-record(cs_guide_next_step_req, {
    next_step_id = erlang:error({required, next_step_id})
}).
-endif.

-ifndef(SC_GUIDE_NEXT_STEP_REPLY_PB_H).
-define(SC_GUIDE_NEXT_STEP_REPLY_PB_H, true).
-record(sc_guide_next_step_reply, {
    result = erlang:error({required, result}),
    reward = []
}).
-endif.

-ifndef(CS_HUNDRED_LAST_WEEK_RANK_QUERY_REQ_PB_H).
-define(CS_HUNDRED_LAST_WEEK_RANK_QUERY_REQ_PB_H, true).
-record(cs_hundred_last_week_rank_query_req, {
    
}).
-endif.

-ifndef(SC_HUNDRED_LAST_WEEK_RANK_QUERY_REPLY_PB_H).
-define(SC_HUNDRED_LAST_WEEK_RANK_QUERY_REPLY_PB_H, true).
-record(sc_hundred_last_week_rank_query_reply, {
    list = []
}).
-endif.

-ifndef(PB_HUNDRED_LAST_WEEK_DATA_PB_H).
-define(PB_HUNDRED_LAST_WEEK_DATA_PB_H, true).
-record(pb_hundred_last_week_data, {
    rank = erlang:error({required, rank}),
    reward_gold = erlang:error({required, reward_gold}),
    name1_round_win = erlang:error({required, name1_round_win}),
    name2_total_win = erlang:error({required, name2_total_win})
}).
-endif.

-ifndef(CS_REAL_NAME_UPDATE_PB_H).
-define(CS_REAL_NAME_UPDATE_PB_H, true).
-record(cs_real_name_update, {
    name = erlang:error({required, name}),
    id_card_num = erlang:error({required, id_card_num})
}).
-endif.

-ifndef(SC_REAL_NAME_UPDATE_PB_H).
-define(SC_REAL_NAME_UPDATE_PB_H, true).
-record(sc_real_name_update, {
    result = erlang:error({required, result}),
    err,
    rewards = []
}).
-endif.

-ifndef(CS_REAL_NAME_REQ_PB_H).
-define(CS_REAL_NAME_REQ_PB_H, true).
-record(cs_real_name_req, {
    
}).
-endif.

-ifndef(SC_REAL_NAME_REQ_PB_H).
-define(SC_REAL_NAME_REQ_PB_H, true).
-record(sc_real_name_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(CS_SUPER_LABA_LAST_WEEK_RANK_QUERY_REQ_PB_H).
-define(CS_SUPER_LABA_LAST_WEEK_RANK_QUERY_REQ_PB_H, true).
-record(cs_super_laba_last_week_rank_query_req, {
    
}).
-endif.

-ifndef(SC_SUPER_LABA_LAST_WEEK_RANK_QUERY_REPLY_PB_H).
-define(SC_SUPER_LABA_LAST_WEEK_RANK_QUERY_REPLY_PB_H, true).
-record(sc_super_laba_last_week_rank_query_reply, {
    list = []
}).
-endif.

-ifndef(CS_QUERY_LAST_DAILY_RANK_REWARD_REQ_PB_H).
-define(CS_QUERY_LAST_DAILY_RANK_REWARD_REQ_PB_H, true).
-record(cs_query_last_daily_rank_reward_req, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_QUERY_LAST_DAILY_RANK_REWARD_REPLY_PB_H).
-define(SC_QUERY_LAST_DAILY_RANK_REWARD_REPLY_PB_H, true).
-record(sc_query_last_daily_rank_reward_reply, {
    type = erlang:error({required, type}),
    date = erlang:error({required, date}),
    rank_info_list = []
}).
-endif.

-ifndef(PB_CUR_STICKINESS_REDPACK_INFO_PB_H).
-define(PB_CUR_STICKINESS_REDPACK_INFO_PB_H, true).
-record(pb_cur_stickiness_redpack_info, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    level = erlang:error({required, level}),
    reward_type = erlang:error({required, reward_type}),
    reward_amount = erlang:error({required, reward_amount}),
    reward_min = erlang:error({required, reward_min}),
    cur_total_amount = erlang:error({required, cur_total_amount}),
    cur_trigger_next_amount = erlang:error({required, cur_trigger_next_amount}),
    cur_earn_gold = erlang:error({required, cur_earn_gold}),
    gold_cov_to_reward_item_rate = erlang:error({required, gold_cov_to_reward_item_rate}),
    holding_earn_gold = erlang:error({required, holding_earn_gold}),
    total_gold = erlang:error({required, total_gold}),
    end_time = erlang:error({required, end_time})
}).
-endif.

-ifndef(SC_PLAYER_STICKINESS_REDPACK_INFO_NOTIFY_PB_H).
-define(SC_PLAYER_STICKINESS_REDPACK_INFO_NOTIFY_PB_H, true).
-record(sc_player_stickiness_redpack_info_notify, {
    cur_info = erlang:error({required, cur_info})
}).
-endif.

-ifndef(CS_STICKINESS_REDPACK_DRAW_REQ_PB_H).
-define(CS_STICKINESS_REDPACK_DRAW_REQ_PB_H, true).
-record(cs_stickiness_redpack_draw_req, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype})
}).
-endif.

-ifndef(SC_STICKINESS_REDPACK_DRAW_RESP_PB_H).
-define(SC_STICKINESS_REDPACK_DRAW_RESP_PB_H, true).
-record(sc_stickiness_redpack_draw_resp, {
    cur_info = erlang:error({required, cur_info}),
    reward_type = erlang:error({required, reward_type}),
    reward_amount = erlang:error({required, reward_amount})
}).
-endif.

-ifndef(CS_PLAYER_STICKINESS_REDPACK_INFO_NOTIFY_REQ_PB_H).
-define(CS_PLAYER_STICKINESS_REDPACK_INFO_NOTIFY_REQ_PB_H, true).
-record(cs_player_stickiness_redpack_info_notify_req, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype})
}).
-endif.

-ifndef(PB_PLAYER_BET_STICKINESS_REDPACK_LIST_ELEM_PB_H).
-define(PB_PLAYER_BET_STICKINESS_REDPACK_LIST_ELEM_PB_H, true).
-record(pb_player_bet_stickiness_redpack_list_elem, {
    level = erlang:error({required, level}),
    redpack_1 = erlang:error({required, redpack_1}),
    redpack_2 = erlang:error({required, redpack_2}),
    redpack_3 = erlang:error({required, redpack_3})
}).
-endif.

-ifndef(SC_PLAYER_BET_STICKINESS_NOTIFY_PB_H).
-define(SC_PLAYER_BET_STICKINESS_NOTIFY_PB_H, true).
-record(sc_player_bet_stickiness_notify, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    cur_bet = erlang:error({required, cur_bet}),
    total_bet = erlang:error({required, total_bet}),
    cur_level = erlang:error({required, cur_level}),
    redpack_list = []
}).
-endif.

-ifndef(CS_PLAYER_BET_STICKINESS_REDPACK_DRAW_REQ_PB_H).
-define(CS_PLAYER_BET_STICKINESS_REDPACK_DRAW_REQ_PB_H, true).
-record(cs_player_bet_stickiness_redpack_draw_req, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    level = erlang:error({required, level})
}).
-endif.

-ifndef(SC_PLAYER_BET_STICKINESS_REDPACK_DRAW_RESP_PB_H).
-define(SC_PLAYER_BET_STICKINESS_REDPACK_DRAW_RESP_PB_H, true).
-record(sc_player_bet_stickiness_redpack_draw_resp, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    level = erlang:error({required, level}),
    reward_amount = erlang:error({required, reward_amount}),
    desc = erlang:error({required, desc})
}).
-endif.

-ifndef(PB_BET_LOCK_CONFIG_LIST_ELEM_PB_H).
-define(PB_BET_LOCK_CONFIG_LIST_ELEM_PB_H, true).
-record(pb_bet_lock_config_list_elem, {
    level = erlang:error({required, level}),
    bet_gold_limit = erlang:error({required, bet_gold_limit}),
    next_gen_gold = erlang:error({required, next_gen_gold}),
    next_gen_vip = erlang:error({required, next_gen_vip})
}).
-endif.

-ifndef(CS_BET_LOCK_CONFIG_REQ_PB_H).
-define(CS_BET_LOCK_CONFIG_REQ_PB_H, true).
-record(cs_bet_lock_config_req, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype})
}).
-endif.

-ifndef(SC_BET_LOCK_CONFIG_RESP_PB_H).
-define(SC_BET_LOCK_CONFIG_RESP_PB_H, true).
-record(sc_bet_lock_config_resp, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    configs = []
}).
-endif.

-ifndef(SC_BET_LOCK_UPDATE_NOTIFY_PB_H).
-define(SC_BET_LOCK_UPDATE_NOTIFY_PB_H, true).
-record(sc_bet_lock_update_notify, {
    room_type = erlang:error({required, room_type}),
    testtype = erlang:error({required, testtype}),
    cur_level = erlang:error({required, cur_level}),
    total_amount = erlang:error({required, total_amount})
}).
-endif.

-ifndef(CS_PLAYER_SALARY_QUERY_REQ_PB_H).
-define(CS_PLAYER_SALARY_QUERY_REQ_PB_H, true).
-record(cs_player_salary_query_req, {
    
}).
-endif.

-ifndef(SC_PLAYER_SALARY_QUERY_RESP_PB_H).
-define(SC_PLAYER_SALARY_QUERY_RESP_PB_H, true).
-record(sc_player_salary_query_resp, {
    yesterday_earn = erlang:error({required, yesterday_earn}),
    today_earn = erlang:error({required, today_earn}),
    yesterday_salary = erlang:error({required, yesterday_salary}),
    is_draw = erlang:error({required, is_draw})
}).
-endif.

-ifndef(CS_PLAYER_SALARY_DRAW_REQ_PB_H).
-define(CS_PLAYER_SALARY_DRAW_REQ_PB_H, true).
-record(cs_player_salary_draw_req, {
    
}).
-endif.

-ifndef(SC_PLAYER_SALARY_DRAW_RESP_PB_H).
-define(SC_PLAYER_SALARY_DRAW_RESP_PB_H, true).
-record(sc_player_salary_draw_resp, {
    salary = erlang:error({required, salary}),
    desc = erlang:error({required, desc})
}).
-endif.

-ifndef(PB_LOTTERY_ITEM_PB_H).
-define(PB_LOTTERY_ITEM_PB_H, true).
-record(pb_lottery_item, {
    item_id = erlang:error({required, item_id}),
    item_num = erlang:error({required, item_num})
}).
-endif.

-ifndef(PB_LOTTERY_REWARD_CONFIG_PB_H).
-define(PB_LOTTERY_REWARD_CONFIG_PB_H, true).
-record(pb_lottery_reward_config, {
    index = erlang:error({required, index}),
    cost_item = erlang:error({required, cost_item}),
    reward_items = []
}).
-endif.

-ifndef(CS_LOTTERY_DRAW_REQ_PB_H).
-define(CS_LOTTERY_DRAW_REQ_PB_H, true).
-record(cs_lottery_draw_req, {
    prize_cls = erlang:error({required, prize_cls})
}).
-endif.

-ifndef(SC_LOTTERY_DRAW_RESP_PB_H).
-define(SC_LOTTERY_DRAW_RESP_PB_H, true).
-record(sc_lottery_draw_resp, {
    left_times = erlang:error({required, left_times}),
    reward_item_id = erlang:error({required, reward_item_id}),
    reward_item_num = erlang:error({required, reward_item_num}),
    is_reward = erlang:error({required, is_reward}),
    reward_configs = []
}).
-endif.

