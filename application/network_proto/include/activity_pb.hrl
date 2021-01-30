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

-ifndef(SC_ACTIVITY_CONFIG_INFO_UPDATE_PB_H).
-define(SC_ACTIVITY_CONFIG_INFO_UPDATE_PB_H, true).
-record(sc_activity_config_info_update, {
    activity_list = [],
    hide_function_flag = erlang:error({required, hide_function_flag})
}).
-endif.

-ifndef(PB_ACTIVITY_CONFIG_PB_H).
-define(PB_ACTIVITY_CONFIG_PB_H, true).
-record(pb_activity_config, {
    activity_data = erlang:error({required, activity_data}),
    sub_list = []
}).
-endif.

-ifndef(PB_SUB_ACTIVITY_CONFIG_PB_H).
-define(PB_SUB_ACTIVITY_CONFIG_PB_H, true).
-record(pb_sub_activity_config, {
    id = erlang:error({required, id}),
    data = erlang:error({required, data}),
    reward_list = []
}).
-endif.

-ifndef(PB_ACTIVITY_DATA_PB_H).
-define(PB_ACTIVITY_DATA_PB_H, true).
-record(pb_activity_data, {
    id = erlang:error({required, id}),
    current_data = erlang:error({required, current_data}),
    draw_info_list = []
}).
-endif.

-ifndef(CS_ACTIVITY_INFO_QUERY_REQ_PB_H).
-define(CS_ACTIVITY_INFO_QUERY_REQ_PB_H, true).
-record(cs_activity_info_query_req, {
    id = erlang:error({required, id})
}).
-endif.

-ifndef(SC_ACTIVITY_INFO_QUERY_REPLY_PB_H).
-define(SC_ACTIVITY_INFO_QUERY_REPLY_PB_H, true).
-record(sc_activity_info_query_reply, {
    activity_data = erlang:error({required, activity_data})
}).
-endif.

-ifndef(CS_ACTIVITY_DRAW_REQ_PB_H).
-define(CS_ACTIVITY_DRAW_REQ_PB_H, true).
-record(cs_activity_draw_req, {
    activity_id = erlang:error({required, activity_id}),
    sub_id = erlang:error({required, sub_id})
}).
-endif.

-ifndef(SC_ACTIVITY_DRAW_REPLY_PB_H).
-define(SC_ACTIVITY_DRAW_REPLY_PB_H, true).
-record(sc_activity_draw_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    reward_list = [],
    activity_id = erlang:error({required, activity_id}),
    sub_id = erlang:error({required, sub_id})
}).
-endif.

-ifndef(PB_ANNOUCEMENT_CONFIG_PB_H).
-define(PB_ANNOUCEMENT_CONFIG_PB_H, true).
-record(pb_annoucement_config, {
    id = erlang:error({required, id}),
    title = erlang:error({required, title}),
    content = erlang:error({required, content})
}).
-endif.

-ifndef(CS_TASK_PAY_AWARD_REQUEST_PB_H).
-define(CS_TASK_PAY_AWARD_REQUEST_PB_H, true).
-record(cs_task_pay_award_request, {
    index = erlang:error({required, index})
}).
-endif.

-ifndef(SC_TASK_PAY_AWARD_RESPONSE_PB_H).
-define(SC_TASK_PAY_AWARD_RESPONSE_PB_H, true).
-record(sc_task_pay_award_response, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    reward_list = []
}).
-endif.

-ifndef(SC_TASK_PAY_INFO_RESPONSE_PB_H).
-define(SC_TASK_PAY_INFO_RESPONSE_PB_H, true).
-record(sc_task_pay_info_response, {
    task_id = erlang:error({required, task_id}),
    process = erlang:error({required, process}),
    status = [],
    open = erlang:error({required, open})
}).
-endif.

-ifndef(CS_TASK_PAY_INFO_REQUEST_PB_H).
-define(CS_TASK_PAY_INFO_REQUEST_PB_H, true).
-record(cs_task_pay_info_request, {
    
}).
-endif.

