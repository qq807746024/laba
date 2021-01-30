-file("src/niu_game_pb.erl", 1).

-module(niu_game_pb).

-export([encode_sc_fudai_pool_update/1,
	 decode_sc_fudai_pool_update/1,
	 encode_sc_redpack_relive_times/1,
	 decode_sc_redpack_relive_times/1,
	 encode_sc_redpack_relive_reply/1,
	 decode_sc_redpack_relive_reply/1,
	 encode_cs_redpack_relive_req/1,
	 decode_cs_redpack_relive_req/1,
	 encode_sc_redpack_redpack_timer_sec_update/1,
	 decode_sc_redpack_redpack_timer_sec_update/1,
	 encode_sc_redpack_room_draw_reply/1,
	 decode_sc_redpack_room_draw_reply/1,
	 encode_cs_redpack_room_draw_req/1,
	 decode_cs_redpack_room_draw_req/1,
	 encode_sc_redpack_room_redpack_notice_update/1,
	 decode_sc_redpack_room_redpack_notice_update/1,
	 encode_sc_redpack_room_player_times_update/1,
	 decode_sc_redpack_room_player_times_update/1,
	 encode_sc_redpack_room_reset_times_update/1,
	 decode_sc_redpack_room_reset_times_update/1,
	 encode_pb_niu_player_info/1,
	 decode_pb_niu_player_info/1, encode_pb_settle_info/1,
	 decode_pb_settle_info/1, encode_game_over_settlement/1,
	 decode_game_over_settlement/1, encode_pb_poker_card/1,
	 decode_pb_poker_card/1,
	 encode_sc_niu_player_back_to_room_info_update/1,
	 decode_sc_niu_player_back_to_room_info_update/1,
	 encode_sc_niu_player_room_info_update/1,
	 decode_sc_niu_player_room_info_update/1,
	 encode_cs_niu_query_player_room_info_req/1,
	 decode_cs_niu_query_player_room_info_req/1,
	 encode_cs_niu_syn_in_game_state_req/1,
	 decode_cs_niu_syn_in_game_state_req/1,
	 encode_sc_niu_player_submit_card_update/1,
	 decode_sc_niu_player_submit_card_update/1,
	 encode_sc_niu_submit_card_reply/1,
	 decode_sc_niu_submit_card_reply/1,
	 encode_cs_niu_submit_card_req/1,
	 decode_cs_niu_submit_card_req/1,
	 encode_sc_niu_leave_room_player_pos_update/1,
	 decode_sc_niu_leave_room_player_pos_update/1,
	 encode_sc_niu_leave_room_reply/1,
	 decode_sc_niu_leave_room_reply/1,
	 encode_cs_niu_leave_room_req/1,
	 decode_cs_niu_leave_room_req/1,
	 encode_sc_niu_player_choose_free_rate_update/1,
	 decode_sc_niu_player_choose_free_rate_update/1,
	 encode_sc_niu_choose_free_rate_reply/1,
	 decode_sc_niu_choose_free_rate_reply/1,
	 encode_cs_niu_choose_free_rate_req/1,
	 decode_cs_niu_choose_free_rate_req/1,
	 encode_sc_niu_player_choose_master_rate_update/1,
	 decode_sc_niu_player_choose_master_rate_update/1,
	 encode_sc_niu_choose_master_rate_reply/1,
	 decode_sc_niu_choose_master_rate_reply/1,
	 encode_cs_niu_choose_master_rate_req/1,
	 decode_cs_niu_choose_master_rate_req/1,
	 encode_sc_niu_enter_room_player_info_update/1,
	 decode_sc_niu_enter_room_player_info_update/1,
	 encode_sc_niu_enter_room_reply/1,
	 decode_sc_niu_enter_room_reply/1,
	 encode_cs_niu_enter_room_req/1,
	 decode_cs_niu_enter_room_req/1,
	 encode_sc_niu_room_state_update/1,
	 decode_sc_niu_room_state_update/1,
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

-record(sc_fudai_pool_update, {num}).

-record(sc_redpack_relive_times, {times}).

-record(sc_redpack_relive_reply, {result, err}).

-record(cs_redpack_relive_req, {}).

-record(sc_redpack_redpack_timer_sec_update,
	{next_can_draw_second, next_open_redpack_second}).

-record(sc_redpack_room_draw_reply,
	{result, err, reward, next_can_draw_second}).

-record(cs_redpack_room_draw_req, {}).

-record(sc_redpack_room_redpack_notice_update,
	{close_draw_second, next_open_redpack_second}).

-record(sc_redpack_room_player_times_update,
	{now_play_times}).

-record(sc_redpack_room_reset_times_update,
	{left_reset_times, reset_seconds,
	 reset_mission_is_draw}).

-record(pb_niu_player_info,
	{pos, player_uuid, gold_num, icon_type, icon_url,
	 player_name, master_rate, free_rate, open_card_list,
	 card_type, vip_level, sex}).

-record(pb_settle_info,
	{player_pos, reward_num, card_type, card_list}).

-record(game_over_settlement, {all_player_settle_info}).

-record(pb_poker_card, {number, color}).

-record(sc_niu_player_back_to_room_info_update,
	{state_id, end_sec_time, player_list, master_pos,
	 my_pos}).

-record(sc_niu_player_room_info_update,
	{room_id, enter_end_time}).

-record(cs_niu_query_player_room_info_req, {}).

-record(cs_niu_syn_in_game_state_req, {}).

-record(sc_niu_player_submit_card_update,
	{player_pos, card_type, card_list}).

-record(sc_niu_submit_card_reply, {result}).

-record(cs_niu_submit_card_req, {}).

-record(sc_niu_leave_room_player_pos_update,
	{leave_pos}).

-record(sc_niu_leave_room_reply, {result}).

-record(cs_niu_leave_room_req, {}).

-record(sc_niu_player_choose_free_rate_update,
	{pos, rate_num}).

-record(sc_niu_choose_free_rate_reply, {result, err}).

-record(cs_niu_choose_free_rate_req,
	{rate_num, test_type}).

-record(sc_niu_player_choose_master_rate_update,
	{pos, rate_num}).

-record(sc_niu_choose_master_rate_reply, {result, err}).

-record(cs_niu_choose_master_rate_req, {rate_num}).

-record(sc_niu_enter_room_player_info_update,
	{player_list}).

-record(sc_niu_enter_room_reply, {result, my_pos}).

-record(cs_niu_enter_room_req, {room_type}).

-record(sc_niu_room_state_update,
	{state_id, end_sec_time, open_card_list, master_pos,
	 last_card_info, settle_list}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_fudai_pool_update(Record)
    when is_record(Record, sc_fudai_pool_update) ->
    encode(sc_fudai_pool_update, Record).

encode_sc_redpack_relive_times(Record)
    when is_record(Record, sc_redpack_relive_times) ->
    encode(sc_redpack_relive_times, Record).

encode_sc_redpack_relive_reply(Record)
    when is_record(Record, sc_redpack_relive_reply) ->
    encode(sc_redpack_relive_reply, Record).

encode_cs_redpack_relive_req(Record)
    when is_record(Record, cs_redpack_relive_req) ->
    encode(cs_redpack_relive_req, Record).

encode_sc_redpack_redpack_timer_sec_update(Record)
    when is_record(Record,
		   sc_redpack_redpack_timer_sec_update) ->
    encode(sc_redpack_redpack_timer_sec_update, Record).

encode_sc_redpack_room_draw_reply(Record)
    when is_record(Record, sc_redpack_room_draw_reply) ->
    encode(sc_redpack_room_draw_reply, Record).

encode_cs_redpack_room_draw_req(Record)
    when is_record(Record, cs_redpack_room_draw_req) ->
    encode(cs_redpack_room_draw_req, Record).

encode_sc_redpack_room_redpack_notice_update(Record)
    when is_record(Record,
		   sc_redpack_room_redpack_notice_update) ->
    encode(sc_redpack_room_redpack_notice_update, Record).

encode_sc_redpack_room_player_times_update(Record)
    when is_record(Record,
		   sc_redpack_room_player_times_update) ->
    encode(sc_redpack_room_player_times_update, Record).

encode_sc_redpack_room_reset_times_update(Record)
    when is_record(Record,
		   sc_redpack_room_reset_times_update) ->
    encode(sc_redpack_room_reset_times_update, Record).

encode_pb_niu_player_info(Record)
    when is_record(Record, pb_niu_player_info) ->
    encode(pb_niu_player_info, Record).

encode_pb_settle_info(Record)
    when is_record(Record, pb_settle_info) ->
    encode(pb_settle_info, Record).

encode_game_over_settlement(Record)
    when is_record(Record, game_over_settlement) ->
    encode(game_over_settlement, Record).

encode_pb_poker_card(Record)
    when is_record(Record, pb_poker_card) ->
    encode(pb_poker_card, Record).

encode_sc_niu_player_back_to_room_info_update(Record)
    when is_record(Record,
		   sc_niu_player_back_to_room_info_update) ->
    encode(sc_niu_player_back_to_room_info_update, Record).

encode_sc_niu_player_room_info_update(Record)
    when is_record(Record,
		   sc_niu_player_room_info_update) ->
    encode(sc_niu_player_room_info_update, Record).

encode_cs_niu_query_player_room_info_req(Record)
    when is_record(Record,
		   cs_niu_query_player_room_info_req) ->
    encode(cs_niu_query_player_room_info_req, Record).

encode_cs_niu_syn_in_game_state_req(Record)
    when is_record(Record, cs_niu_syn_in_game_state_req) ->
    encode(cs_niu_syn_in_game_state_req, Record).

encode_sc_niu_player_submit_card_update(Record)
    when is_record(Record,
		   sc_niu_player_submit_card_update) ->
    encode(sc_niu_player_submit_card_update, Record).

encode_sc_niu_submit_card_reply(Record)
    when is_record(Record, sc_niu_submit_card_reply) ->
    encode(sc_niu_submit_card_reply, Record).

encode_cs_niu_submit_card_req(Record)
    when is_record(Record, cs_niu_submit_card_req) ->
    encode(cs_niu_submit_card_req, Record).

encode_sc_niu_leave_room_player_pos_update(Record)
    when is_record(Record,
		   sc_niu_leave_room_player_pos_update) ->
    encode(sc_niu_leave_room_player_pos_update, Record).

encode_sc_niu_leave_room_reply(Record)
    when is_record(Record, sc_niu_leave_room_reply) ->
    encode(sc_niu_leave_room_reply, Record).

encode_cs_niu_leave_room_req(Record)
    when is_record(Record, cs_niu_leave_room_req) ->
    encode(cs_niu_leave_room_req, Record).

encode_sc_niu_player_choose_free_rate_update(Record)
    when is_record(Record,
		   sc_niu_player_choose_free_rate_update) ->
    encode(sc_niu_player_choose_free_rate_update, Record).

encode_sc_niu_choose_free_rate_reply(Record)
    when is_record(Record, sc_niu_choose_free_rate_reply) ->
    encode(sc_niu_choose_free_rate_reply, Record).

encode_cs_niu_choose_free_rate_req(Record)
    when is_record(Record, cs_niu_choose_free_rate_req) ->
    encode(cs_niu_choose_free_rate_req, Record).

encode_sc_niu_player_choose_master_rate_update(Record)
    when is_record(Record,
		   sc_niu_player_choose_master_rate_update) ->
    encode(sc_niu_player_choose_master_rate_update, Record).

encode_sc_niu_choose_master_rate_reply(Record)
    when is_record(Record,
		   sc_niu_choose_master_rate_reply) ->
    encode(sc_niu_choose_master_rate_reply, Record).

encode_cs_niu_choose_master_rate_req(Record)
    when is_record(Record, cs_niu_choose_master_rate_req) ->
    encode(cs_niu_choose_master_rate_req, Record).

encode_sc_niu_enter_room_player_info_update(Record)
    when is_record(Record,
		   sc_niu_enter_room_player_info_update) ->
    encode(sc_niu_enter_room_player_info_update, Record).

encode_sc_niu_enter_room_reply(Record)
    when is_record(Record, sc_niu_enter_room_reply) ->
    encode(sc_niu_enter_room_reply, Record).

encode_cs_niu_enter_room_req(Record)
    when is_record(Record, cs_niu_enter_room_req) ->
    encode(cs_niu_enter_room_req, Record).

encode_sc_niu_room_state_update(Record)
    when is_record(Record, sc_niu_room_state_update) ->
    encode(sc_niu_room_state_update, Record).

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
encode(sc_niu_room_state_update, Record) ->
    [iolist(sc_niu_room_state_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_enter_room_req, Record) ->
    [iolist(cs_niu_enter_room_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_enter_room_reply, Record) ->
    [iolist(sc_niu_enter_room_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_enter_room_player_info_update, Record) ->
    [iolist(sc_niu_enter_room_player_info_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_choose_master_rate_req, Record) ->
    [iolist(cs_niu_choose_master_rate_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_choose_master_rate_reply, Record) ->
    [iolist(sc_niu_choose_master_rate_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_player_choose_master_rate_update,
       Record) ->
    [iolist(sc_niu_player_choose_master_rate_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_choose_free_rate_req, Record) ->
    [iolist(cs_niu_choose_free_rate_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_choose_free_rate_reply, Record) ->
    [iolist(sc_niu_choose_free_rate_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_player_choose_free_rate_update, Record) ->
    [iolist(sc_niu_player_choose_free_rate_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_leave_room_req, Record) ->
    [iolist(cs_niu_leave_room_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_leave_room_reply, Record) ->
    [iolist(sc_niu_leave_room_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_leave_room_player_pos_update, Record) ->
    [iolist(sc_niu_leave_room_player_pos_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_submit_card_req, Record) ->
    [iolist(cs_niu_submit_card_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_submit_card_reply, Record) ->
    [iolist(sc_niu_submit_card_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_player_submit_card_update, Record) ->
    [iolist(sc_niu_player_submit_card_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_syn_in_game_state_req, Record) ->
    [iolist(cs_niu_syn_in_game_state_req, Record)
     | encode_extensions(Record)];
encode(cs_niu_query_player_room_info_req, Record) ->
    [iolist(cs_niu_query_player_room_info_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_player_room_info_update, Record) ->
    [iolist(sc_niu_player_room_info_update, Record)
     | encode_extensions(Record)];
encode(sc_niu_player_back_to_room_info_update,
       Record) ->
    [iolist(sc_niu_player_back_to_room_info_update, Record)
     | encode_extensions(Record)];
encode(pb_poker_card, Record) ->
    [iolist(pb_poker_card, Record)
     | encode_extensions(Record)];
encode(game_over_settlement, Record) ->
    [iolist(game_over_settlement, Record)
     | encode_extensions(Record)];
encode(pb_settle_info, Record) ->
    [iolist(pb_settle_info, Record)
     | encode_extensions(Record)];
encode(pb_niu_player_info, Record) ->
    [iolist(pb_niu_player_info, Record)
     | encode_extensions(Record)];
encode(sc_redpack_room_reset_times_update, Record) ->
    [iolist(sc_redpack_room_reset_times_update, Record)
     | encode_extensions(Record)];
encode(sc_redpack_room_player_times_update, Record) ->
    [iolist(sc_redpack_room_player_times_update, Record)
     | encode_extensions(Record)];
encode(sc_redpack_room_redpack_notice_update, Record) ->
    [iolist(sc_redpack_room_redpack_notice_update, Record)
     | encode_extensions(Record)];
encode(cs_redpack_room_draw_req, Record) ->
    [iolist(cs_redpack_room_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_redpack_room_draw_reply, Record) ->
    [iolist(sc_redpack_room_draw_reply, Record)
     | encode_extensions(Record)];
encode(sc_redpack_redpack_timer_sec_update, Record) ->
    [iolist(sc_redpack_redpack_timer_sec_update, Record)
     | encode_extensions(Record)];
encode(cs_redpack_relive_req, Record) ->
    [iolist(cs_redpack_relive_req, Record)
     | encode_extensions(Record)];
encode(sc_redpack_relive_reply, Record) ->
    [iolist(sc_redpack_relive_reply, Record)
     | encode_extensions(Record)];
encode(sc_redpack_relive_times, Record) ->
    [iolist(sc_redpack_relive_times, Record)
     | encode_extensions(Record)];
encode(sc_fudai_pool_update, Record) ->
    [iolist(sc_fudai_pool_update, Record)
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
iolist(sc_niu_room_state_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_room_state_update.state_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_room_state_update.end_sec_time,
		       none),
	  uint32, []),
     pack(3, repeated,
	  with_default(Record#sc_niu_room_state_update.open_card_list,
		       none),
	  pb_poker_card, []),
     pack(4, optional,
	  with_default(Record#sc_niu_room_state_update.master_pos,
		       none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#sc_niu_room_state_update.last_card_info,
		       none),
	  pb_poker_card, []),
     pack(6, optional,
	  with_default(Record#sc_niu_room_state_update.settle_list,
		       none),
	  game_over_settlement, [])];
iolist(cs_niu_enter_room_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_enter_room_req.room_type,
		       none),
	  uint32, [])];
iolist(sc_niu_enter_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_enter_room_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_enter_room_reply.my_pos,
		       none),
	  uint32, [])];
iolist(sc_niu_enter_room_player_info_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_niu_enter_room_player_info_update.player_list,
		       none),
	  pb_niu_player_info, [])];
iolist(cs_niu_choose_master_rate_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_choose_master_rate_req.rate_num,
		       none),
	  uint32, [])];
iolist(sc_niu_choose_master_rate_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_choose_master_rate_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_niu_choose_master_rate_reply.err,
		       none),
	  bytes, [])];
iolist(sc_niu_player_choose_master_rate_update,
       Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_player_choose_master_rate_update.pos,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_player_choose_master_rate_update.rate_num,
		       none),
	  uint32, [])];
iolist(cs_niu_choose_free_rate_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_choose_free_rate_req.rate_num,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_niu_choose_free_rate_req.test_type,
		       none),
	  int32, [])];
iolist(sc_niu_choose_free_rate_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_choose_free_rate_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_niu_choose_free_rate_reply.err,
		       none),
	  bytes, [])];
iolist(sc_niu_player_choose_free_rate_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_player_choose_free_rate_update.pos,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_player_choose_free_rate_update.rate_num,
		       none),
	  uint32, [])];
iolist(cs_niu_leave_room_req, _Record) -> [];
iolist(sc_niu_leave_room_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_leave_room_reply.result,
		       none),
	  uint32, [])];
