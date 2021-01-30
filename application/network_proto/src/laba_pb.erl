-file("src/laba_pb.erl", 1).

-module(laba_pb).

-export([encode_sc_airlaba_impov_sub_reply/1,
	 decode_sc_airlaba_impov_sub_reply/1,
	 encode_cs_airlaba_impov_sub_req/1,
	 decode_cs_airlaba_impov_sub_req/1,
	 encode_sc_airlaba_use_item_reply/1,
	 decode_sc_airlaba_use_item_reply/1,
	 encode_cs_airlaba_use_item_req/1,
	 decode_cs_airlaba_use_item_req/1,
	 encode_sc_airlaba_pool_num_update/1,
	 decode_sc_airlaba_pool_num_update/1,
	 encode_sc_airlaba_switch_phase_reply/1,
	 decode_sc_airlaba_switch_phase_reply/1,
	 encode_cs_airlaba_switch_phase_req/1,
	 decode_cs_airlaba_switch_phase_req/1,
	 encode_sc_airlaba_fire_bet_reply/1,
	 decode_sc_airlaba_fire_bet_reply/1,
	 encode_cs_airlaba_fire_bet_req/1,
	 decode_cs_airlaba_fire_bet_req/1,
	 encode_sc_airlaba_leave_room_reply/1,
	 decode_sc_airlaba_leave_room_reply/1,
	 encode_cs_airlaba_leave_room_req/1,
	 decode_cs_airlaba_leave_room_req/1,
	 encode_sc_airlaba_enter_room_reply/1,
	 decode_sc_airlaba_enter_room_reply/1,
	 encode_pb_airlaba_item_list_item/1,
	 decode_pb_airlaba_item_list_item/1,
	 encode_cs_airlaba_enter_room_req/1,
	 decode_cs_airlaba_enter_room_req/1,
	 encode_sc_win_player_list/1,
	 decode_sc_win_player_list/1,
	 encode_cs_win_player_list/1,
	 decode_cs_win_player_list/1,
	 encode_pb_laba_line_reward/1,
	 decode_pb_laba_line_reward/1,
	 encode_pb_laba_fruit_info/1,
	 decode_pb_laba_fruit_info/1,
	 encode_sc_laba_spin_reply/1,
	 decode_sc_laba_spin_reply/1, encode_cs_laba_spin_req/1,
	 decode_cs_laba_spin_req/1,
	 encode_pb_pool_win_player_info/1,
	 decode_pb_pool_win_player_info/1,
	 encode_sc_laba_pool_num_update/1,
	 decode_sc_laba_pool_num_update/1,
	 encode_sc_laba_leave_room_reply/1,
	 decode_sc_laba_leave_room_reply/1,
	 encode_cs_laba_leave_room_req/1,
	 decode_cs_laba_leave_room_req/1,
	 encode_sc_laba_enter_room_reply/1,
	 decode_sc_laba_enter_room_reply/1,
	 encode_cs_laba_enter_room_req/1,
	 decode_cs_laba_enter_room_req/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_airlaba_impov_sub_reply,
	{code, reward_item_id, reward_item_num}).

-record(cs_airlaba_impov_sub_req, {type}).

-record(sc_airlaba_use_item_reply,
	{req, success, left_num}).

-record(cs_airlaba_use_item_req,
	{item_id, item_num, order_id}).

-record(sc_airlaba_pool_num_update,
	{pool_num, rank_pool_num}).

-record(sc_airlaba_switch_phase_reply, {}).

-record(cs_airlaba_switch_phase_req, {}).

-record(sc_airlaba_fire_bet_reply,
	{result, desc, target_down, earn_gold, hit_objid}).

-record(cs_airlaba_fire_bet_req,
	{bullet_cost, bullet_num, hit_objtype, hit_objid,
	 bullet_item_id}).

-record(sc_airlaba_leave_room_reply, {laba_resp}).

-record(cs_airlaba_leave_room_req, {laba_req}).

-record(sc_airlaba_enter_room_reply,
	{laba_resp, item_list}).

-record(pb_airlaba_item_list_item, {item_id, item_num}).

-record(cs_airlaba_enter_room_req,
	{laba_req, base_bet_num, base_line_num}).

-record(sc_win_player_list, {win_players}).

-record(cs_win_player_list, {type}).

-record(pb_laba_line_reward, {line_id, same_num}).

-record(pb_laba_fruit_info, {pos_id, fruit_type}).

-record(sc_laba_spin_reply,
	{total_reward_num, fruit_list, reward_list,
	 new_last_free_times, pool, free}).

-record(cs_laba_spin_req,
	{line_num, line_set_chips, type, test_type}).

-record(pb_pool_win_player_info,
	{player_uuid, icon_url, player_name, vip_level,
	 win_gold, c_time}).

-record(sc_laba_pool_num_update,
	{total_pool_num, total_rank_num}).

-record(sc_laba_leave_room_reply, {result}).

-record(cs_laba_leave_room_req, {type}).

-record(sc_laba_enter_room_reply,
	{line_num, line_set_chips, last_free_times, type,
	 start_time, end_time}).

-record(cs_laba_enter_room_req, {type, test_type}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_airlaba_impov_sub_reply(Record)
    when is_record(Record, sc_airlaba_impov_sub_reply) ->
    encode(sc_airlaba_impov_sub_reply, Record).

encode_cs_airlaba_impov_sub_req(Record)
    when is_record(Record, cs_airlaba_impov_sub_req) ->
    encode(cs_airlaba_impov_sub_req, Record).

encode_sc_airlaba_use_item_reply(Record)
    when is_record(Record, sc_airlaba_use_item_reply) ->
    encode(sc_airlaba_use_item_reply, Record).

encode_cs_airlaba_use_item_req(Record)
    when is_record(Record, cs_airlaba_use_item_req) ->
    encode(cs_airlaba_use_item_req, Record).

encode_sc_airlaba_pool_num_update(Record)
    when is_record(Record, sc_airlaba_pool_num_update) ->
    encode(sc_airlaba_pool_num_update, Record).

encode_sc_airlaba_switch_phase_reply(Record)
    when is_record(Record, sc_airlaba_switch_phase_reply) ->
    encode(sc_airlaba_switch_phase_reply, Record).

encode_cs_airlaba_switch_phase_req(Record)
    when is_record(Record, cs_airlaba_switch_phase_req) ->
    encode(cs_airlaba_switch_phase_req, Record).

encode_sc_airlaba_fire_bet_reply(Record)
    when is_record(Record, sc_airlaba_fire_bet_reply) ->
    encode(sc_airlaba_fire_bet_reply, Record).

encode_cs_airlaba_fire_bet_req(Record)
    when is_record(Record, cs_airlaba_fire_bet_req) ->
    encode(cs_airlaba_fire_bet_req, Record).

encode_sc_airlaba_leave_room_reply(Record)
    when is_record(Record, sc_airlaba_leave_room_reply) ->
    encode(sc_airlaba_leave_room_reply, Record).

encode_cs_airlaba_leave_room_req(Record)
    when is_record(Record, cs_airlaba_leave_room_req) ->
    encode(cs_airlaba_leave_room_req, Record).

encode_sc_airlaba_enter_room_reply(Record)
    when is_record(Record, sc_airlaba_enter_room_reply) ->
    encode(sc_airlaba_enter_room_reply, Record).

encode_pb_airlaba_item_list_item(Record)
    when is_record(Record, pb_airlaba_item_list_item) ->
    encode(pb_airlaba_item_list_item, Record).

encode_cs_airlaba_enter_room_req(Record)
    when is_record(Record, cs_airlaba_enter_room_req) ->
    encode(cs_airlaba_enter_room_req, Record).

encode_sc_win_player_list(Record)
    when is_record(Record, sc_win_player_list) ->
    encode(sc_win_player_list, Record).

encode_cs_win_player_list(Record)
    when is_record(Record, cs_win_player_list) ->
    encode(cs_win_player_list, Record).

encode_pb_laba_line_reward(Record)
    when is_record(Record, pb_laba_line_reward) ->
    encode(pb_laba_line_reward, Record).

encode_pb_laba_fruit_info(Record)
    when is_record(Record, pb_laba_fruit_info) ->
    encode(pb_laba_fruit_info, Record).

encode_sc_laba_spin_reply(Record)
    when is_record(Record, sc_laba_spin_reply) ->
    encode(sc_laba_spin_reply, Record).

encode_cs_laba_spin_req(Record)
    when is_record(Record, cs_laba_spin_req) ->
    encode(cs_laba_spin_req, Record).

encode_pb_pool_win_player_info(Record)
    when is_record(Record, pb_pool_win_player_info) ->
    encode(pb_pool_win_player_info, Record).

encode_sc_laba_pool_num_update(Record)
    when is_record(Record, sc_laba_pool_num_update) ->
    encode(sc_laba_pool_num_update, Record).

encode_sc_laba_leave_room_reply(Record)
    when is_record(Record, sc_laba_leave_room_reply) ->
    encode(sc_laba_leave_room_reply, Record).

encode_cs_laba_leave_room_req(Record)
    when is_record(Record, cs_laba_leave_room_req) ->
    encode(cs_laba_leave_room_req, Record).

encode_sc_laba_enter_room_reply(Record)
    when is_record(Record, sc_laba_enter_room_reply) ->
    encode(sc_laba_enter_room_reply, Record).

encode_cs_laba_enter_room_req(Record)
    when is_record(Record, cs_laba_enter_room_req) ->
    encode(cs_laba_enter_room_req, Record).

encode(cs_laba_enter_room_req, Record) ->
    [iolist(cs_laba_enter_room_req, Record)
     | encode_extensions(Record)];
encode(sc_laba_enter_room_reply, Record) ->
    [iolist(sc_laba_enter_room_reply, Record)
     | encode_extensions(Record)];
encode(cs_laba_leave_room_req, Record) ->
    [iolist(cs_laba_leave_room_req, Record)
     | encode_extensions(Record)];
encode(sc_laba_leave_room_reply, Record) ->
    [iolist(sc_laba_leave_room_reply, Record)
     | encode_extensions(Record)];
encode(sc_laba_pool_num_update, Record) ->
    [iolist(sc_laba_pool_num_update, Record)
     | encode_extensions(Record)];
encode(pb_pool_win_player_info, Record) ->
    [iolist(pb_pool_win_player_info, Record)
     | encode_extensions(Record)];
encode(cs_laba_spin_req, Record) ->
    [iolist(cs_laba_spin_req, Record)
     | encode_extensions(Record)];
encode(sc_laba_spin_reply, Record) ->
    [iolist(sc_laba_spin_reply, Record)
     | encode_extensions(Record)];
encode(pb_laba_fruit_info, Record) ->
    [iolist(pb_laba_fruit_info, Record)
     | encode_extensions(Record)];
encode(pb_laba_line_reward, Record) ->
    [iolist(pb_laba_line_reward, Record)
     | encode_extensions(Record)];
encode(cs_win_player_list, Record) ->
    [iolist(cs_win_player_list, Record)
     | encode_extensions(Record)];
encode(sc_win_player_list, Record) ->
    [iolist(sc_win_player_list, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_enter_room_req, Record) ->
    [iolist(cs_airlaba_enter_room_req, Record)
     | encode_extensions(Record)];
encode(pb_airlaba_item_list_item, Record) ->
    [iolist(pb_airlaba_item_list_item, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_enter_room_reply, Record) ->
    [iolist(sc_airlaba_enter_room_reply, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_leave_room_req, Record) ->
    [iolist(cs_airlaba_leave_room_req, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_leave_room_reply, Record) ->
    [iolist(sc_airlaba_leave_room_reply, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_fire_bet_req, Record) ->
    [iolist(cs_airlaba_fire_bet_req, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_fire_bet_reply, Record) ->
    [iolist(sc_airlaba_fire_bet_reply, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_switch_phase_req, Record) ->
    [iolist(cs_airlaba_switch_phase_req, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_switch_phase_reply, Record) ->
    [iolist(sc_airlaba_switch_phase_reply, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_pool_num_update, Record) ->
    [iolist(sc_airlaba_pool_num_update, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_use_item_req, Record) ->
    [iolist(cs_airlaba_use_item_req, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_use_item_reply, Record) ->
    [iolist(sc_airlaba_use_item_reply, Record)
     | encode_extensions(Record)];
encode(cs_airlaba_impov_sub_req, Record) ->
    [iolist(cs_airlaba_impov_sub_req, Record)
     | encode_extensions(Record)];
encode(sc_airlaba_impov_sub_reply, Record) ->
    [iolist(sc_airlaba_impov_sub_reply, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(cs_laba_enter_room_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_laba_enter_room_req.type, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_laba_enter_room_req.test_type,
		       none),
	  int32, [])];
iolist(sc_laba_enter_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_laba_enter_room_reply.line_num,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_laba_enter_room_reply.line_set_chips,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_laba_enter_room_reply.last_free_times,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#sc_laba_enter_room_reply.type,
		       none),
	  int32, []),
     pack(5, optional,
	  with_default(Record#sc_laba_enter_room_reply.start_time,
		       none),
	  int32, []),
     pack(6, optional,
	  with_default(Record#sc_laba_enter_room_reply.end_time,
		       none),
	  int32, [])];
iolist(cs_laba_leave_room_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_laba_leave_room_req.type, none),
	  int32, [])];
iolist(sc_laba_leave_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_laba_leave_room_reply.result,
		       none),
	  uint32, [])];
iolist(sc_laba_pool_num_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_laba_pool_num_update.total_pool_num,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#sc_laba_pool_num_update.total_rank_num,
		       none),
	  string, [])];
iolist(pb_pool_win_player_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_pool_win_player_info.player_uuid,
		       none),
	  string, []),
     pack(2, optional,
	  with_default(Record#pb_pool_win_player_info.icon_url,
		       none),
	  string, []),
     pack(3, optional,
	  with_default(Record#pb_pool_win_player_info.player_name,
		       none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#pb_pool_win_player_info.vip_level,
		       none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#pb_pool_win_player_info.win_gold,
		       none),
	  string, []),
     pack(6, optional,
	  with_default(Record#pb_pool_win_player_info.c_time,
		       none),
	  int32, [])];
iolist(cs_laba_spin_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_laba_spin_req.line_num, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_laba_spin_req.line_set_chips,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#cs_laba_spin_req.type, none), int32,
	  []),
     pack(4, required,
	  with_default(Record#cs_laba_spin_req.test_type, none),
	  int32, [])];
iolist(sc_laba_spin_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_laba_spin_reply.total_reward_num,
		       none),
	  string, []),
     pack(2, repeated,
	  with_default(Record#sc_laba_spin_reply.fruit_list,
		       none),
	  pb_laba_fruit_info, []),
     pack(3, repeated,
	  with_default(Record#sc_laba_spin_reply.reward_list,
		       none),
	  pb_laba_line_reward, []),
     pack(4, required,
	  with_default(Record#sc_laba_spin_reply.new_last_free_times,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_laba_spin_reply.pool, none),
	  uint32, []),
     pack(6, required,
	  with_default(Record#sc_laba_spin_reply.free, none),
	  uint32, [])];
iolist(pb_laba_fruit_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_laba_fruit_info.pos_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_laba_fruit_info.fruit_type,
		       none),
	  uint32, [])];
iolist(pb_laba_line_reward, Record) ->
    [pack(1, required,
	  with_default(Record#pb_laba_line_reward.line_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_laba_line_reward.same_num, none),
	  uint32, [])];
iolist(cs_win_player_list, Record) ->
    [pack(1, required,
	  with_default(Record#cs_win_player_list.type, none),
	  int32, [])];
iolist(sc_win_player_list, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_win_player_list.win_players,
		       none),
	  pb_pool_win_player_info, [])];
iolist(cs_airlaba_enter_room_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_airlaba_enter_room_req.laba_req,
		       none),
	  cs_laba_enter_room_req, []),
     pack(2, required,
	  with_default(Record#cs_airlaba_enter_room_req.base_bet_num,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#cs_airlaba_enter_room_req.base_line_num,
		       none),
	  uint32, [])];
