-file("src/share_pb.erl", 1).

-module(share_pb).

-export([encode_cs_share_with_friends_req/1,
	 decode_cs_share_with_friends_req/1,
	 encode_sc_task_seven_award_response/1,
	 decode_sc_task_seven_award_response/1,
	 encode_cs_task_seven_award_request/1,
	 decode_cs_task_seven_award_request/1,
	 encode_sc_task_seven_info_response/1,
	 decode_sc_task_seven_info_response/1,
	 encode_sc_draw_count_response/1,
	 decode_sc_draw_count_response/1,
	 encode_sc_share_rank_response/1,
	 decode_sc_share_rank_response/1,
	 encode_pb_share_rank_item_response/1,
	 decode_pb_share_rank_item_response/1,
	 encode_sc_share_history_response/1,
	 decode_sc_share_history_response/1,
	 encode_pb_share_history_friend_item_response/1,
	 decode_pb_share_history_friend_item_response/1,
	 encode_pb_share_history_item_response/1,
	 decode_pb_share_history_item_response/1,
	 encode_sc_share_draw_response/1,
	 decode_sc_share_draw_response/1,
	 encode_cs_share_rank_request/1,
	 decode_cs_share_rank_request/1,
	 encode_cs_share_friend_request/1,
	 decode_cs_share_friend_request/1,
	 encode_cs_share_draw_request/1,
	 decode_cs_share_draw_request/1,
	 encode_sc_share_mission_update/1,
	 decode_sc_share_mission_update/1,
	 encode_sc_share_info/1, decode_sc_share_info/1,
	 encode_pb_share_mission/1, decode_pb_share_mission/1,
	 encode_sc_share_mission_reward_reply/1,
	 decode_sc_share_mission_reward_reply/1,
	 encode_cs_share_mission_reward_req/1,
	 decode_cs_share_mission_reward_req/1,
	 encode_sc_share_new_bee_reward_reply/1,
	 decode_sc_share_new_bee_reward_reply/1,
	 encode_cs_share_new_bee_reward_req/1,
	 decode_cs_share_new_bee_reward_req/1,
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

-record(cs_share_with_friends_req, {}).

-record(sc_task_seven_award_response,
	{result, err, rewards}).

-record(cs_task_seven_award_request, {}).

-record(sc_task_seven_info_response,
	{task_id, process, status, award}).

-record(sc_draw_count_response,
	{draw_count, draw_count_seven, draw_count_one}).

-record(sc_share_rank_response,
	{count, rank, pages, list, begintime, endtime}).

-record(pb_share_rank_item_response,
	{rank, name, count}).

-record(sc_share_history_response,
	{count, one_draw, three_draw, seven_draw, pages, list}).

-record(pb_share_history_friend_item_response,
	{userid, name, create_time, first_day, three_day,
	 seven_day, is_red}).

-record(pb_share_history_item_response,
	{name, process}).

-record(sc_share_draw_response, {result, err, index}).

-record(cs_share_rank_request, {page}).

-record(cs_share_friend_request, {page, user_id}).

-record(cs_share_draw_request, {flag}).

-record(sc_share_mission_update, {list, count}).

-record(sc_share_info,
	{my_code, code, free, count, list}).

-record(pb_share_mission,
	{friend_id, name, head, vip_lv, title, type, status}).

-record(sc_share_mission_reward_reply,
	{result, err, rewards, friend_id, type}).

-record(cs_share_mission_reward_req, {friend_id, type}).

-record(sc_share_new_bee_reward_reply,
	{result, err, rewards}).

-record(cs_share_new_bee_reward_req, {code}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_cs_share_with_friends_req(Record)
    when is_record(Record, cs_share_with_friends_req) ->
    encode(cs_share_with_friends_req, Record).

encode_sc_task_seven_award_response(Record)
    when is_record(Record, sc_task_seven_award_response) ->
    encode(sc_task_seven_award_response, Record).

encode_cs_task_seven_award_request(Record)
    when is_record(Record, cs_task_seven_award_request) ->
    encode(cs_task_seven_award_request, Record).

encode_sc_task_seven_info_response(Record)
    when is_record(Record, sc_task_seven_info_response) ->
    encode(sc_task_seven_info_response, Record).

encode_sc_draw_count_response(Record)
    when is_record(Record, sc_draw_count_response) ->
    encode(sc_draw_count_response, Record).

encode_sc_share_rank_response(Record)
    when is_record(Record, sc_share_rank_response) ->
    encode(sc_share_rank_response, Record).

encode_pb_share_rank_item_response(Record)
    when is_record(Record, pb_share_rank_item_response) ->
    encode(pb_share_rank_item_response, Record).

encode_sc_share_history_response(Record)
    when is_record(Record, sc_share_history_response) ->
    encode(sc_share_history_response, Record).

encode_pb_share_history_friend_item_response(Record)
    when is_record(Record,
		   pb_share_history_friend_item_response) ->
    encode(pb_share_history_friend_item_response, Record).

encode_pb_share_history_item_response(Record)
    when is_record(Record,
		   pb_share_history_item_response) ->
    encode(pb_share_history_item_response, Record).

encode_sc_share_draw_response(Record)
    when is_record(Record, sc_share_draw_response) ->
    encode(sc_share_draw_response, Record).

encode_cs_share_rank_request(Record)
    when is_record(Record, cs_share_rank_request) ->
    encode(cs_share_rank_request, Record).

encode_cs_share_friend_request(Record)
    when is_record(Record, cs_share_friend_request) ->
    encode(cs_share_friend_request, Record).

encode_cs_share_draw_request(Record)
    when is_record(Record, cs_share_draw_request) ->
    encode(cs_share_draw_request, Record).

encode_sc_share_mission_update(Record)
    when is_record(Record, sc_share_mission_update) ->
    encode(sc_share_mission_update, Record).

encode_sc_share_info(Record)
    when is_record(Record, sc_share_info) ->
    encode(sc_share_info, Record).

encode_pb_share_mission(Record)
    when is_record(Record, pb_share_mission) ->
    encode(pb_share_mission, Record).

encode_sc_share_mission_reward_reply(Record)
    when is_record(Record, sc_share_mission_reward_reply) ->
    encode(sc_share_mission_reward_reply, Record).

encode_cs_share_mission_reward_req(Record)
    when is_record(Record, cs_share_mission_reward_req) ->
    encode(cs_share_mission_reward_req, Record).

encode_sc_share_new_bee_reward_reply(Record)
    when is_record(Record, sc_share_new_bee_reward_reply) ->
    encode(sc_share_new_bee_reward_reply, Record).

encode_cs_share_new_bee_reward_req(Record)
    when is_record(Record, cs_share_new_bee_reward_req) ->
    encode(cs_share_new_bee_reward_req, Record).

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
encode(cs_share_new_bee_reward_req, Record) ->
    [iolist(cs_share_new_bee_reward_req, Record)
     | encode_extensions(Record)];
encode(sc_share_new_bee_reward_reply, Record) ->
    [iolist(sc_share_new_bee_reward_reply, Record)
     | encode_extensions(Record)];
encode(cs_share_mission_reward_req, Record) ->
    [iolist(cs_share_mission_reward_req, Record)
     | encode_extensions(Record)];
encode(sc_share_mission_reward_reply, Record) ->
    [iolist(sc_share_mission_reward_reply, Record)
     | encode_extensions(Record)];
encode(pb_share_mission, Record) ->
    [iolist(pb_share_mission, Record)
     | encode_extensions(Record)];
encode(sc_share_info, Record) ->
    [iolist(sc_share_info, Record)
     | encode_extensions(Record)];
encode(sc_share_mission_update, Record) ->
    [iolist(sc_share_mission_update, Record)
     | encode_extensions(Record)];
encode(cs_share_draw_request, Record) ->
    [iolist(cs_share_draw_request, Record)
     | encode_extensions(Record)];
encode(cs_share_friend_request, Record) ->
    [iolist(cs_share_friend_request, Record)
     | encode_extensions(Record)];
encode(cs_share_rank_request, Record) ->
    [iolist(cs_share_rank_request, Record)
     | encode_extensions(Record)];
encode(sc_share_draw_response, Record) ->
    [iolist(sc_share_draw_response, Record)
     | encode_extensions(Record)];
encode(pb_share_history_item_response, Record) ->
    [iolist(pb_share_history_item_response, Record)
     | encode_extensions(Record)];
encode(pb_share_history_friend_item_response, Record) ->
    [iolist(pb_share_history_friend_item_response, Record)
     | encode_extensions(Record)];
encode(sc_share_history_response, Record) ->
    [iolist(sc_share_history_response, Record)
     | encode_extensions(Record)];
encode(pb_share_rank_item_response, Record) ->
    [iolist(pb_share_rank_item_response, Record)
     | encode_extensions(Record)];
encode(sc_share_rank_response, Record) ->
    [iolist(sc_share_rank_response, Record)
     | encode_extensions(Record)];
encode(sc_draw_count_response, Record) ->
    [iolist(sc_draw_count_response, Record)
     | encode_extensions(Record)];
encode(sc_task_seven_info_response, Record) ->
    [iolist(sc_task_seven_info_response, Record)
     | encode_extensions(Record)];
encode(cs_task_seven_award_request, Record) ->
    [iolist(cs_task_seven_award_request, Record)
     | encode_extensions(Record)];
encode(sc_task_seven_award_response, Record) ->
    [iolist(sc_task_seven_award_response, Record)
     | encode_extensions(Record)];
encode(cs_share_with_friends_req, Record) ->
    [iolist(cs_share_with_friends_req, Record)
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
iolist(cs_share_new_bee_reward_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_share_new_bee_reward_req.code,
		       none),
	  string, [])];
iolist(sc_share_new_bee_reward_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_new_bee_reward_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_share_new_bee_reward_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_share_new_bee_reward_reply.rewards,
		       none),
	  pb_reward_info, [])];
