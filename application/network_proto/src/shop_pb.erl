-file("src/shop_pb.erl", 1).

-module(shop_pb).

-export([encode_sc_golden_bull_mission/1,
	 decode_sc_golden_bull_mission/1,
	 encode_cs_golden_bull_mission/1,
	 decode_cs_golden_bull_mission/1,
	 encode_sc_cash_transformation_reply/1,
	 decode_sc_cash_transformation_reply/1,
	 encode_cs_cash_transformation_req/1,
	 decode_cs_cash_transformation_req/1,
	 encode_sc_period_card_draw_reply/1,
	 decode_sc_period_card_draw_reply/1,
	 encode_cs_period_card_draw_req/1,
	 decode_cs_period_card_draw_req/1,
	 encode_sc_period_card_info_update/1,
	 decode_sc_period_card_info_update/1,
	 encode_sc_month_card_draw_reply/1,
	 decode_sc_month_card_draw_reply/1,
	 encode_cs_month_card_draw_req/1,
	 decode_cs_month_card_draw_req/1,
	 encode_sc_month_card_info_update/1,
	 decode_sc_month_card_info_update/1,
	 encode_sc_golden_bull_draw_reply/1,
	 decode_sc_golden_bull_draw_reply/1,
	 encode_cs_golden_bull_draw_req/1,
	 decode_cs_golden_bull_draw_req/1,
	 encode_sc_golden_bull_info_update/1,
	 decode_sc_golden_bull_info_update/1,
	 encode_sc_shop_buy_reply/1, decode_sc_shop_buy_reply/1,
	 encode_cs_shop_buy_query/1, decode_cs_shop_buy_query/1,
	 encode_pb_cost_type_and_num/1,
	 decode_pb_cost_type_and_num/1, encode_pb_shop_item/1,
	 decode_pb_shop_item/1,
	 encode_sc_shop_all_item_base_config/1,
	 decode_sc_shop_all_item_base_config/1,
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

-record(sc_golden_bull_mission, {process}).

-record(cs_golden_bull_mission, {}).

-record(sc_cash_transformation_reply, {result, err}).

-record(cs_cash_transformation_req, {num}).

-record(sc_period_card_draw_reply, {type, result, err}).

-record(cs_period_card_draw_req, {type}).

-record(sc_period_card_info_update,
	{type, today_draw_flag, left_times}).

-record(sc_month_card_draw_reply, {result, err}).

-record(cs_month_card_draw_req, {}).

-record(sc_month_card_info_update,
	{today_draw_flag, left_times}).

-record(sc_golden_bull_draw_reply, {result, err}).

-record(cs_golden_bull_draw_req, {key}).

-record(sc_golden_bull_info_update, {left_times}).

-record(sc_shop_buy_reply,
	{result, err_msg, rewards, left_times, id}).

-record(cs_shop_buy_query, {id}).

-record(pb_cost_type_and_num, {cost_type, cost_num}).

-record(pb_shop_item,
	{id, shop_type, item_id, item_num, item_extra_num,
	 cost_list, discount, special_flag, start_time, end_time,
	 limit_times, vip_limit, left_times, icon, name, sort}).

-record(sc_shop_all_item_base_config, {item_list}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_golden_bull_mission(Record)
    when is_record(Record, sc_golden_bull_mission) ->
    encode(sc_golden_bull_mission, Record).

encode_cs_golden_bull_mission(Record)
    when is_record(Record, cs_golden_bull_mission) ->
    encode(cs_golden_bull_mission, Record).

encode_sc_cash_transformation_reply(Record)
    when is_record(Record, sc_cash_transformation_reply) ->
    encode(sc_cash_transformation_reply, Record).

encode_cs_cash_transformation_req(Record)
    when is_record(Record, cs_cash_transformation_req) ->
    encode(cs_cash_transformation_req, Record).

encode_sc_period_card_draw_reply(Record)
    when is_record(Record, sc_period_card_draw_reply) ->
    encode(sc_period_card_draw_reply, Record).

encode_cs_period_card_draw_req(Record)
    when is_record(Record, cs_period_card_draw_req) ->
    encode(cs_period_card_draw_req, Record).

encode_sc_period_card_info_update(Record)
    when is_record(Record, sc_period_card_info_update) ->
    encode(sc_period_card_info_update, Record).

encode_sc_month_card_draw_reply(Record)
    when is_record(Record, sc_month_card_draw_reply) ->
    encode(sc_month_card_draw_reply, Record).

encode_cs_month_card_draw_req(Record)
    when is_record(Record, cs_month_card_draw_req) ->
    encode(cs_month_card_draw_req, Record).

encode_sc_month_card_info_update(Record)
    when is_record(Record, sc_month_card_info_update) ->
    encode(sc_month_card_info_update, Record).

encode_sc_golden_bull_draw_reply(Record)
    when is_record(Record, sc_golden_bull_draw_reply) ->
    encode(sc_golden_bull_draw_reply, Record).

encode_cs_golden_bull_draw_req(Record)
    when is_record(Record, cs_golden_bull_draw_req) ->
    encode(cs_golden_bull_draw_req, Record).

encode_sc_golden_bull_info_update(Record)
    when is_record(Record, sc_golden_bull_info_update) ->
    encode(sc_golden_bull_info_update, Record).

encode_sc_shop_buy_reply(Record)
    when is_record(Record, sc_shop_buy_reply) ->
    encode(sc_shop_buy_reply, Record).

encode_cs_shop_buy_query(Record)
    when is_record(Record, cs_shop_buy_query) ->
    encode(cs_shop_buy_query, Record).

encode_pb_cost_type_and_num(Record)
    when is_record(Record, pb_cost_type_and_num) ->
    encode(pb_cost_type_and_num, Record).

encode_pb_shop_item(Record)
    when is_record(Record, pb_shop_item) ->
    encode(pb_shop_item, Record).

encode_sc_shop_all_item_base_config(Record)
    when is_record(Record, sc_shop_all_item_base_config) ->
    encode(sc_shop_all_item_base_config, Record).

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
encode(sc_shop_all_item_base_config, Record) ->
    [iolist(sc_shop_all_item_base_config, Record)
     | encode_extensions(Record)];
encode(pb_shop_item, Record) ->
    [iolist(pb_shop_item, Record)
     | encode_extensions(Record)];
encode(pb_cost_type_and_num, Record) ->
    [iolist(pb_cost_type_and_num, Record)
     | encode_extensions(Record)];
encode(cs_shop_buy_query, Record) ->
    [iolist(cs_shop_buy_query, Record)
     | encode_extensions(Record)];
encode(sc_shop_buy_reply, Record) ->
    [iolist(sc_shop_buy_reply, Record)
     | encode_extensions(Record)];
encode(sc_golden_bull_info_update, Record) ->
    [iolist(sc_golden_bull_info_update, Record)
     | encode_extensions(Record)];
encode(cs_golden_bull_draw_req, Record) ->
    [iolist(cs_golden_bull_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_golden_bull_draw_reply, Record) ->
    [iolist(sc_golden_bull_draw_reply, Record)
     | encode_extensions(Record)];
encode(sc_month_card_info_update, Record) ->
    [iolist(sc_month_card_info_update, Record)
     | encode_extensions(Record)];
encode(cs_month_card_draw_req, Record) ->
    [iolist(cs_month_card_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_month_card_draw_reply, Record) ->
    [iolist(sc_month_card_draw_reply, Record)
     | encode_extensions(Record)];
encode(sc_period_card_info_update, Record) ->
    [iolist(sc_period_card_info_update, Record)
     | encode_extensions(Record)];
encode(cs_period_card_draw_req, Record) ->
    [iolist(cs_period_card_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_period_card_draw_reply, Record) ->
    [iolist(sc_period_card_draw_reply, Record)
     | encode_extensions(Record)];
encode(cs_cash_transformation_req, Record) ->
    [iolist(cs_cash_transformation_req, Record)
     | encode_extensions(Record)];
encode(sc_cash_transformation_reply, Record) ->
    [iolist(sc_cash_transformation_reply, Record)
     | encode_extensions(Record)];
encode(cs_golden_bull_mission, Record) ->
    [iolist(cs_golden_bull_mission, Record)
     | encode_extensions(Record)];
encode(sc_golden_bull_mission, Record) ->
    [iolist(sc_golden_bull_mission, Record)
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
iolist(sc_shop_all_item_base_config, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_shop_all_item_base_config.item_list,
		       none),
	  pb_shop_item, [])];
iolist(pb_shop_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_shop_item.id, none), uint32, []),
     pack(2, required,
	  with_default(Record#pb_shop_item.shop_type, none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#pb_shop_item.item_id, none), uint32,
	  []),
     pack(4, required,
	  with_default(Record#pb_shop_item.item_num, none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#pb_shop_item.item_extra_num, none),
	  uint32, []),
     pack(6, repeated,
	  with_default(Record#pb_shop_item.cost_list, none),
	  pb_cost_type_and_num, []),
     pack(7, required,
	  with_default(Record#pb_shop_item.discount, none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#pb_shop_item.special_flag, none),
	  uint32, []),
     pack(9, required,
	  with_default(Record#pb_shop_item.start_time, none),
	  uint32, []),
     pack(10, required,
	  with_default(Record#pb_shop_item.end_time, none),
	  uint32, []),
     pack(11, required,
	  with_default(Record#pb_shop_item.limit_times, none),
	  uint32, []),
     pack(12, required,
	  with_default(Record#pb_shop_item.vip_limit, none),
	  uint32, []),
     pack(13, required,
	  with_default(Record#pb_shop_item.left_times, none),
	  uint32, []),
     pack(14, required,
	  with_default(Record#pb_shop_item.icon, none), string,
	  []),
     pack(15, required,
	  with_default(Record#pb_shop_item.name, none), bytes,
	  []),
     pack(16, required,
	  with_default(Record#pb_shop_item.sort, none), uint32,
	  [])];
iolist(pb_cost_type_and_num, Record) ->
    [pack(1, required,
	  with_default(Record#pb_cost_type_and_num.cost_type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_cost_type_and_num.cost_num,
		       none),
	  uint32, [])];
iolist(cs_shop_buy_query, Record) ->
    [pack(1, required,
	  with_default(Record#cs_shop_buy_query.id, none), uint32,
	  [])];
iolist(sc_shop_buy_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_shop_buy_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_shop_buy_reply.err_msg, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_shop_buy_reply.rewards, none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_shop_buy_reply.left_times, none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_shop_buy_reply.id, none), uint32,
	  [])];
iolist(sc_golden_bull_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_golden_bull_info_update.left_times,
		       none),
	  uint32, [])];
iolist(cs_golden_bull_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_golden_bull_draw_req.key, none),
	  uint32, [])];
iolist(sc_golden_bull_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_golden_bull_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_golden_bull_draw_reply.err,
		       none),
	  bytes, [])];
iolist(sc_month_card_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_month_card_info_update.today_draw_flag,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_month_card_info_update.left_times,
		       none),
	  uint32, [])];
iolist(cs_month_card_draw_req, _Record) -> [];
iolist(sc_month_card_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_month_card_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_month_card_draw_reply.err, none),
	  bytes, [])];
iolist(sc_period_card_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_period_card_info_update.type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_period_card_info_update.today_draw_flag,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_period_card_info_update.left_times,
		       none),
	  uint32, [])];
iolist(cs_period_card_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_period_card_draw_req.type, none),
	  uint32, [])];
