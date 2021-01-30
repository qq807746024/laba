-file("src/prize_exchange_pb.erl", 1).

-module(prize_exchange_pb).

-export([encode_sc_prize_query_phonecard_key_reply/1,
	 decode_sc_prize_query_phonecard_key_reply/1,
	 encode_cs_prize_query_phonecard_key_req/1,
	 decode_cs_prize_query_phonecard_key_req/1,
	 encode_pb_prize_query_one/1,
	 decode_pb_prize_query_one/1,
	 encode_sc_prize_storage_red_point_update/1,
	 decode_sc_prize_storage_red_point_update/1,
	 encode_sc_prize_address_change_reply/1,
	 decode_sc_prize_address_change_reply/1,
	 encode_cs_prize_address_change_req/1,
	 decode_cs_prize_address_change_req/1,
	 encode_pb_prize_address_info/1,
	 decode_pb_prize_address_info/1,
	 encode_sc_prize_address_info_update/1,
	 decode_sc_prize_address_info_update/1,
	 encode_pb_prize_exchange_record/1,
	 decode_pb_prize_exchange_record/1,
	 encode_sc_prize_exchange_record_update/1,
	 decode_sc_prize_exchange_record_update/1,
	 encode_sc_prize_exchange_reply/1,
	 decode_sc_prize_exchange_reply/1,
	 encode_cs_prize_exchange_req/1,
	 decode_cs_prize_exchange_req/1,
	 encode_sc_prize_query_one_reply/1,
	 decode_sc_prize_query_one_reply/1,
	 encode_cs_prize_query_one_req/1,
	 decode_cs_prize_query_one_req/1, encode_pb_prize_info/1,
	 decode_pb_prize_info/1, encode_sc_prize_config_update/1,
	 decode_sc_prize_config_update/1,
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

-record(sc_prize_query_phonecard_key_reply,
	{result, err, state, key}).

-record(cs_prize_query_phonecard_key_req, {rec_id}).

-record(pb_prize_query_one,
	{obj_id, store_num, crad_num}).

-record(sc_prize_storage_red_point_update, {list}).

-record(sc_prize_address_change_reply, {result, err}).

-record(cs_prize_address_change_req, {new_info}).

-record(pb_prize_address_info,
	{id, name, sex, province_name, city_name, address,
	 phone_number}).

-record(sc_prize_address_info_update, {list}).

-record(pb_prize_exchange_record,
	{id, record_type, obj_id, need_item_id, need_item_num,
	 second_time, recharge_type, recharge_state, card_number,
	 card_psd}).

-record(sc_prize_exchange_record_update, {list}).

-record(sc_prize_exchange_reply,
	{result, err, reward, obj_id}).

-record(cs_prize_exchange_req,
	{obj_id, phone_card_charge_type, phone_number,
	 address_id}).

-record(sc_prize_query_one_reply,
	{obj_id, day_times_config, today_exchange_times,
	 store_num, crad_num, special_left_times,
	 need_vip_level}).

-record(cs_prize_query_one_req, {obj_id}).

-record(pb_prize_info,
	{obj_id, name, need_item_id, need_item_num,
	 need_vip_level, icon, tag, cls, dsc, today_buy_times,
	 sort_id, special_left_times}).

-record(sc_prize_config_update, {list}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_prize_query_phonecard_key_reply(Record)
    when is_record(Record,
		   sc_prize_query_phonecard_key_reply) ->
    encode(sc_prize_query_phonecard_key_reply, Record).

encode_cs_prize_query_phonecard_key_req(Record)
    when is_record(Record,
		   cs_prize_query_phonecard_key_req) ->
    encode(cs_prize_query_phonecard_key_req, Record).

encode_pb_prize_query_one(Record)
    when is_record(Record, pb_prize_query_one) ->
    encode(pb_prize_query_one, Record).

encode_sc_prize_storage_red_point_update(Record)
    when is_record(Record,
		   sc_prize_storage_red_point_update) ->
    encode(sc_prize_storage_red_point_update, Record).

encode_sc_prize_address_change_reply(Record)
    when is_record(Record, sc_prize_address_change_reply) ->
    encode(sc_prize_address_change_reply, Record).

encode_cs_prize_address_change_req(Record)
    when is_record(Record, cs_prize_address_change_req) ->
    encode(cs_prize_address_change_req, Record).

encode_pb_prize_address_info(Record)
    when is_record(Record, pb_prize_address_info) ->
    encode(pb_prize_address_info, Record).

encode_sc_prize_address_info_update(Record)
    when is_record(Record, sc_prize_address_info_update) ->
    encode(sc_prize_address_info_update, Record).

encode_pb_prize_exchange_record(Record)
    when is_record(Record, pb_prize_exchange_record) ->
    encode(pb_prize_exchange_record, Record).

encode_sc_prize_exchange_record_update(Record)
    when is_record(Record,
		   sc_prize_exchange_record_update) ->
    encode(sc_prize_exchange_record_update, Record).

encode_sc_prize_exchange_reply(Record)
    when is_record(Record, sc_prize_exchange_reply) ->
    encode(sc_prize_exchange_reply, Record).

encode_cs_prize_exchange_req(Record)
    when is_record(Record, cs_prize_exchange_req) ->
    encode(cs_prize_exchange_req, Record).

encode_sc_prize_query_one_reply(Record)
    when is_record(Record, sc_prize_query_one_reply) ->
    encode(sc_prize_query_one_reply, Record).

encode_cs_prize_query_one_req(Record)
    when is_record(Record, cs_prize_query_one_req) ->
    encode(cs_prize_query_one_req, Record).

encode_pb_prize_info(Record)
    when is_record(Record, pb_prize_info) ->
    encode(pb_prize_info, Record).

encode_sc_prize_config_update(Record)
    when is_record(Record, sc_prize_config_update) ->
    encode(sc_prize_config_update, Record).

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
encode(sc_prize_config_update, Record) ->
    [iolist(sc_prize_config_update, Record)
     | encode_extensions(Record)];
encode(pb_prize_info, Record) ->
    [iolist(pb_prize_info, Record)
     | encode_extensions(Record)];
encode(cs_prize_query_one_req, Record) ->
    [iolist(cs_prize_query_one_req, Record)
     | encode_extensions(Record)];
encode(sc_prize_query_one_reply, Record) ->
    [iolist(sc_prize_query_one_reply, Record)
     | encode_extensions(Record)];
encode(cs_prize_exchange_req, Record) ->
    [iolist(cs_prize_exchange_req, Record)
     | encode_extensions(Record)];
encode(sc_prize_exchange_reply, Record) ->
    [iolist(sc_prize_exchange_reply, Record)
     | encode_extensions(Record)];
encode(sc_prize_exchange_record_update, Record) ->
    [iolist(sc_prize_exchange_record_update, Record)
     | encode_extensions(Record)];
encode(pb_prize_exchange_record, Record) ->
    [iolist(pb_prize_exchange_record, Record)
     | encode_extensions(Record)];
encode(sc_prize_address_info_update, Record) ->
    [iolist(sc_prize_address_info_update, Record)
     | encode_extensions(Record)];
encode(pb_prize_address_info, Record) ->
    [iolist(pb_prize_address_info, Record)
     | encode_extensions(Record)];
encode(cs_prize_address_change_req, Record) ->
    [iolist(cs_prize_address_change_req, Record)
     | encode_extensions(Record)];
encode(sc_prize_address_change_reply, Record) ->
    [iolist(sc_prize_address_change_reply, Record)
     | encode_extensions(Record)];
encode(sc_prize_storage_red_point_update, Record) ->
    [iolist(sc_prize_storage_red_point_update, Record)
     | encode_extensions(Record)];
encode(pb_prize_query_one, Record) ->
    [iolist(pb_prize_query_one, Record)
     | encode_extensions(Record)];
encode(cs_prize_query_phonecard_key_req, Record) ->
    [iolist(cs_prize_query_phonecard_key_req, Record)
     | encode_extensions(Record)];
encode(sc_prize_query_phonecard_key_reply, Record) ->
    [iolist(sc_prize_query_phonecard_key_reply, Record)
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
iolist(sc_prize_config_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_prize_config_update.list, none),
	  pb_prize_info, [])];
iolist(pb_prize_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_prize_info.obj_id, none), uint32,
	  []),
     pack(2, required,
	  with_default(Record#pb_prize_info.name, none), bytes,
	  []),
     pack(3, required,
	  with_default(Record#pb_prize_info.need_item_id, none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_prize_info.need_item_num, none),
	  uint64, []),
     pack(5, required,
	  with_default(Record#pb_prize_info.need_vip_level, none),
	  uint32, []),
     pack(6, required,
	  with_default(Record#pb_prize_info.icon, none), string,
	  []),
     pack(7, required,
	  with_default(Record#pb_prize_info.tag, none), uint32,
	  []),
     pack(8, required,
	  with_default(Record#pb_prize_info.cls, none), uint32,
	  []),
     pack(9, required,
	  with_default(Record#pb_prize_info.dsc, none), bytes,
	  []),
     pack(10, required,
	  with_default(Record#pb_prize_info.today_buy_times,
		       none),
	  uint32, []),
     pack(11, required,
	  with_default(Record#pb_prize_info.sort_id, none), int32,
	  []),
     pack(12, required,
	  with_default(Record#pb_prize_info.special_left_times,
		       none),
	  uint32, [])];
iolist(cs_prize_query_one_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_prize_query_one_req.obj_id,
		       none),
	  uint32, [])];
iolist(sc_prize_query_one_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_prize_query_one_reply.obj_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_prize_query_one_reply.day_times_config,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_prize_query_one_reply.today_exchange_times,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#sc_prize_query_one_reply.store_num,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_prize_query_one_reply.crad_num,
		       none),
	  uint32, []),
     pack(6, required,
	  with_default(Record#sc_prize_query_one_reply.special_left_times,
		       none),
	  uint32, []),
     pack(7, required,
	  with_default(Record#sc_prize_query_one_reply.need_vip_level,
		       none),
	  uint32, [])];
iolist(cs_prize_exchange_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_prize_exchange_req.obj_id, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#cs_prize_exchange_req.phone_card_charge_type,
		       none),
	  uint32, []),
     pack(3, optional,
	  with_default(Record#cs_prize_exchange_req.phone_number,
		       none),
	  string, []),
     pack(4, optional,
	  with_default(Record#cs_prize_exchange_req.address_id,
		       none),
	  uint32, [])];
iolist(sc_prize_exchange_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_prize_exchange_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_prize_exchange_reply.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_prize_exchange_reply.reward,
		       none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_prize_exchange_reply.obj_id,
		       none),
	  uint32, [])];
