-ifndef(CS_RED_PACK_QUERY_LIST_REQ_PB_H).
-define(CS_RED_PACK_QUERY_LIST_REQ_PB_H, true).
-record(cs_red_pack_query_list_req, {
    begin_id = erlang:error({required, begin_id}),
    end_id = erlang:error({required, end_id})
}).
-endif.

-ifndef(SC_RED_PACK_QUERY_LIST_REPLY_PB_H).
-define(SC_RED_PACK_QUERY_LIST_REPLY_PB_H, true).
-record(sc_red_pack_query_list_reply, {
    begin_id = erlang:error({required, begin_id}),
    end_id = erlang:error({required, end_id}),
    max_num = erlang:error({required, max_num}),
    list = []
}).
-endif.

-ifndef(PB_RED_PACK_INFO_PB_H).
-define(PB_RED_PACK_INFO_PB_H, true).
-record(pb_red_pack_info, {
    uid = erlang:error({required, uid}),
    player_name = erlang:error({required, player_name}),
    player_icon = erlang:error({required, player_icon}),
    player_id = erlang:error({required, player_id}),
    min_num = erlang:error({required, min_num}),
    max_num = erlang:error({required, max_num}),
    over_time = erlang:error({required, over_time}),
    des = erlang:error({required, des}),
    account = erlang:error({required, account}),
    sex = erlang:error({required, sex})
}).
-endif.

-ifndef(CS_RED_PACK_OPEN_REQ_PB_H).
-define(CS_RED_PACK_OPEN_REQ_PB_H, true).
-record(cs_red_pack_open_req, {
    uid = erlang:error({required, uid}),
    check_num = erlang:error({required, check_num})
}).
-endif.

-ifndef(SC_RED_PACK_OPEN_REPLY_PB_H).
-define(SC_RED_PACK_OPEN_REPLY_PB_H, true).
-record(sc_red_pack_open_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    reward_num = erlang:error({required, reward_num}),
    uid = erlang:error({required, uid})
}).
-endif.

-ifndef(CS_RED_PACK_CREATE_REQ_PB_H).
-define(CS_RED_PACK_CREATE_REQ_PB_H, true).
-record(cs_red_pack_create_req, {
    set_num = erlang:error({required, set_num}),
    des = erlang:error({required, des})
}).
-endif.

-ifndef(SC_RED_PACK_CREATE_REPLY_PB_H).
-define(SC_RED_PACK_CREATE_REPLY_PB_H, true).
-record(sc_red_pack_create_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err})
}).
-endif.

-ifndef(SC_RED_PACK_NOTICE_UPDATE_PB_H).
-define(SC_RED_PACK_NOTICE_UPDATE_PB_H, true).
-record(sc_red_pack_notice_update, {
    list = [],
    delete_notice_list = []
}).
-endif.

-ifndef(PB_RED_PACK_NOTICE_PB_H).
-define(PB_RED_PACK_NOTICE_PB_H, true).
-record(pb_red_pack_notice, {
    notice_id = erlang:error({required, notice_id}),
    notice_type = erlang:error({required, notice_type}),
    get_sec_time = erlang:error({required, get_sec_time}),
    content = erlang:error({required, content}),
    gold_num = erlang:error({required, gold_num}),
    type = erlang:error({required, type}),
    open_player_name = erlang:error({required, open_player_name}),
    open_player_account = erlang:error({required, open_player_account}),
    uid = erlang:error({required, uid})
}).
-endif.

-ifndef(CS_RED_PACK_CANCEL_REQ_PB_H).
-define(CS_RED_PACK_CANCEL_REQ_PB_H, true).
-record(cs_red_pack_cancel_req, {
    uid = erlang:error({required, uid})
}).
-endif.

-ifndef(SC_RED_PACK_CANCEL_REPLY_PB_H).
-define(SC_RED_PACK_CANCEL_REPLY_PB_H, true).
-record(sc_red_pack_cancel_reply, {
    result = erlang:error({required, result}),
    err = erlang:error({required, err}),
    uid = erlang:error({required, uid})
}).
-endif.

-ifndef(SC_SELF_RED_PACK_INFO_PB_H).
-define(SC_SELF_RED_PACK_INFO_PB_H, true).
-record(sc_self_red_pack_info, {
    all_red_pack_num = erlang:error({required, all_red_pack_num}),
    red_pack_list = []
}).
-endif.

-ifndef(CS_RED_PACK_DO_SELECT_REQ_PB_H).
-define(CS_RED_PACK_DO_SELECT_REQ_PB_H, true).
-record(cs_red_pack_do_select_req, {
    notice_id = erlang:error({required, notice_id}),
    opt = erlang:error({required, opt})
}).
-endif.

-ifndef(SC_RED_PACK_DO_SELECT_REPLY_PB_H).
-define(SC_RED_PACK_DO_SELECT_REPLY_PB_H, true).
-record(sc_red_pack_do_select_reply, {
    result = erlang:error({required, result}),
    err_msg,
    redpack_id = erlang:error({required, redpack_id}),
    opt = erlang:error({required, opt}),
    notice_id = erlang:error({required, notice_id})
}).
-endif.

-ifndef(CS_RED_PACK_SEARCH_REQ_PB_H).
-define(CS_RED_PACK_SEARCH_REQ_PB_H, true).
-record(cs_red_pack_search_req, {
    uid = erlang:error({required, uid})
}).
-endif.

-ifndef(SC_RED_PACK_SEARCH_REPLY_PB_H).
-define(SC_RED_PACK_SEARCH_REPLY_PB_H, true).
-record(sc_red_pack_search_reply, {
    list = []
}).
-endif.

