-file("src/mission_pb.erl", 1).

-module(mission_pb).

-export([encode_sc_redpack_task_draw_reply/1,
	 decode_sc_redpack_task_draw_reply/1,
	 encode_cs_redpack_task_draw_req/1,
	 decode_cs_redpack_task_draw_req/1,
	 encode_pb_redpack_task_draw_info/1,
	 decode_pb_redpack_task_draw_info/1,
	 encode_sc_redpack_task_draw_list_update/1,
	 decode_sc_redpack_task_draw_list_update/1,
	 encode_sc_game_task_box_draw_reply/1,
	 decode_sc_game_task_box_draw_reply/1,
	 encode_cs_game_task_box_draw_req/1,
	 decode_cs_game_task_box_draw_req/1,
	 encode_sc_game_task_draw_reply/1,
	 decode_sc_game_task_draw_reply/1,
	 encode_cs_game_task_draw_req/1,
	 decode_cs_game_task_draw_req/1,
	 encode_sc_game_task_box_info_update/1,
	 decode_sc_game_task_box_info_update/1,
	 encode_pb_game_task_info/1, decode_pb_game_task_info/1,
	 encode_sc_game_task_info_update/1,
	 decode_sc_game_task_info_update/1, encode_pb_mission/1,
	 decode_pb_mission/1, encode_sc_mission_del/1,
	 decode_sc_mission_del/1, encode_sc_mission_add/1,
	 decode_sc_mission_add/1, encode_sc_mission_update/1,
	 decode_sc_mission_update/1, encode_sc_mission/1,
	 decode_sc_mission/1,
	 encode_sc_draw_mission_result_reply/1,
	 decode_sc_draw_mission_result_reply/1,
	 encode_cs_draw_mission_request/1,
	 decode_cs_draw_mission_request/1,
	 encode_pb_reward_info/1, decode_pb_reward_info/1,
	 encode_sc_item_use_reply/1, decode_sc_item_use_reply/1,
	 encode_cs_item_use_req/1, decode_cs_item_use_req/1,
	 encode_pb_item_info/1, decode_pb_item_info/1,
	 encode_sc_items_init_update/1,
	 decode_sc_items_init_update/1, encode_sc_items_delete/1,
	 decode_sc_items_delete/1, encode_sc_items_add/1,
	 decode_sc_items_add/1, encode_sc_items_update/1,
	 decode_sc_items_update/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_redpack_task_draw_reply,
	{result, err, reward, game_type, task_id}).

-record(cs_redpack_task_draw_req, {game_type, task_id}).

-record(pb_redpack_task_draw_info,
	{game_type, gold_num, draw_list}).

-record(sc_redpack_task_draw_list_update,
	{upd_type, list}).

-record(sc_game_task_box_draw_reply,
	{result, err, reward}).

-record(cs_game_task_box_draw_req, {box, game_type}).

-record(sc_game_task_draw_reply, {result, err, reward}).

-record(cs_game_task_draw_req, {game_type, task_id}).

-record(sc_game_task_box_info_update,
	{game_type, box_flag_list}).

-record(pb_game_task_info,
	{taskid, process, status, boxstart, boxprocess,
	 boxstatus, remaindtime, tast_type, vip_level}).

-record(sc_game_task_info_update, {tast_info}).

-record(pb_mission, {id, state, count}).

-record(sc_mission_del, {id}).

-record(sc_mission_add, {mission_}).

-record(sc_mission_update, {mission_}).

-record(sc_mission, {missions}).

-record(sc_draw_mission_result_reply,
	{result, err_msg, reward_info_s}).

-record(cs_draw_mission_request, {id}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_redpack_task_draw_reply(Record)
    when is_record(Record, sc_redpack_task_draw_reply) ->
    encode(sc_redpack_task_draw_reply, Record).

encode_cs_redpack_task_draw_req(Record)
    when is_record(Record, cs_redpack_task_draw_req) ->
    encode(cs_redpack_task_draw_req, Record).

encode_pb_redpack_task_draw_info(Record)
    when is_record(Record, pb_redpack_task_draw_info) ->
    encode(pb_redpack_task_draw_info, Record).

encode_sc_redpack_task_draw_list_update(Record)
    when is_record(Record,
		   sc_redpack_task_draw_list_update) ->
    encode(sc_redpack_task_draw_list_update, Record).

encode_sc_game_task_box_draw_reply(Record)
    when is_record(Record, sc_game_task_box_draw_reply) ->
    encode(sc_game_task_box_draw_reply, Record).

encode_cs_game_task_box_draw_req(Record)
    when is_record(Record, cs_game_task_box_draw_req) ->
    encode(cs_game_task_box_draw_req, Record).

encode_sc_game_task_draw_reply(Record)
    when is_record(Record, sc_game_task_draw_reply) ->
    encode(sc_game_task_draw_reply, Record).

encode_cs_game_task_draw_req(Record)
    when is_record(Record, cs_game_task_draw_req) ->
    encode(cs_game_task_draw_req, Record).

encode_sc_game_task_box_info_update(Record)
    when is_record(Record, sc_game_task_box_info_update) ->
    encode(sc_game_task_box_info_update, Record).

encode_pb_game_task_info(Record)
    when is_record(Record, pb_game_task_info) ->
    encode(pb_game_task_info, Record).

encode_sc_game_task_info_update(Record)
    when is_record(Record, sc_game_task_info_update) ->
    encode(sc_game_task_info_update, Record).

encode_pb_mission(Record)
    when is_record(Record, pb_mission) ->
    encode(pb_mission, Record).

encode_sc_mission_del(Record)
    when is_record(Record, sc_mission_del) ->
    encode(sc_mission_del, Record).

encode_sc_mission_add(Record)
    when is_record(Record, sc_mission_add) ->
    encode(sc_mission_add, Record).

encode_sc_mission_update(Record)
    when is_record(Record, sc_mission_update) ->
    encode(sc_mission_update, Record).

encode_sc_mission(Record)
    when is_record(Record, sc_mission) ->
    encode(sc_mission, Record).

encode_sc_draw_mission_result_reply(Record)
    when is_record(Record, sc_draw_mission_result_reply) ->
    encode(sc_draw_mission_result_reply, Record).

encode_cs_draw_mission_request(Record)
    when is_record(Record, cs_draw_mission_request) ->
    encode(cs_draw_mission_request, Record).

encode_pb_reward_info(Record)
    when is_record(Record, pb_reward_info) ->
    encode(pb_reward_info, Record).

encode_sc_item_use_reply(Record)
    when is_record(Record, sc_item_use_reply) ->
    encode(sc_item_use_reply, Record).

encode_cs_item_use_req(Record)
    when is_record(Record, cs_item_use_req) ->
    encode(cs_item_use_req, Record).

encode_pb_item_info(Record)
    when is_record(Record, pb_item_info) ->
    encode(pb_item_info, Record).

encode_sc_items_init_update(Record)
    when is_record(Record, sc_items_init_update) ->
    encode(sc_items_init_update, Record).

encode_sc_items_delete(Record)
    when is_record(Record, sc_items_delete) ->
    encode(sc_items_delete, Record).

encode_sc_items_add(Record)
    when is_record(Record, sc_items_add) ->
    encode(sc_items_add, Record).

encode_sc_items_update(Record)
    when is_record(Record, sc_items_update) ->
    encode(sc_items_update, Record).

encode(sc_items_update, Record) ->
    [iolist(sc_items_update, Record)
     | encode_extensions(Record)];
encode(sc_items_add, Record) ->
    [iolist(sc_items_add, Record)
     | encode_extensions(Record)];
encode(sc_items_delete, Record) ->
    [iolist(sc_items_delete, Record)
     | encode_extensions(Record)];
encode(sc_items_init_update, Record) ->
    [iolist(sc_items_init_update, Record)
     | encode_extensions(Record)];
encode(pb_item_info, Record) ->
    [iolist(pb_item_info, Record)
     | encode_extensions(Record)];
encode(cs_item_use_req, Record) ->
    [iolist(cs_item_use_req, Record)
     | encode_extensions(Record)];
encode(sc_item_use_reply, Record) ->
    [iolist(sc_item_use_reply, Record)
     | encode_extensions(Record)];
encode(pb_reward_info, Record) ->
    [iolist(pb_reward_info, Record)
     | encode_extensions(Record)];
encode(cs_draw_mission_request, Record) ->
    [iolist(cs_draw_mission_request, Record)
     | encode_extensions(Record)];
encode(sc_draw_mission_result_reply, Record) ->
    [iolist(sc_draw_mission_result_reply, Record)
     | encode_extensions(Record)];
encode(sc_mission, Record) ->
    [iolist(sc_mission, Record)
     | encode_extensions(Record)];
encode(sc_mission_update, Record) ->
    [iolist(sc_mission_update, Record)
     | encode_extensions(Record)];
encode(sc_mission_add, Record) ->
    [iolist(sc_mission_add, Record)
     | encode_extensions(Record)];
encode(sc_mission_del, Record) ->
    [iolist(sc_mission_del, Record)
     | encode_extensions(Record)];
encode(pb_mission, Record) ->
    [iolist(pb_mission, Record)
     | encode_extensions(Record)];
encode(sc_game_task_info_update, Record) ->
    [iolist(sc_game_task_info_update, Record)
     | encode_extensions(Record)];
encode(pb_game_task_info, Record) ->
    [iolist(pb_game_task_info, Record)
     | encode_extensions(Record)];
encode(sc_game_task_box_info_update, Record) ->
    [iolist(sc_game_task_box_info_update, Record)
     | encode_extensions(Record)];
encode(cs_game_task_draw_req, Record) ->
    [iolist(cs_game_task_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_game_task_draw_reply, Record) ->
    [iolist(sc_game_task_draw_reply, Record)
     | encode_extensions(Record)];
encode(cs_game_task_box_draw_req, Record) ->
    [iolist(cs_game_task_box_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_game_task_box_draw_reply, Record) ->
    [iolist(sc_game_task_box_draw_reply, Record)
     | encode_extensions(Record)];
encode(sc_redpack_task_draw_list_update, Record) ->
    [iolist(sc_redpack_task_draw_list_update, Record)
     | encode_extensions(Record)];
encode(pb_redpack_task_draw_info, Record) ->
    [iolist(pb_redpack_task_draw_info, Record)
     | encode_extensions(Record)];
encode(cs_redpack_task_draw_req, Record) ->
    [iolist(cs_redpack_task_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_redpack_task_draw_reply, Record) ->
    [iolist(sc_redpack_task_draw_reply, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(sc_items_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_update.upd_list, none),
	  pb_item_info, [])];
iolist(sc_items_add, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_add.add_list, none),
	  pb_item_info, [])];
iolist(sc_items_delete, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_delete.del_list, none),
	  string, [])];
iolist(sc_items_init_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_init_update.all_list,
		       none),
	  pb_item_info, [])];