iolist(pb_airlaba_item_list_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_airlaba_item_list_item.item_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_airlaba_item_list_item.item_num,
		       none),
	  uint32, [])];
iolist(sc_airlaba_enter_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_enter_room_reply.laba_resp,
		       none),
	  sc_airlaba_enter_room_reply, []),
     pack(2, required,
	  with_default(Record#sc_airlaba_enter_room_reply.item_list,
		       none),
	  pb_airlaba_item_list_item, [])];
iolist(cs_airlaba_leave_room_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_airlaba_leave_room_req.laba_req,
		       none),
	  cs_laba_leave_room_req, [])];
iolist(sc_airlaba_leave_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_leave_room_reply.laba_resp,
		       none),
	  sc_laba_leave_room_reply, [])];
iolist(cs_airlaba_fire_bet_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_airlaba_fire_bet_req.bullet_cost,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_airlaba_fire_bet_req.bullet_num,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#cs_airlaba_fire_bet_req.hit_objtype,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#cs_airlaba_fire_bet_req.hit_objid,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#cs_airlaba_fire_bet_req.bullet_item_id,
		       none),
	  uint32, [])];
iolist(sc_airlaba_fire_bet_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_fire_bet_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_airlaba_fire_bet_reply.desc,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_airlaba_fire_bet_reply.target_down,
		       none),
	  bool, []),
     pack(4, required,
	  with_default(Record#sc_airlaba_fire_bet_reply.earn_gold,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_airlaba_fire_bet_reply.hit_objid,
		       none),
	  uint32, [])];
