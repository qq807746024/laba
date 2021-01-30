%% @author zouv
%% @doc @todo 公用接口

-module(util_url).

-define(MD5_KEY, "2324er37ewrcw7@^%&*&*$#*!N*dfsgfdgldfgdt0i").

-compile(export_all).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).


%% ====================================================================
%% Internal functions
%% ====================================================================
%%解析参数
parse_paremeter(ParamterStr)    ->
    ParamterList = string:tokens(ParamterStr, "&"), 
    parse_paremeter1(ParamterList, []). 

parse_paremeter1([], Acc)   ->
    lists:reverse(Acc);

parse_paremeter1([Parameter|Tail], Acc) ->
    case string:tokens(Parameter, "=")  of
        [Name, Value] ->
            parse_paremeter1(Tail, [{string:strip(Name), string:strip(Value)}|Acc]);
        []                      ->
            parse_paremeter1(Tail, Acc);
        _                           ->
            { error , {Parameter, parameter_invalid}}
    end.

get_param_string(PreList) ->
	SignList = lists:map(fun({_, EData}) -> EData end, lists:keysort(1, PreList)),
	Check = lists:concat(SignList),
	StrMd5 = string:join( [ Check, ?MD5_KEY], ""),
	Md5Hex = lists:flatten([io_lib:format("~2.16.0b", [D]) || D <- binary_to_list(erlang:md5(StrMd5))]),
	ParamList = PreList ++ [{"sign", Md5Hex}],
	%rfc4627:encode({obj, ParamList}).
	ParamStr1 = lists:foldl(fun({EKey, EValue}, Acc) ->
		Acc ++ ["&", EKey, "=", EValue] end, [], ParamList),
	[_|Last] = lists:concat(ParamStr1),
	Last.