iolist(sc_niu_leave_room_player_pos_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_leave_room_player_pos_update.leave_pos,
		       none),
	  uint32, [])];
iolist(cs_niu_submit_card_req, _Record) -> [];
iolist(sc_niu_submit_card_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_submit_card_reply.result,
		       none),
	  uint32, [])];
iolist(sc_niu_player_submit_card_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_player_submit_card_update.player_pos,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_player_submit_card_update.card_type,
		       none),
	  uint32, []),
     pack(3, repeated,
	  with_default(Record#sc_niu_player_submit_card_update.card_list,
		       none),
	  pb_poker_card, [])];
iolist(cs_niu_syn_in_game_state_req, _Record) -> [];
iolist(cs_niu_query_player_room_info_req, _Record) ->
    [];
iolist(sc_niu_player_room_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_player_room_info_update.room_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_player_room_info_update.enter_end_time,
		       none),
	  uint32, [])];
iolist(sc_niu_player_back_to_room_info_update,
       Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_player_back_to_room_info_update.state_id,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_player_back_to_room_info_update.end_sec_time,
		       none),
	  uint32, []),
     pack(3, repeated,
	  with_default(Record#sc_niu_player_back_to_room_info_update.player_list,
		       none),
	  pb_niu_player_info, []),
     pack(4, optional,
	  with_default(Record#sc_niu_player_back_to_room_info_update.master_pos,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_niu_player_back_to_room_info_update.my_pos,
		       none),
	  uint32, [])];
