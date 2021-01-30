-file("src/car_pb.erl", 1).

-module(car_pb).

-export([encode_cs_car_query_pool_win_player_req/1,
	 decode_cs_car_query_pool_win_player_req/1,
	 encode_sc_car_query_pool_win_player_reply/1,
	 decode_sc_car_query_pool_win_player_reply/1,
	 encode_pb_car_query_pool_win_player_reply_list_elem/1,
	 decode_pb_car_query_pool_win_player_reply_list_elem/1,
	 encode_pb_car_niu_player_info/1,
	 decode_pb_car_niu_player_info/1,
	 encode_cs_car_syn_in_game_state_req/1,
	 decode_cs_car_syn_in_game_state_req/1,
	 encode_sc_car_add_money_reply/1,
	 decode_sc_car_add_money_reply/1,
	 encode_cs_car_add_money_req/1,
	 decode_cs_car_add_money_req/1,
	 encode_sc_car_pool_reply/1, decode_sc_car_pool_reply/1,
	 encode_sc_car_result_reply/1,
	 decode_sc_car_result_reply/1,
	 encode_sc_car_hint_reply/1, decode_sc_car_hint_reply/1,
	 encode_sc_car_room_info_reply/1,
	 decode_sc_car_room_info_reply/1,
	 encode_pb_car_bet_item/1, decode_pb_car_bet_item/1,
	 encode_sc_car_status_reply/1,
	 decode_sc_car_status_reply/1,
	 encode_sc_car_master_info_reply/1,
	 decode_sc_car_master_info_reply/1,
	 encode_sc_car_master_wait_list_reply/1,
	 decode_sc_car_master_wait_list_reply/1,
	 encode_pb_car_result_history_item/1,
	 decode_pb_car_result_history_item/1,
	 encode_sc_car_result_history_req/1,
	 decode_sc_car_result_history_req/1,
	 encode_pb_car_user_item/1, decode_pb_car_user_item/1,
	 encode_sc_car_user_list_reply/1,
	 decode_sc_car_user_list_reply/1,
	 encode_cs_car_user_list_req/1,
	 decode_cs_car_user_list_req/1,
	 encode_pb_car_master_item/1,
	 decode_pb_car_master_item/1,
	 encode_cs_car_master_list_req/1,
	 decode_cs_car_master_list_req/1,
	 encode_sc_car_rebet_reply/1,
	 decode_sc_car_rebet_reply/1, encode_cs_car_rebet_req/1,
	 decode_cs_car_rebet_req/1, encode_sc_car_bet_reply/1,
	 decode_sc_car_bet_reply/1, encode_cs_car_bet_req/1,
	 decode_cs_car_bet_req/1, encode_sc_car_master_reply/1,
	 decode_sc_car_master_reply/1,
	 encode_cs_car_master_req/1, decode_cs_car_master_req/1,
	 encode_sc_car_exit_reply/1, decode_sc_car_exit_reply/1,
	 encode_cs_car_exit_req/1, decode_cs_car_exit_req/1,
	 encode_sc_car_enter_reply/1,
	 decode_sc_car_enter_reply/1, encode_cs_car_enter_req/1,
	 decode_cs_car_enter_req/1, encode_pb_reward_info/1,
	 decode_pb_reward_info/1, encode_sc_item_use_reply/1,
	 decode_sc_item_use_reply/1, encode_cs_item_use_req/1,
	 decode_cs_item_use_req/1, encode_pb_item_info/1,
	 decode_pb_item_info/1, encode_sc_items_init_update/1,
	 decode_sc_items_init_update/1, encode_sc_items_delete/1,
	 decode_sc_items_delete/1, encode_sc_items_add/1,
	 decode_sc_items_add/1, encode_sc_items_update/1,
	 decode_sc_items_update/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(cs_car_query_pool_win_player_req, {}).

-record(sc_car_query_pool_win_player_reply, {list}).

-record(pb_car_query_pool_win_player_reply_list_elem,
	{date, list}).

-record(pb_car_niu_player_info,
	{player_uuid, icon_type, icon_url, player_name,
	 vip_level, gold, pos, pool_win_gold, sex}).

-record(cs_car_syn_in_game_state_req, {}).

-record(sc_car_add_money_reply, {result, err}).

-record(cs_car_add_money_req, {money}).

-record(sc_car_pool_reply, {result, rank_result}).

-record(sc_car_result_reply,
	{result, resultindex, selfnum, masternum, poolsub,
	 pool}).

-record(sc_car_hint_reply, {msg}).

-record(sc_car_room_info_reply,
	{masterinfo, list, listself, result, self_num,
	 master_num, pool_sub, pool, bet_limit}).

-record(pb_car_bet_item, {index, money}).

-record(sc_car_status_reply, {status, time}).

-record(sc_car_master_info_reply,
	{self, name, money, score, count, head, vip, sex}).

-record(sc_car_master_wait_list_reply, {flag, list}).

-record(pb_car_result_history_item,
	{open_index, result, pool}).

-record(sc_car_result_history_req, {list}).

-record(pb_car_user_item,
	{name, money, vip, head, sex}).

-record(sc_car_user_list_reply, {flag, list}).

-record(cs_car_user_list_req, {}).

-record(pb_car_master_item, {name, money, vip}).

-record(cs_car_master_list_req, {flag}).

-record(sc_car_rebet_reply, {result, err, list}).

-record(cs_car_rebet_req, {list}).

-record(sc_car_bet_reply,
	{result, err, index, money, self}).

-record(cs_car_bet_req, {index, money}).

-record(sc_car_master_reply, {result, err, flag}).

-record(cs_car_master_req, {flag, money}).

-record(sc_car_exit_reply, {result, err}).

-record(cs_car_exit_req, {}).

-record(sc_car_enter_reply, {result, err}).

-record(cs_car_enter_req, {test_type}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_cs_car_query_pool_win_player_req(Record)
    when is_record(Record,
		   cs_car_query_pool_win_player_req) ->
    encode(cs_car_query_pool_win_player_req, Record).

encode_sc_car_query_pool_win_player_reply(Record)
    when is_record(Record,
		   sc_car_query_pool_win_player_reply) ->
    encode(sc_car_query_pool_win_player_reply, Record).

encode_pb_car_query_pool_win_player_reply_list_elem(Record)
    when is_record(Record,
		   pb_car_query_pool_win_player_reply_list_elem) ->
    encode(pb_car_query_pool_win_player_reply_list_elem,
	   Record).

encode_pb_car_niu_player_info(Record)
    when is_record(Record, pb_car_niu_player_info) ->
    encode(pb_car_niu_player_info, Record).

encode_cs_car_syn_in_game_state_req(Record)
    when is_record(Record, cs_car_syn_in_game_state_req) ->
    encode(cs_car_syn_in_game_state_req, Record).

encode_sc_car_add_money_reply(Record)
    when is_record(Record, sc_car_add_money_reply) ->
    encode(sc_car_add_money_reply, Record).

encode_cs_car_add_money_req(Record)
    when is_record(Record, cs_car_add_money_req) ->
    encode(cs_car_add_money_req, Record).

encode_sc_car_pool_reply(Record)
    when is_record(Record, sc_car_pool_reply) ->
    encode(sc_car_pool_reply, Record).

encode_sc_car_result_reply(Record)
    when is_record(Record, sc_car_result_reply) ->
    encode(sc_car_result_reply, Record).

encode_sc_car_hint_reply(Record)
    when is_record(Record, sc_car_hint_reply) ->
    encode(sc_car_hint_reply, Record).

encode_sc_car_room_info_reply(Record)
    when is_record(Record, sc_car_room_info_reply) ->
    encode(sc_car_room_info_reply, Record).

encode_pb_car_bet_item(Record)
    when is_record(Record, pb_car_bet_item) ->
    encode(pb_car_bet_item, Record).

encode_sc_car_status_reply(Record)
    when is_record(Record, sc_car_status_reply) ->
    encode(sc_car_status_reply, Record).

encode_sc_car_master_info_reply(Record)
    when is_record(Record, sc_car_master_info_reply) ->
    encode(sc_car_master_info_reply, Record).

encode_sc_car_master_wait_list_reply(Record)
    when is_record(Record, sc_car_master_wait_list_reply) ->
    encode(sc_car_master_wait_list_reply, Record).

encode_pb_car_result_history_item(Record)
    when is_record(Record, pb_car_result_history_item) ->
    encode(pb_car_result_history_item, Record).

encode_sc_car_result_history_req(Record)
    when is_record(Record, sc_car_result_history_req) ->
    encode(sc_car_result_history_req, Record).

encode_pb_car_user_item(Record)
    when is_record(Record, pb_car_user_item) ->
    encode(pb_car_user_item, Record).

encode_sc_car_user_list_reply(Record)
    when is_record(Record, sc_car_user_list_reply) ->
    encode(sc_car_user_list_reply, Record).

encode_cs_car_user_list_req(Record)
    when is_record(Record, cs_car_user_list_req) ->
    encode(cs_car_user_list_req, Record).

encode_pb_car_master_item(Record)
    when is_record(Record, pb_car_master_item) ->
    encode(pb_car_master_item, Record).

encode_cs_car_master_list_req(Record)
    when is_record(Record, cs_car_master_list_req) ->
    encode(cs_car_master_list_req, Record).

encode_sc_car_rebet_reply(Record)
    when is_record(Record, sc_car_rebet_reply) ->
    encode(sc_car_rebet_reply, Record).

encode_cs_car_rebet_req(Record)
    when is_record(Record, cs_car_rebet_req) ->
    encode(cs_car_rebet_req, Record).

encode_sc_car_bet_reply(Record)
    when is_record(Record, sc_car_bet_reply) ->
    encode(sc_car_bet_reply, Record).

encode_cs_car_bet_req(Record)
    when is_record(Record, cs_car_bet_req) ->
    encode(cs_car_bet_req, Record).

encode_sc_car_master_reply(Record)
    when is_record(Record, sc_car_master_reply) ->
    encode(sc_car_master_reply, Record).

encode_cs_car_master_req(Record)
    when is_record(Record, cs_car_master_req) ->
    encode(cs_car_master_req, Record).

encode_sc_car_exit_reply(Record)
    when is_record(Record, sc_car_exit_reply) ->
    encode(sc_car_exit_reply, Record).

encode_cs_car_exit_req(Record)
    when is_record(Record, cs_car_exit_req) ->
    encode(cs_car_exit_req, Record).

encode_sc_car_enter_reply(Record)
    when is_record(Record, sc_car_enter_reply) ->
    encode(sc_car_enter_reply, Record).

encode_cs_car_enter_req(Record)
    when is_record(Record, cs_car_enter_req) ->
    encode(cs_car_enter_req, Record).

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
encode(cs_car_enter_req, Record) ->
    [iolist(cs_car_enter_req, Record)
     | encode_extensions(Record)];
encode(sc_car_enter_reply, Record) ->
    [iolist(sc_car_enter_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_exit_req, Record) ->
    [iolist(cs_car_exit_req, Record)
     | encode_extensions(Record)];
encode(sc_car_exit_reply, Record) ->
    [iolist(sc_car_exit_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_master_req, Record) ->
    [iolist(cs_car_master_req, Record)
     | encode_extensions(Record)];
encode(sc_car_master_reply, Record) ->
    [iolist(sc_car_master_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_bet_req, Record) ->
    [iolist(cs_car_bet_req, Record)
     | encode_extensions(Record)];
encode(sc_car_bet_reply, Record) ->
    [iolist(sc_car_bet_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_rebet_req, Record) ->
    [iolist(cs_car_rebet_req, Record)
     | encode_extensions(Record)];
encode(sc_car_rebet_reply, Record) ->
    [iolist(sc_car_rebet_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_master_list_req, Record) ->
    [iolist(cs_car_master_list_req, Record)
     | encode_extensions(Record)];
encode(pb_car_master_item, Record) ->
    [iolist(pb_car_master_item, Record)
     | encode_extensions(Record)];
encode(cs_car_user_list_req, Record) ->
    [iolist(cs_car_user_list_req, Record)
     | encode_extensions(Record)];
encode(sc_car_user_list_reply, Record) ->
    [iolist(sc_car_user_list_reply, Record)
     | encode_extensions(Record)];
encode(pb_car_user_item, Record) ->
    [iolist(pb_car_user_item, Record)
     | encode_extensions(Record)];
encode(sc_car_result_history_req, Record) ->
    [iolist(sc_car_result_history_req, Record)
     | encode_extensions(Record)];
encode(pb_car_result_history_item, Record) ->
    [iolist(pb_car_result_history_item, Record)
     | encode_extensions(Record)];
encode(sc_car_master_wait_list_reply, Record) ->
    [iolist(sc_car_master_wait_list_reply, Record)
     | encode_extensions(Record)];
encode(sc_car_master_info_reply, Record) ->
    [iolist(sc_car_master_info_reply, Record)
     | encode_extensions(Record)];
encode(sc_car_status_reply, Record) ->
    [iolist(sc_car_status_reply, Record)
     | encode_extensions(Record)];
encode(pb_car_bet_item, Record) ->
    [iolist(pb_car_bet_item, Record)
     | encode_extensions(Record)];
encode(sc_car_room_info_reply, Record) ->
    [iolist(sc_car_room_info_reply, Record)
     | encode_extensions(Record)];
encode(sc_car_hint_reply, Record) ->
    [iolist(sc_car_hint_reply, Record)
     | encode_extensions(Record)];
encode(sc_car_result_reply, Record) ->
    [iolist(sc_car_result_reply, Record)
     | encode_extensions(Record)];
encode(sc_car_pool_reply, Record) ->
    [iolist(sc_car_pool_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_add_money_req, Record) ->
    [iolist(cs_car_add_money_req, Record)
     | encode_extensions(Record)];
encode(sc_car_add_money_reply, Record) ->
    [iolist(sc_car_add_money_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_syn_in_game_state_req, Record) ->
    [iolist(cs_car_syn_in_game_state_req, Record)
     | encode_extensions(Record)];
encode(pb_car_niu_player_info, Record) ->
    [iolist(pb_car_niu_player_info, Record)
     | encode_extensions(Record)];
encode(pb_car_query_pool_win_player_reply_list_elem,
       Record) ->
    [iolist(pb_car_query_pool_win_player_reply_list_elem,
	    Record)
     | encode_extensions(Record)];
encode(sc_car_query_pool_win_player_reply, Record) ->
    [iolist(sc_car_query_pool_win_player_reply, Record)
     | encode_extensions(Record)];
encode(cs_car_query_pool_win_player_req, Record) ->
    [iolist(cs_car_query_pool_win_player_req, Record)
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
iolist(cs_car_enter_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_car_enter_req.test_type, none),
	  int32, [])];
iolist(sc_car_enter_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_enter_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_enter_reply.err, none),
	  bytes, [])];
iolist(cs_car_exit_req, _Record) -> [];
iolist(sc_car_exit_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_exit_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_exit_reply.err, none), bytes,
	  [])];
iolist(cs_car_master_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_car_master_req.flag, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_car_master_req.money, none),
	  int32, [])];
iolist(sc_car_master_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_master_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_master_reply.err, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_car_master_reply.flag, none),
	  int32, [])];
iolist(cs_car_bet_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_car_bet_req.index, none), int32,
	  []),
     pack(2, required,
	  with_default(Record#cs_car_bet_req.money, none), int32,
	  [])];