iolist(pb_item_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_item_info.uuid, none), string,
	  []),
     pack(2, required,
	  with_default(Record#pb_item_info.base_id, none), uint32,
	  []),
     pack(3, required,
	  with_default(Record#pb_item_info.count, none), uint32,
	  [])];
iolist(cs_item_use_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_item_use_req.item_uuid, none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_item_use_req.num, none), uint32,
	  [])];
iolist(sc_item_use_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_item_use_reply.result, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_item_use_reply.err_msg, none),
	  bytes, [])];
iolist(pb_reward_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_reward_info.base_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_reward_info.count, none), uint64,
	  [])];
iolist(cs_draw_mission_request, Record) ->
    [pack(1, required,
	  with_default(Record#cs_draw_mission_request.id, none),
	  uint32, [])];
iolist(sc_draw_mission_result_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_draw_mission_result_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_draw_mission_result_reply.err_msg,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_draw_mission_result_reply.reward_info_s,
		       none),
	  pb_reward_info, [])];
iolist(sc_mission, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_mission.missions, none),
	  pb_mission, [])];
iolist(sc_mission_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mission_update.mission_, none),
	  pb_mission, [])];
iolist(sc_mission_add, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mission_add.mission_, none),
	  pb_mission, [])];
iolist(sc_mission_del, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mission_del.id, none), uint32,
	  [])];