iolist(cs_share_mission_reward_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_share_mission_reward_req.friend_id,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_share_mission_reward_req.type,
		       none),
	  int32, [])];
iolist(sc_share_mission_reward_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_mission_reward_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_share_mission_reward_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_share_mission_reward_reply.rewards,
		       none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_share_mission_reward_reply.friend_id,
		       none),
	  string, []),
     pack(5, required,
	  with_default(Record#sc_share_mission_reward_reply.type,
		       none),
	  int32, [])];
iolist(pb_share_mission, Record) ->
    [pack(1, required,
	  with_default(Record#pb_share_mission.friend_id, none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_share_mission.name, none), bytes,
	  []),
     pack(3, required,
	  with_default(Record#pb_share_mission.head, none),
	  string, []),
     pack(4, required,
	  with_default(Record#pb_share_mission.vip_lv, none),
	  int32, []),
     pack(5, required,
	  with_default(Record#pb_share_mission.title, none),
	  string, []),
     pack(6, required,
	  with_default(Record#pb_share_mission.type, none), int32,
	  []),
     pack(7, required,
	  with_default(Record#pb_share_mission.status, none),
	  int32, [])];
iolist(sc_share_info, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_info.my_code, none),
	  string, []),
     pack(2, required,
	  with_default(Record#sc_share_info.code, none), string,
	  []),
     pack(3, required,
	  with_default(Record#sc_share_info.free, none), bool,
	  []),
     pack(4, required,
	  with_default(Record#sc_share_info.count, none), int32,
	  []),
     pack(5, repeated,
	  with_default(Record#sc_share_info.list, none),
	  pb_share_mission, [])];
iolist(sc_share_mission_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_share_mission_update.list, none),
	  pb_share_mission, []),
     pack(2, required,
	  with_default(Record#sc_share_mission_update.count,
		       none),
	  int32, [])];
iolist(cs_share_draw_request, Record) ->
    [pack(1, required,
	  with_default(Record#cs_share_draw_request.flag, none),
	  int32, [])];
iolist(cs_share_friend_request, Record) ->
    [pack(1, required,
	  with_default(Record#cs_share_friend_request.page, none),
	  int32, []),
     pack(2, optional,
	  with_default(Record#cs_share_friend_request.user_id,
		       none),
	  string, [])];
iolist(cs_share_rank_request, Record) ->
    [pack(1, required,
	  with_default(Record#cs_share_rank_request.page, none),
	  int32, [])];
iolist(sc_share_draw_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_draw_response.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_share_draw_response.err, none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_share_draw_response.index, none),
	  int32, [])];
iolist(pb_share_history_item_response, Record) ->
    [pack(1, required,
	  with_default(Record#pb_share_history_item_response.name,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_share_history_item_response.process,
		       none),
	  int32, [])];
iolist(pb_share_history_friend_item_response, Record) ->
    [pack(1, required,
	  with_default(Record#pb_share_history_friend_item_response.userid,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#pb_share_history_friend_item_response.name,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#pb_share_history_friend_item_response.create_time,
		       none),
	  int32, []),
     pack(4, required,
	  with_default(Record#pb_share_history_friend_item_response.first_day,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#pb_share_history_friend_item_response.three_day,
		       none),
	  int32, []),
     pack(6, required,
	  with_default(Record#pb_share_history_friend_item_response.seven_day,
		       none),
	  int32, []),
     pack(7, required,
	  with_default(Record#pb_share_history_friend_item_response.is_red,
		       none),
	  int32, [])];
iolist(sc_share_history_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_history_response.count,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_share_history_response.one_draw,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_share_history_response.three_draw,
		       none),
	  int32, []),
     pack(4, required,
	  with_default(Record#sc_share_history_response.seven_draw,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#sc_share_history_response.pages,
		       none),
	  int32, []),
     pack(6, repeated,
	  with_default(Record#sc_share_history_response.list,
		       none),
	  pb_share_history_friend_item_response, [])];
iolist(pb_share_rank_item_response, Record) ->
    [pack(1, required,
	  with_default(Record#pb_share_rank_item_response.rank,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#pb_share_rank_item_response.name,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#pb_share_rank_item_response.count,
		       none),
	  int32, [])];
iolist(sc_share_rank_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_share_rank_response.count, none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_share_rank_response.rank, none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_share_rank_response.pages, none),
	  int32, []),
     pack(4, repeated,
	  with_default(Record#sc_share_rank_response.list, none),
	  pb_share_rank_item_response, []),
     pack(5, optional,
	  with_default(Record#sc_share_rank_response.begintime,
		       none),
	  int32, []),
     pack(6, optional,
	  with_default(Record#sc_share_rank_response.endtime,
		       none),
	  int32, [])];
iolist(sc_draw_count_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_draw_count_response.draw_count,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_draw_count_response.draw_count_seven,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_draw_count_response.draw_count_one,
		       none),
	  int32, [])];
iolist(sc_task_seven_info_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_task_seven_info_response.task_id,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_task_seven_info_response.process,
		       none),
	  int32, []),
     pack(3, optional,
	  with_default(Record#sc_task_seven_info_response.status,
		       none),
	  int32, []),
     pack(4, optional,
	  with_default(Record#sc_task_seven_info_response.award,
		       none),
	  int32, [])];
