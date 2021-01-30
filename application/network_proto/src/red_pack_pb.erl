-file("src/red_pack_pb.erl", 1).

-module(red_pack_pb).

-export([encode_sc_red_pack_search_reply/1,
	 decode_sc_red_pack_search_reply/1,
	 encode_cs_red_pack_search_req/1,
	 decode_cs_red_pack_search_req/1,
	 encode_sc_red_pack_do_select_reply/1,
	 decode_sc_red_pack_do_select_reply/1,
	 encode_cs_red_pack_do_select_req/1,
	 decode_cs_red_pack_do_select_req/1,
	 encode_sc_self_red_pack_info/1,
	 decode_sc_self_red_pack_info/1,
	 encode_sc_red_pack_cancel_reply/1,
	 decode_sc_red_pack_cancel_reply/1,
	 encode_cs_red_pack_cancel_req/1,
	 decode_cs_red_pack_cancel_req/1,
	 encode_pb_red_pack_notice/1,
	 decode_pb_red_pack_notice/1,
	 encode_sc_red_pack_notice_update/1,
	 decode_sc_red_pack_notice_update/1,
	 encode_sc_red_pack_create_reply/1,
	 decode_sc_red_pack_create_reply/1,
	 encode_cs_red_pack_create_req/1,
	 decode_cs_red_pack_create_req/1,
	 encode_sc_red_pack_open_reply/1,
	 decode_sc_red_pack_open_reply/1,
	 encode_cs_red_pack_open_req/1,
	 decode_cs_red_pack_open_req/1,
	 encode_pb_red_pack_info/1, decode_pb_red_pack_info/1,
	 encode_sc_red_pack_query_list_reply/1,
	 decode_sc_red_pack_query_list_reply/1,
	 encode_cs_red_pack_query_list_req/1,
	 decode_cs_red_pack_query_list_req/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_red_pack_search_reply, {list}).

-record(cs_red_pack_search_req, {uid}).

-record(sc_red_pack_do_select_reply,
	{result, err_msg, redpack_id, opt, notice_id}).

-record(cs_red_pack_do_select_req, {notice_id, opt}).

-record(sc_self_red_pack_info,
	{all_red_pack_num, red_pack_list}).

-record(sc_red_pack_cancel_reply, {result, err, uid}).

-record(cs_red_pack_cancel_req, {uid}).

-record(pb_red_pack_notice,
	{notice_id, notice_type, get_sec_time, content,
	 gold_num, type, open_player_name, open_player_account,
	 uid}).

-record(sc_red_pack_notice_update,
	{list, delete_notice_list}).

-record(sc_red_pack_create_reply, {result, err}).

-record(cs_red_pack_create_req, {set_num, des}).

-record(sc_red_pack_open_reply,
	{result, err, reward_num, uid}).

-record(cs_red_pack_open_req, {uid, check_num}).

-record(pb_red_pack_info,
	{uid, player_name, player_icon, player_id, min_num,
	 max_num, over_time, des, account, sex}).

-record(sc_red_pack_query_list_reply,
	{begin_id, end_id, max_num, list}).

-record(cs_red_pack_query_list_req, {begin_id, end_id}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_red_pack_search_reply(Record)
    when is_record(Record, sc_red_pack_search_reply) ->
    encode(sc_red_pack_search_reply, Record).

encode_cs_red_pack_search_req(Record)
    when is_record(Record, cs_red_pack_search_req) ->
    encode(cs_red_pack_search_req, Record).

encode_sc_red_pack_do_select_reply(Record)
    when is_record(Record, sc_red_pack_do_select_reply) ->
    encode(sc_red_pack_do_select_reply, Record).

encode_cs_red_pack_do_select_req(Record)
    when is_record(Record, cs_red_pack_do_select_req) ->
    encode(cs_red_pack_do_select_req, Record).

encode_sc_self_red_pack_info(Record)
    when is_record(Record, sc_self_red_pack_info) ->
    encode(sc_self_red_pack_info, Record).

encode_sc_red_pack_cancel_reply(Record)
    when is_record(Record, sc_red_pack_cancel_reply) ->
    encode(sc_red_pack_cancel_reply, Record).

encode_cs_red_pack_cancel_req(Record)
    when is_record(Record, cs_red_pack_cancel_req) ->
    encode(cs_red_pack_cancel_req, Record).

encode_pb_red_pack_notice(Record)
    when is_record(Record, pb_red_pack_notice) ->
    encode(pb_red_pack_notice, Record).

encode_sc_red_pack_notice_update(Record)
    when is_record(Record, sc_red_pack_notice_update) ->
    encode(sc_red_pack_notice_update, Record).

encode_sc_red_pack_create_reply(Record)
    when is_record(Record, sc_red_pack_create_reply) ->
    encode(sc_red_pack_create_reply, Record).

encode_cs_red_pack_create_req(Record)
    when is_record(Record, cs_red_pack_create_req) ->
    encode(cs_red_pack_create_req, Record).

encode_sc_red_pack_open_reply(Record)
    when is_record(Record, sc_red_pack_open_reply) ->
    encode(sc_red_pack_open_reply, Record).

encode_cs_red_pack_open_req(Record)
    when is_record(Record, cs_red_pack_open_req) ->
    encode(cs_red_pack_open_req, Record).

encode_pb_red_pack_info(Record)
    when is_record(Record, pb_red_pack_info) ->
    encode(pb_red_pack_info, Record).

encode_sc_red_pack_query_list_reply(Record)
    when is_record(Record, sc_red_pack_query_list_reply) ->
    encode(sc_red_pack_query_list_reply, Record).

encode_cs_red_pack_query_list_req(Record)
    when is_record(Record, cs_red_pack_query_list_req) ->
    encode(cs_red_pack_query_list_req, Record).

encode(cs_red_pack_query_list_req, Record) ->
    [iolist(cs_red_pack_query_list_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_query_list_reply, Record) ->
    [iolist(sc_red_pack_query_list_reply, Record)
     | encode_extensions(Record)];
encode(pb_red_pack_info, Record) ->
    [iolist(pb_red_pack_info, Record)
     | encode_extensions(Record)];
encode(cs_red_pack_open_req, Record) ->
    [iolist(cs_red_pack_open_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_open_reply, Record) ->
    [iolist(sc_red_pack_open_reply, Record)
     | encode_extensions(Record)];
encode(cs_red_pack_create_req, Record) ->
    [iolist(cs_red_pack_create_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_create_reply, Record) ->
    [iolist(sc_red_pack_create_reply, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_notice_update, Record) ->
    [iolist(sc_red_pack_notice_update, Record)
     | encode_extensions(Record)];
encode(pb_red_pack_notice, Record) ->
    [iolist(pb_red_pack_notice, Record)
     | encode_extensions(Record)];
encode(cs_red_pack_cancel_req, Record) ->
    [iolist(cs_red_pack_cancel_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_cancel_reply, Record) ->
    [iolist(sc_red_pack_cancel_reply, Record)
     | encode_extensions(Record)];
encode(sc_self_red_pack_info, Record) ->
    [iolist(sc_self_red_pack_info, Record)
     | encode_extensions(Record)];
encode(cs_red_pack_do_select_req, Record) ->
    [iolist(cs_red_pack_do_select_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_do_select_reply, Record) ->
    [iolist(sc_red_pack_do_select_reply, Record)
     | encode_extensions(Record)];
encode(cs_red_pack_search_req, Record) ->
    [iolist(cs_red_pack_search_req, Record)
     | encode_extensions(Record)];
encode(sc_red_pack_search_reply, Record) ->
    [iolist(sc_red_pack_search_reply, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(cs_red_pack_query_list_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_query_list_req.begin_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_red_pack_query_list_req.end_id,
		       none),
	  uint32, [])];
iolist(sc_red_pack_query_list_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_red_pack_query_list_reply.begin_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_red_pack_query_list_reply.end_id,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_red_pack_query_list_reply.max_num,
		       none),
	  uint32, []),
     pack(4, repeated,
	  with_default(Record#sc_red_pack_query_list_reply.list,
		       none),
	  pb_red_pack_info, [])];
iolist(pb_red_pack_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_red_pack_info.uid, none), string,
	  []),
     pack(2, required,
	  with_default(Record#pb_red_pack_info.player_name, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#pb_red_pack_info.player_icon, none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#pb_red_pack_info.player_id, none),
	  string, []),
     pack(5, required,
	  with_default(Record#pb_red_pack_info.min_num, none),
	  uint64, []),
     pack(6, required,
	  with_default(Record#pb_red_pack_info.max_num, none),
	  uint64, []),
     pack(7, required,
	  with_default(Record#pb_red_pack_info.over_time, none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#pb_red_pack_info.des, none), bytes,
	  []),
     pack(9, required,
	  with_default(Record#pb_red_pack_info.account, none),
	  string, []),
     pack(10, required,
	  with_default(Record#pb_red_pack_info.sex, none), uint32,
	  [])];
iolist(cs_red_pack_open_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_open_req.uid, none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_red_pack_open_req.check_num,
		       none),
	  uint64, [])];
iolist(sc_red_pack_open_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_red_pack_open_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_red_pack_open_reply.err, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_red_pack_open_reply.reward_num,
		       none),
	  uint64, []),
     pack(4, required,
	  with_default(Record#sc_red_pack_open_reply.uid, none),
	  string, [])];
iolist(cs_red_pack_create_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_create_req.set_num,
		       none),
	  uint64, []),
     pack(2, required,
	  with_default(Record#cs_red_pack_create_req.des, none),
	  bytes, [])];
iolist(sc_red_pack_create_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_red_pack_create_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_red_pack_create_reply.err, none),
	  bytes, [])];
iolist(sc_red_pack_notice_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_red_pack_notice_update.list,
		       none),
	  pb_red_pack_notice, []),
     pack(2, repeated,
	  with_default(Record#sc_red_pack_notice_update.delete_notice_list,
		       none),
	  string, [])];
iolist(pb_red_pack_notice, Record) ->
    [pack(1, required,
	  with_default(Record#pb_red_pack_notice.notice_id, none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_red_pack_notice.notice_type,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#pb_red_pack_notice.get_sec_time,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_red_pack_notice.content, none),
	  bytes, []),
     pack(5, required,
	  with_default(Record#pb_red_pack_notice.gold_num, none),
	  uint64, []),
     pack(6, required,
	  with_default(Record#pb_red_pack_notice.type, none),
	  uint32, []),
     pack(7, required,
	  with_default(Record#pb_red_pack_notice.open_player_name,
		       none),
	  bytes, []),
     pack(8, required,
	  with_default(Record#pb_red_pack_notice.open_player_account,
		       none),
	  string, []),
     pack(9, required,
	  with_default(Record#pb_red_pack_notice.uid, none),
	  string, [])];
iolist(cs_red_pack_cancel_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_cancel_req.uid, none),
	  string, [])];
iolist(sc_red_pack_cancel_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_red_pack_cancel_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_red_pack_cancel_reply.err, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_red_pack_cancel_reply.uid, none),
	  string, [])];
iolist(sc_self_red_pack_info, Record) ->
    [pack(1, required,
	  with_default(Record#sc_self_red_pack_info.all_red_pack_num,
		       none),
	  uint32, []),
     pack(2, repeated,
	  with_default(Record#sc_self_red_pack_info.red_pack_list,
		       none),
	  pb_red_pack_info, [])];
iolist(cs_red_pack_do_select_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_do_select_req.notice_id,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_red_pack_do_select_req.opt,
		       none),
	  uint32, [])];