iolist(cs_airlaba_switch_phase_req, _Record) -> [];
iolist(sc_airlaba_switch_phase_reply, _Record) -> [];
iolist(sc_airlaba_pool_num_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_pool_num_update.pool_num,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#sc_airlaba_pool_num_update.rank_pool_num,
		       none),
	  string, [])];
iolist(cs_airlaba_use_item_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_airlaba_use_item_req.item_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_airlaba_use_item_req.item_num,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#cs_airlaba_use_item_req.order_id,
		       none),
	  uint32, [])];
iolist(sc_airlaba_use_item_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_use_item_reply.req,
		       none),
	  cs_airlaba_use_item_req, []),
     pack(2, required,
	  with_default(Record#sc_airlaba_use_item_reply.success,
		       none),
	  bool, []),
     pack(3, required,
	  with_default(Record#sc_airlaba_use_item_reply.left_num,
		       none),
	  uint32, [])];
iolist(cs_airlaba_impov_sub_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_airlaba_impov_sub_req.type,
		       none),
	  uint32, [])];
iolist(sc_airlaba_impov_sub_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_airlaba_impov_sub_reply.code,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_airlaba_impov_sub_reply.reward_item_id,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_airlaba_impov_sub_reply.reward_item_num,
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

decode_sc_airlaba_impov_sub_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_impov_sub_reply, Bytes).