iolist(sc_prize_exchange_record_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_prize_exchange_record_update.list,
		       none),
	  pb_prize_exchange_record, [])];
iolist(pb_prize_exchange_record, Record) ->
    [pack(1, required,
	  with_default(Record#pb_prize_exchange_record.id, none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_prize_exchange_record.record_type,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#pb_prize_exchange_record.obj_id,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_prize_exchange_record.need_item_id,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#pb_prize_exchange_record.need_item_num,
		       none),
	  uint64, []),
     pack(6, required,
	  with_default(Record#pb_prize_exchange_record.second_time,
		       none),
	  uint32, []),
     pack(7, optional,
	  with_default(Record#pb_prize_exchange_record.recharge_type,
		       none),
	  uint32, []),
     pack(8, optional,
	  with_default(Record#pb_prize_exchange_record.recharge_state,
		       none),
	  uint32, []),
     pack(9, optional,
	  with_default(Record#pb_prize_exchange_record.card_number,
		       none),
	  string, []),
     pack(10, optional,
	  with_default(Record#pb_prize_exchange_record.card_psd,
		       none),
	  string, [])];
iolist(sc_prize_address_info_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_prize_address_info_update.list,
		       none),
	  pb_prize_address_info, [])];
iolist(pb_prize_address_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_prize_address_info.id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_prize_address_info.name, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#pb_prize_address_info.sex, none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_prize_address_info.province_name,
		       none),
	  bytes, []),
     pack(5, required,
	  with_default(Record#pb_prize_address_info.city_name,
		       none),
	  bytes, []),
     pack(6, required,
	  with_default(Record#pb_prize_address_info.address,
		       none),
	  bytes, []),
     pack(7, required,
	  with_default(Record#pb_prize_address_info.phone_number,
		       none),
	  bytes, [])];
