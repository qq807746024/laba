-ifndef(CS_COMMON_HEARTBEAT_PB_H).
-define(CS_COMMON_HEARTBEAT_PB_H, true).
-record(cs_common_heartbeat, {
    
}).
-endif.

-ifndef(SC_COMMON_HEARTBEAT_REPLY_PB_H).
-define(SC_COMMON_HEARTBEAT_REPLY_PB_H, true).
-record(sc_common_heartbeat_reply, {
    now_time = erlang:error({required, now_time})
}).
-endif.

-ifndef(CS_COMMON_PROTO_COUNT_PB_H).
-define(CS_COMMON_PROTO_COUNT_PB_H, true).
-record(cs_common_proto_count, {
    count = erlang:error({required, count})
}).
-endif.

-ifndef(SC_COMMON_PROTO_COUNT_PB_H).
-define(SC_COMMON_PROTO_COUNT_PB_H, true).
-record(sc_common_proto_count, {
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_COMMON_PROTO_CLEAN_PB_H).
-define(CS_COMMON_PROTO_CLEAN_PB_H, true).
-record(cs_common_proto_clean, {
    count = erlang:error({required, count})
}).
-endif.

-ifndef(SC_COMMON_PROTO_CLEAN_PB_H).
-define(SC_COMMON_PROTO_CLEAN_PB_H, true).
-record(sc_common_proto_clean, {
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_COMMON_BUG_FEEDBACK_PB_H).
-define(CS_COMMON_BUG_FEEDBACK_PB_H, true).
-record(cs_common_bug_feedback, {
    content = erlang:error({required, content})
}).
-endif.

-ifndef(SC_COMMON_BUG_FEEDBACK_PB_H).
-define(SC_COMMON_BUG_FEEDBACK_PB_H, true).
-record(sc_common_bug_feedback, {
    result = erlang:error({required, result})
}).
-endif.