decode_cs_airlaba_impov_sub_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_impov_sub_req, Bytes).

decode_sc_airlaba_use_item_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_use_item_reply, Bytes).

decode_cs_airlaba_use_item_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_use_item_req, Bytes).

decode_sc_airlaba_pool_num_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_pool_num_update, Bytes).

decode_sc_airlaba_switch_phase_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_switch_phase_reply, Bytes).

decode_cs_airlaba_switch_phase_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_switch_phase_req, Bytes).

decode_sc_airlaba_fire_bet_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_fire_bet_reply, Bytes).

decode_cs_airlaba_fire_bet_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_fire_bet_req, Bytes).

decode_sc_airlaba_leave_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_leave_room_reply, Bytes).

decode_cs_airlaba_leave_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_leave_room_req, Bytes).

decode_sc_airlaba_enter_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_airlaba_enter_room_reply, Bytes).

decode_pb_airlaba_item_list_item(Bytes)
    when is_binary(Bytes) ->
    decode(pb_airlaba_item_list_item, Bytes).

decode_cs_airlaba_enter_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_airlaba_enter_room_req, Bytes).

decode_sc_win_player_list(Bytes)
    when is_binary(Bytes) ->
    decode(sc_win_player_list, Bytes).

decode_cs_win_player_list(Bytes)
    when is_binary(Bytes) ->
    decode(cs_win_player_list, Bytes).

