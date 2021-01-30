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

-ifndef(CS_DRAW_MISSION_REQUEST_PB_H).
-define(CS_DRAW_MISSION_REQUEST_PB_H, true).
-record(cs_draw_mission_request, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(SC_DRAW_MISSION_RESULT_REPLY_PB_H).
-define(SC_DRAW_MISSION_RESULT_REPLY_PB_H, true).
-record(sc_draw_mission_result_reply, {
    result = erlang:error({required, result}),
    err_msg,
    reward_info_s = []
}).
-endif.

-ifndef(SC_MISSION_PB_H).
-define(SC_MISSION_PB_H, true).
-record(sc_mission, {
    missions = []
}).
-endif.

-ifndef(SC_MISSION_UPDATE_PB_H).
-define(SC_MISSION_UPDATE_PB_H, true).
-record(sc_mission_update, {
    mission_ = erlang:error({required, mission_})
}).
-endif.

-ifndef(SC_MISSION_ADD_PB_H).
-define(SC_MISSION_ADD_PB_H, true).
-record(sc_mission_add, {
    mission_ = erlang:error({required, mission_})
}).
-endif.

-ifndef(SC_MISSION_DEL_PB_H).
-define(SC_MISSION_DEL_PB_H, true).
-record(sc_mission_del, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(PB_MISSION_PB_H).
-define(PB_MISSION_PB_H, true).
-record(pb_mission, {
    id = erlang:error({required, id}),
    state = erlang:error({required, state}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(SC_GAME_TASK_INFO_UPDATE_PB_H).
-define(SC_GAME_TASK_INFO_UPDATE_PB_H, true).
-record(sc_game_task_info_update, {
    tast_info = []
}).
-endif.

-ifndef(PB_GAME_TASK_INFO_PB_H).
-define(PB_GAME_TASK_INFO_PB_H, true).
-record(pb_game_task_info, {
    taskid = erlang:error({required, taskid}),
    process,
    status,
    boxstart,
    boxprocess,
    boxstatus = [],
    remaindtime,
    tast_type = erlang:error({required, tast_type}),
    vip_level = erlang:error({required, vip_level})
}).
-endif.

-ifndef(SC_GAME_TASK_BOX_INFO_UPDATE_PB_H).
-define(SC_GAME_TASK_BOX_INFO_UPDATE_PB_H, true).
-record(sc_game_task_box_info_update, {
    game_type = erlang:error({required, game_type}),
    box_flag_list = []
}).
-endif.

-ifndef(CS_GAME_TASK_DRAW_REQ_PB_H).
-define(CS_GAME_TASK_DRAW_REQ_PB_H, true).
-record(cs_game_task_draw_req, {
    game_type = erlang:error({required, game_type}),
    task_id = erlang:error({required, task_id})
}).
-endif.

-ifndef(SC_GAME_TASK_DRAW_REPLY_PB_H).
-define(SC_GAME_TASK_DRAW_REPLY_PB_H, true).
-record(sc_game_task_draw_reply, {
    result = erlang:error({required, result}),
    err,
    reward = []
}).
-endif.

-ifndef(CS_GAME_TASK_BOX_DRAW_REQ_PB_H).
-define(CS_GAME_TASK_BOX_DRAW_REQ_PB_H, true).
-record(cs_game_task_box_draw_req, {
    box = erlang:error({required, box}),
    game_type = erlang:error({required, game_type})
}).
-endif.

-ifndef(SC_GAME_TASK_BOX_DRAW_REPLY_PB_H).
-define(SC_GAME_TASK_BOX_DRAW_REPLY_PB_H, true).
-record(sc_game_task_box_draw_reply, {
    result = erlang:error({required, result}),
    err,
    reward = []
}).
-endif.

-ifndef(SC_REDPACK_TASK_DRAW_LIST_UPDATE_PB_H).
-define(SC_REDPACK_TASK_DRAW_LIST_UPDATE_PB_H, true).
-record(sc_redpack_task_draw_list_update, {
    upd_type = erlang:error({required, upd_type}),
    list = []
}).
-endif.

-ifndef(PB_REDPACK_TASK_DRAW_INFO_PB_H).
-define(PB_REDPACK_TASK_DRAW_INFO_PB_H, true).
-record(pb_redpack_task_draw_info, {
    game_type = erlang:error({required, game_type}),
    gold_num = erlang:error({required, gold_num}),
    draw_list = []
}).
-endif.

-ifndef(CS_REDPACK_TASK_DRAW_REQ_PB_H).
-define(CS_REDPACK_TASK_DRAW_REQ_PB_H, true).
-record(cs_redpack_task_draw_req, {
    game_type = erlang:error({required, game_type}),
    task_id = erlang:error({required, task_id})
}).
-endif.

-ifndef(SC_REDPACK_TASK_DRAW_REPLY_PB_H).
-define(SC_REDPACK_TASK_DRAW_REPLY_PB_H, true).
-record(sc_redpack_task_draw_reply, {
    result = erlang:error({required, result}),
    err,
    reward = [],
    game_type = erlang:error({required, game_type}),
    task_id = erlang:error({required, task_id})
}).
-endif.