iolist(sc_car_bet_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_bet_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_bet_reply.err, none), bytes,
	  []),
     pack(3, required,
	  with_default(Record#sc_car_bet_reply.index, none),
	  int32, []),
     pack(4, required,
	  with_default(Record#sc_car_bet_reply.money, none),
	  int32, []),
     pack(5, required,
	  with_default(Record#sc_car_bet_reply.self, none), int32,
	  [])];
iolist(cs_car_rebet_req, Record) ->
    [pack(1, repeated,
	  with_default(Record#cs_car_rebet_req.list, none),
	  cs_car_bet_req, [])];
iolist(sc_car_rebet_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_rebet_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_rebet_reply.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_car_rebet_reply.list, none),
	  sc_car_bet_reply, [])];
iolist(cs_car_master_list_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_car_master_list_req.flag, none),
	  int32, [])];
iolist(pb_car_master_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_master_item.name, none),
	  bytes, []),
     pack(2, required,
	  with_default(Record#pb_car_master_item.money, none),
	  int32, []),
     pack(3, required,
	  with_default(Record#pb_car_master_item.vip, none),
	  int32, [])];
iolist(cs_car_user_list_req, _Record) -> [];
iolist(sc_car_user_list_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_user_list_reply.flag, none),
	  int32, []),
     pack(2, repeated,
	  with_default(Record#sc_car_user_list_reply.list, none),
	  pb_car_user_item, [])];