iolist(pb_poker_card, Record) ->
    [pack(1, required,
	  with_default(Record#pb_poker_card.number, none), uint32,
	  []),
     pack(2, required,
	  with_default(Record#pb_poker_card.color, none), uint32,
	  [])];
iolist(game_over_settlement, Record) ->
    [pack(1, repeated,
	  with_default(Record#game_over_settlement.all_player_settle_info,
		       none),
	  pb_settle_info, [])];
iolist(pb_settle_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_settle_info.player_pos, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_settle_info.reward_num, none),
	  int64, []),
     pack(3, required,
	  with_default(Record#pb_settle_info.card_type, none),
	  uint32, []),
     pack(4, repeated,
	  with_default(Record#pb_settle_info.card_list, none),
	  pb_poker_card, [])];
iolist(pb_niu_player_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_niu_player_info.pos, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_niu_player_info.player_uuid,
		       none),
	  string, []),
     pack(3, required,
	  with_default(Record#pb_niu_player_info.gold_num, none),
	  uint64, []),
     pack(4, required,
	  with_default(Record#pb_niu_player_info.icon_type, none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#pb_niu_player_info.icon_url, none),
	  string, []),
     pack(6, optional,
	  with_default(Record#pb_niu_player_info.player_name,
		       none),
	  bytes, []),
     pack(7, optional,
	  with_default(Record#pb_niu_player_info.master_rate,
		       none),
	  uint32, []),
     pack(8, optional,
	  with_default(Record#pb_niu_player_info.free_rate, none),
	  uint32, []),
     pack(9, repeated,
	  with_default(Record#pb_niu_player_info.open_card_list,
		       none),
	  pb_poker_card, []),
     pack(10, optional,
	  with_default(Record#pb_niu_player_info.card_type, none),
	  uint32, []),
     pack(11, required,
	  with_default(Record#pb_niu_player_info.vip_level, none),
	  uint32, []),
     pack(12, required,
	  with_default(Record#pb_niu_player_info.sex, none),
	  uint32, [])];
iolist(sc_redpack_room_reset_times_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_room_reset_times_update.left_reset_times,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_redpack_room_reset_times_update.reset_seconds,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_redpack_room_reset_times_update.reset_mission_is_draw,
		       none),
	  uint32, [])];
iolist(sc_redpack_room_player_times_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_room_player_times_update.now_play_times,
		       none),
	  uint32, [])];
iolist(sc_redpack_room_redpack_notice_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_room_redpack_notice_update.close_draw_second,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_redpack_room_redpack_notice_update.next_open_redpack_second,
		       none),
	  uint32, [])];