iolist(sc_red_pack_do_select_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_red_pack_do_select_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_red_pack_do_select_reply.err_msg,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_red_pack_do_select_reply.redpack_id,
		       none),
	  string, []),
     pack(4, required,
	  with_default(Record#sc_red_pack_do_select_reply.opt,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_red_pack_do_select_reply.notice_id,
		       none),
	  string, [])];
iolist(cs_red_pack_search_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_red_pack_search_req.uid, none),
	  string, [])];
iolist(sc_red_pack_search_reply, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_red_pack_search_reply.list,
		       none),
	  pb_red_pack_info, [])].

with_default(Default, Default) -> undefined;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(_, repeated_packed, undefined, _, _) -> [];
pack(_, repeated_packed, [], _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, repeated_packed, Data, Type, _) ->
    protobuffs:encode_packed(FNum, Data, Type);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    [RecName | _] = tuple_to_list(Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _)
    when Type =:= bool;
	 Type =:= int32;
	 Type =:= uint32;
	 Type =:= int64;
	 Type =:= uint64;
	 Type =:= sint32;
	 Type =:= sint64;
	 Type =:= fixed32;
	 Type =:= sfixed32;
	 Type =:= fixed64;
	 Type =:= sfixed64;
	 Type =:= string;
	 Type =:= bytes;
	 Type =:= float;
	 Type =:= double ->
    protobuffs:encode(FNum, Data, Type);