iolist(pb_car_user_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_user_item.name, none), bytes,
	  []),
     pack(2, required,
	  with_default(Record#pb_car_user_item.money, none),
	  int32, []),
     pack(3, required,
	  with_default(Record#pb_car_user_item.vip, none), int32,
	  []),
     pack(4, required,
	  with_default(Record#pb_car_user_item.head, none),
	  string, []),
     pack(5, required,
	  with_default(Record#pb_car_user_item.sex, none), int32,
	  [])];
iolist(sc_car_result_history_req, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_car_result_history_req.list,
		       none),
	  pb_car_result_history_item, [])];
iolist(pb_car_result_history_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_result_history_item.open_index,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_car_result_history_item.result,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#pb_car_result_history_item.pool,
		       none),
	  int32, [])];
iolist(sc_car_master_wait_list_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_master_wait_list_reply.flag,
		       none),
	  int32, []),
     pack(2, repeated,
	  with_default(Record#sc_car_master_wait_list_reply.list,
		       none),
	  pb_car_master_item, [])];
iolist(sc_car_master_info_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_master_info_reply.self,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_car_master_info_reply.name,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_car_master_info_reply.money,
		       none),
	  int32, []),
     pack(4, required,
	  with_default(Record#sc_car_master_info_reply.score,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#sc_car_master_info_reply.count,
		       none),
	  int32, []),
     pack(6, required,
	  with_default(Record#sc_car_master_info_reply.head,
		       none),
	  string, []),
     pack(7, required,
	  with_default(Record#sc_car_master_info_reply.vip, none),
	  int32, []),
     pack(8, required,
	  with_default(Record#sc_car_master_info_reply.sex, none),
	  int32, [])];
iolist(sc_car_status_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_status_reply.status, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_car_status_reply.time, none),
	  int32, [])];