iolist(cs_task_seven_award_request, _Record) -> [];
iolist(sc_task_seven_award_response, Record) ->
    [pack(1, required,
	  with_default(Record#sc_task_seven_award_response.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_task_seven_award_response.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_task_seven_award_response.rewards,
		       none),
	  pb_reward_info, [])];
iolist(cs_share_with_friends_req, _Record) -> [].

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

decode_cs_share_with_friends_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_with_friends_req, Bytes).

decode_sc_task_seven_award_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_task_seven_award_response, Bytes).

decode_cs_task_seven_award_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_task_seven_award_request, Bytes).

decode_sc_task_seven_info_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_task_seven_info_response, Bytes).

decode_sc_draw_count_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_draw_count_response, Bytes).

decode_sc_share_rank_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_rank_response, Bytes).

decode_pb_share_rank_item_response(Bytes)
    when is_binary(Bytes) ->
    decode(pb_share_rank_item_response, Bytes).

decode_sc_share_history_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_history_response, Bytes).

decode_pb_share_history_friend_item_response(Bytes)
    when is_binary(Bytes) ->
    decode(pb_share_history_friend_item_response, Bytes).

decode_pb_share_history_item_response(Bytes)
    when is_binary(Bytes) ->
    decode(pb_share_history_item_response, Bytes).

