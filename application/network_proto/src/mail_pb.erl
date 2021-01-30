-file("src/mail_pb.erl", 1).

-module(mail_pb).

-export([encode_sc_mail_draw_reply/1,
	 decode_sc_mail_draw_reply/1,
	 encode_cs_mail_draw_request/1,
	 decode_cs_mail_draw_request/1, encode_cs_read_mail/1,
	 decode_cs_read_mail/1, encode_sc_mail_delete_reply/1,
	 decode_sc_mail_delete_reply/1,
	 encode_cs_mail_delete_request/1,
	 decode_cs_mail_delete_request/1, encode_sc_mail_add/1,
	 decode_sc_mail_add/1, encode_pb_mail/1,
	 decode_pb_mail/1, encode_sc_mails_init_update/1,
	 decode_sc_mails_init_update/1, encode_pb_reward_info/1,
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

-record(sc_mail_draw_reply,
	{result, err_msg, reward_info_s, request_mark}).

-record(cs_mail_draw_request, {mail_ids, request_mark}).

-record(cs_read_mail, {mail_id}).

-record(sc_mail_delete_reply,
	{result, err_msg, request_mark}).

-record(cs_mail_delete_request,
	{mail_id, request_mark}).

-record(sc_mail_add, {add_sys_mail}).

-record(pb_mail,
	{mail_id, cls, title, content, read, receive_date,
	 expire_date, reward_list}).

-record(sc_mails_init_update, {sys_mails}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_mail_draw_reply(Record)
    when is_record(Record, sc_mail_draw_reply) ->
    encode(sc_mail_draw_reply, Record).

encode_cs_mail_draw_request(Record)
    when is_record(Record, cs_mail_draw_request) ->
    encode(cs_mail_draw_request, Record).

encode_cs_read_mail(Record)
    when is_record(Record, cs_read_mail) ->
    encode(cs_read_mail, Record).

encode_sc_mail_delete_reply(Record)
    when is_record(Record, sc_mail_delete_reply) ->
    encode(sc_mail_delete_reply, Record).

encode_cs_mail_delete_request(Record)
    when is_record(Record, cs_mail_delete_request) ->
    encode(cs_mail_delete_request, Record).

encode_sc_mail_add(Record)
    when is_record(Record, sc_mail_add) ->
    encode(sc_mail_add, Record).

encode_pb_mail(Record)
    when is_record(Record, pb_mail) ->
    encode(pb_mail, Record).

encode_sc_mails_init_update(Record)
    when is_record(Record, sc_mails_init_update) ->
    encode(sc_mails_init_update, Record).

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
encode(sc_mails_init_update, Record) ->
    [iolist(sc_mails_init_update, Record)
     | encode_extensions(Record)];
encode(pb_mail, Record) ->
    [iolist(pb_mail, Record) | encode_extensions(Record)];
encode(sc_mail_add, Record) ->
    [iolist(sc_mail_add, Record)
     | encode_extensions(Record)];
encode(cs_mail_delete_request, Record) ->
    [iolist(cs_mail_delete_request, Record)
     | encode_extensions(Record)];
encode(sc_mail_delete_reply, Record) ->
    [iolist(sc_mail_delete_reply, Record)
     | encode_extensions(Record)];
encode(cs_read_mail, Record) ->
    [iolist(cs_read_mail, Record)
     | encode_extensions(Record)];
encode(cs_mail_draw_request, Record) ->
    [iolist(cs_mail_draw_request, Record)
     | encode_extensions(Record)];
encode(sc_mail_draw_reply, Record) ->
    [iolist(sc_mail_draw_reply, Record)
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
iolist(sc_mails_init_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_mails_init_update.sys_mails,
		       none),
	  pb_mail, [])];
iolist(pb_mail, Record) ->
    [pack(1, required,
	  with_default(Record#pb_mail.mail_id, none), string, []),
     pack(2, required,
	  with_default(Record#pb_mail.cls, none), uint32, []),
     pack(3, required,
	  with_default(Record#pb_mail.title, none), bytes, []),
     pack(4, required,
	  with_default(Record#pb_mail.content, none), bytes, []),
     pack(5, required,
	  with_default(Record#pb_mail.read, none), bool, []),
     pack(6, required,
	  with_default(Record#pb_mail.receive_date, none), uint32,
	  []),
     pack(7, required,
	  with_default(Record#pb_mail.expire_date, none), uint32,
	  []),
     pack(8, repeated,
	  with_default(Record#pb_mail.reward_list, none),
	  pb_reward_info, [])];
iolist(sc_mail_add, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mail_add.add_sys_mail, none),
	  pb_mail, [])];
iolist(cs_mail_delete_request, Record) ->
    [pack(1, required,
	  with_default(Record#cs_mail_delete_request.mail_id,
		       none),
	  string, []),
     pack(2, optional,
	  with_default(Record#cs_mail_delete_request.request_mark,
		       none),
	  string, [])];
iolist(sc_mail_delete_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mail_delete_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_mail_delete_reply.err_msg, none),
	  bytes, []),
     pack(3, optional,
	  with_default(Record#sc_mail_delete_reply.request_mark,
		       none),
	  string, [])];
iolist(cs_read_mail, Record) ->
    [pack(1, required,
	  with_default(Record#cs_read_mail.mail_id, none), string,
	  [])];
iolist(cs_mail_draw_request, Record) ->
    [pack(1, repeated,
	  with_default(Record#cs_mail_draw_request.mail_ids,
		       none),
	  string, []),
     pack(2, optional,
	  with_default(Record#cs_mail_draw_request.request_mark,
		       none),
	  string, [])];
iolist(sc_mail_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_mail_draw_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_mail_draw_reply.err_msg, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_mail_draw_reply.reward_info_s,
		       none),
	  pb_reward_info, []),
     pack(4, optional,
	  with_default(Record#sc_mail_draw_reply.request_mark,
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

decode_sc_mail_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_mail_draw_reply, Bytes).

decode_cs_mail_draw_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_mail_draw_request, Bytes).

decode_cs_read_mail(Bytes) when is_binary(Bytes) ->
    decode(cs_read_mail, Bytes).

decode_sc_mail_delete_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_mail_delete_reply, Bytes).

decode_cs_mail_delete_request(Bytes)
    when is_binary(Bytes) ->
    decode(cs_mail_delete_request, Bytes).

decode_sc_mail_add(Bytes) when is_binary(Bytes) ->
    decode(sc_mail_add, Bytes).

decode_pb_mail(Bytes) when is_binary(Bytes) ->
    decode(pb_mail, Bytes).

decode_sc_mails_init_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_mails_init_update, Bytes).

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
decode(sc_mails_init_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, sys_mails, pb_mail,
	      [is_record, repeated]}],
    Defaults = [{1, sys_mails, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mails_init_update, Decoded);
decode(pb_mail, Bytes) when is_binary(Bytes) ->
    Types = [{8, reward_list, pb_reward_info,
	      [is_record, repeated]},
	     {7, expire_date, uint32, []},
	     {6, receive_date, uint32, []}, {5, read, bool, []},
	     {4, content, bytes, []}, {3, title, bytes, []},
	     {2, cls, uint32, []}, {1, mail_id, string, []}],
    Defaults = [{8, reward_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_mail, Decoded);
decode(sc_mail_add, Bytes) when is_binary(Bytes) ->
    Types = [{1, add_sys_mail, pb_mail, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mail_add, Decoded);
decode(cs_mail_delete_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, request_mark, string, []},
	     {1, mail_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_mail_delete_request, Decoded);
decode(sc_mail_delete_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, request_mark, string, []},
	     {2, err_msg, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mail_delete_reply, Decoded);
decode(cs_read_mail, Bytes) when is_binary(Bytes) ->
    Types = [{1, mail_id, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_read_mail, Decoded);
decode(cs_mail_draw_request, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, request_mark, string, []},
	     {1, mail_ids, string, [repeated]}],
    Defaults = [{1, mail_ids, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_mail_draw_request, Decoded);
decode(sc_mail_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, request_mark, string, []},
	     {3, reward_info_s, pb_reward_info,
	      [is_record, repeated]},
	     {2, err_msg, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, reward_info_s, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_mail_draw_reply, Decoded).

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
to_record(sc_mails_init_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mails_init_update),
						   Record, Name, Val)
			  end,
			  #sc_mails_init_update{}, DecodedTuples),
    Record1;
to_record(pb_mail, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields, pb_mail),
						   Record, Name, Val)
			  end,
			  #pb_mail{}, DecodedTuples),
    Record1;
to_record(sc_mail_add, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mail_add),
						   Record, Name, Val)
			  end,
			  #sc_mail_add{}, DecodedTuples),
    Record1;
to_record(cs_mail_delete_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_mail_delete_request),
						   Record, Name, Val)
			  end,
			  #cs_mail_delete_request{}, DecodedTuples),
    Record1;
to_record(sc_mail_delete_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mail_delete_reply),
						   Record, Name, Val)
			  end,
			  #sc_mail_delete_reply{}, DecodedTuples),
    Record1;
to_record(cs_read_mail, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_read_mail),
						   Record, Name, Val)
			  end,
			  #cs_read_mail{}, DecodedTuples),
    Record1;
to_record(cs_mail_draw_request, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_mail_draw_request),
						   Record, Name, Val)
			  end,
			  #cs_mail_draw_request{}, DecodedTuples),
    Record1;
to_record(sc_mail_draw_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_mail_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_mail_draw_reply{}, DecodedTuples),
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