iolist(cs_redpack_room_draw_req, _Record) -> [];
iolist(sc_redpack_room_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_room_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_redpack_room_draw_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_redpack_room_draw_reply.reward,
		       none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_redpack_room_draw_reply.next_can_draw_second,
		       none),
	  uint32, [])];
iolist(sc_redpack_redpack_timer_sec_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_redpack_timer_sec_update.next_can_draw_second,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_redpack_redpack_timer_sec_update.next_open_redpack_second,
		       none),
	  uint32, [])];
iolist(cs_redpack_relive_req, _Record) -> [];
iolist(sc_redpack_relive_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_relive_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_redpack_relive_reply.err, none),
	  bytes, [])];
iolist(sc_redpack_relive_times, Record) ->
    [pack(1, required,
	  with_default(Record#sc_redpack_relive_times.times,
		       none),
	  uint32, [])];
iolist(sc_fudai_pool_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_fudai_pool_update.num, none),
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

decode_sc_fudai_pool_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_fudai_pool_update, Bytes).

decode_sc_redpack_relive_times(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_relive_times, Bytes).

decode_sc_redpack_relive_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_relive_reply, Bytes).

decode_cs_redpack_relive_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_redpack_relive_req, Bytes).

decode_sc_redpack_redpack_timer_sec_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_redpack_timer_sec_update, Bytes).