iolist(cs_prize_address_change_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_prize_address_change_req.new_info,
		       none),
	  pb_prize_address_info, [])];
iolist(sc_prize_address_change_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_prize_address_change_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_prize_address_change_reply.err,
		       none),
	  bytes, [])];
iolist(sc_prize_storage_red_point_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_prize_storage_red_point_update.list,
		       none),
	  pb_prize_query_one, [])];
iolist(pb_prize_query_one, Record) ->
    [pack(1, required,
	  with_default(Record#pb_prize_query_one.obj_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_prize_query_one.store_num, none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#pb_prize_query_one.crad_num, none),
	  uint32, [])];
iolist(cs_prize_query_phonecard_key_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_prize_query_phonecard_key_req.rec_id,
		       none),
	  string, [])];
iolist(sc_prize_query_phonecard_key_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_prize_query_phonecard_key_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_prize_query_phonecard_key_reply.err,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_prize_query_phonecard_key_reply.state,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#sc_prize_query_phonecard_key_reply.key,
		       none),
	  string, [])].

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

decode_sc_prize_query_phonecard_key_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_query_phonecard_key_reply, Bytes).

decode_cs_prize_query_phonecard_key_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_prize_query_phonecard_key_req, Bytes).

decode_pb_prize_query_one(Bytes)
    when is_binary(Bytes) ->
    decode(pb_prize_query_one, Bytes).

