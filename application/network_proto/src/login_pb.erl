-file("src/login_pb.erl", 1).

-module(login_pb).

-export([encode_sc_login_proto_complete/1,
	 decode_sc_login_proto_complete/1,
	 encode_sc_login_repeat/1, decode_sc_login_repeat/1,
	 encode_sc_login_reconnection_reply/1,
	 decode_sc_login_reconnection_reply/1,
	 encode_cs_login_reconnection/1,
	 decode_cs_login_reconnection/1, encode_cs_login_out/1,
	 decode_cs_login_out/1, encode_sc_login_reply/1,
	 decode_sc_login_reply/1, encode_cs_login/1,
	 decode_cs_login/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_login_proto_complete, {is_new_player}).

-record(sc_login_repeat, {}).

-record(sc_login_reconnection_reply,
	{result, reason, proto_key}).

-record(cs_login_reconnection,
	{platform_flag, user, reconnect_key}).

-record(cs_login_out, {}).

-record(sc_login_reply,
	{result, reason, reconnect_key, proto_key}).

-record(cs_login,
	{platform_flag, uid, password, sz_param, version,
	 network_type, sys_type, chnid, sub_chnid, ios_idfa,
	 ios_idfv, mac_address, device_type}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_login_proto_complete(Record)
    when is_record(Record, sc_login_proto_complete) ->
    encode(sc_login_proto_complete, Record).

encode_sc_login_repeat(Record)
    when is_record(Record, sc_login_repeat) ->
    encode(sc_login_repeat, Record).

encode_sc_login_reconnection_reply(Record)
    when is_record(Record, sc_login_reconnection_reply) ->
    encode(sc_login_reconnection_reply, Record).

encode_cs_login_reconnection(Record)
    when is_record(Record, cs_login_reconnection) ->
    encode(cs_login_reconnection, Record).

encode_cs_login_out(Record)
    when is_record(Record, cs_login_out) ->
    encode(cs_login_out, Record).

encode_sc_login_reply(Record)
    when is_record(Record, sc_login_reply) ->
    encode(sc_login_reply, Record).

encode_cs_login(Record)
    when is_record(Record, cs_login) ->
    encode(cs_login, Record).

encode(cs_login, Record) ->
    [iolist(cs_login, Record) | encode_extensions(Record)];
encode(sc_login_reply, Record) ->
    [iolist(sc_login_reply, Record)
     | encode_extensions(Record)];
encode(cs_login_out, Record) ->
    [iolist(cs_login_out, Record)
     | encode_extensions(Record)];
encode(cs_login_reconnection, Record) ->
    [iolist(cs_login_reconnection, Record)
     | encode_extensions(Record)];
encode(sc_login_reconnection_reply, Record) ->
    [iolist(sc_login_reconnection_reply, Record)
     | encode_extensions(Record)];
encode(sc_login_repeat, Record) ->
    [iolist(sc_login_repeat, Record)
     | encode_extensions(Record)];
encode(sc_login_proto_complete, Record) ->
    [iolist(sc_login_proto_complete, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(cs_login, Record) ->
    [pack(1, required,
	  with_default(Record#cs_login.platform_flag, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_login.uid, none), string, []),
     pack(3, required,
	  with_default(Record#cs_login.password, none), bytes,
	  []),
     pack(4, required,
	  with_default(Record#cs_login.sz_param, none), string,
	  []),
     pack(5, required,
	  with_default(Record#cs_login.version, none), string,
	  []),
     pack(6, required,
	  with_default(Record#cs_login.network_type, none),
	  string, []),
     pack(7, required,
	  with_default(Record#cs_login.sys_type, none), uint32,
	  []),
     pack(8, required,
	  with_default(Record#cs_login.chnid, none), uint32, []),
     pack(9, required,
	  with_default(Record#cs_login.sub_chnid, none), uint32,
	  []),
     pack(10, required,
	  with_default(Record#cs_login.ios_idfa, none), string,
	  []),
     pack(11, required,
	  with_default(Record#cs_login.ios_idfv, none), string,
	  []),
     pack(12, required,
	  with_default(Record#cs_login.mac_address, none), string,
	  []),
     pack(13, required,
	  with_default(Record#cs_login.device_type, none), string,
	  [])];
iolist(sc_login_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_login_reply.result, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_login_reply.reason, none), bytes,
	  []),
     pack(3, required,
	  with_default(Record#sc_login_reply.reconnect_key, none),
	  string, []),
     pack(4, required,
	  with_default(Record#sc_login_reply.proto_key, none),
	  bytes, [])];
iolist(cs_login_out, _Record) -> [];
iolist(cs_login_reconnection, Record) ->
    [pack(1, required,
	  with_default(Record#cs_login_reconnection.platform_flag,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_login_reconnection.user, none),
	  string, []),
     pack(3, required,
	  with_default(Record#cs_login_reconnection.reconnect_key,
		       none),
	  string, [])];
iolist(sc_login_reconnection_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_login_reconnection_reply.result,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_login_reconnection_reply.reason,
		       none),
	  bytes, []),
     pack(3, required,
	  with_default(Record#sc_login_reconnection_reply.proto_key,
		       none),
	  bytes, [])];
iolist(sc_login_repeat, _Record) -> [];
iolist(sc_login_proto_complete, Record) ->
    [pack(1, required,
	  with_default(Record#sc_login_proto_complete.is_new_player,
		       none),
	  bool, [])].

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

decode_sc_login_proto_complete(Bytes)
    when is_binary(Bytes) ->
    decode(sc_login_proto_complete, Bytes).

decode_sc_login_repeat(Bytes) when is_binary(Bytes) ->
    decode(sc_login_repeat, Bytes).

decode_sc_login_reconnection_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_login_reconnection_reply, Bytes).

decode_cs_login_reconnection(Bytes)
    when is_binary(Bytes) ->
    decode(cs_login_reconnection, Bytes).

decode_cs_login_out(Bytes) when is_binary(Bytes) ->
    decode(cs_login_out, Bytes).

decode_sc_login_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_login_reply, Bytes).

decode_cs_login(Bytes) when is_binary(Bytes) ->
    decode(cs_login, Bytes).

decode(enummsg_values, 1) -> value1;
decode(cs_login, Bytes) when is_binary(Bytes) ->
    Types = [{13, device_type, string, []},
	     {12, mac_address, string, []},
	     {11, ios_idfv, string, []}, {10, ios_idfa, string, []},
	     {9, sub_chnid, uint32, []}, {8, chnid, uint32, []},
	     {7, sys_type, uint32, []},
	     {6, network_type, string, []}, {5, version, string, []},
	     {4, sz_param, string, []}, {3, password, bytes, []},
	     {2, uid, string, []}, {1, platform_flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_login, Decoded);
decode(sc_login_reply, Bytes) when is_binary(Bytes) ->
    Types = [{4, proto_key, bytes, []},
	     {3, reconnect_key, string, []}, {2, reason, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_login_reply, Decoded);
decode(cs_login_out, Bytes) when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_login_out, Decoded);
decode(cs_login_reconnection, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reconnect_key, string, []},
	     {2, user, string, []}, {1, platform_flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_login_reconnection, Decoded);
decode(sc_login_reconnection_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, proto_key, bytes, []},
	     {2, reason, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_login_reconnection_reply, Decoded);
decode(sc_login_repeat, Bytes) when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_login_repeat, Decoded);
decode(sc_login_proto_complete, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, is_new_player, bool, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_login_proto_complete, Decoded).

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

to_record(cs_login, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_login),
						   Record, Name, Val)
			  end,
			  #cs_login{}, DecodedTuples),
    Record1;
to_record(sc_login_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_login_reply),
						   Record, Name, Val)
			  end,
			  #sc_login_reply{}, DecodedTuples),
    Record1;
to_record(cs_login_out, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_login_out),
						   Record, Name, Val)
			  end,
			  #cs_login_out{}, DecodedTuples),
    Record1;
to_record(cs_login_reconnection, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_login_reconnection),
						   Record, Name, Val)
			  end,
			  #cs_login_reconnection{}, DecodedTuples),
    Record1;
to_record(sc_login_reconnection_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_login_reconnection_reply),
						   Record, Name, Val)
			  end,
			  #sc_login_reconnection_reply{}, DecodedTuples),
    Record1;
to_record(sc_login_repeat, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_login_repeat),
						   Record, Name, Val)
			  end,
			  #sc_login_repeat{}, DecodedTuples),
    Record1;
to_record(sc_login_proto_complete, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_login_proto_complete),
						   Record, Name, Val)
			  end,
			  #sc_login_proto_complete{}, DecodedTuples),
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

