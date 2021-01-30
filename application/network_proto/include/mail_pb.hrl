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

-ifndef(SC_MAILS_INIT_UPDATE_PB_H).
-define(SC_MAILS_INIT_UPDATE_PB_H, true).
-record(sc_mails_init_update, {
    sys_mails = []
}).
-endif.

-ifndef(PB_MAIL_PB_H).
-define(PB_MAIL_PB_H, true).
-record(pb_mail, {
    mail_id = erlang:error({required, mail_id}),
    cls = erlang:error({required, cls}),
    title = erlang:error({required, title}),
    content = erlang:error({required, content}),
    read = erlang:error({required, read}),
    receive_date = erlang:error({required, receive_date}),
    expire_date = erlang:error({required, expire_date}),
    reward_list = []
}).
-endif.

-ifndef(SC_MAIL_ADD_PB_H).
-define(SC_MAIL_ADD_PB_H, true).
-record(sc_mail_add, {
    add_sys_mail = erlang:error({required, add_sys_mail})
}).
-endif.

-ifndef(CS_MAIL_DELETE_REQUEST_PB_H).
-define(CS_MAIL_DELETE_REQUEST_PB_H, true).
-record(cs_mail_delete_request, {
    mail_id = erlang:error({required, mail_id}),
    request_mark
}).
-endif.

-ifndef(SC_MAIL_DELETE_REPLY_PB_H).
-define(SC_MAIL_DELETE_REPLY_PB_H, true).
-record(sc_mail_delete_reply, {
    result = erlang:error({required, result}),
    err_msg,
    request_mark
}).
-endif.

-ifndef(CS_READ_MAIL_PB_H).
-define(CS_READ_MAIL_PB_H, true).
-record(cs_read_mail, {
    mail_id = erlang:error({required, mail_id})
}).
-endif.

-ifndef(CS_MAIL_DRAW_REQUEST_PB_H).
-define(CS_MAIL_DRAW_REQUEST_PB_H, true).
-record(cs_mail_draw_request, {
    mail_ids = [],
    request_mark
}).
-endif.

-ifndef(SC_MAIL_DRAW_REPLY_PB_H).
-define(SC_MAIL_DRAW_REPLY_PB_H, true).
-record(sc_mail_draw_reply, {
    result = erlang:error({required, result}),
    err_msg,
    reward_info_s = [],
    request_mark
}).
-endif.