decode_pb_laba_line_reward(Bytes)
    when is_binary(Bytes) ->
    decode(pb_laba_line_reward, Bytes).

decode_pb_laba_fruit_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_laba_fruit_info, Bytes).

decode_sc_laba_spin_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_laba_spin_reply, Bytes).

decode_cs_laba_spin_req(Bytes) when is_binary(Bytes) ->
    decode(cs_laba_spin_req, Bytes).

decode_pb_pool_win_player_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_pool_win_player_info, Bytes).

decode_sc_laba_pool_num_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_laba_pool_num_update, Bytes).

decode_sc_laba_leave_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_laba_leave_room_reply, Bytes).

decode_cs_laba_leave_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_laba_leave_room_req, Bytes).

decode_sc_laba_enter_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_laba_enter_room_reply, Bytes).

decode_cs_laba_enter_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_laba_enter_room_req, Bytes).

decode(enummsg_values, 1) -> value1;
decode(cs_laba_enter_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, test_type, int32, []},
	     {1, type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_laba_enter_room_req, Decoded);
decode(sc_laba_enter_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, end_time, int32, []},
	     {5, start_time, int32, []}, {4, type, int32, []},
	     {3, last_free_times, uint32, []},
	     {2, line_set_chips, uint32, []},
	     {1, line_num, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_laba_enter_room_reply, Decoded);