decode_sc_share_draw_response(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_draw_response, Bytes).

decode_cs_share_rank_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_rank_request, Bytes).

decode_cs_share_friend_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_friend_request, Bytes).

decode_cs_share_draw_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_draw_request, Bytes).

decode_sc_share_mission_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_mission_update, Bytes).

decode_sc_share_info(Bytes) when is_binary(Bytes) ->
    decode(sc_share_info, Bytes).

decode_pb_share_mission(Bytes) when is_binary(Bytes) ->
    decode(pb_share_mission, Bytes).

decode_sc_share_mission_reward_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_mission_reward_reply, Bytes).

decode_cs_share_mission_reward_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_mission_reward_req, Bytes).

decode_sc_share_new_bee_reward_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_share_new_bee_reward_reply, Bytes).

decode_cs_share_new_bee_reward_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_share_new_bee_reward_req, Bytes).

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
decode(cs_share_new_bee_reward_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, code, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_new_bee_reward_req, Decoded);
decode(sc_share_new_bee_reward_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rewards, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_new_bee_reward_reply, Decoded);
decode(cs_share_mission_reward_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, type, int32, []},
	     {1, friend_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_mission_reward_req, Decoded);
decode(sc_share_mission_reward_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, type, int32, []},
	     {4, friend_id, string, []},
	     {3, rewards, pb_reward_info, [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_mission_reward_reply, Decoded);
decode(pb_share_mission, Bytes) when is_binary(Bytes) ->
    Types = [{7, status, int32, []}, {6, type, int32, []},
	     {5, title, string, []}, {4, vip_lv, int32, []},
	     {3, head, string, []}, {2, name, bytes, []},
	     {1, friend_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_share_mission, Decoded);
decode(sc_share_info, Bytes) when is_binary(Bytes) ->
    Types = [{5, list, pb_share_mission,
	      [is_record, repeated]},
	     {4, count, int32, []}, {3, free, bool, []},
	     {2, code, string, []}, {1, my_code, string, []}],
    Defaults = [{5, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_info, Decoded);
decode(sc_share_mission_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, count, int32, []},
	     {1, list, pb_share_mission, [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_mission_update, Decoded);
decode(cs_share_draw_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, flag, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_draw_request, Decoded);
decode(cs_share_friend_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, user_id, string, []},
	     {1, page, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_friend_request, Decoded);
decode(cs_share_rank_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, page, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_rank_request, Decoded);
decode(sc_share_draw_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, index, int32, []}, {2, err, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_draw_response, Decoded);
decode(pb_share_history_item_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, process, int32, []},
	     {1, name, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_share_history_item_response, Decoded);
decode(pb_share_history_friend_item_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{7, is_red, int32, []},
	     {6, seven_day, int32, []}, {5, three_day, int32, []},
	     {4, first_day, int32, []}, {3, create_time, int32, []},
	     {2, name, bytes, []}, {1, userid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_share_history_friend_item_response,
	      Decoded);
decode(sc_share_history_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, list,
	      pb_share_history_friend_item_response,
	      [is_record, repeated]},
	     {5, pages, int32, []}, {4, seven_draw, int32, []},
	     {3, three_draw, int32, []}, {2, one_draw, int32, []},
	     {1, count, int32, []}],
    Defaults = [{6, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_history_response, Decoded);
decode(pb_share_rank_item_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, count, int32, []}, {2, name, bytes, []},
	     {1, rank, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_share_rank_item_response, Decoded);
decode(sc_share_rank_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, endtime, int32, []},
	     {5, begintime, int32, []},
	     {4, list, pb_share_rank_item_response,
	      [is_record, repeated]},
	     {3, pages, int32, []}, {2, rank, int32, []},
	     {1, count, int32, []}],
    Defaults = [{4, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_share_rank_response, Decoded);
decode(sc_draw_count_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, draw_count_one, int32, []},
	     {2, draw_count_seven, int32, []},
	     {1, draw_count, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_draw_count_response, Decoded);
decode(sc_task_seven_info_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, award, int32, []}, {3, status, int32, []},
	     {2, process, int32, []}, {1, task_id, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_task_seven_info_response, Decoded);
decode(cs_task_seven_award_request, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_task_seven_award_request, Decoded);
decode(sc_task_seven_award_response, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rewards, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_task_seven_award_response, Decoded);
decode(cs_share_with_friends_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_share_with_friends_req, Decoded).

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
to_record(cs_share_new_bee_reward_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_new_bee_reward_req),
						   Record, Name, Val)
			  end,
			  #cs_share_new_bee_reward_req{}, DecodedTuples),
    Record1;
to_record(sc_share_new_bee_reward_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_new_bee_reward_reply),
						   Record, Name, Val)
			  end,
			  #sc_share_new_bee_reward_reply{}, DecodedTuples),
    Record1;
to_record(cs_share_mission_reward_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_mission_reward_req),
						   Record, Name, Val)
			  end,
			  #cs_share_mission_reward_req{}, DecodedTuples),
    Record1;
to_record(sc_share_mission_reward_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_mission_reward_reply),
						   Record, Name, Val)
			  end,
			  #sc_share_mission_reward_reply{}, DecodedTuples),
    Record1;
to_record(pb_share_mission, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_share_mission),
						   Record, Name, Val)
			  end,
			  #pb_share_mission{}, DecodedTuples),
    Record1;
