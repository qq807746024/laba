-file("src/common_pb.erl", 1).

-module(common_pb).

-export([encode_sc_common_bug_feedback/1,
	 decode_sc_common_bug_feedback/1,
	 encode_cs_common_bug_feedback/1,
	 decode_cs_common_bug_feedback/1,
	 encode_sc_common_proto_clean/1,
	 decode_sc_common_proto_clean/1,
	 encode_cs_common_proto_clean/1,
	 decode_cs_common_proto_clean/1,
	 encode_sc_common_proto_count/1,
	 decode_sc_common_proto_count/1,
	 encode_cs_common_proto_count/1,
	 decode_cs_common_proto_count/1,
	 encode_sc_common_heartbeat_reply/1,
	 decode_sc_common_heartbeat_reply/1,
	 encode_cs_common_heartbeat/1,
	 decode_cs_common_heartbeat/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_common_bug_feedback, {result}).

-record(cs_common_bug_feedback, {content}).

-record(sc_common_proto_clean, {count}).

-record(cs_common_proto_clean, {count}).

-record(sc_common_proto_count, {count}).

-record(cs_common_proto_count, {count}).

-record(sc_common_heartbeat_reply, {now_time}).

-record(cs_common_heartbeat, {}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_common_bug_feedback(Record)
    when is_record(Record, sc_common_bug_feedback) ->
    encode(sc_common_bug_feedback, Record).

encode_cs_common_bug_feedback(Record)
    when is_record(Record, cs_common_bug_feedback) ->
    encode(cs_common_bug_feedback, Record).

encode_sc_common_proto_clean(Record)
    when is_record(Record, sc_common_proto_clean) ->
    encode(sc_common_proto_clean, Record).

encode_cs_common_proto_clean(Record)
    when is_record(Record, cs_common_proto_clean) ->
    encode(cs_common_proto_clean, Record).

encode_sc_common_proto_count(Record)
    when is_record(Record, sc_common_proto_count) ->
    encode(sc_common_proto_count, Record).

encode_cs_common_proto_count(Record)
    when is_record(Record, cs_common_proto_count) ->
    encode(cs_common_proto_count, Record).

encode_sc_common_heartbeat_reply(Record)
    when is_record(Record, sc_common_heartbeat_reply) ->
    encode(sc_common_heartbeat_reply, Record).

encode_cs_common_heartbeat(Record)
    when is_record(Record, cs_common_heartbeat) ->
    encode(cs_common_heartbeat, Record).

encode(cs_common_heartbeat, Record) ->
    [iolist(cs_common_heartbeat, Record)
     | encode_extensions(Record)];
encode(sc_common_heartbeat_reply, Record) ->
    [iolist(sc_common_heartbeat_reply, Record)
     | encode_extensions(Record)];
encode(cs_common_proto_count, Record) ->
    [iolist(cs_common_proto_count, Record)
     | encode_extensions(Record)];
encode(sc_common_proto_count, Record) ->
    [iolist(sc_common_proto_count, Record)
     | encode_extensions(Record)];
encode(cs_common_proto_clean, Record) ->
    [iolist(cs_common_proto_clean, Record)
     | encode_extensions(Record)];
encode(sc_common_proto_clean, Record) ->
    [iolist(sc_common_proto_clean, Record)
     | encode_extensions(Record)];
encode(cs_common_bug_feedback, Record) ->
    [iolist(cs_common_bug_feedback, Record)
     | encode_extensions(Record)];
encode(sc_common_bug_feedback, Record) ->
    [iolist(sc_common_bug_feedback, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(cs_common_heartbeat, _Record) -> [];
iolist(sc_common_heartbeat_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_common_heartbeat_reply.now_time,
		       none),
	  uint32, [])];
iolist(cs_common_proto_count, Record) ->
    [pack(1, required,
	  with_default(Record#cs_common_proto_count.count, none),
	  uint32, [])];
iolist(sc_common_proto_count, Record) ->
    [pack(1, required,
	  with_default(Record#sc_common_proto_count.count, none),
	  uint32, [])];
iolist(cs_common_proto_clean, Record) ->
    [pack(1, required,
	  with_default(Record#cs_common_proto_clean.count, none),
	  uint32, [])];
iolist(sc_common_proto_clean, Record) ->
    [pack(1, required,
	  with_default(Record#sc_common_proto_clean.count, none),
	  uint32, [])];
iolist(cs_common_bug_feedback, Record) ->
    [pack(1, required,
	  with_default(Record#cs_common_bug_feedback.content,
		       none),
	  bytes, [])];
iolist(sc_common_bug_feedback, Record) ->
    [pack(1, required,
	  with_default(Record#sc_common_bug_feedback.result,
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

decode_sc_common_bug_feedback(Bytes)
    when is_binary(Bytes) ->
    decode(sc_common_bug_feedback, Bytes).

decode_cs_common_bug_feedback(Bytes)
    when is_binary(Bytes) ->
    decode(cs_common_bug_feedback, Bytes).

decode_sc_common_proto_clean(Bytes)
    when is_binary(Bytes) ->
    decode(sc_common_proto_clean, Bytes).

decode_cs_common_proto_clean(Bytes)
    when is_binary(Bytes) ->
    decode(cs_common_proto_clean, Bytes).

decode_sc_common_proto_count(Bytes)
    when is_binary(Bytes) ->
    decode(sc_common_proto_count, Bytes).

decode_cs_common_proto_count(Bytes)
    when is_binary(Bytes) ->
    decode(cs_common_proto_count, Bytes).

decode_sc_common_heartbeat_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_common_heartbeat_reply, Bytes).

decode_cs_common_heartbeat(Bytes)
    when is_binary(Bytes) ->
    decode(cs_common_heartbeat, Bytes).

decode(enummsg_values, 1) -> value1;
decode(cs_common_heartbeat, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_common_heartbeat, Decoded);
decode(sc_common_heartbeat_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, now_time, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_common_heartbeat_reply, Decoded);
decode(cs_common_proto_count, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, count, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_common_proto_count, Decoded);
decode(sc_common_proto_count, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, count, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_common_proto_count, Decoded);
decode(cs_common_proto_clean, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, count, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_common_proto_clean, Decoded);
decode(sc_common_proto_clean, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, count, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_common_proto_clean, Decoded);
decode(cs_common_bug_feedback, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, content, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_common_bug_feedback, Decoded);
decode(sc_common_bug_feedback, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_common_bug_feedback, Decoded).

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

to_record(cs_common_heartbeat, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_common_heartbeat),
						   Record, Name, Val)
			  end,
			  #cs_common_heartbeat{}, DecodedTuples),
    Record1;
to_record(sc_common_heartbeat_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_common_heartbeat_reply),
						   Record, Name, Val)
			  end,
			  #sc_common_heartbeat_reply{}, DecodedTuples),
    Record1;
to_record(cs_common_proto_count, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_common_proto_count),
						   Record, Name, Val)
			  end,
			  #cs_common_proto_count{}, DecodedTuples),
    Record1;
to_record(sc_common_proto_count, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_common_proto_count),
						   Record, Name, Val)
			  end,
			  #sc_common_proto_count{}, DecodedTuples),
    Record1;
to_record(cs_common_proto_clean, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_common_proto_clean),
						   Record, Name, Val)
			  end,
			  #cs_common_proto_clean{}, DecodedTuples),
    Record1;
to_record(sc_common_proto_clean, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_common_proto_clean),
						   Record, Name, Val)
			  end,
			  #sc_common_proto_clean{}, DecodedTuples),
    Record1;
to_record(cs_common_bug_feedback, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_common_bug_feedback),
						   Record, Name, Val)
			  end,
			  #cs_common_bug_feedback{}, DecodedTuples),
    Record1;
to_record(sc_common_bug_feedback, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_common_bug_feedback),
						   Record, Name, Val)
			  end,
			  #sc_common_bug_feedback{}, DecodedTuples),
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