decode(cs_laba_leave_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_laba_leave_room_req, Decoded);
decode(sc_laba_leave_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_laba_leave_room_reply, Decoded);
decode(sc_laba_pool_num_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, total_rank_num, string, []},
	     {1, total_pool_num, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_laba_pool_num_update, Decoded);
decode(pb_pool_win_player_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, c_time, int32, []},
	     {5, win_gold, string, []}, {4, vip_level, uint32, []},
	     {3, player_name, bytes, []}, {2, icon_url, string, []},
	     {1, player_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_pool_win_player_info, Decoded);
decode(cs_laba_spin_req, Bytes) when is_binary(Bytes) ->
    Types = [{4, test_type, int32, []},
	     {3, type, int32, []}, {2, line_set_chips, uint32, []},
	     {1, line_num, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_laba_spin_req, Decoded);
decode(sc_laba_spin_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, free, uint32, []}, {5, pool, uint32, []},
	     {4, new_last_free_times, uint32, []},
	     {3, reward_list, pb_laba_line_reward,
	      [is_record, repeated]},
	     {2, fruit_list, pb_laba_fruit_info,
	      [is_record, repeated]},
	     {1, total_reward_num, string, []}],
    Defaults = [{2, fruit_list, []}, {3, reward_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_laba_spin_reply, Decoded);
decode(pb_laba_fruit_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, fruit_type, uint32, []},
	     {1, pos_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_laba_fruit_info, Decoded);
decode(pb_laba_line_reward, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, same_num, uint32, []},
	     {1, line_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_laba_line_reward, Decoded);
decode(cs_win_player_list, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_win_player_list, Decoded);
decode(sc_win_player_list, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, win_players, pb_pool_win_player_info,
	      [is_record, repeated]}],
    Defaults = [{1, win_players, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_win_player_list, Decoded);
decode(cs_airlaba_enter_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, base_line_num, uint32, []},
	     {2, base_bet_num, uint32, []},
	     {1, laba_req, cs_laba_enter_room_req, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_enter_room_req, Decoded);
decode(pb_airlaba_item_list_item, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, item_num, uint32, []},
	     {1, item_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_airlaba_item_list_item, Decoded);
decode(sc_airlaba_enter_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, item_list, pb_airlaba_item_list_item,
	      [is_record]},
	     {1, laba_resp, sc_airlaba_enter_room_reply,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_enter_room_reply, Decoded);
decode(cs_airlaba_leave_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, laba_req, cs_laba_leave_room_req,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_leave_room_req, Decoded);
decode(sc_airlaba_leave_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, laba_resp, sc_laba_leave_room_reply,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_leave_room_reply, Decoded);
decode(cs_airlaba_fire_bet_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, bullet_item_id, uint32, []},
	     {4, hit_objid, uint32, []},
	     {3, hit_objtype, uint32, []},
	     {2, bullet_num, uint32, []},
	     {1, bullet_cost, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_fire_bet_req, Decoded);
decode(sc_airlaba_fire_bet_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, hit_objid, uint32, []},
	     {4, earn_gold, uint32, []}, {3, target_down, bool, []},
	     {2, desc, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_fire_bet_reply, Decoded);
decode(cs_airlaba_switch_phase_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_switch_phase_req, Decoded);
decode(sc_airlaba_switch_phase_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_switch_phase_reply, Decoded);
decode(sc_airlaba_pool_num_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, rank_pool_num, string, []},
	     {1, pool_num, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_pool_num_update, Decoded);
decode(cs_airlaba_use_item_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, order_id, uint32, []},
	     {2, item_num, uint32, []}, {1, item_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_use_item_req, Decoded);
decode(sc_airlaba_use_item_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, left_num, uint32, []},
	     {2, success, bool, []},
	     {1, req, cs_airlaba_use_item_req, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_use_item_reply, Decoded);
decode(cs_airlaba_impov_sub_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_airlaba_impov_sub_req, Decoded);
decode(sc_airlaba_impov_sub_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward_item_num, uint32, []},
	     {2, reward_item_id, uint32, []}, {1, code, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_airlaba_impov_sub_reply, Decoded).

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

to_record(cs_laba_enter_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_laba_enter_room_req),
						   Record, Name, Val)
			  end,
			  #cs_laba_enter_room_req{}, DecodedTuples),
    Record1;
