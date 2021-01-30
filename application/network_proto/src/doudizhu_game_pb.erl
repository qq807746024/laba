-file("src/doudizhu_game_pb.erl", 1).

-module(doudizhu_game_pb).

-export([encode_pb_doudizhu_player_info/1,
	 decode_pb_doudizhu_player_info/1,
	 encode_pb_special_card/1, decode_pb_special_card/1,
	 encode_pb_doudizhu_settlement/1,
	 decode_pb_doudizhu_settlement/1, encode_pb_auto_list/1,
	 decode_pb_auto_list/1,
	 encode_pb_doudizhu_hand_num_list/1,
	 decode_pb_doudizhu_hand_num_list/1,
	 encode_pb_doudizhu_calc_card/1,
	 decode_pb_doudizhu_calc_card/1,
	 encode_pb_doudizhu_calc_card_list/1,
	 decode_pb_doudizhu_calc_card_list/1,
	 encode_pb_doudizhu_card/1, decode_pb_doudizhu_card/1,
	 encode_pb_doudizhu_card_list/1,
	 decode_pb_doudizhu_card_list/1,
	 encode_pb_doudizhu_last_cards_list/1,
	 decode_pb_doudizhu_last_cards_list/1,
	 encode_sc_doudizhu_query_gaming_reply/1,
	 decode_sc_doudizhu_query_gaming_reply/1,
	 encode_cs_doudizhu_query_gaming_req/1,
	 decode_cs_doudizhu_query_gaming_req/1,
	 encode_sc_doudizhu_play_card_update/1,
	 decode_sc_doudizhu_play_card_update/1,
	 encode_sc_doudizhu_play_card_reply/1,
	 decode_sc_doudizhu_play_card_reply/1,
	 encode_cs_doudizhu_play_card_req/1,
	 decode_cs_doudizhu_play_card_req/1,
	 encode_sc_doudizhu_leave_update/1,
	 decode_sc_doudizhu_leave_update/1,
	 encode_sc_doudizhu_leave_reply/1,
	 decode_sc_doudizhu_leave_reply/1,
	 encode_cs_doudizhu_leave_req/1,
	 decode_cs_doudizhu_leave_req/1,
	 encode_sc_doudizhu_bet_update/1,
	 decode_sc_doudizhu_bet_update/1,
	 encode_sc_doudizhu_bet_reply/1,
	 decode_sc_doudizhu_bet_reply/1,
	 encode_cs_doudizhu_bet_req/1,
	 decode_cs_doudizhu_bet_req/1,
	 encode_sc_doudizhu_player_update/1,
	 decode_sc_doudizhu_player_update/1,
	 encode_sc_doudizhu_enter_reply/1,
	 decode_sc_doudizhu_enter_reply/1,
	 encode_cs_doudizhu_enter_req/1,
	 decode_cs_doudizhu_enter_req/1,
	 encode_sc_doudizhu_room_state_update/1,
	 decode_sc_doudizhu_room_state_update/1,
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

-record(pb_doudizhu_player_info,
	{pos, player_uuid, gold_num, icon_type, icon_url,
	 player_name, vip_level, sex}).

-record(pb_special_card, {type, multiples}).

-record(pb_doudizhu_settlement,
	{special, basescore, multiples, identity, reward}).

-record(pb_auto_list, {auto}).

-record(pb_doudizhu_hand_num_list, {number}).

-record(pb_doudizhu_calc_card, {number, remaind}).

-record(pb_doudizhu_calc_card_list, {cards}).

-record(pb_doudizhu_card, {number, color}).

-record(pb_doudizhu_card_list, {cards}).

-record(pb_doudizhu_last_cards_list, {}).

-record(sc_doudizhu_query_gaming_reply, {level}).

-record(cs_doudizhu_query_gaming_req, {}).

-record(sc_doudizhu_play_card_update, {pos, card_list}).

-record(sc_doudizhu_play_card_reply, {result}).

-record(cs_doudizhu_play_card_req, {card_list}).

-record(sc_doudizhu_leave_update, {pos}).

-record(sc_doudizhu_leave_reply, {result}).

-record(cs_doudizhu_leave_req, {}).

-record(sc_doudizhu_bet_update, {pos, rate}).

-record(sc_doudizhu_bet_reply, {result, err}).

-record(cs_doudizhu_bet_req, {rate}).

-record(sc_doudizhu_player_update, {player_list}).

-record(sc_doudizhu_enter_reply, {result, my_pos}).

-record(cs_doudizhu_enter_req, {level}).

-record(sc_doudizhu_room_state_update,
	{state_id, auto_list, basescore, multiples,
	 my_card_list, hand_num_list, remain_card_list,
	 calc_card_list, dizhu_pos, settlement,
	 last_cards_list}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_pb_doudizhu_player_info(Record)
    when is_record(Record, pb_doudizhu_player_info) ->
    encode(pb_doudizhu_player_info, Record).

encode_pb_special_card(Record)
    when is_record(Record, pb_special_card) ->
    encode(pb_special_card, Record).

encode_pb_doudizhu_settlement(Record)
    when is_record(Record, pb_doudizhu_settlement) ->
    encode(pb_doudizhu_settlement, Record).

encode_pb_auto_list(Record)
    when is_record(Record, pb_auto_list) ->
    encode(pb_auto_list, Record).

encode_pb_doudizhu_hand_num_list(Record)
    when is_record(Record, pb_doudizhu_hand_num_list) ->
    encode(pb_doudizhu_hand_num_list, Record).

encode_pb_doudizhu_calc_card(Record)
    when is_record(Record, pb_doudizhu_calc_card) ->
    encode(pb_doudizhu_calc_card, Record).

encode_pb_doudizhu_calc_card_list(Record)
    when is_record(Record, pb_doudizhu_calc_card_list) ->
    encode(pb_doudizhu_calc_card_list, Record).

encode_pb_doudizhu_card(Record)
    when is_record(Record, pb_doudizhu_card) ->
    encode(pb_doudizhu_card, Record).

encode_pb_doudizhu_card_list(Record)
    when is_record(Record, pb_doudizhu_card_list) ->
    encode(pb_doudizhu_card_list, Record).

encode_pb_doudizhu_last_cards_list(Record)
    when is_record(Record, pb_doudizhu_last_cards_list) ->
    encode(pb_doudizhu_last_cards_list, Record).

encode_sc_doudizhu_query_gaming_reply(Record)
    when is_record(Record,
		   sc_doudizhu_query_gaming_reply) ->
    encode(sc_doudizhu_query_gaming_reply, Record).

encode_cs_doudizhu_query_gaming_req(Record)
    when is_record(Record, cs_doudizhu_query_gaming_req) ->
    encode(cs_doudizhu_query_gaming_req, Record).

encode_sc_doudizhu_play_card_update(Record)
    when is_record(Record, sc_doudizhu_play_card_update) ->
    encode(sc_doudizhu_play_card_update, Record).

encode_sc_doudizhu_play_card_reply(Record)
    when is_record(Record, sc_doudizhu_play_card_reply) ->
    encode(sc_doudizhu_play_card_reply, Record).

encode_cs_doudizhu_play_card_req(Record)
    when is_record(Record, cs_doudizhu_play_card_req) ->
    encode(cs_doudizhu_play_card_req, Record).

encode_sc_doudizhu_leave_update(Record)
    when is_record(Record, sc_doudizhu_leave_update) ->
    encode(sc_doudizhu_leave_update, Record).

encode_sc_doudizhu_leave_reply(Record)
    when is_record(Record, sc_doudizhu_leave_reply) ->
    encode(sc_doudizhu_leave_reply, Record).

encode_cs_doudizhu_leave_req(Record)
    when is_record(Record, cs_doudizhu_leave_req) ->
    encode(cs_doudizhu_leave_req, Record).

encode_sc_doudizhu_bet_update(Record)
    when is_record(Record, sc_doudizhu_bet_update) ->
    encode(sc_doudizhu_bet_update, Record).

encode_sc_doudizhu_bet_reply(Record)
    when is_record(Record, sc_doudizhu_bet_reply) ->
    encode(sc_doudizhu_bet_reply, Record).

encode_cs_doudizhu_bet_req(Record)
    when is_record(Record, cs_doudizhu_bet_req) ->
    encode(cs_doudizhu_bet_req, Record).

encode_sc_doudizhu_player_update(Record)
    when is_record(Record, sc_doudizhu_player_update) ->
    encode(sc_doudizhu_player_update, Record).

encode_sc_doudizhu_enter_reply(Record)
    when is_record(Record, sc_doudizhu_enter_reply) ->
    encode(sc_doudizhu_enter_reply, Record).

encode_cs_doudizhu_enter_req(Record)
    when is_record(Record, cs_doudizhu_enter_req) ->
    encode(cs_doudizhu_enter_req, Record).

encode_sc_doudizhu_room_state_update(Record)
    when is_record(Record, sc_doudizhu_room_state_update) ->
    encode(sc_doudizhu_room_state_update, Record).

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
encode(sc_doudizhu_room_state_update, Record) ->
    [iolist(sc_doudizhu_room_state_update, Record)
     | encode_extensions(Record)];
encode(cs_doudizhu_enter_req, Record) ->
    [iolist(cs_doudizhu_enter_req, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_enter_reply, Record) ->
    [iolist(sc_doudizhu_enter_reply, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_player_update, Record) ->
    [iolist(sc_doudizhu_player_update, Record)
     | encode_extensions(Record)];
encode(cs_doudizhu_bet_req, Record) ->
    [iolist(cs_doudizhu_bet_req, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_bet_reply, Record) ->
    [iolist(sc_doudizhu_bet_reply, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_bet_update, Record) ->
    [iolist(sc_doudizhu_bet_update, Record)
     | encode_extensions(Record)];
encode(cs_doudizhu_leave_req, Record) ->
    [iolist(cs_doudizhu_leave_req, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_leave_reply, Record) ->
    [iolist(sc_doudizhu_leave_reply, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_leave_update, Record) ->
    [iolist(sc_doudizhu_leave_update, Record)
     | encode_extensions(Record)];
encode(cs_doudizhu_play_card_req, Record) ->
    [iolist(cs_doudizhu_play_card_req, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_play_card_reply, Record) ->
    [iolist(sc_doudizhu_play_card_reply, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_play_card_update, Record) ->
    [iolist(sc_doudizhu_play_card_update, Record)
     | encode_extensions(Record)];
encode(cs_doudizhu_query_gaming_req, Record) ->
    [iolist(cs_doudizhu_query_gaming_req, Record)
     | encode_extensions(Record)];
encode(sc_doudizhu_query_gaming_reply, Record) ->
    [iolist(sc_doudizhu_query_gaming_reply, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_last_cards_list, Record) ->
    [iolist(pb_doudizhu_last_cards_list, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_card_list, Record) ->
    [iolist(pb_doudizhu_card_list, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_card, Record) ->
    [iolist(pb_doudizhu_card, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_calc_card_list, Record) ->
    [iolist(pb_doudizhu_calc_card_list, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_calc_card, Record) ->
    [iolist(pb_doudizhu_calc_card, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_hand_num_list, Record) ->
    [iolist(pb_doudizhu_hand_num_list, Record)
     | encode_extensions(Record)];
encode(pb_auto_list, Record) ->
    [iolist(pb_auto_list, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_settlement, Record) ->
    [iolist(pb_doudizhu_settlement, Record)
     | encode_extensions(Record)];
encode(pb_special_card, Record) ->
    [iolist(pb_special_card, Record)
     | encode_extensions(Record)];
encode(pb_doudizhu_player_info, Record) ->
    [iolist(pb_doudizhu_player_info, Record)
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
iolist(sc_doudizhu_room_state_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_room_state_update.state_id,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_doudizhu_room_state_update.auto_list,
		       none),
	  pb_auto_list, []),
     pack(3, optional,
	  with_default(Record#sc_doudizhu_room_state_update.basescore,
		       none),
	  uint32, []),
     pack(4, optional,
	  with_default(Record#sc_doudizhu_room_state_update.multiples,
		       none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#sc_doudizhu_room_state_update.my_card_list,
		       none),
	  pb_doudizhu_card_list, []),
     pack(6, optional,
	  with_default(Record#sc_doudizhu_room_state_update.hand_num_list,
		       none),
	  pb_doudizhu_hand_num_list, []),
     pack(7, optional,
	  with_default(Record#sc_doudizhu_room_state_update.remain_card_list,
		       none),
	  pb_doudizhu_card_list, []),
     pack(8, optional,
	  with_default(Record#sc_doudizhu_room_state_update.calc_card_list,
		       none),
	  pb_doudizhu_calc_card_list, []),
     pack(9, optional,
	  with_default(Record#sc_doudizhu_room_state_update.dizhu_pos,
		       none),
	  uint32, []),
     pack(10, optional,
	  with_default(Record#sc_doudizhu_room_state_update.settlement,
		       none),
	  pb_doudizhu_settlement, []),
     pack(11, optional,
	  with_default(Record#sc_doudizhu_room_state_update.last_cards_list,
		       none),
	  pb_doudizhu_last_cards_list, [])];
iolist(cs_doudizhu_enter_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_doudizhu_enter_req.level, none),
	  uint32, [])];
iolist(sc_doudizhu_enter_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_enter_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_doudizhu_enter_reply.my_pos,
		       none),
	  uint32, [])];
iolist(sc_doudizhu_player_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_doudizhu_player_update.player_list,
		       none),
	  pb_doudizhu_player_info, [])];
iolist(cs_doudizhu_bet_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_doudizhu_bet_req.rate, none),
	  uint32, [])];
iolist(sc_doudizhu_bet_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_bet_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_doudizhu_bet_reply.err, none),
	  bytes, [])];
iolist(sc_doudizhu_bet_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_bet_update.pos, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_doudizhu_bet_update.rate, none),
	  uint32, [])];
iolist(cs_doudizhu_leave_req, _Record) -> [];
iolist(sc_doudizhu_leave_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_leave_reply.result,
		       none),
	  uint32, [])];
iolist(sc_doudizhu_leave_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_leave_update.pos, none),
	  uint32, [])];
iolist(cs_doudizhu_play_card_req, Record) ->
    [pack(1, repeated,
	  with_default(Record#cs_doudizhu_play_card_req.card_list,
		       none),
	  pb_doudizhu_card_list, [])];
iolist(sc_doudizhu_play_card_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_play_card_reply.result,
		       none),
	  uint32, [])];