iolist(pb_mission, Record) ->
    [pack(1, required,
	  with_default(Record#pb_mission.id, none), uint32, []),
     pack(2, required,
	  with_default(Record#pb_mission.state, none), uint32,
	  []),
     pack(3, required,
	  with_default(Record#pb_mission.count, none), uint64,
	  [])];
iolist(sc_game_task_info_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_game_task_info_update.tast_info,
		       none),
	  pb_game_task_info, [])];
iolist(pb_game_task_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_game_task_info.taskid, none),
	  int32, []),
     pack(2, optional,
	  with_default(Record#pb_game_task_info.process, none),
	  int32, []),
     pack(3, optional,
	  with_default(Record#pb_game_task_info.status, none),
	  int32, []),
     pack(4, optional,
	  with_default(Record#pb_game_task_info.boxstart, none),
	  int32, []),
     pack(5, optional,
	  with_default(Record#pb_game_task_info.boxprocess, none),
	  int32, []),
     pack(6, repeated,
	  with_default(Record#pb_game_task_info.boxstatus, none),
	  int32, []),
     pack(7, optional,
	  with_default(Record#pb_game_task_info.remaindtime,
		       none),
	  int32, []),
     pack(8, required,
	  with_default(Record#pb_game_task_info.tast_type, none),
	  int32, []),
     pack(9, required,
	  with_default(Record#pb_game_task_info.vip_level, none),
	  int32, [])];
iolist(sc_game_task_box_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_game_task_box_info_update.game_type,
		       none),
	  uint32, []),
     pack(2, repeated,
	  with_default(Record#sc_game_task_box_info_update.box_flag_list,
		       none),
	  uint32, [])];
iolist(cs_game_task_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_game_task_draw_req.game_type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_game_task_draw_req.task_id,
		       none),
	  uint32, [])];
iolist(sc_game_task_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_game_task_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_game_task_draw_reply.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_game_task_draw_reply.reward,
		       none),
	  pb_reward_info, [])];
iolist(cs_game_task_box_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_game_task_box_draw_req.box,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_game_task_box_draw_req.game_type,
		       none),
	  uint32, [])];