to_record(sc_share_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_info),
						   Record, Name, Val)
			  end,
			  #sc_share_info{}, DecodedTuples),
    Record1;
to_record(sc_share_mission_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_mission_update),
						   Record, Name, Val)
			  end,
			  #sc_share_mission_update{}, DecodedTuples),
    Record1;
to_record(cs_share_draw_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_draw_request),
						   Record, Name, Val)
			  end,
			  #cs_share_draw_request{}, DecodedTuples),
    Record1;
to_record(cs_share_friend_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_friend_request),
						   Record, Name, Val)
			  end,
			  #cs_share_friend_request{}, DecodedTuples),
    Record1;
to_record(cs_share_rank_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_rank_request),
						   Record, Name, Val)
			  end,
			  #cs_share_rank_request{}, DecodedTuples),
    Record1;
to_record(sc_share_draw_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_draw_response),
						   Record, Name, Val)
			  end,
			  #sc_share_draw_response{}, DecodedTuples),
    Record1;
to_record(pb_share_history_item_response,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_share_history_item_response),
						   Record, Name, Val)
			  end,
			  #pb_share_history_item_response{}, DecodedTuples),
    Record1;
to_record(pb_share_history_friend_item_response,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_share_history_friend_item_response),
						   Record, Name, Val)
			  end,
			  #pb_share_history_friend_item_response{},
			  DecodedTuples),
    Record1;