decode_sc_redpack_room_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_room_draw_reply, Bytes).

decode_cs_redpack_room_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_redpack_room_draw_req, Bytes).

decode_sc_redpack_room_redpack_notice_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_room_redpack_notice_update, Bytes).

decode_sc_redpack_room_player_times_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_room_player_times_update, Bytes).

decode_sc_redpack_room_reset_times_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_redpack_room_reset_times_update, Bytes).

decode_pb_niu_player_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_niu_player_info, Bytes).

decode_pb_settle_info(Bytes) when is_binary(Bytes) ->
    decode(pb_settle_info, Bytes).

decode_game_over_settlement(Bytes)
    when is_binary(Bytes) ->
    decode(game_over_settlement, Bytes).

decode_pb_poker_card(Bytes) when is_binary(Bytes) ->
    decode(pb_poker_card, Bytes).

decode_sc_niu_player_back_to_room_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_player_back_to_room_info_update, Bytes).

decode_sc_niu_player_room_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_player_room_info_update, Bytes).

decode_cs_niu_query_player_room_info_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_query_player_room_info_req, Bytes).

decode_cs_niu_syn_in_game_state_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_syn_in_game_state_req, Bytes).

decode_sc_niu_player_submit_card_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_player_submit_card_update, Bytes).

decode_sc_niu_submit_card_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_submit_card_reply, Bytes).