iolist(sc_game_task_box_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_game_task_box_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_game_task_box_draw_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_game_task_box_draw_reply.reward,
		       none),
	  pb_reward_info, [])];
iolist(sc_redpack_task_draw_list_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_task_draw_list_update.upd_type,
		       none),
	  uint32, []),
     pack(2, repeated,
	  with_default(Record#sc_redpack_task_draw_list_update.list,
		       none),
	  pb_redpack_task_draw_info, [])];
iolist(pb_redpack_task_draw_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_redpack_task_draw_info.game_type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_redpack_task_draw_info.gold_num,
		       none),
	  uint64, []),
     pack(3, repeated,
	  with_default(Record#pb_redpack_task_draw_info.draw_list,
		       none),
	  uint32, [])];
iolist(cs_redpack_task_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_redpack_task_draw_req.game_type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_redpack_task_draw_req.task_id,
		       none),
	  uint32, [])];
iolist(sc_redpack_task_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_task_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_redpack_task_draw_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_redpack_task_draw_reply.reward,
		       none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_redpack_task_draw_reply.game_type,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_redpack_task_draw_reply.task_id,
		       none),
	  uint32, [])].

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

decode_sc_redpack_task_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_task_draw_reply, Bytes).

decode_cs_redpack_task_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_redpack_task_draw_req, Bytes).

decode_pb_redpack_task_draw_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_redpack_task_draw_info, Bytes).

decode_sc_redpack_task_draw_list_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_task_draw_list_update, Bytes).

decode_sc_game_task_box_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_game_task_box_draw_reply, Bytes).

decode_cs_game_task_box_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_game_task_box_draw_req, Bytes).

decode_sc_game_task_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_game_task_draw_reply, Bytes).

decode_cs_game_task_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_game_task_draw_req, Bytes).

decode_sc_game_task_box_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_game_task_box_info_update, Bytes).

decode_pb_game_task_info(Bytes) when is_binary(Bytes) ->
    decode(pb_game_task_info, Bytes).

decode_sc_game_task_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_game_task_info_update, Bytes).

decode_pb_mission(Bytes) when is_binary(Bytes) ->
    decode(pb_mission, Bytes).

decode_sc_mission_del(Bytes) when is_binary(Bytes) ->
    decode(sc_mission_del, Bytes).

decode_sc_mission_add(Bytes) when is_binary(Bytes) ->
    decode(sc_mission_add, Bytes).

decode_sc_mission_update(Bytes) when is_binary(Bytes) ->
    decode(sc_mission_update, Bytes).

decode_sc_mission(Bytes) when is_binary(Bytes) ->
    decode(sc_mission, Bytes).

decode_sc_draw_mission_result_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_draw_mission_result_reply, Bytes).

decode_cs_draw_mission_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_draw_mission_request, Bytes).

decode_pb_reward_info(Bytes) when is_binary(Bytes) ->
    decode(pb_reward_info, Bytes).

decode_sc_item_use_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_item_use_reply, Bytes).