iolist(pb_car_bet_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_bet_item.index, none), int32,
	  []),
     pack(2, required,
	  with_default(Record#pb_car_bet_item.money, none), int32,
	  [])];
iolist(sc_car_room_info_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_room_info_reply.masterinfo,
		       none),
	  sc_car_master_info_reply, []),
     pack(2, repeated,
	  with_default(Record#sc_car_room_info_reply.list, none),
	  pb_car_bet_item, []),
     pack(3, repeated,
	  with_default(Record#sc_car_room_info_reply.listself,
		       none),
	  pb_car_bet_item, []),
     pack(4, required,
	  with_default(Record#sc_car_room_info_reply.result,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#sc_car_room_info_reply.self_num,
		       none),
	  int32, []),
     pack(6, required,
	  with_default(Record#sc_car_room_info_reply.master_num,
		       none),
	  int32, []),
     pack(7, required,
	  with_default(Record#sc_car_room_info_reply.pool_sub,
		       none),
	  int32, []),
     pack(8, required,
	  with_default(Record#sc_car_room_info_reply.pool, none),
	  int32, []),
     pack(9, optional,
	  with_default(Record#sc_car_room_info_reply.bet_limit,
		       none),
	  int32, [])];
iolist(sc_car_hint_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_hint_reply.msg, none), bytes,
	  [])];