iolist(sc_period_card_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_period_card_draw_reply.type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_period_card_draw_reply.result,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_period_card_draw_reply.err,
		       none),
	  bytes, [])];
iolist(cs_cash_transformation_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_cash_transformation_req.num,
		       none),
	  int32, [])];
iolist(sc_cash_transformation_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_cash_transformation_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_cash_transformation_reply.err,
		       none),
	  bytes, [])];
iolist(cs_golden_bull_mission, _Record) -> [];
iolist(sc_golden_bull_mission, Record) ->
    [pack(1, required,
	  with_default(Record#sc_golden_bull_mission.process,
		       none),
	  int32, [])].

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

decode_sc_golden_bull_mission(Bytes)
    when is_binary(Bytes) ->
    decode(sc_golden_bull_mission, Bytes).

decode_cs_golden_bull_mission(Bytes)
    when is_binary(Bytes) ->
    decode(cs_golden_bull_mission, Bytes).

decode_sc_cash_transformation_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_cash_transformation_reply, Bytes).

decode_cs_cash_transformation_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_cash_transformation_req, Bytes).

decode_sc_period_card_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_period_card_draw_reply, Bytes).

decode_cs_period_card_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_period_card_draw_req, Bytes).

decode_sc_period_card_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_period_card_info_update, Bytes).