iolist(sc_doudizhu_play_card_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_play_card_update.pos,
		       none),
	  uint32, []),
     pack(2, repeated,
	  with_default(Record#sc_doudizhu_play_card_update.card_list,
		       none),
	  pb_doudizhu_card_list, [])];
iolist(cs_doudizhu_query_gaming_req, _Record) -> [];
iolist(sc_doudizhu_query_gaming_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_doudizhu_query_gaming_reply.level,
		       none),
	  uint32, [])];
iolist(pb_doudizhu_last_cards_list, _Record) -> [];
iolist(pb_doudizhu_card_list, Record) ->
    [pack(1, repeated,
	  with_default(Record#pb_doudizhu_card_list.cards, none),
	  pb_doudizhu_card, [])];
iolist(pb_doudizhu_card, Record) ->
    [pack(1, required,
	  with_default(Record#pb_doudizhu_card.number, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_doudizhu_card.color, none),
	  uint32, [])];
iolist(pb_doudizhu_calc_card_list, Record) ->
    [pack(1, repeated,
	  with_default(Record#pb_doudizhu_calc_card_list.cards,
		       none),
	  pb_doudizhu_calc_card, [])];
iolist(pb_doudizhu_calc_card, Record) ->
    [pack(1, required,
	  with_default(Record#pb_doudizhu_calc_card.number, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_doudizhu_calc_card.remaind,
		       none),
	  uint32, [])];
iolist(pb_doudizhu_hand_num_list, Record) ->
    [pack(1, repeated,
	  with_default(Record#pb_doudizhu_hand_num_list.number,
		       none),
	  uint32, [])];
iolist(pb_auto_list, Record) ->
    [pack(1, repeated,
	  with_default(Record#pb_auto_list.auto, none), bool,
	  [])];
iolist(pb_doudizhu_settlement, Record) ->
    [pack(1, repeated,
	  with_default(Record#pb_doudizhu_settlement.special,
		       none),
	  pb_special_card, []),
     pack(2, required,
	  with_default(Record#pb_doudizhu_settlement.basescore,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#pb_doudizhu_settlement.multiples,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_doudizhu_settlement.identity,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#pb_doudizhu_settlement.reward,
		       none),
	  uint32, [])];
iolist(pb_special_card, Record) ->
    [pack(1, required,
	  with_default(Record#pb_special_card.type, none), uint32,
	  []),
     pack(2, required,
	  with_default(Record#pb_special_card.multiples, none),
	  uint32, [])];
iolist(pb_doudizhu_player_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_doudizhu_player_info.pos, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_doudizhu_player_info.player_uuid,
		       none),
	  string, []),
     pack(3, required,
	  with_default(Record#pb_doudizhu_player_info.gold_num,
		       none),
	  uint64, []),
     pack(4, required,
	  with_default(Record#pb_doudizhu_player_info.icon_type,
		       none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#pb_doudizhu_player_info.icon_url,
		       none),
	  string, []),
     pack(6, optional,
	  with_default(Record#pb_doudizhu_player_info.player_name,
		       none),
	  bytes, []),
     pack(7, required,
	  with_default(Record#pb_doudizhu_player_info.vip_level,
		       none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#pb_doudizhu_player_info.sex, none),
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

decode_pb_doudizhu_player_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_player_info, Bytes).

decode_pb_special_card(Bytes) when is_binary(Bytes) ->
    decode(pb_special_card, Bytes).

decode_pb_doudizhu_settlement(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_settlement, Bytes).

decode_pb_auto_list(Bytes) when is_binary(Bytes) ->
    decode(pb_auto_list, Bytes).

decode_pb_doudizhu_hand_num_list(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_hand_num_list, Bytes).

decode_pb_doudizhu_calc_card(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_calc_card, Bytes).

decode_pb_doudizhu_calc_card_list(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_calc_card_list, Bytes).

decode_pb_doudizhu_card(Bytes) when is_binary(Bytes) ->
    decode(pb_doudizhu_card, Bytes).

decode_pb_doudizhu_card_list(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_card_list, Bytes).

decode_pb_doudizhu_last_cards_list(Bytes)
    when is_binary(Bytes) ->
    decode(pb_doudizhu_last_cards_list, Bytes).

decode_sc_doudizhu_query_gaming_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_query_gaming_reply, Bytes).

decode_cs_doudizhu_query_gaming_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_doudizhu_query_gaming_req, Bytes).

decode_sc_doudizhu_play_card_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_play_card_update, Bytes).

decode_sc_doudizhu_play_card_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_play_card_reply, Bytes).

decode_cs_doudizhu_play_card_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_doudizhu_play_card_req, Bytes).