iolist(sc_car_result_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_result_reply.result, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_car_result_reply.resultindex,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_car_result_reply.selfnum, none),
	  int32, []),
     pack(4, required,
	  with_default(Record#sc_car_result_reply.masternum,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#sc_car_result_reply.poolsub, none),
	  int32, []),
     pack(6, required,
	  with_default(Record#sc_car_result_reply.pool, none),
	  int32, [])];
iolist(sc_car_pool_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_pool_reply.result, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_car_pool_reply.rank_result,
		       none),
	  int32, [])];
iolist(cs_car_add_money_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_car_add_money_req.money, none),
	  int32, [])];
iolist(sc_car_add_money_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_car_add_money_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_car_add_money_reply.err, none),
	  bytes, [])];
iolist(cs_car_syn_in_game_state_req, _Record) -> [];
iolist(pb_car_niu_player_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_niu_player_info.player_uuid,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_car_niu_player_info.icon_type,
		       none),
	  uint32, []),
     pack(3, optional,
	  with_default(Record#pb_car_niu_player_info.icon_url,
		       none),
	  string, []),
     pack(4, optional,
	  with_default(Record#pb_car_niu_player_info.player_name,
		       none),
	  bytes, []),
     pack(5, required,
	  with_default(Record#pb_car_niu_player_info.vip_level,
		       none),
	  uint32, []),
     pack(6, optional,
	  with_default(Record#pb_car_niu_player_info.gold, none),
	  uint64, []),
     pack(7, optional,
	  with_default(Record#pb_car_niu_player_info.pos, none),
	  uint32, []),
     pack(8, optional,
	  with_default(Record#pb_car_niu_player_info.pool_win_gold,
		       none),
	  uint64, []),
     pack(9, required,
	  with_default(Record#pb_car_niu_player_info.sex, none),
	  uint32, [])];
iolist(pb_car_query_pool_win_player_reply_list_elem,
       Record) ->
    [pack(1, required,
	  with_default(Record#pb_car_query_pool_win_player_reply_list_elem.date,
		       none),
	  uint64, []),
     pack(2, repeated,
	  with_default(Record#pb_car_query_pool_win_player_reply_list_elem.list,
		       none),
	  pb_car_niu_player_info, [])];
iolist(sc_car_query_pool_win_player_reply, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_car_query_pool_win_player_reply.list,
		       none),
	  pb_car_query_pool_win_player_reply_list_elem, [])];