decode_sc_prize_storage_red_point_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_storage_red_point_update, Bytes).

decode_sc_prize_address_change_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_address_change_reply, Bytes).

decode_cs_prize_address_change_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_prize_address_change_req, Bytes).

decode_pb_prize_address_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_prize_address_info, Bytes).

decode_sc_prize_address_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_address_info_update, Bytes).

decode_pb_prize_exchange_record(Bytes)
    when is_binary(Bytes) ->
    decode(pb_prize_exchange_record, Bytes).

decode_sc_prize_exchange_record_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_exchange_record_update, Bytes).

decode_sc_prize_exchange_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_exchange_reply, Bytes).

decode_cs_prize_exchange_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_prize_exchange_req, Bytes).

decode_sc_prize_query_one_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_query_one_reply, Bytes).

decode_cs_prize_query_one_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_prize_query_one_req, Bytes).

decode_pb_prize_info(Bytes) when is_binary(Bytes) ->
    decode(pb_prize_info, Bytes).

decode_sc_prize_config_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_prize_config_update, Bytes).

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
decode(sc_prize_config_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_prize_info,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_config_update, Decoded);
decode(pb_prize_info, Bytes) when is_binary(Bytes) ->
    Types = [{12, special_left_times, uint32, []},
	     {11, sort_id, int32, []},
	     {10, today_buy_times, uint32, []}, {9, dsc, bytes, []},
	     {8, cls, uint32, []}, {7, tag, uint32, []},
	     {6, icon, string, []}, {5, need_vip_level, uint32, []},
	     {4, need_item_num, uint64, []},
	     {3, need_item_id, uint32, []}, {2, name, bytes, []},
	     {1, obj_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_prize_info, Decoded);
decode(cs_prize_query_one_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, obj_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_prize_query_one_req, Decoded);
decode(sc_prize_query_one_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{7, need_vip_level, uint32, []},
	     {6, special_left_times, uint32, []},
	     {5, crad_num, uint32, []}, {4, store_num, uint32, []},
	     {3, today_exchange_times, uint32, []},
	     {2, day_times_config, uint32, []},
	     {1, obj_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_query_one_reply, Decoded);
decode(cs_prize_exchange_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, address_id, uint32, []},
	     {3, phone_number, string, []},
	     {2, phone_card_charge_type, uint32, []},
	     {1, obj_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_prize_exchange_req, Decoded);
decode(sc_prize_exchange_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, obj_id, uint32, []},
	     {3, reward, pb_reward_info, [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_exchange_reply, Decoded);
decode(sc_prize_exchange_record_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_prize_exchange_record,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_exchange_record_update, Decoded);
decode(pb_prize_exchange_record, Bytes)
    when is_binary(Bytes) ->
    Types = [{10, card_psd, string, []},
	     {9, card_number, string, []},
	     {8, recharge_state, uint32, []},
	     {7, recharge_type, uint32, []},
	     {6, second_time, uint32, []},
	     {5, need_item_num, uint64, []},
	     {4, need_item_id, uint32, []}, {3, obj_id, uint32, []},
	     {2, record_type, uint32, []}, {1, id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_prize_exchange_record, Decoded);
decode(sc_prize_address_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_prize_address_info,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_address_info_update, Decoded);
decode(pb_prize_address_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{7, phone_number, bytes, []},
	     {6, address, bytes, []}, {5, city_name, bytes, []},
	     {4, province_name, bytes, []}, {3, sex, uint32, []},
	     {2, name, bytes, []}, {1, id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_prize_address_info, Decoded);
decode(cs_prize_address_change_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, new_info, pb_prize_address_info,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_prize_address_change_req, Decoded);
decode(sc_prize_address_change_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_address_change_reply, Decoded);
decode(sc_prize_storage_red_point_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_prize_query_one,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_storage_red_point_update, Decoded);
decode(pb_prize_query_one, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, crad_num, uint32, []},
	     {2, store_num, uint32, []}, {1, obj_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_prize_query_one, Decoded);
decode(cs_prize_query_phonecard_key_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, rec_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_prize_query_phonecard_key_req, Decoded);
decode(sc_prize_query_phonecard_key_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, key, string, []}, {3, state, uint32, []},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_prize_query_phonecard_key_reply, Decoded).

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
to_record(sc_prize_config_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_config_update),
						   Record, Name, Val)
			  end,
			  #sc_prize_config_update{}, DecodedTuples),
    Record1;
to_record(pb_prize_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_prize_info),
						   Record, Name, Val)
			  end,
			  #pb_prize_info{}, DecodedTuples),
    Record1;
to_record(cs_prize_query_one_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_prize_query_one_req),
						   Record, Name, Val)
			  end,
			  #cs_prize_query_one_req{}, DecodedTuples),
    Record1;
to_record(sc_prize_query_one_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_query_one_reply),
						   Record, Name, Val)
			  end,
			  #sc_prize_query_one_reply{}, DecodedTuples),
    Record1;