to_record(sc_laba_enter_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_laba_enter_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_laba_enter_room_reply{}, DecodedTuples),
    Record1;
to_record(cs_laba_leave_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_laba_leave_room_req),
						   Record, Name, Val)
			  end,
			  #cs_laba_leave_room_req{}, DecodedTuples),
    Record1;
to_record(sc_laba_leave_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_laba_leave_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_laba_leave_room_reply{}, DecodedTuples),
    Record1;
to_record(sc_laba_pool_num_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_laba_pool_num_update),
						   Record, Name, Val)
			  end,
			  #sc_laba_pool_num_update{}, DecodedTuples),
    Record1;
to_record(pb_pool_win_player_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_pool_win_player_info),
						   Record, Name, Val)
			  end,
			  #pb_pool_win_player_info{}, DecodedTuples),
    Record1;
to_record(cs_laba_spin_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_laba_spin_req),
						   Record, Name, Val)
			  end,
			  #cs_laba_spin_req{}, DecodedTuples),
    Record1;
to_record(sc_laba_spin_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_laba_spin_reply),
						   Record, Name, Val)
			  end,
			  #sc_laba_spin_reply{}, DecodedTuples),
    Record1;
to_record(pb_laba_fruit_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_laba_fruit_info),
						   Record, Name, Val)
			  end,
			  #pb_laba_fruit_info{}, DecodedTuples),
    Record1;
to_record(pb_laba_line_reward, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_laba_line_reward),
						   Record, Name, Val)
			  end,
			  #pb_laba_line_reward{}, DecodedTuples),
    Record1;
to_record(cs_win_player_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_win_player_list),
						   Record, Name, Val)
			  end,
			  #cs_win_player_list{}, DecodedTuples),
    Record1;
to_record(sc_win_player_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_win_player_list),
						   Record, Name, Val)
			  end,
			  #sc_win_player_list{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_enter_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_enter_room_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_enter_room_req{}, DecodedTuples),
    Record1;
to_record(pb_airlaba_item_list_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_airlaba_item_list_item),
						   Record, Name, Val)
			  end,
			  #pb_airlaba_item_list_item{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_enter_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_enter_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_enter_room_reply{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_leave_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_leave_room_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_leave_room_req{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_leave_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_leave_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_leave_room_reply{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_fire_bet_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_fire_bet_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_fire_bet_req{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_fire_bet_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_fire_bet_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_fire_bet_reply{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_switch_phase_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_switch_phase_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_switch_phase_req{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_switch_phase_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_switch_phase_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_switch_phase_reply{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_pool_num_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_pool_num_update),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_pool_num_update{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_use_item_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_use_item_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_use_item_req{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_use_item_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_use_item_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_use_item_reply{}, DecodedTuples),
    Record1;
to_record(cs_airlaba_impov_sub_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_airlaba_impov_sub_req),
						   Record, Name, Val)
			  end,
			  #cs_airlaba_impov_sub_req{}, DecodedTuples),
    Record1;
to_record(sc_airlaba_impov_sub_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_airlaba_impov_sub_reply),
						   Record, Name, Val)
			  end,
			  #sc_airlaba_impov_sub_reply{}, DecodedTuples),
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