iolist(cs_car_query_pool_win_player_req, _Record) -> [].

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

decode_cs_car_query_pool_win_player_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_car_query_pool_win_player_req, Bytes).

decode_sc_car_query_pool_win_player_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_query_pool_win_player_reply, Bytes).

decode_pb_car_query_pool_win_player_reply_list_elem(Bytes)
    when is_binary(Bytes) ->
    decode(pb_car_query_pool_win_player_reply_list_elem,
	   Bytes).

decode_pb_car_niu_player_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_car_niu_player_info, Bytes).

decode_cs_car_syn_in_game_state_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_car_syn_in_game_state_req, Bytes).

decode_sc_car_add_money_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_add_money_reply, Bytes).

decode_cs_car_add_money_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_car_add_money_req, Bytes).

decode_sc_car_pool_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_car_pool_reply, Bytes).

decode_sc_car_result_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_result_reply, Bytes).

decode_sc_car_hint_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_car_hint_reply, Bytes).

decode_sc_car_room_info_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_room_info_reply, Bytes).

decode_pb_car_bet_item(Bytes) when is_binary(Bytes) ->
    decode(pb_car_bet_item, Bytes).

decode_sc_car_status_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_status_reply, Bytes).

decode_sc_car_master_info_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_master_info_reply, Bytes).

decode_sc_car_master_wait_list_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_master_wait_list_reply, Bytes).

decode_pb_car_result_history_item(Bytes)
    when is_binary(Bytes) ->
    decode(pb_car_result_history_item, Bytes).

decode_sc_car_result_history_req(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_result_history_req, Bytes).

decode_pb_car_user_item(Bytes) when is_binary(Bytes) ->
    decode(pb_car_user_item, Bytes).

decode_sc_car_user_list_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_user_list_reply, Bytes).

decode_cs_car_user_list_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_car_user_list_req, Bytes).

decode_pb_car_master_item(Bytes)
    when is_binary(Bytes) ->
    decode(pb_car_master_item, Bytes).

decode_cs_car_master_list_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_car_master_list_req, Bytes).

decode_sc_car_rebet_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_rebet_reply, Bytes).

decode_cs_car_rebet_req(Bytes) when is_binary(Bytes) ->
    decode(cs_car_rebet_req, Bytes).

decode_sc_car_bet_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_car_bet_reply, Bytes).

decode_cs_car_bet_req(Bytes) when is_binary(Bytes) ->
    decode(cs_car_bet_req, Bytes).

decode_sc_car_master_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_master_reply, Bytes).

decode_cs_car_master_req(Bytes) when is_binary(Bytes) ->
    decode(cs_car_master_req, Bytes).

decode_sc_car_exit_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_car_exit_reply, Bytes).

decode_cs_car_exit_req(Bytes) when is_binary(Bytes) ->
    decode(cs_car_exit_req, Bytes).

decode_sc_car_enter_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_car_enter_reply, Bytes).