to_record(cs_prize_exchange_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_prize_exchange_req),
						   Record, Name, Val)
			  end,
			  #cs_prize_exchange_req{}, DecodedTuples),
    Record1;
to_record(sc_prize_exchange_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_exchange_reply),
						   Record, Name, Val)
			  end,
			  #sc_prize_exchange_reply{}, DecodedTuples),
    Record1;
to_record(sc_prize_exchange_record_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_exchange_record_update),
						   Record, Name, Val)
			  end,
			  #sc_prize_exchange_record_update{}, DecodedTuples),
    Record1;
to_record(pb_prize_exchange_record, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_prize_exchange_record),
						   Record, Name, Val)
			  end,
			  #pb_prize_exchange_record{}, DecodedTuples),
    Record1;
to_record(sc_prize_address_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_address_info_update),
						   Record, Name, Val)
			  end,
			  #sc_prize_address_info_update{}, DecodedTuples),
    Record1;
to_record(pb_prize_address_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_prize_address_info),
						   Record, Name, Val)
			  end,
			  #pb_prize_address_info{}, DecodedTuples),
    Record1;
to_record(cs_prize_address_change_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_prize_address_change_req),
						   Record, Name, Val)
			  end,
			  #cs_prize_address_change_req{}, DecodedTuples),
    Record1;
to_record(sc_prize_address_change_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_address_change_reply),
						   Record, Name, Val)
			  end,
			  #sc_prize_address_change_reply{}, DecodedTuples),
    Record1;
to_record(sc_prize_storage_red_point_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_storage_red_point_update),
						   Record, Name, Val)
			  end,
			  #sc_prize_storage_red_point_update{}, DecodedTuples),
    Record1;
to_record(pb_prize_query_one, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_prize_query_one),
						   Record, Name, Val)
			  end,
			  #pb_prize_query_one{}, DecodedTuples),
    Record1;
to_record(cs_prize_query_phonecard_key_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_prize_query_phonecard_key_req),
						   Record, Name, Val)
			  end,
			  #cs_prize_query_phonecard_key_req{}, DecodedTuples),
    Record1;
to_record(sc_prize_query_phonecard_key_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_prize_query_phonecard_key_reply),
						   Record, Name, Val)
			  end,
			  #sc_prize_query_phonecard_key_reply{}, DecodedTuples),
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