to_record(sc_share_history_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_history_response),
						   Record, Name, Val)
			  end,
			  #sc_share_history_response{}, DecodedTuples),
    Record1;
to_record(pb_share_rank_item_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_share_rank_item_response),
						   Record, Name, Val)
			  end,
			  #pb_share_rank_item_response{}, DecodedTuples),
    Record1;
to_record(sc_share_rank_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_share_rank_response),
						   Record, Name, Val)
			  end,
			  #sc_share_rank_response{}, DecodedTuples),
    Record1;
to_record(sc_draw_count_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_draw_count_response),
						   Record, Name, Val)
			  end,
			  #sc_draw_count_response{}, DecodedTuples),
    Record1;
to_record(sc_task_seven_info_response, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_task_seven_info_response),
						   Record, Name, Val)
			  end,
			  #sc_task_seven_info_response{}, DecodedTuples),
    Record1;
to_record(cs_task_seven_award_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_task_seven_award_request),
						   Record, Name, Val)
			  end,
			  #cs_task_seven_award_request{}, DecodedTuples),
    Record1;
to_record(sc_task_seven_award_response,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_task_seven_award_response),
						   Record, Name, Val)
			  end,
			  #sc_task_seven_award_response{}, DecodedTuples),
    Record1;
to_record(cs_share_with_friends_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_share_with_friends_req),
						   Record, Name, Val)
			  end,
			  #cs_share_with_friends_req{}, DecodedTuples),
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