pack(FNum, _, Data, Type, _) when is_atom(Data) ->
    protobuffs:encode(FNum, enum_to_int(Type, Data), enum).

enum_to_int(pikachu, value) -> 1.

int_to_enum(_, Val) -> Val.

decode_sc_red_pack_search_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_search_reply, Bytes).

decode_cs_red_pack_search_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_search_req, Bytes).

decode_sc_red_pack_do_select_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_do_select_reply, Bytes).

decode_cs_red_pack_do_select_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_do_select_req, Bytes).

decode_sc_self_red_pack_info(Bytes)
    when is_binary(Bytes) ->
    decode(sc_self_red_pack_info, Bytes).

decode_sc_red_pack_cancel_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_cancel_reply, Bytes).

decode_cs_red_pack_cancel_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_cancel_req, Bytes).

decode_pb_red_pack_notice(Bytes)
    when is_binary(Bytes) ->
    decode(pb_red_pack_notice, Bytes).

decode_sc_red_pack_notice_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_notice_update, Bytes).

decode_sc_red_pack_create_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_create_reply, Bytes).

decode_cs_red_pack_create_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_create_req, Bytes).

decode_sc_red_pack_open_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_open_reply, Bytes).

decode_cs_red_pack_open_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_open_req, Bytes).

decode_pb_red_pack_info(Bytes) when is_binary(Bytes) ->
    decode(pb_red_pack_info, Bytes).

