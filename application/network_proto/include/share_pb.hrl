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

-ifndef(CS_SHARE_NEW_BEE_REWARD_REQ_PB_H).
-define(CS_SHARE_NEW_BEE_REWARD_REQ_PB_H, true).
-record(cs_share_new_bee_reward_req, {
    code = erlang:error({required, code})
}).
-endif.

-ifndef(SC_SHARE_NEW_BEE_REWARD_REPLY_PB_H).
-define(SC_SHARE_NEW_BEE_REWARD_REPLY_PB_H, true).
-record(sc_share_new_bee_reward_reply, {
    result = erlang:error({required, result}),
    err,
    rewards = []
}).
-endif.

-ifndef(CS_SHARE_MISSION_REWARD_REQ_PB_H).
-define(CS_SHARE_MISSION_REWARD_REQ_PB_H, true).
-record(cs_share_mission_reward_req, {
    friend_id = erlang:error({required, friend_id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(SC_SHARE_MISSION_REWARD_REPLY_PB_H).
-define(SC_SHARE_MISSION_REWARD_REPLY_PB_H, true).
-record(sc_share_mission_reward_reply, {
    result = erlang:error({required, result}),
    err,
    rewards = [],
    friend_id = erlang:error({required, friend_id}),
    type = erlang:error({required, type})
}).
-endif.

-ifndef(PB_SHARE_MISSION_PB_H).
-define(PB_SHARE_MISSION_PB_H, true).
-record(pb_share_mission, {
    friend_id = erlang:error({required, friend_id}),
    name = erlang:error({required, name}),
    head = erlang:error({required, head}),
    vip_lv = erlang:error({required, vip_lv}),
    title = erlang:error({required, title}),
    type = erlang:error({required, type}),
    status = erlang:error({required, status})
}).
-endif.

-ifndef(SC_SHARE_INFO_PB_H).
-define(SC_SHARE_INFO_PB_H, true).
-record(sc_share_info, {
    my_code = erlang:error({required, my_code}),
    code = erlang:error({required, code}),
    free = erlang:error({required, free}),
    count = erlang:error({required, count}),
    list = []
}).
-endif.

-ifndef(SC_SHARE_MISSION_UPDATE_PB_H).
-define(SC_SHARE_MISSION_UPDATE_PB_H, true).
-record(sc_share_mission_update, {
    list = [],
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_SHARE_DRAW_REQUEST_PB_H).
-define(CS_SHARE_DRAW_REQUEST_PB_H, true).
-record(cs_share_draw_request, {
    flag = erlang:error({required, flag})
}).
-endif.

-ifndef(CS_SHARE_FRIEND_REQUEST_PB_H).
-define(CS_SHARE_FRIEND_REQUEST_PB_H, true).
-record(cs_share_friend_request, {
    page = erlang:error({required, page}),
    user_id
}).
-endif.

-ifndef(CS_SHARE_RANK_REQUEST_PB_H).
-define(CS_SHARE_RANK_REQUEST_PB_H, true).
-record(cs_share_rank_request, {
    page = erlang:error({required, page})
}).
-endif.

-ifndef(SC_SHARE_DRAW_RESPONSE_PB_H).
-define(SC_SHARE_DRAW_RESPONSE_PB_H, true).
-record(sc_share_draw_response, {
    result = erlang:error({required, result}),
    err,
    index = erlang:error({required, index})
}).
-endif.

-ifndef(PB_SHARE_HISTORY_ITEM_RESPONSE_PB_H).
-define(PB_SHARE_HISTORY_ITEM_RESPONSE_PB_H, true).
-record(pb_share_history_item_response, {
    name = erlang:error({required, name}),
    process = erlang:error({required, process})
}).
-endif.

-ifndef(PB_SHARE_HISTORY_FRIEND_ITEM_RESPONSE_PB_H).
-define(PB_SHARE_HISTORY_FRIEND_ITEM_RESPONSE_PB_H, true).
-record(pb_share_history_friend_item_response, {
    userid = erlang:error({required, userid}),
    name = erlang:error({required, name}),
    create_time = erlang:error({required, create_time}),
    first_day = erlang:error({required, first_day}),
    three_day = erlang:error({required, three_day}),
    seven_day = erlang:error({required, seven_day}),
    is_red = erlang:error({required, is_red})
}).
-endif.

-ifndef(SC_SHARE_HISTORY_RESPONSE_PB_H).
-define(SC_SHARE_HISTORY_RESPONSE_PB_H, true).
-record(sc_share_history_response, {
    count = erlang:error({required, count}),
    one_draw = erlang:error({required, one_draw}),
    three_draw = erlang:error({required, three_draw}),
    seven_draw = erlang:error({required, seven_draw}),
    pages = erlang:error({required, pages}),
    list = []
}).
-endif.

-ifndef(PB_SHARE_RANK_ITEM_RESPONSE_PB_H).
-define(PB_SHARE_RANK_ITEM_RESPONSE_PB_H, true).
-record(pb_share_rank_item_response, {
    rank = erlang:error({required, rank}),
    name = erlang:error({required, name}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(SC_SHARE_RANK_RESPONSE_PB_H).
-define(SC_SHARE_RANK_RESPONSE_PB_H, true).
-record(sc_share_rank_response, {
    count = erlang:error({required, count}),
    rank = erlang:error({required, rank}),
    pages = erlang:error({required, pages}),
    list = [],
    begintime,
    endtime
}).
-endif.

-ifndef(SC_DRAW_COUNT_RESPONSE_PB_H).
-define(SC_DRAW_COUNT_RESPONSE_PB_H, true).
-record(sc_draw_count_response, {
    draw_count = erlang:error({required, draw_count}),
    draw_count_seven = erlang:error({required, draw_count_seven}),
    draw_count_one = erlang:error({required, draw_count_one})
}).
-endif.

-ifndef(SC_TASK_SEVEN_INFO_RESPONSE_PB_H).
-define(SC_TASK_SEVEN_INFO_RESPONSE_PB_H, true).
-record(sc_task_seven_info_response, {
    task_id = erlang:error({required, task_id}),
    process = erlang:error({required, process}),
    status,
    award
}).
-endif.

-ifndef(CS_TASK_SEVEN_AWARD_REQUEST_PB_H).
-define(CS_TASK_SEVEN_AWARD_REQUEST_PB_H, true).
-record(cs_task_seven_award_request, {
    
}).
-endif.

-ifndef(SC_TASK_SEVEN_AWARD_RESPONSE_PB_H).
-define(SC_TASK_SEVEN_AWARD_RESPONSE_PB_H, true).
-record(sc_task_seven_award_response, {
    result = erlang:error({required, result}),
    err,
    rewards = []
}).
-endif.

-ifndef(CS_SHARE_WITH_FRIENDS_REQ_PB_H).
-define(CS_SHARE_WITH_FRIENDS_REQ_PB_H, true).
-record(cs_share_with_friends_req, {
    
}).
-endif.