decode_sc_doudizhu_leave_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_leave_update, Bytes).

decode_sc_doudizhu_leave_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_leave_reply, Bytes).

decode_cs_doudizhu_leave_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_doudizhu_leave_req, Bytes).

decode_sc_doudizhu_bet_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_bet_update, Bytes).

decode_sc_doudizhu_bet_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_bet_reply, Bytes).

decode_cs_doudizhu_bet_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_doudizhu_bet_req, Bytes).

decode_sc_doudizhu_player_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_player_update, Bytes).

decode_sc_doudizhu_enter_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_enter_reply, Bytes).

decode_cs_doudizhu_enter_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_doudizhu_enter_req, Bytes).

decode_sc_doudizhu_room_state_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_doudizhu_room_state_update, Bytes).

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
decode(sc_doudizhu_room_state_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{11, last_cards_list,
	      pb_doudizhu_last_cards_list, [is_record]},
	     {10, settlement, pb_doudizhu_settlement, [is_record]},
	     {9, dizhu_pos, uint32, []},
	     {8, calc_card_list, pb_doudizhu_calc_card_list,
	      [is_record]},
	     {7, remain_card_list, pb_doudizhu_card_list,
	      [is_record]},
	     {6, hand_num_list, pb_doudizhu_hand_num_list,
	      [is_record]},
	     {5, my_card_list, pb_doudizhu_card_list, [is_record]},
	     {4, multiples, uint32, []}, {3, basescore, uint32, []},
	     {2, auto_list, pb_auto_list, [is_record]},
	     {1, state_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_room_state_update, Decoded);
decode(cs_doudizhu_enter_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, level, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_doudizhu_enter_req, Decoded);
decode(sc_doudizhu_enter_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, my_pos, uint32, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_enter_reply, Decoded);
decode(sc_doudizhu_player_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, player_list, pb_doudizhu_player_info,
	      [is_record, repeated]}],
    Defaults = [{1, player_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_player_update, Decoded);
decode(cs_doudizhu_bet_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, rate, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_doudizhu_bet_req, Decoded);
decode(sc_doudizhu_bet_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_bet_reply, Decoded);
decode(sc_doudizhu_bet_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, rate, uint32, []}, {1, pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_bet_update, Decoded);
decode(cs_doudizhu_leave_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_doudizhu_leave_req, Decoded);
decode(sc_doudizhu_leave_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_leave_reply, Decoded);
decode(sc_doudizhu_leave_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_leave_update, Decoded);
decode(cs_doudizhu_play_card_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, card_list, pb_doudizhu_card_list,
	      [is_record, repeated]}],
    Defaults = [{1, card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_doudizhu_play_card_req, Decoded);
decode(sc_doudizhu_play_card_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_play_card_reply, Decoded);
decode(sc_doudizhu_play_card_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, card_list, pb_doudizhu_card_list,
	      [is_record, repeated]},
	     {1, pos, uint32, []}],
    Defaults = [{2, card_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_play_card_update, Decoded);
decode(cs_doudizhu_query_gaming_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_doudizhu_query_gaming_req, Decoded);
decode(sc_doudizhu_query_gaming_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, level, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_doudizhu_query_gaming_reply, Decoded);
decode(pb_doudizhu_last_cards_list, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_last_cards_list, Decoded);
decode(pb_doudizhu_card_list, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, cards, pb_doudizhu_card,
	      [is_record, repeated]}],
    Defaults = [{1, cards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_card_list, Decoded);
decode(pb_doudizhu_card, Bytes) when is_binary(Bytes) ->
    Types = [{2, color, uint32, []},
	     {1, number, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_card, Decoded);
decode(pb_doudizhu_calc_card_list, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, cards, pb_doudizhu_calc_card,
	      [is_record, repeated]}],
    Defaults = [{1, cards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_calc_card_list, Decoded);
decode(pb_doudizhu_calc_card, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, remaind, uint32, []},
	     {1, number, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_calc_card, Decoded);
decode(pb_doudizhu_hand_num_list, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, number, uint32, [repeated]}],
    Defaults = [{1, number, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_hand_num_list, Decoded);
decode(pb_auto_list, Bytes) when is_binary(Bytes) ->
    Types = [{1, auto, bool, [repeated]}],
    Defaults = [{1, auto, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_auto_list, Decoded);
decode(pb_doudizhu_settlement, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, reward, uint32, []},
	     {4, identity, uint32, []}, {3, multiples, uint32, []},
	     {2, basescore, uint32, []},
	     {1, special, pb_special_card, [is_record, repeated]}],
    Defaults = [{1, special, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_settlement, Decoded);
decode(pb_special_card, Bytes) when is_binary(Bytes) ->
    Types = [{2, multiples, uint32, []},
	     {1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_special_card, Decoded);
decode(pb_doudizhu_player_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{8, sex, uint32, []},
	     {7, vip_level, uint32, []}, {6, player_name, bytes, []},
	     {5, icon_url, string, []}, {4, icon_type, uint32, []},
	     {3, gold_num, uint64, []}, {2, player_uuid, string, []},
	     {1, pos, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_doudizhu_player_info, Decoded).

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
to_record(sc_doudizhu_room_state_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_room_state_update),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_room_state_update{}, DecodedTuples),
    Record1;
to_record(cs_doudizhu_enter_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_doudizhu_enter_req),
						   Record, Name, Val)
			  end,
			  #cs_doudizhu_enter_req{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_enter_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_enter_reply),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_enter_reply{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_player_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_player_update),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_player_update{}, DecodedTuples),
    Record1;
to_record(cs_doudizhu_bet_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_doudizhu_bet_req),
						   Record, Name, Val)
			  end,
			  #cs_doudizhu_bet_req{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_bet_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_bet_reply),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_bet_reply{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_bet_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_bet_update),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_bet_update{}, DecodedTuples),
    Record1;
to_record(cs_doudizhu_leave_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_doudizhu_leave_req),
						   Record, Name, Val)
			  end,
			  #cs_doudizhu_leave_req{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_leave_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_leave_reply),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_leave_reply{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_leave_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_leave_update),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_leave_update{}, DecodedTuples),
    Record1;
to_record(cs_doudizhu_play_card_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_doudizhu_play_card_req),
						   Record, Name, Val)
			  end,
			  #cs_doudizhu_play_card_req{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_play_card_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_play_card_reply),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_play_card_reply{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_play_card_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_play_card_update),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_play_card_update{}, DecodedTuples),
    Record1;