decode_cs_car_enter_req(Bytes) when is_binary(Bytes) ->
    decode(cs_car_enter_req, Bytes).

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
decode(cs_car_enter_req, Bytes) when is_binary(Bytes) ->
    Types = [{1, test_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_enter_req, Decoded);
decode(sc_car_enter_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_enter_reply, Decoded);
decode(cs_car_exit_req, Bytes) when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_exit_req, Decoded);
decode(sc_car_exit_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_exit_reply, Decoded);
decode(cs_car_master_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, money, int32, []}, {1, flag, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_master_req, Decoded);
decode(sc_car_master_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, flag, int32, []}, {2, err, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_master_reply, Decoded);
decode(cs_car_bet_req, Bytes) when is_binary(Bytes) ->
    Types = [{2, money, int32, []}, {1, index, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_bet_req, Decoded);
decode(sc_car_bet_reply, Bytes) when is_binary(Bytes) ->
    Types = [{5, self, int32, []}, {4, money, int32, []},
	     {3, index, int32, []}, {2, err, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_bet_reply, Decoded);
decode(cs_car_rebet_req, Bytes) when is_binary(Bytes) ->
    Types = [{1, list, cs_car_bet_req,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_rebet_req, Decoded);
decode(sc_car_rebet_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, list, sc_car_bet_reply,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_rebet_reply, Decoded);
decode(cs_car_master_list_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, flag, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_master_list_req, Decoded);
decode(pb_car_master_item, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, vip, int32, []}, {2, money, int32, []},
	     {1, name, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_master_item, Decoded);
decode(cs_car_user_list_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_user_list_req, Decoded);
decode(sc_car_user_list_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, list, pb_car_user_item,
	      [is_record, repeated]},
	     {1, flag, int32, []}],
    Defaults = [{2, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_user_list_reply, Decoded);
decode(pb_car_user_item, Bytes) when is_binary(Bytes) ->
    Types = [{5, sex, int32, []}, {4, head, string, []},
	     {3, vip, int32, []}, {2, money, int32, []},
	     {1, name, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_user_item, Decoded);
decode(sc_car_result_history_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_car_result_history_item,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_result_history_req, Decoded);
decode(pb_car_result_history_item, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, pool, int32, []}, {2, result, int32, []},
	     {1, open_index, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_result_history_item, Decoded);
decode(sc_car_master_wait_list_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, list, pb_car_master_item,
	      [is_record, repeated]},
	     {1, flag, int32, []}],
    Defaults = [{2, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_master_wait_list_reply, Decoded);
decode(sc_car_master_info_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{8, sex, int32, []}, {7, vip, int32, []},
	     {6, head, string, []}, {5, count, int32, []},
	     {4, score, int32, []}, {3, money, int32, []},
	     {2, name, bytes, []}, {1, self, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_master_info_reply, Decoded);
decode(sc_car_status_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, time, int32, []}, {1, status, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_status_reply, Decoded);
decode(pb_car_bet_item, Bytes) when is_binary(Bytes) ->
    Types = [{2, money, int32, []}, {1, index, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_bet_item, Decoded);
decode(sc_car_room_info_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{9, bet_limit, int32, []},
	     {8, pool, int32, []}, {7, pool_sub, int32, []},
	     {6, master_num, int32, []}, {5, self_num, int32, []},
	     {4, result, int32, []},
	     {3, listself, pb_car_bet_item, [is_record, repeated]},
	     {2, list, pb_car_bet_item, [is_record, repeated]},
	     {1, masterinfo, sc_car_master_info_reply, [is_record]}],
    Defaults = [{2, list, []}, {3, listself, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_room_info_reply, Decoded);
decode(sc_car_hint_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, msg, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_hint_reply, Decoded);
decode(sc_car_result_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, pool, int32, []}, {5, poolsub, int32, []},
	     {4, masternum, int32, []}, {3, selfnum, int32, []},
	     {2, resultindex, int32, []}, {1, result, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_result_reply, Decoded);
decode(sc_car_pool_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, rank_result, int32, []},
	     {1, result, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_pool_reply, Decoded);
decode(cs_car_add_money_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, money, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_add_money_req, Decoded);
decode(sc_car_add_money_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_add_money_reply, Decoded);
decode(cs_car_syn_in_game_state_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_syn_in_game_state_req, Decoded);
decode(pb_car_niu_player_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{9, sex, uint32, []},
	     {8, pool_win_gold, uint64, []}, {7, pos, uint32, []},
	     {6, gold, uint64, []}, {5, vip_level, uint32, []},
	     {4, player_name, bytes, []}, {3, icon_url, string, []},
	     {2, icon_type, uint32, []},
	     {1, player_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_niu_player_info, Decoded);
decode(pb_car_query_pool_win_player_reply_list_elem,
       Bytes)
    when is_binary(Bytes) ->
    Types = [{2, list, pb_car_niu_player_info,
	      [is_record, repeated]},
	     {1, date, uint64, []}],
    Defaults = [{2, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_car_query_pool_win_player_reply_list_elem,
	      Decoded);
decode(sc_car_query_pool_win_player_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list,
	      pb_car_query_pool_win_player_reply_list_elem,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_car_query_pool_win_player_reply, Decoded);
decode(cs_car_query_pool_win_player_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_car_query_pool_win_player_req, Decoded).

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
to_record(cs_car_enter_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_enter_req),
						   Record, Name, Val)
			  end,
			  #cs_car_enter_req{}, DecodedTuples),
    Record1;
to_record(sc_car_enter_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_enter_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_enter_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_exit_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_exit_req),
						   Record, Name, Val)
			  end,
			  #cs_car_exit_req{}, DecodedTuples),
    Record1;
to_record(sc_car_exit_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_exit_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_exit_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_master_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_master_req),
						   Record, Name, Val)
			  end,
			  #cs_car_master_req{}, DecodedTuples),
    Record1;
to_record(sc_car_master_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_master_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_master_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_bet_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_bet_req),
						   Record, Name, Val)
			  end,
			  #cs_car_bet_req{}, DecodedTuples),
    Record1;
to_record(sc_car_bet_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_bet_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_bet_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_rebet_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_rebet_req),
						   Record, Name, Val)
			  end,
			  #cs_car_rebet_req{}, DecodedTuples),
    Record1;
to_record(sc_car_rebet_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_rebet_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_rebet_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_master_list_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_master_list_req),
						   Record, Name, Val)
			  end,
			  #cs_car_master_list_req{}, DecodedTuples),
    Record1;
to_record(pb_car_master_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_master_item),
						   Record, Name, Val)
			  end,
			  #pb_car_master_item{}, DecodedTuples),
    Record1;
to_record(cs_car_user_list_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_user_list_req),
						   Record, Name, Val)
			  end,
			  #cs_car_user_list_req{}, DecodedTuples),
    Record1;
to_record(sc_car_user_list_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_user_list_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_user_list_reply{}, DecodedTuples),
    Record1;
to_record(pb_car_user_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_user_item),
						   Record, Name, Val)
			  end,
			  #pb_car_user_item{}, DecodedTuples),
    Record1;