decode_sc_month_card_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_month_card_draw_reply, Bytes).

decode_cs_month_card_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_month_card_draw_req, Bytes).

decode_sc_month_card_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_month_card_info_update, Bytes).

decode_sc_golden_bull_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_golden_bull_draw_reply, Bytes).

decode_cs_golden_bull_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_golden_bull_draw_req, Bytes).

decode_sc_golden_bull_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_golden_bull_info_update, Bytes).

decode_sc_shop_buy_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_shop_buy_reply, Bytes).

decode_cs_shop_buy_query(Bytes) when is_binary(Bytes) ->
    decode(cs_shop_buy_query, Bytes).

decode_pb_cost_type_and_num(Bytes)
    when is_binary(Bytes) ->
    decode(pb_cost_type_and_num, Bytes).

decode_pb_shop_item(Bytes) when is_binary(Bytes) ->
    decode(pb_shop_item, Bytes).

decode_sc_shop_all_item_base_config(Bytes)
    when is_binary(Bytes) ->
    decode(sc_shop_all_item_base_config, Bytes).

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
decode(sc_shop_all_item_base_config, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, item_list, pb_shop_item,
	      [is_record, repeated]}],
    Defaults = [{1, item_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_shop_all_item_base_config, Decoded);
decode(pb_shop_item, Bytes) when is_binary(Bytes) ->
    Types = [{16, sort, uint32, []}, {15, name, bytes, []},
	     {14, icon, string, []}, {13, left_times, uint32, []},
	     {12, vip_limit, uint32, []},
	     {11, limit_times, uint32, []},
	     {10, end_time, uint32, []}, {9, start_time, uint32, []},
	     {8, special_flag, uint32, []},
	     {7, discount, uint32, []},
	     {6, cost_list, pb_cost_type_and_num,
	      [is_record, repeated]},
	     {5, item_extra_num, uint32, []},
	     {4, item_num, uint32, []}, {3, item_id, uint32, []},
	     {2, shop_type, uint32, []}, {1, id, uint32, []}],
    Defaults = [{6, cost_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_shop_item, Decoded);
decode(pb_cost_type_and_num, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, cost_num, uint32, []},
	     {1, cost_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_cost_type_and_num, Decoded);
decode(cs_shop_buy_query, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_shop_buy_query, Decoded);
decode(sc_shop_buy_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, id, uint32, []},
	     {4, left_times, uint32, []},
	     {3, rewards, pb_reward_info, [is_record, repeated]},
	     {2, err_msg, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_shop_buy_reply, Decoded);
decode(sc_golden_bull_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, left_times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_golden_bull_info_update, Decoded);
decode(cs_golden_bull_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, key, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_golden_bull_draw_req, Decoded);
decode(sc_golden_bull_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_golden_bull_draw_reply, Decoded);
decode(sc_month_card_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, left_times, uint32, []},
	     {1, today_draw_flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_month_card_info_update, Decoded);
decode(cs_month_card_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_month_card_draw_req, Decoded);
decode(sc_month_card_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_month_card_draw_reply, Decoded);
decode(sc_period_card_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, left_times, uint32, []},
	     {2, today_draw_flag, uint32, []},
	     {1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_period_card_info_update, Decoded);
decode(cs_period_card_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_period_card_draw_req, Decoded);
decode(sc_period_card_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, err, bytes, []}, {2, result, uint32, []},
	     {1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_period_card_draw_reply, Decoded);
decode(cs_cash_transformation_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, num, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_cash_transformation_req, Decoded);
decode(sc_cash_transformation_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_cash_transformation_reply, Decoded);
decode(cs_golden_bull_mission, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_golden_bull_mission, Decoded);
decode(sc_golden_bull_mission, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, process, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_golden_bull_mission, Decoded).

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
to_record(sc_shop_all_item_base_config,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_shop_all_item_base_config),
						   Record, Name, Val)
			  end,
			  #sc_shop_all_item_base_config{}, DecodedTuples),
    Record1;
to_record(pb_shop_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_shop_item),
						   Record, Name, Val)
			  end,
			  #pb_shop_item{}, DecodedTuples),
    Record1;