decode_cs_item_use_req(Bytes) when is_binary(Bytes) ->
    decode(cs_item_use_req, Bytes).

decode_pb_item_info(Bytes) when is_binary(Bytes) ->
    decode(pb_item_info, Bytes).

decode_sc_items_init_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_items_init_update, Bytes).

decode_sc_items_delete(Bytes) when is_binary(Bytes) ->
    decode(sc_items_delete, Bytes).

decode_sc_items_add(Bytes) when is_binary(Bytes) ->
    decode(sc_items_add, Bytes).

decode_sc_items_update(Bytes) when is_binary(Bytes) ->
    decode(sc_items_update, Bytes).

decode(enummsg_values, 1) -> value1;
decode(sc_items_update, Bytes) when is_binary(Bytes) ->
    Types = [{1, upd_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, upd_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_update, Decoded);
decode(sc_items_add, Bytes) when is_binary(Bytes) ->
    Types = [{1, add_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, add_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_add, Decoded);
decode(sc_items_delete, Bytes) when is_binary(Bytes) ->
    Types = [{1, del_list, string, [repeated]}],
    Defaults = [{1, del_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_delete, Decoded);
decode(sc_items_init_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, all_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, all_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_init_update, Decoded);
decode(pb_item_info, Bytes) when is_binary(Bytes) ->
    Types = [{3, count, uint32, []},
	     {2, base_id, uint32, []}, {1, uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_item_info, Decoded);
decode(cs_item_use_req, Bytes) when is_binary(Bytes) ->
    Types = [{2, num, uint32, []},
	     {1, item_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_item_use_req, Decoded);
decode(sc_item_use_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err_msg, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_item_use_reply, Decoded);
decode(pb_reward_info, Bytes) when is_binary(Bytes) ->
    Types = [{2, count, uint64, []},
	     {1, base_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_reward_info, Decoded);
decode(cs_draw_mission_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_draw_mission_request, Decoded);
decode(sc_draw_mission_result_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward_info_s, pb_reward_info,
	      [is_record, repeated]},
	     {2, err_msg, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward_info_s, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_draw_mission_result_reply, Decoded);
decode(sc_mission, Bytes) when is_binary(Bytes) ->
    Types = [{1, missions, pb_mission,
	      [is_record, repeated]}],
    Defaults = [{1, missions, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mission, Decoded);
decode(sc_mission_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, mission_, pb_mission, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mission_update, Decoded);
decode(sc_mission_add, Bytes) when is_binary(Bytes) ->
    Types = [{1, mission_, pb_mission, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mission_add, Decoded);
decode(sc_mission_del, Bytes) when is_binary(Bytes) ->
    Types = [{1, id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mission_del, Decoded);
decode(pb_mission, Bytes) when is_binary(Bytes) ->
    Types = [{3, count, uint64, []}, {2, state, uint32, []},
	     {1, id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_mission, Decoded);
decode(sc_game_task_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, tast_info, pb_game_task_info,
	      [is_record, repeated]}],
    Defaults = [{1, tast_info, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_game_task_info_update, Decoded);
decode(pb_game_task_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{9, vip_level, int32, []},
	     {8, tast_type, int32, []}, {7, remaindtime, int32, []},
	     {6, boxstatus, int32, [repeated]},
	     {5, boxprocess, int32, []}, {4, boxstart, int32, []},
	     {3, status, int32, []}, {2, process, int32, []},
	     {1, taskid, int32, []}],
    Defaults = [{6, boxstatus, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_game_task_info, Decoded);
decode(sc_game_task_box_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, box_flag_list, uint32, [repeated]},
	     {1, game_type, uint32, []}],
    Defaults = [{2, box_flag_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_game_task_box_info_update, Decoded);
decode(cs_game_task_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, task_id, uint32, []},
	     {1, game_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_game_task_draw_req, Decoded);
decode(sc_game_task_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_game_task_draw_reply, Decoded);
decode(cs_game_task_box_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, game_type, uint32, []},
	     {1, box, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_game_task_box_draw_req, Decoded);
decode(sc_game_task_box_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_game_task_box_draw_reply, Decoded);
decode(sc_redpack_task_draw_list_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, list, pb_redpack_task_draw_info,
	      [is_record, repeated]},
	     {1, upd_type, uint32, []}],
    Defaults = [{2, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_task_draw_list_update, Decoded);
decode(pb_redpack_task_draw_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, draw_list, uint32, [repeated]},
	     {2, gold_num, uint64, []}, {1, game_type, uint32, []}],
    Defaults = [{3, draw_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_redpack_task_draw_info, Decoded);
decode(cs_redpack_task_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, task_id, uint32, []},
	     {1, game_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_redpack_task_draw_req, Decoded);
decode(sc_redpack_task_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, task_id, uint32, []},
	     {4, game_type, uint32, []},
	     {3, reward, pb_reward_info, [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_task_draw_reply, Decoded).

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

to_record(sc_items_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_update),
						   Record, Name, Val)
			  end,
			  #sc_items_update{}, DecodedTuples),
    Record1;
to_record(sc_items_add, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_add),
						   Record, Name, Val)
			  end,
			  #sc_items_add{}, DecodedTuples),
    Record1;
to_record(sc_items_delete, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_delete),
						   Record, Name, Val)
			  end,
			  #sc_items_delete{}, DecodedTuples),
    Record1;
to_record(sc_items_init_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_init_update),
						   Record, Name, Val)
			  end,
			  #sc_items_init_update{}, DecodedTuples),
    Record1;
to_record(pb_item_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_item_info),
						   Record, Name, Val)
			  end,
			  #pb_item_info{}, DecodedTuples),
    Record1;
to_record(cs_item_use_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_item_use_req),
						   Record, Name, Val)
			  end,
			  #cs_item_use_req{}, DecodedTuples),
    Record1;
to_record(sc_item_use_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_item_use_reply),
						   Record, Name, Val)
			  end,
			  #sc_item_use_reply{}, DecodedTuples),
    Record1;
to_record(pb_reward_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_reward_info),
						   Record, Name, Val)
			  end,
			  #pb_reward_info{}, DecodedTuples),
    Record1;
to_record(cs_draw_mission_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_draw_mission_request),
						   Record, Name, Val)
			  end,
			  #cs_draw_mission_request{}, DecodedTuples),
    Record1;
to_record(sc_draw_mission_result_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_draw_mission_result_reply),
						   Record, Name, Val)
			  end,
			  #sc_draw_mission_result_reply{}, DecodedTuples),
    Record1;
to_record(sc_mission, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mission),
						   Record, Name, Val)
			  end,
			  #sc_mission{}, DecodedTuples),
    Record1;
to_record(sc_mission_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mission_update),
						   Record, Name, Val)
			  end,
			  #sc_mission_update{}, DecodedTuples),
    Record1;