to_record(sc_car_result_history_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_result_history_req),
						   Record, Name, Val)
			  end,
			  #sc_car_result_history_req{}, DecodedTuples),
    Record1;
to_record(pb_car_result_history_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_result_history_item),
						   Record, Name, Val)
			  end,
			  #pb_car_result_history_item{}, DecodedTuples),
    Record1;
to_record(sc_car_master_wait_list_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_master_wait_list_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_master_wait_list_reply{}, DecodedTuples),
    Record1;
to_record(sc_car_master_info_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_master_info_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_master_info_reply{}, DecodedTuples),
    Record1;
to_record(sc_car_status_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_status_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_status_reply{}, DecodedTuples),
    Record1;
to_record(pb_car_bet_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_bet_item),
						   Record, Name, Val)
			  end,
			  #pb_car_bet_item{}, DecodedTuples),
    Record1;
to_record(sc_car_room_info_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_room_info_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_room_info_reply{}, DecodedTuples),
    Record1;
to_record(sc_car_hint_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_hint_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_hint_reply{}, DecodedTuples),
    Record1;
to_record(sc_car_result_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_result_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_result_reply{}, DecodedTuples),
    Record1;
to_record(sc_car_pool_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_pool_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_pool_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_add_money_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_add_money_req),
						   Record, Name, Val)
			  end,
			  #cs_car_add_money_req{}, DecodedTuples),
    Record1;
to_record(sc_car_add_money_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_add_money_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_add_money_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_syn_in_game_state_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_syn_in_game_state_req),
						   Record, Name, Val)
			  end,
			  #cs_car_syn_in_game_state_req{}, DecodedTuples),
    Record1;
to_record(pb_car_niu_player_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_niu_player_info),
						   Record, Name, Val)
			  end,
			  #pb_car_niu_player_info{}, DecodedTuples),
    Record1;
to_record(pb_car_query_pool_win_player_reply_list_elem,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_car_query_pool_win_player_reply_list_elem),
						   Record, Name, Val)
			  end,
			  #pb_car_query_pool_win_player_reply_list_elem{},
			  DecodedTuples),
    Record1;
to_record(sc_car_query_pool_win_player_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_car_query_pool_win_player_reply),
						   Record, Name, Val)
			  end,
			  #sc_car_query_pool_win_player_reply{}, DecodedTuples),
    Record1;
to_record(cs_car_query_pool_win_player_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_car_query_pool_win_player_req),
						   Record, Name, Val)
			  end,
			  #cs_car_query_pool_win_player_req{}, DecodedTuples),
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