decode_sc_red_pack_query_list_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_red_pack_query_list_reply, Bytes).

decode_cs_red_pack_query_list_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_red_pack_query_list_req, Bytes).

decode(enummsg_values, 1) -> value1;
decode(cs_red_pack_query_list_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, end_id, uint32, []},
	     {1, begin_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_query_list_req, Decoded);
decode(sc_red_pack_query_list_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, list, pb_red_pack_info,
	      [is_record, repeated]},
	     {3, max_num, uint32, []}, {2, end_id, uint32, []},
	     {1, begin_id, uint32, []}],
    Defaults = [{4, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_query_list_reply, Decoded);
decode(pb_red_pack_info, Bytes) when is_binary(Bytes) ->
    Types = [{10, sex, uint32, []},
	     {9, account, string, []}, {8, des, bytes, []},
	     {7, over_time, uint32, []}, {6, max_num, uint64, []},
	     {5, min_num, uint64, []}, {4, player_id, string, []},
	     {3, player_icon, bytes, []},
	     {2, player_name, bytes, []}, {1, uid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_red_pack_info, Decoded);
decode(cs_red_pack_open_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, check_num, uint64, []},
	     {1, uid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_open_req, Decoded);
decode(sc_red_pack_open_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, uid, string, []},
	     {3, reward_num, uint64, []}, {2, err, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_open_reply, Decoded);
decode(cs_red_pack_create_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, des, bytes, []}, {1, set_num, uint64, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_create_req, Decoded);
decode(sc_red_pack_create_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_create_reply, Decoded);
decode(sc_red_pack_notice_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, delete_notice_list, string, [repeated]},
	     {1, list, pb_red_pack_notice, [is_record, repeated]}],
    Defaults = [{1, list, []}, {2, delete_notice_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_notice_update, Decoded);
decode(pb_red_pack_notice, Bytes)
    when is_binary(Bytes) ->
    Types = [{9, uid, string, []},
	     {8, open_player_account, string, []},
	     {7, open_player_name, bytes, []}, {6, type, uint32, []},
	     {5, gold_num, uint64, []}, {4, content, bytes, []},
	     {3, get_sec_time, uint32, []},
	     {2, notice_type, uint32, []},
	     {1, notice_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_red_pack_notice, Decoded);
decode(cs_red_pack_cancel_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, uid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_cancel_req, Decoded);
decode(sc_red_pack_cancel_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, uid, string, []}, {2, err, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_cancel_reply, Decoded);
decode(sc_self_red_pack_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, red_pack_list, pb_red_pack_info,
	      [is_record, repeated]},
	     {1, all_red_pack_num, uint32, []}],
    Defaults = [{2, red_pack_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_self_red_pack_info, Decoded);
decode(cs_red_pack_do_select_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, opt, uint32, []},
	     {1, notice_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_do_select_req, Decoded);
decode(sc_red_pack_do_select_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, notice_id, string, []},
	     {4, opt, uint32, []}, {3, redpack_id, string, []},
	     {2, err_msg, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_do_select_reply, Decoded);
decode(cs_red_pack_search_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, uid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_red_pack_search_req, Decoded);
decode(sc_red_pack_search_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_red_pack_info,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_red_pack_search_reply, Decoded).

decode(<<>>, Types, Acc) ->
    reverse_repeated_fields(Acc, Types);
decode(Bytes, Types, Acc) ->
    {ok, FNum} = protobuffs:next_field_num(Bytes),
    case lists:keyfind(FNum, 1, Types) of
      {FNum, Name, Type, Opts} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {{FNum, V}, R} = protobuffs:decode(Bytes,
								     bytes),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  case lists:member(repeated_packed, Opts) of
				    true ->
					{{FNum, V}, R} =
					    protobuffs:decode_packed(Bytes,
								     Type),
					{V, R};
				    false ->
					{{FNum, V}, R} =
					    protobuffs:decode(Bytes, Type),
					{unpack_value(V, Type), R}
				  end
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1) | List]}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1)]} | Acc])
		end;
	    false ->
		decode(Rest1, Types,
		       [{FNum, Name, int_to_enum(Type, Value1)} | Acc])
	  end;
      false ->
	  case lists:keyfind('$extensions', 2, Acc) of
	    {_, _, Dict} ->
		{{FNum, _V}, R} = protobuffs:decode(Bytes, bytes),
		Diff = size(Bytes) - size(R),
		<<V:Diff/binary, _/binary>> = Bytes,
		NewDict = dict:store(FNum, V, Dict),
		NewAcc = lists:keyreplace('$extensions', 2, Acc,
					  {false, '$extensions', NewDict}),
		decode(R, Types, NewAcc);
	    _ ->
		{ok, Skipped} = protobuffs:skip_next_field(Bytes),
		decode(Skipped, Types, Acc)
	  end
    end.