to_record(cs_doudizhu_query_gaming_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_doudizhu_query_gaming_req),
						   Record, Name, Val)
			  end,
			  #cs_doudizhu_query_gaming_req{}, DecodedTuples),
    Record1;
to_record(sc_doudizhu_query_gaming_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_doudizhu_query_gaming_reply),
						   Record, Name, Val)
			  end,
			  #sc_doudizhu_query_gaming_reply{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_last_cards_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_last_cards_list),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_last_cards_list{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_card_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_card_list),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_card_list{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_card, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_card),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_card{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_calc_card_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_calc_card_list),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_calc_card_list{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_calc_card, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_calc_card),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_calc_card{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_hand_num_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_hand_num_list),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_hand_num_list{}, DecodedTuples),
    Record1;
to_record(pb_auto_list, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_auto_list),
						   Record, Name, Val)
			  end,
			  #pb_auto_list{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_settlement, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_settlement),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_settlement{}, DecodedTuples),
    Record1;
to_record(pb_special_card, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_special_card),
						   Record, Name, Val)
			  end,
			  #pb_special_card{}, DecodedTuples),
    Record1;
to_record(pb_doudizhu_player_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_doudizhu_player_info),
						   Record, Name, Val)
			  end,
			  #pb_doudizhu_player_info{}, DecodedTuples),
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