decode_cs_niu_submit_card_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_submit_card_req, Bytes).

decode_sc_niu_leave_room_player_pos_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_leave_room_player_pos_update, Bytes).

decode_sc_niu_leave_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_leave_room_reply, Bytes).

decode_cs_niu_leave_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_leave_room_req, Bytes).

decode_sc_niu_player_choose_free_rate_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_player_choose_free_rate_update, Bytes).

decode_sc_niu_choose_free_rate_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_choose_free_rate_reply, Bytes).

decode_cs_niu_choose_free_rate_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_choose_free_rate_req, Bytes).

decode_sc_niu_player_choose_master_rate_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_player_choose_master_rate_update, Bytes).

decode_sc_niu_choose_master_rate_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_choose_master_rate_reply, Bytes).

decode_cs_niu_choose_master_rate_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_choose_master_rate_req, Bytes).

decode_sc_niu_enter_room_player_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_enter_room_player_info_update, Bytes).

decode_sc_niu_enter_room_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_enter_room_reply, Bytes).

decode_cs_niu_enter_room_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_enter_room_req, Bytes).

decode_sc_niu_room_state_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_room_state_update, Bytes).

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
decode(sc_niu_room_state_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, settle_list, game_over_settlement,
	      [is_record]},
	     {5, last_card_info, pb_poker_card, [is_record]},
	     {4, master_pos, uint32, []},
	     {3, open_card_list, pb_poker_card,
	      [is_record, repeated]},
	     {2, end_sec_time, uint32, []},
	     {1, state_id, uint32, []}],
    Defaults = [{3, open_card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_room_state_update, Decoded);
decode(cs_niu_enter_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, room_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_enter_room_req, Decoded);
decode(sc_niu_enter_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, my_pos, uint32, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_enter_room_reply, Decoded);
decode(sc_niu_enter_room_player_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, player_list, pb_niu_player_info,
	      [is_record, repeated]}],
    Defaults = [{1, player_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_enter_room_player_info_update,
	      Decoded);
decode(cs_niu_choose_master_rate_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, rate_num, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_choose_master_rate_req, Decoded);
decode(sc_niu_choose_master_rate_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_choose_master_rate_reply, Decoded);
decode(sc_niu_player_choose_master_rate_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, rate_num, uint32, []},
	     {1, pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_player_choose_master_rate_update,
	      Decoded);
decode(cs_niu_choose_free_rate_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, test_type, int32, []},
	     {1, rate_num, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_choose_free_rate_req, Decoded);
decode(sc_niu_choose_free_rate_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_choose_free_rate_reply, Decoded);
decode(sc_niu_player_choose_free_rate_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, rate_num, uint32, []},
	     {1, pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_player_choose_free_rate_update,
	      Decoded);
decode(cs_niu_leave_room_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_leave_room_req, Decoded);
decode(sc_niu_leave_room_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_leave_room_reply, Decoded);
decode(sc_niu_leave_room_player_pos_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, leave_pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_leave_room_player_pos_update, Decoded);
decode(cs_niu_submit_card_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_submit_card_req, Decoded);
decode(sc_niu_submit_card_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_submit_card_reply, Decoded);
decode(sc_niu_player_submit_card_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, card_list, pb_poker_card,
	      [is_record, repeated]},
	     {2, card_type, uint32, []},
	     {1, player_pos, uint32, []}],
    Defaults = [{3, card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_player_submit_card_update, Decoded);
decode(cs_niu_syn_in_game_state_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_syn_in_game_state_req, Decoded);
decode(cs_niu_query_player_room_info_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_query_player_room_info_req, Decoded);
decode(sc_niu_player_room_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, enter_end_time, uint32, []},
	     {1, room_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_player_room_info_update, Decoded);
decode(sc_niu_player_back_to_room_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, my_pos, uint32, []},
	     {4, master_pos, uint32, []},
	     {3, player_list, pb_niu_player_info,
	      [is_record, repeated]},
	     {2, end_sec_time, uint32, []},
	     {1, state_id, uint32, []}],
    Defaults = [{3, player_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_player_back_to_room_info_update,
	      Decoded);
decode(pb_poker_card, Bytes) when is_binary(Bytes) ->
    Types = [{2, color, uint32, []},
	     {1, number, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_poker_card, Decoded);
decode(game_over_settlement, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, all_player_settle_info, pb_settle_info,
	      [is_record, repeated]}],
    Defaults = [{1, all_player_settle_info, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(game_over_settlement, Decoded);
decode(pb_settle_info, Bytes) when is_binary(Bytes) ->
    Types = [{4, card_list, pb_poker_card,
	      [is_record, repeated]},
	     {3, card_type, uint32, []}, {2, reward_num, int64, []},
	     {1, player_pos, uint32, []}],
    Defaults = [{4, card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_settle_info, Decoded);
decode(pb_niu_player_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{12, sex, uint32, []},
	     {11, vip_level, uint32, []},
	     {10, card_type, uint32, []},
	     {9, open_card_list, pb_poker_card,
	      [is_record, repeated]},
	     {8, free_rate, uint32, []},
	     {7, master_rate, uint32, []},
	     {6, player_name, bytes, []}, {5, icon_url, string, []},
	     {4, icon_type, uint32, []}, {3, gold_num, uint64, []},
	     {2, player_uuid, string, []}, {1, pos, uint32, []}],
    Defaults = [{9, open_card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_niu_player_info, Decoded);
decode(sc_redpack_room_reset_times_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reset_mission_is_draw, uint32, []},
	     {2, reset_seconds, uint32, []},
	     {1, left_reset_times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_room_reset_times_update, Decoded);
decode(sc_redpack_room_player_times_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, now_play_times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_room_player_times_update, Decoded);
decode(sc_redpack_room_redpack_notice_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, next_open_redpack_second, uint32, []},
	     {1, close_draw_second, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_room_redpack_notice_update,
	      Decoded);
decode(cs_redpack_room_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_redpack_room_draw_req, Decoded);
decode(sc_redpack_room_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, next_can_draw_second, uint32, []},
	     {3, reward, pb_reward_info, [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_room_draw_reply, Decoded);
decode(sc_redpack_redpack_timer_sec_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, next_open_redpack_second, uint32, []},
	     {1, next_can_draw_second, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_redpack_timer_sec_update, Decoded);
decode(cs_redpack_relive_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_redpack_relive_req, Decoded);
decode(sc_redpack_relive_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_relive_reply, Decoded);
decode(sc_redpack_relive_times, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_redpack_relive_times, Decoded);
decode(sc_fudai_pool_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, num, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_fudai_pool_update, Decoded).

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
to_record(sc_niu_room_state_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_room_state_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_room_state_update{}, DecodedTuples),
    Record1;
to_record(cs_niu_enter_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_enter_room_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_enter_room_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_enter_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_enter_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_enter_room_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_enter_room_player_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_enter_room_player_info_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_enter_room_player_info_update{},
			  DecodedTuples),
    Record1;
to_record(cs_niu_choose_master_rate_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_choose_master_rate_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_choose_master_rate_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_choose_master_rate_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_choose_master_rate_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_choose_master_rate_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_player_choose_master_rate_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_player_choose_master_rate_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_player_choose_master_rate_update{},
			  DecodedTuples),
    Record1;
to_record(cs_niu_choose_free_rate_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_choose_free_rate_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_choose_free_rate_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_choose_free_rate_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_choose_free_rate_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_choose_free_rate_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_player_choose_free_rate_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_player_choose_free_rate_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_player_choose_free_rate_update{},
			  DecodedTuples),
    Record1;
to_record(cs_niu_leave_room_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_leave_room_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_leave_room_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_leave_room_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_leave_room_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_leave_room_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_leave_room_player_pos_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_leave_room_player_pos_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_leave_room_player_pos_update{},
			  DecodedTuples),
    Record1;
to_record(cs_niu_submit_card_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_submit_card_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_submit_card_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_submit_card_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_submit_card_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_submit_card_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_player_submit_card_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_player_submit_card_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_player_submit_card_update{}, DecodedTuples),
    Record1;
to_record(cs_niu_syn_in_game_state_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_syn_in_game_state_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_syn_in_game_state_req{}, DecodedTuples),
    Record1;
to_record(cs_niu_query_player_room_info_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_query_player_room_info_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_query_player_room_info_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_player_room_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_player_room_info_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_player_room_info_update{}, DecodedTuples),
    Record1;
to_record(sc_niu_player_back_to_room_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_player_back_to_room_info_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_player_back_to_room_info_update{},
			  DecodedTuples),
    Record1;
to_record(pb_poker_card, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_poker_card),
						   Record, Name, Val)
			  end,
			  #pb_poker_card{}, DecodedTuples),
    Record1;
to_record(game_over_settlement, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       game_over_settlement),
						   Record, Name, Val)
			  end,
			  #game_over_settlement{}, DecodedTuples),
    Record1;
to_record(pb_settle_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_settle_info),
						   Record, Name, Val)
			  end,
			  #pb_settle_info{}, DecodedTuples),
    Record1;
to_record(pb_niu_player_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_niu_player_info),
						   Record, Name, Val)
			  end,
			  #pb_niu_player_info{}, DecodedTuples),
    Record1;
to_record(sc_redpack_room_reset_times_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_room_reset_times_update),
						   Record, Name, Val)
			  end,
			  #sc_redpack_room_reset_times_update{}, DecodedTuples),
    Record1;
to_record(sc_redpack_room_player_times_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_room_player_times_update),
						   Record, Name, Val)
			  end,
			  #sc_redpack_room_player_times_update{},
			  DecodedTuples),
    Record1;