reverse_repeated_fields(FieldList, Types) ->
    [begin
       case lists:keyfind(FNum, 1, Types) of
	 {FNum, Name, _Type, Opts} ->
	     case lists:member(repeated, Opts) of
	       true -> {FNum, Name, lists:reverse(Value)};
	       _ -> Field
	     end;
	 _ -> Field
       end
     end
     || {FNum, Name, Value} = Field <- FieldList].

unpack_value(Binary, string) when is_binary(Binary) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(cs_red_pack_query_list_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_query_list_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_query_list_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_query_list_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_query_list_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_query_list_reply{}, DecodedTuples),
    Record1;
to_record(pb_red_pack_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_red_pack_info),
						   Record, Name, Val)
			  end,
			  #pb_red_pack_info{}, DecodedTuples),
    Record1;
to_record(cs_red_pack_open_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_open_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_open_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_open_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_open_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_open_reply{}, DecodedTuples),
    Record1;
to_record(cs_red_pack_create_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_create_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_create_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_create_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_create_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_create_reply{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_notice_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_notice_update),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_notice_update{}, DecodedTuples),
    Record1;
to_record(pb_red_pack_notice, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_red_pack_notice),
						   Record, Name, Val)
			  end,
			  #pb_red_pack_notice{}, DecodedTuples),
    Record1;