to_record(pb_cost_type_and_num, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_cost_type_and_num),
						   Record, Name, Val)
			  end,
			  #pb_cost_type_and_num{}, DecodedTuples),
    Record1;
to_record(cs_shop_buy_query, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_shop_buy_query),
						   Record, Name, Val)
			  end,
			  #cs_shop_buy_query{}, DecodedTuples),
    Record1;
to_record(sc_shop_buy_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_shop_buy_reply),
						   Record, Name, Val)
			  end,
			  #sc_shop_buy_reply{}, DecodedTuples),
    Record1;
to_record(sc_golden_bull_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_golden_bull_info_update),
						   Record, Name, Val)
			  end,
			  #sc_golden_bull_info_update{}, DecodedTuples),
    Record1;
to_record(cs_golden_bull_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_golden_bull_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_golden_bull_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_golden_bull_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_golden_bull_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_golden_bull_draw_reply{}, DecodedTuples),
    Record1;
to_record(sc_month_card_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_month_card_info_update),
						   Record, Name, Val)
			  end,
			  #sc_month_card_info_update{}, DecodedTuples),
    Record1;
to_record(cs_month_card_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_month_card_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_month_card_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_month_card_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_month_card_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_month_card_draw_reply{}, DecodedTuples),
    Record1;
to_record(sc_period_card_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_period_card_info_update),
						   Record, Name, Val)
			  end,
			  #sc_period_card_info_update{}, DecodedTuples),
    Record1;
to_record(cs_period_card_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_period_card_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_period_card_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_period_card_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_period_card_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_period_card_draw_reply{}, DecodedTuples),
    Record1;
to_record(cs_cash_transformation_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_cash_transformation_req),
						   Record, Name, Val)
			  end,
			  #cs_cash_transformation_req{}, DecodedTuples),
    Record1;
to_record(sc_cash_transformation_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_cash_transformation_reply),
						   Record, Name, Val)
			  end,
			  #sc_cash_transformation_reply{}, DecodedTuples),
    Record1;
to_record(cs_golden_bull_mission, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_golden_bull_mission),
						   Record, Name, Val)
			  end,
			  #cs_golden_bull_mission{}, DecodedTuples),
    Record1;
to_record(sc_golden_bull_mission, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_golden_bull_mission),
						   Record, Name, Val)
			  end,
			  #sc_golden_bull_mission{}, DecodedTuples),
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