to_record(sc_redpack_room_redpack_notice_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_room_redpack_notice_update),
						   Record, Name, Val)
			  end,
			  #sc_redpack_room_redpack_notice_update{},
			  DecodedTuples),
    Record1;
to_record(cs_redpack_room_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_redpack_room_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_redpack_room_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_redpack_room_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_room_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_redpack_room_draw_reply{}, DecodedTuples),
    Record1;
to_record(sc_redpack_redpack_timer_sec_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_redpack_timer_sec_update),
						   Record, Name, Val)
			  end,
			  #sc_redpack_redpack_timer_sec_update{},
			  DecodedTuples),
    Record1;
to_record(cs_redpack_relive_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_redpack_relive_req),
						   Record, Name, Val)
			  end,
			  #cs_redpack_relive_req{}, DecodedTuples),
    Record1;
to_record(sc_redpack_relive_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_relive_reply),
						   Record, Name, Val)
			  end,
			  #sc_redpack_relive_reply{}, DecodedTuples),
    Record1;
to_record(sc_redpack_relive_times, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_redpack_relive_times),
						   Record, Name, Val)
			  end,
			  #sc_redpack_relive_times{}, DecodedTuples),
    Record1;
to_record(sc_fudai_pool_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_fudai_pool_update),
						   Record, Name, Val)
			  end,
			  #sc_fudai_pool_update{}, DecodedTuples),
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

