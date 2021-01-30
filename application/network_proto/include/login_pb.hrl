-ifndef(CS_LOGIN_PB_H).
-define(CS_LOGIN_PB_H, true).
-record(cs_login, {
    platform_flag = erlang:error({required, platform_flag}),
    uid = erlang:error({required, uid}),
    password = erlang:error({required, password}),
    sz_param = erlang:error({required, sz_param}),
    version = erlang:error({required, version}),
    network_type = erlang:error({required, network_type}),
    sys_type = erlang:error({required, sys_type}),
    chnid = erlang:error({required, chnid}),
    sub_chnid = erlang:error({required, sub_chnid}),
    ios_idfa = erlang:error({required, ios_idfa}),
    ios_idfv = erlang:error({required, ios_idfv}),
    mac_address = erlang:error({required, mac_address}),
    device_type = erlang:error({required, device_type})
}).
-endif.

-ifndef(SC_LOGIN_REPLY_PB_H).
-define(SC_LOGIN_REPLY_PB_H, true).
-record(sc_login_reply, {
    result = erlang:error({required, result}),
    reason = erlang:error({required, reason}),
    reconnect_key = erlang:error({required, reconnect_key}),
    proto_key = erlang:error({required, proto_key})
}).
-endif.

-ifndef(CS_LOGIN_OUT_PB_H).
-define(CS_LOGIN_OUT_PB_H, true).
-record(cs_login_out, {
    
}).
-endif.

-ifndef(CS_LOGIN_RECONNECTION_PB_H).
-define(CS_LOGIN_RECONNECTION_PB_H, true).
-record(cs_login_reconnection, {
    platform_flag = erlang:error({required, platform_flag}),
    user = erlang:error({required, user}),
    reconnect_key = erlang:error({required, reconnect_key})
}).
-endif.

-ifndef(SC_LOGIN_RECONNECTION_REPLY_PB_H).
-define(SC_LOGIN_RECONNECTION_REPLY_PB_H, true).
-record(sc_login_reconnection_reply, {
    result = erlang:error({required, result}),
    reason = erlang:error({required, reason}),
    proto_key = erlang:error({required, proto_key})
}).
-endif.

-ifndef(SC_LOGIN_REPEAT_PB_H).
-define(SC_LOGIN_REPEAT_PB_H, true).
-record(sc_login_repeat, {
    
}).
-endif.

-ifndef(SC_LOGIN_PROTO_COMPLETE_PB_H).
-define(SC_LOGIN_PROTO_COMPLETE_PB_H, true).
-record(sc_login_proto_complete, {
    is_new_player = erlang:error({required, is_new_player})
}).
-endif.