to_record(cs_red_pack_cancel_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_cancel_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_cancel_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_cancel_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_cancel_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_cancel_reply{}, DecodedTuples),
    Record1;
to_record(sc_self_red_pack_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_self_red_pack_info),
						   Record, Name, Val)
			  end,
			  #sc_self_red_pack_info{}, DecodedTuples),
    Record1;
to_record(cs_red_pack_do_select_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_do_select_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_do_select_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_do_select_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_do_select_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_do_select_reply{}, DecodedTuples),
    Record1;
to_record(cs_red_pack_search_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_red_pack_search_req),
						   Record, Name, Val)
			  end,
			  #cs_red_pack_search_req{}, DecodedTuples),
    Record1;
to_record(sc_red_pack_search_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_red_pack_search_reply),
						   Record, Name, Val)
			  end,
			  #sc_red_pack_search_reply{}, DecodedTuples),
    Record1.

decode_extensions(Record) -> Record.

decode_extensions(_Types, [], Acc) ->
    dict:from_list(Acc);
decode_extensions(Types, [{Fnum, Bytes} | Tail], Acc) ->
    NewAcc = case lists:keyfind(Fnum, 1, Types) of
	       {Fnum, Name, Type, Opts} ->
		   {Value1, Rest1} = case lists:member(is_record, Opts) of
				       true ->
					   {{FNum, V}, R} =
					       protobuffs:decode(Bytes, bytes),
					   RecVal = decode(Type, V),
					   {RecVal, R};
				       false ->
					   case lists:member(repeated_packed,
							     Opts)
					       of
					     true ->
						 {{FNum, V}, R} =
						     protobuffs:decode_packed(Bytes,
									      Type),
						 {V, R};
					     false ->
						 {{FNum, V}, R} =
						     protobuffs:decode(Bytes,
								       Type),
						 {unpack_value(V, Type), R}
					   end
				     end,
		   case lists:member(repeated, Opts) of
		     true ->
			 case lists:keytake(FNum, 1, Acc) of
			   {value, {FNum, Name, List}, Acc1} ->
			       decode(Rest1, Types,
				      [{FNum, Name,
					lists:reverse([int_to_enum(Type, Value1)
						       | lists:reverse(List)])}
				       | Acc1]);
			   false ->
			       decode(Rest1, Types,
				      [{FNum, Name, [int_to_enum(Type, Value1)]}
				       | Acc])
			 end;
		     false ->
			 [{Fnum,
			   {optional, int_to_enum(Type, Value1), Type, Opts}}
			  | Acc]
		   end;
	       false -> [{Fnum, Bytes} | Acc]
	     end,
    decode_extensions(Types, Tail, NewAcc).

set_record_field(Fields, Record, '$extensions',
		 Value) ->
    Decodable = [],
    NewValue = decode_extensions(element(1, Record),
				 Decodable, dict:to_list(Value)),
    Index = list_index('$extensions', Fields),
    erlang:setelement(Index + 1, Record, NewValue);
set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> -1.

extension_size(_) -> 0.

has_extension(_Record, _FieldName) -> false.

get_extension(_Record, _FieldName) -> undefined.

set_extension(Record, _, _) -> {error, Record}.