to_record(sc_mission_add, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mission_add),
						   Record, Name, Val)
			  end,
			  #sc_mission_add{}, DecodedTuples),
    Record1;
to_record(sc_mission_del, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mission_del),
						   Record, Name, Val)
			  end,
			  #sc_mission_del{}, DecodedTuples),
    Record1;
to_record(pb_mission, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_mission),
						   Record, Name, Val)
			  end,
			  #pb_mission{}, DecodedTuples),
    Record1;
to_record(sc_game_task_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_game_task_info_update),
						   Record, Name, Val)
			  end,
			  #sc_game_task_info_update{}, DecodedTuples),
    Record1;
to_record(pb_game_task_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_game_task_info),
						   Record, Name, Val)
			  end,
			  #pb_game_task_info{}, DecodedTuples),
    Record1;
to_record(sc_game_task_box_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_game_task_box_info_update),
						   Record, Name, Val)
			  end,
			  #sc_game_task_box_info_update{}, DecodedTuples),
    Record1;
to_record(cs_game_task_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_game_task_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_game_task_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_game_task_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_game_task_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_game_task_draw_reply{}, DecodedTuples),
    Record1;
to_record(cs_game_task_box_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_game_task_box_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_game_task_box_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_game_task_box_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_game_task_box_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_game_task_box_draw_reply{}, DecodedTuples),
    Record1;
to_record(sc_redpack_task_draw_list_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_task_draw_list_update),
						   Record, Name, Val)
			  end,
			  #sc_redpack_task_draw_list_update{}, DecodedTuples),
    Record1;
to_record(pb_redpack_task_draw_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_redpack_task_draw_info),
						   Record, Name, Val)
			  end,
			  #pb_redpack_task_draw_info{}, DecodedTuples),
    Record1;
to_record(cs_redpack_task_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_redpack_task_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_redpack_task_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_redpack_task_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_task_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_redpack_task_draw_reply{}, DecodedTuples),
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

