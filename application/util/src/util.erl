
-module(util).

-include("../../gate/include/logger.hrl").
-include("util.hrl").

-define(FRAME_TIME,42).	
-define(X_PIXELS,40).
-define(Y_PIXELS,20).

-compile(export_all).

-ifdef(TEST).
-define(RANDOM_SEED, skip).
-else.
-define(RANDOM_SEED, random:seed(erlang:now())).
-endif.

is_has_function(Script,Fun,Arith)->
	mod_util:load_module_if_not_loaded(Script),
	erlang:function_exported(Script,Fun,Arith).

sub_unicode_string(Utf8String,Length) when is_binary(Utf8String)->
	UniString = unicode:characters_to_list(Utf8String,unicode),
	unicode:characters_to_binary(lists:sublist(UniString,Length), utf8);

sub_unicode_string(InputString,Length) when is_list(InputString)->
	Utf8Binary = list_to_binary(InputString),
	sub_unicode_string(Utf8Binary,Length).

%%get_adjust_move_time({X1,Y1},{X2,Y2},Speed)->
%%	if
%%		(X2 - X1)*(Y2-Y1)>0 ->
%%			Rate = 1.12;
%%		(X2 - X1)*(Y2-Y1)<0 ->
%%			Rate = 0.56;
%%		(X2 - X1)*(Y2-Y1)=:=0 ->
%%			Rate = 1
%%	end,
%%	InclinedNum = min(abs(X2 - X1),abs(Y2-Y1)),
%%	StraightNum = max(abs(X2 - X1),abs(Y2-Y1)) - InclinedNum,
%%	trunc(1000/Speed*(StraightNum + InclinedNum/Rate)).

%% 获取现在时间（秒）
now_seconds() ->
	server_time:now_seconds().

%%now_seconds_tamp() ->
%%    {MegaSecs, Secs, _MicroSecs} = os:timestamp(),
%%    MegaSecs * 1000000 + Secs.

%% 获取现在时间（毫秒）
now_long_seconds() ->
	server_time:now_milseconds().

%%system_time() ->
%%    {MegaSecs, Secs, MicroSecs} = erlang:now(),
%%    (MegaSecs * 1000000 + Secs) * 1000000 + MicroSecs.

%% 获取秒对应日期
seconds_to_datetime(Seconds) ->
    DateTime = calendar:gregorian_seconds_to_datetime(Seconds + ?DIFF_SECONDS_0000_1970),
    calendar:universal_time_to_local_time(DateTime).

datetime_to_seconds(DateTime) ->
    [UniversalTime] = calendar:local_time_to_universal_time_dst(DateTime),
    calendar:datetime_to_gregorian_seconds(UniversalTime) - ?DIFF_SECONDS_0000_1970.

%% "19:00" -> second
string_hour_to_second(String) ->
	String1 = string:strip(String, both, $"),
	[StrHour, StrMin] = string:tokens(String1, ":"),
	Hour = list_to_integer(StrHour),
	Min = list_to_integer(StrMin),
	Hour * 3600 + Min * 60.

%% {19,0,0} -> second
hour_to_second({H,M,S}) ->
	TodayStart = get_today_start_second(),
	TodayStart + H*3600 + M*60 + S.

hour_to_second_0({H,M,S}) ->
	H*3600 + M*60 + S.

%% "2015-01-06 12:11:00" -> {{2015,1,6},{12,11,0}}
string_datetime_to_datetime(String) ->
    case string:tokens(String, " ") of
        [StrDate, StrTime] ->
            ok;
        [StrDate] ->
            StrTime = "00:00:00"
    end,
    [StrYear, StrMonth, StrDay] = string:tokens(StrDate, "-"),
    [StrHour, StrMinute, StrSecond] = string:tokens(StrTime, ":"),
    Year = list_to_integer(StrYear),
    Month = list_to_integer(StrMonth),
    Day = list_to_integer(StrDay),
    Hour = list_to_integer(StrHour),
    Minute = list_to_integer(StrMinute),
    Second = list_to_integer(StrSecond),
    {{Year, Month, Day}, {Hour, Minute, Second}}.

string_datetime_to_seconds(String) ->
    DateTime = string_datetime_to_datetime(String),
    datetime_to_seconds(DateTime).

%% 是否同一天
%%	28800：八时区间隔，86400：每天秒长
is_same_date_GMT(Seconds1, Seconds2) ->
    Day1 = (Seconds1 + ?TIME_ZONE_SECOND) div ?DAY_SECOND,
    Day2 = (Seconds2 + ?TIME_ZONE_SECOND) div ?DAY_SECOND,
    Day1 == Day2.

is_same_date(Seconds1, Seconds2) ->
	is_same_date_GMT(Seconds1, Seconds2).

is_same_date_local(Seconds1, Seconds2) ->
	Day1 = Seconds1 div ?DAY_SECOND,
    Day2 = Seconds2 div ?DAY_SECOND,
    Day1 == Day2.

is_same_date_spe(SpeSeconds, Seconds1, Seconds2) ->
	is_same_date_spe_GMT(SpeSeconds, Seconds1, Seconds2).

is_same_date_spe_local(SpeSeconds, Seconds1, Seconds2) ->
	SpeSeconds1 = SpeSeconds rem ?DAY_SECOND,
    Day1 = (Seconds1 - SpeSeconds1) div ?DAY_SECOND,
    Day2 = (Seconds2 - SpeSeconds1) div ?DAY_SECOND,
    Day1 == Day2.

%% 是否特定点后的24小时内
is_same_date_spe_GMT(SpeSeconds, Seconds1, Seconds2) ->
	SpeSeconds1 = SpeSeconds rem ?DAY_SECOND,
    Day1 = (Seconds1 + ?TIME_ZONE_SECOND - SpeSeconds1) div ?DAY_SECOND,
    Day2 = (Seconds2 + ?TIME_ZONE_SECOND - SpeSeconds1) div ?DAY_SECOND,
    Day1 == Day2.

%% 判断是否同一星期
is_same_week(Seconds1, Seconds2) ->
    {{Year1, Month1, Day1}, Time1} = seconds_to_datetime(Seconds1),
    % 星期几
    Week1  = calendar:day_of_the_week(Year1, Month1, Day1),
    % 从午夜到现在的秒数
    Diff1  = calendar:time_to_seconds(Time1),
    Monday = Seconds1 - Diff1 - (Week1 - 1) * ?DAY_SECOND,
    Sunday = Seconds1 + (7 - Week1) * ?DAY_SECOND + (?DAY_SECOND - Diff1),
    if 
		((Seconds2 >= Monday) and (Seconds2 < Sunday)) -> 
			true;
        true -> 
			false
    end.

%% 判断是否同一月
is_same_month_by_datetime(ErlLocalTime1, ErlLocalTime2) ->
	{{Y1, M1, _}, _} = ErlLocalTime1,
	{{Y2, M2, _}, _} = ErlLocalTime2,
	Y1 =:= Y2 andalso M1 =:= M2.

is_same_month(Seconds1, Seconds2) ->
    {{_Year1, Month1, _Day1}, _Time1} = seconds_to_datetime(Seconds1),
    {{_Year2, Month2, _Day2}, _Time2} = seconds_to_datetime(Seconds2),
	is_same_month_by_datetime(Month1, Month2).

get_special_day_start_second(Sec) ->
	Sec - (Sec + ?TIME_ZONE_SECOND) rem ?DAY_SECOND.

%% 获取今天凌晨秒数
get_today_start_second() ->
	NowSecond = now_seconds(),
	get_special_day_start_second(NowSecond).

%% 获取现在时间距格林标准时间的秒数
%% get_gregorian_seconds() ->
%%	LocalDateTime = calendar:local_time(),
%%	calendar:datetime_to_gregorian_seconds(LocalDateTime)-calendar:datetime_to_gregorian_seconds({{1970,1,1},{8,0,0}}).

%% 获取相差天数
get_diff_days(Seconds1, Seconds2) ->
    DateSeconds = ?DAY_SECOND,
    DifSeconds = abs(Seconds2 - Seconds1),
    DifSeconds div DateSeconds.

%% 获取星期
get_week_day() ->
	util:get_week_day(server_time:now_seconds()).

get_week_day(Seconds) ->
    {Date, _Time} = seconds_to_datetime(Seconds),
    calendar:day_of_the_week(Date).

%%%% 获取日期
%%get_month_day() ->
%%    {{_Year, Month, Day}, _Time} = calendar:local_time(),
%%    {Month, Day}.
%%
%%get_month_day(Seconds) ->
%%    {{_Year, Month, Day}, _Time} = seconds_to_datetime(Seconds),
%%    {Month, Day}.

init_rand_seed() ->
	?RANDOM_SEED,
	ok.

% 日期格式化 yyyy-MM-dd
now_to_local_string() ->
	binary_to_list(server_time:datebin2()).

%% 生成随机数
rand(Min, Max) when Min == Max ->
	Min;
rand(Min, Max) when Min >= Max ->
	rand(Max, Min);
rand(Min, Max) ->
	Min1 = Min - 1,
	random:uniform(Max - Min1) + Min1.

uniform() ->
	random:uniform().

%% bitstring转换为term <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> []; 
bitstring_to_term(<<"">>) -> [];
bitstring_to_term(BitString) ->
	if 
		is_binary(BitString)->
			string_to_term(binary_to_list(BitString));
		true->
			BitString
	end.

string_to_term(String)->
	case erl_scan:string(String++".") of
		{ok, Tokens, _}->
			case erl_parse:parse_term(Tokens) of
				{ok, Term} ->
					Term;
				_Reason ->
					undefined				
			end;
		_Reason ->
			undefined
	end.

%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~p", [Term]))).

term_to_wstring(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~w", [Term]))).

%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~p", [Term])).

now_to_ms({A,B,C})->
	A*1000000000+B*1000 + C div 1000.

ms_to_now(MsTime)->
	C = (MsTime rem 1000)*1000,
	STime = MsTime div 1000,
	B = STime rem 1000000,
	A = STime div 1000000,
	{A,B,C}.

change_now_time({A,B,C},MsTime)->
	NowMs = now_to_ms({A,B,C}),
	RealMs = NowMs + MsTime,
	ms_to_now(RealMs).

broadcast(Members, Msg) ->
	util:foreach(fun(H) -> H ! Msg end, Members).
  
even_div(Number,Divisor)->
	FloatNum = Number/Divisor,
	if
		 FloatNum - erlang:trunc(FloatNum)>0 ->
		 	erlang:trunc(FloatNum)+1;
		 true->	
		 	erlang:trunc(FloatNum)
	end.

idle_loop(Interval) ->
	timer:sleep(Interval),
	idle_loop(Interval).

format_utc_timestamp() ->
	TS = {_,_,Micro} = os:timestamp(),
	{{Year,Month,Day},{Hour,Minute,Second}} = calendar:now_to_local_time(TS),
	Mstr = element(Month,{"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}),
	io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w.~6..0w", [Day,Mstr,Year,Hour,Minute,Second,Micro]).

%% send_state_event(Node,ProcName,Event)->
%% 	CurNode = node(),
%% 	case Node of
%% 		CurNode -> 
%% 			gen_fsm:send_event(ProcName,Event);
%% 		_ ->
%% 			gen_fsm:send_event({ProcName,Node}, Event)
%% 	end.
%% 
%% sync_send_state_event(Node, ProcName, Event) ->
%% 	CurNode = node(),
%% 	case Node of
%% 		CurNode -> 
%% 			gen_fsm:sync_send_event(ProcName,Event);
%% 		_ ->
%% 			gen_fsm:sync_send_event({ProcName,Node}, Event)
%% 	end.
%% 
%% send_state_event(Pid,Event)->
%% 	gen_fsm:send_event(Pid,Event).

is_process_alive(Pid) 
  when is_pid(Pid) ->
	rpc:call(node(Pid), erlang, is_process_alive, [Pid]).

is_process_alive(undefined, _ProcName) ->
	false;
is_process_alive(_Node, undefined) ->
	false;
is_process_alive(Node, Pid)when is_pid(Pid) ->
	case rpc:call(Node, erlang, is_process_alive, [Pid]) of
		undefined ->
			false;
		_Pid ->
			true
	end;     
is_process_alive(Node, ProcName) ->
	case rpc:call(Node, erlang, whereis, [ProcName]) of
		undefined ->
			false;
		_Pid ->
			true
	end.      

make_int_str(Int)->
	integer_to_list(Int).

make_int_str2(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0", Str);
		_-> Str
	end.

make_int_str3(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00", Str);
		2-> string:concat("0", Str);
		_-> Str
	end.

make_int_str4(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("000", Str);
		2-> string:concat("00", Str);
		3-> string:concat("0", Str);
		_-> Str
	end.

make_int_str5(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000", Str);
		2-> string:concat("000", Str);
		3-> string:concat("00", Str);
		4-> string:concat("0", Str);
		_-> Str
	end.

make_int_str6(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00000", Str);
		2-> string:concat("0000", Str);
		3-> string:concat("000", Str);
		4-> string:concat("00", Str);
		5-> string:concat("0", Str);
		_-> Str
	end.

make_int_str7(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("000000", Str);
		2-> string:concat("00000", Str);
		3-> string:concat("0000", Str);
		4-> string:concat("000", Str);
		5-> string:concat("00", Str);
		6-> string:concat("0", Str);
		_-> Str
	end.	

make_int_str8(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000000", Str);
		2-> string:concat("000000", Str);
		3-> string:concat("00000", Str);
		4-> string:concat("0000", Str);
		5-> string:concat("000", Str);
		6-> string:concat("00", Str);
		7-> string:concat("0", Str);
		_-> Str
	end.
make_int_str20(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000000000000000000", Str);
		2-> string:concat("000000000000000000", Str);
		3-> string:concat("00000000000000000", Str);
		4-> string:concat("0000000000000000", Str);
		5-> string:concat("000000000000000", Str);
		6-> string:concat("00000000000000", Str);
		7-> string:concat("0000000000000", Str);
		8-> string:concat("000000000000", Str);
		9-> string:concat("00000000000", Str);
		10-> string:concat("0000000000", Str);
		11-> string:concat("000000000", Str);
		12-> string:concat("00000000", Str);
		13-> string:concat("0000000", Str);
		14-> string:concat("000000", Str);
		15-> string:concat("00000", Str);
		16-> string:concat("0000", Str);
		17-> string:concat("000", Str);
		18-> string:concat("00", Str);
		19-> string:concat("0", Str);
		_-> Str
	end.
make_int_str30(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00000000000000000000000000000", Str);
		2-> string:concat("0000000000000000000000000000", Str);
		3-> string:concat("000000000000000000000000000", Str);
		4-> string:concat("00000000000000000000000000", Str);
		5-> string:concat("0000000000000000000000000", Str);
		6-> string:concat("000000000000000000000000", Str);
		7-> string:concat("00000000000000000000000", Str);
		8-> string:concat("0000000000000000000000", Str);
		9-> string:concat("000000000000000000000", Str);
		10-> string:concat("00000000000000000000", Str);
		11-> string:concat("0000000000000000000", Str);
		12-> string:concat("000000000000000000", Str);
		13-> string:concat("00000000000000000", Str);
		14-> string:concat("0000000000000000", Str);
		15-> string:concat("000000000000000", Str);
		16-> string:concat("00000000000000", Str);
		17-> string:concat("0000000000000", Str);
		18-> string:concat("000000000000", Str);
		19-> string:concat("00000000000", Str);
		20-> string:concat("0000000000", Str);
		21-> string:concat("000000000", Str);
		22-> string:concat("00000000", Str);
		23-> string:concat("0000000", Str);
		24-> string:concat("000000", Str);
		25-> string:concat("00000", Str);
		26-> string:concat("0000", Str);
		27-> string:concat("000", Str);
		28-> string:concat("00", Str);
		29-> string:concat("0", Str);
		_-> Str
	end.
get_sql_res(Result,Field)->
	case lists:keyfind(Field,1,Result) of
		false-> [];
		{_,Value}->[{Field,Value}]
	end.

cat_atom(Atom1,Atom2)->
	Str1 = case erlang:is_atom(Atom1) of
		       true->atom_to_list(Atom1);
		       _-> Atom1
	       end,
	Str2 = case erlang:is_atom(Atom2) of
		       true->atom_to_list(Atom2);
		       _-> Atom2
	       end,
	list_to_atom(string:concat(Str1,Str2)).

cat_atom(AtomList)->
	F = fun(X)->
			    case erlang:is_atom(X) of
				    true->atom_to_list(X);
				    _-> X
			    end
	    end,
	list_to_atom(lists:concat(util:map(F, AtomList))).

make_field_list(Fields)->
	string:join(util:map(fun(X)-> atom_to_list(X) end,Fields),",").

safe_binary_to_list(Bin) when is_binary(Bin)->
	binary_to_list(Bin);
safe_binary_to_list(Bin)->
	Bin.

safe_list_to_binary(List) when is_list(List)->
	list_to_binary(List);
safe_list_to_binary(List)->
	List.
get_script_value(Bin)->
	Str = binary_to_list(Bin), 
	{ok,Ts,_} = erl_scan:string(Str), 
	Ts1 = case lists:reverse(Ts) of 
		      [{dot,_}|_] -> Ts; 
		      TsR -> lists:reverse([{dot,1} | TsR]) 
	      end, 
	{ok,Expr} = erl_parse:parse_exprs(Ts1), 
	{value,V,_} = erl_eval:exprs(Expr, []),
	V.

call_script(Bin)->
	Str = binary_to_list(Bin), 
	{ok,Ts,_} = erl_scan:string(Str), 
	Ts1 = case lists:reverse(Ts) of 
		      [{dot,_}|_] -> Ts; 
		      TsR -> lists:reverse([{dot,1} | TsR]) 
	      end, 
	{ok,Expr} = erl_parse:parse_exprs(Ts1), 
	erl_eval:exprs(Expr, []), 
	ok.	

which_class(ClassId) ->
	if
		(ClassId >= 500000000) and (ClassId < 600000000) ->
			skill;
		true ->
			undefined
	end.

get_distance(PosMy,PosEnemy)->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosEnemy,
	erlang:max(erlang:abs(Myx - Enemyx),erlang:abs(Myy - Enemyy)).

get_flytime(SkillSpeed,PosMy,PosEnemy)->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosEnemy,
	if
		SkillSpeed =< 0->
			0;
		Myx=:=Enemyx->
			erlang:trunc(erlang:abs(Myy - Enemyy)*20/SkillSpeed*42);
		Myy=:=Enemyy->
			erlang:trunc(erlang:abs(Myx - Enemyx)*40/SkillSpeed*42);
		true->
			if
				erlang:abs(Myx - Enemyx) >= erlang:abs(Myy - Enemyy)/2->
					erlang:trunc(erlang:abs(Myx - Enemyx)*40/SkillSpeed*42);
				true->
					erlang:trunc(erlang:abs(Myy - Enemyy)*20/SkillSpeed*42)
			end
	end.

is_in_range(PosMy,PosOther,Range) ->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosOther,
	((erlang:abs(Myx - Enemyx) =< Range) and (erlang:abs(Myy - Enemyy) =< Range)).

get_argument(Input) when is_atom(Input)->
	case init:get_argument(Input) of
		error-> [];
		{ok, [ArgString]}-> util:map(fun(E)-> list_to_atom(E) end, ArgString)
	end;
get_argument(Input) when is_list(Input)->
	case init:get_argument(list_to_atom(Input)) of
		error-> [];
		{ok, [ArgString]}-> util:map(fun(E)-> list_to_atom(E) end, ArgString)
	end;
get_argument(_Input)->
	[].

json_encode({struct,_MemberList}=Term)->
	try
		Json = json:encode(Term),
		{ok,list_to_binary(Json)}
	catch
		E:R-> 
			?ERROR_LOG("json_encode exception ~p:~p",[E,R]),
			{error,"Excption!"}
	end;
json_encode({scribe_valuetolist,_MemberList}=Term)->
	try
		Json = json:encode(Term),
		{ok,list_to_binary(Json)}
	catch
		E:R-> 
			?ERROR_LOG("json_encode scribe_valuetolist exception ~p:~p",[E,R]),
			{error,"Excption!"}
	end;
json_encode({scribe_static,_MemberList}=Term)->
	try
		Json = json:encode(Term),
		{ok,list_to_binary(Json)}
	catch
		E:R-> 
			?ERROR_LOG("json_encode scribe_static exception ~p:~p ~p",[E,R,Term]),
			{error,"Excption!"}
	end;
json_encode(S) when is_binary(S)->
	try
		Json = json:encode(S),
		{ok,list_to_binary(Json)}
	catch
		E:R-> 
			?ERROR_LOG("s_encode exception ~p:~p",[E,R]),
			{error,"Excption!"}
	end;
json_encode(_)->
	{error,"not support!"}.

json_decode(Json) when is_list(Json)->
	try
		Term = json:decode(Json),
		{ok,Term}
	catch
		E:R-> ?ERROR_LOG("json_decode exception ~p:~p",[E,R])
	end;
json_decode(Json) when is_binary(Json)->
	try
		Term = json:decode(binary_to_list(Json)),
		{ok,Term}
	catch
		E:R-> ?ERROR_LOG("json_decode exception ~p:~p",[E,R])
	end;
json_decode(_)->
	{error}.

get_json_member(JsonObj,Member) when is_list(Member)->
	get_json_member_pure(JsonObj,list_to_binary(Member));

get_json_member(JsonObj,Member)when is_binary(Member)->
	get_json_member_pure(JsonObj,Member);

get_json_member(_JsonObj,_Member)->
	{error,"bad arguments"}.

get_json_member_pure(JsonObj,Member)->
	case JsonObj of
		{struct,MemberList}-> 
			case lists:keyfind(Member, 1, MemberList) of
				false-> {error,"cannot find"};
				{_,Value}-> 
					if is_binary(Value)->
						   {ok,binary_to_list(Value)};
					   true->
						   {ok,Value}
					end
			end;
		_-> {error,"bad json"}
	end.

string_match(String,MatchList)->
	M = fun(Match,Acc)->
			case Acc of
				true-> true;
				false->
					case Match of
						"*"-> true;
						_->
							case string:right(Match,1) of
								"*"-> MatchStr = string:left(Match, erlang:length(Match)-1),
									  FindIndx = string:str(String, MatchStr),
									  if
										  FindIndx == 0->false;
										  true-> true
									  end;
								_-> Match =:= String
							end
					end
			end
		end,
	util:foldl(M, false, MatchList).

term_to_record(Term, RecordName) ->
	list_to_tuple([RecordName | tuple_to_list(Term)]).

term_to_record_for_list([], _TableName) ->
	[];
term_to_record_for_list(Term, TableName) when is_list(Term) ->
	[list_to_tuple([TableName | tuple_to_list(Tup)]) ||Tup <- Term].

file_read(FunTerm,FunError,FunProc,FunEof,FileName,ProcNum)->
	case file:open(FileName, read) of
		{ok,Fd}->
			do_file_read(Fd,0,ProcNum,FunTerm,FunError,FunProc,FunEof) ;
		{error,Reason}->
			FunError(Reason)
	end.

do_file_read(Fd,Num,ProcNum,FunTerm,FunError,FunProc,FunEof)->
	case io:read(Fd,'') of
		{ok,Term}->
			case ((Num+1) rem ProcNum) of
				0-> FunProc(Num+1);
				_-> nothing
			end,
			FunTerm(Term),
			do_file_read(Fd,Num + 1,ProcNum,FunTerm,FunError,FunProc,FunEof);
		eof ->
			FunEof(); 
		Error-> 
			FunError(Error)
	end.

get_qualty_color(Quality)->
	case Quality of
		0->["#ffffff"];
		1->["#00FF00"];
		2->["#3399ff"];
		3->["#ff00ff"];
		_->["#CD7F32"]
	end.

get_random_list_from_list(List,Count)->
	RandomFun = fun(dummy,{TempList,OriList})->
						Len = erlang:length(OriList),
						Random = random:uniform(Len),
						Tuple = lists:nth(Random,OriList),
						{TempList ++ [Tuple],lists:delete(Tuple, OriList)}
				end,
	{Back,_} = util:foldl(RandomFun, {[],List}, lists:duplicate(Count, dummy)),
	Back.

% TODO 
get_server_start_time()->
	PlatForm = env:get(platform,[]),
	if 
		PlatForm =:=[]->
			?ERROR_LOG("platform not find in option"),
			[];
		true->
			BaseServerId = env:get(baseserverid,0),
			ServerId = env:get(serverid,0),
			ServerNum = ServerId-BaseServerId,
			StartTimeList = env:get2(server_start_time,PlatForm,[]),
			case lists:keyfind(ServerNum, 1, StartTimeList) of
				false->
					?ERROR_LOG("not find server start time "),
					[];
				{_,ServerStartTime}->
					ServerStartTime
			end
	end.

sprintf(Format,Data)->
	TempList = io_lib:format(Format,Data),
	lists:flatten(TempList).

get_datetime_string() ->
    NowSeconds = now_seconds(),
	get_datetime_string(NowSeconds).

get_datetime_string(NowSeconds) ->
    DataTime = seconds_to_datetime(NowSeconds),
    format_datetime_to_string(DataTime).

format_datetime_to_string({{Year, Month, Day}, {Hour, Minute, Second}}) ->
  Date = lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0w", [Year, Month, Day])),
  Time = lists:flatten(io_lib:format("~2..0w:~2..0w:~2..0w", [Hour, Minute,Second])),
  Date ++ " " ++ Time.

%% --------------------------------------------------------------------
%% Func: replace_all/3
%% Purpose: Subject,RE,Replacement
%% Returns: List
%% --------------------------------------------------------------------
replace_all(Subject, RE, Replacement) ->
    replace_all(Subject, RE, Replacement, []). 

%% --------------------------------------------------------------------
%% Func: replace_all/4
%% Purpose: Subject,RE,Replacement,Options
%% Returns: List
%% --------------------------------------------------------------------
replace_all(Subject0, RE, Replacement, Options) ->
    Subject = 
        case Subject0 of
            undefined -> [];
            _ -> Subject0
        end,
    ReSubject = re:replace(Subject, RE, Replacement, Options),
    case ReSubject =:= Subject of
        false ->
            replace_all(ReSubject, RE, Replacement, Options);
        _ ->
            ReSubject
    end.

to_list(Msg) when is_list(Msg) -> 
    Msg;
to_list(Msg) when is_atom(Msg) -> 
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> 
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) -> 
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> 
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) ->
    tuple_to_list(Msg);
to_list(_) ->
    throw(other_value).

f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
    A.

%% 生成md5码
md5(S) ->
    Md5Bin = erlang:md5(S),
    Md5List = binary_to_list(Md5Bin), 
    lists:flatten(list_to_hex(Md5List)). 

list_to_hex(L) ->
    util:map(fun(X) -> int_to_hex(X) end, L).

%% 十进制转十六进制
int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
    $0 + N;
hex(N) when N >= 10, N < 16 ->
    $a + (N - 10).


%% 把List随机乱序   by sen
randomOrder(List) ->
	randomList(List,[]).

randomList([], NewList) ->
	NewList;

randomList(List,NewList) -> 
	Index = random(length(List)),
	E = lists:nth(Index,List),
	NewList1 = [E | NewList],
	List2 = List -- [E],
	randomList(List2, NewList1).

random(N) -> 
	if is_integer(N) -> 
			R = random:uniform(N),
			R;
		true -> ok
	end.

%% 返回列表中包含某个元素的个数
element_num(Elem, List) ->
	Fun = fun(E, Acc) ->
				if
					E == Elem ->
						Acc + 1;
					true ->
						Acc
				end
		  end,
	util:foldl(Fun, 0, List).

%% 格式化倒计时，n天n小时n分钟n秒
format_second_time(SecondTime) ->
    Days = SecondTime div ?DAY_SECOND,
    StrDay = 
        if
            Days > 0 ->
                io_lib:format("~p天", [Days]);
            true ->
                ""
        end,
    Hours = SecondTime rem ?DAY_SECOND div 3600,
    StrHour = 
        if
            Hours > 0 ->
                io_lib:format("~p小时", [Hours]);
            true ->
                ""
        end,
    Minutes = SecondTime rem 3600 div 60,
    StrMinster = 
        if
            Minutes > 0 ->
                io_lib:format("~p分钟", [Minutes]);
            true ->
                ""
        end,
    Seconds = SecondTime rem 60,
    StrSecond = 
        if
            Seconds > 0 ->
                io_lib:format("~p秒", [Seconds]);
            true ->
                ""
        end,
    lists:append([StrDay, StrHour, StrMinster, StrSecond]).

for(I, N, F) when I >= N -> [F()];
for(I, N, F) -> [F() | for(I + 1, N, F)].

%% get_words_verlist() ->
%%     Content = ["()sss"],
%%     Content_0 =  util:replace_all(Content, "[()\"?]", "", [{return,list}]),
%%     Content_1 =  util:replace_all(Content_0, " ", "", [{return,list}]),
%%     Content_2 =  util:replace_all(Content_1, "[\[]", "", [{return,list}]),
%%     Content_3 =  util:replace_all(Content_2, "[\]]", "", [{return,list}]),
%%     Content_4 =  util:replace_all(Content_3, "[+]", "", [{return,list}]),
%%     Content_5 =  util:replace_all(Content_4, "[=]", "", [{return,list}]),
%%     Content_6 = string:concat((util:to_list(Content_5)), ""),   %%",<,>,\\,/"),
%%     Content_list = string:tokens(Content_6, ","),
%%     Content_list_1 = 
%%         util:map(fun(Item) ->
%%                           Item1 = 
%%                               case lists:last(Item) == 92  of
%%                                   true -> lists:sublist(Item, length(Item)-1);
%%                                   _ -> Item
%%                               end,
%%                           lists:concat(['"', Item1, '"\t\n,'])
%%                   end, 
%%                   Content_list),
%%     Content_list_2 = lists:flatten(Content_list_1),
%%     Content_list_3 = 
%%         if 
%%             length(Content_list_2) > 0 ->
%%                 lists:sublist(Content_list_2, length(Content_list_2)-1);
%%             true -> 
%%                 []
%%         end,
%%     Content_list_3.
%% 
%% test() ->
%%     Content = "你好胡锦， 你好毛泽",
%%     FilterWords = ["胡锦", "毛泽"],
%%     Result = 
%%         util:foldl(fun(EKeyWord, AccContent) ->
%%                             util:replace_all(AccContent, EKeyWord, "*", [{return,list}])
%%                     end, 
%%                     Content, 
%%                     FilterWords),
%%     Result1 = erlang:list_to_bitstring(Result),
%%     io:format("~ts ~n", [Result1]),
%%     ok.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  list单元相关函数覆盖
-define(MAX_LOOP_COUNT, 1000000).
seq(Min, Max) ->
  Sub = erlang:abs(Max - Min),
  if
    (Sub > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
		lists:seq(Min, Max);
    true ->
      lists:seq(Min, Max)
  end.

map(Fun, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
      ?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
      lists:map(Fun, List);
    true ->
      lists:map(Fun, List)
  end.

foldl(Fun, Acc0, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
      lists:foldl(Fun, Acc0, List);
    true ->
      lists:foldl(Fun, Acc0, List)
  end.

foldr(Fun, Acc0, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
      lists:foldr(Fun, Acc0, List);
    true ->
      lists:foldr(Fun, Acc0, List)
  end.

filter(Predicate, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
      lists:filter(Predicate, List);
    true ->
      lists:filter(Predicate, List)
  end.

all(Predicate, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
      lists:all(Predicate, List);
    true ->
      lists:all(Predicate, List)
  end.

any(Predicate, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
		lists:any(Predicate, List);
    true ->
      lists:any(Predicate, List)
  end.

dropwhile(Predicate, List) ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
		lists:dropwhile(Predicate, List);
    true ->
      lists:dropwhile(Predicate, List)
  end.

foreach(Fun, List)  ->
  Len = erlang:length(List),
  if
    (Len > ?MAX_LOOP_COUNT) ->
		?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
		lists:foreach(Fun, List);
    true ->
      lists:foreach(Fun, List)
  end.

mapfoldl(Fun, Acc0, List) ->
	Len = erlang:length(List),
	if
		(Len > ?MAX_LOOP_COUNT) ->
			?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
			lists:mapfoldl(Fun, Acc0, List);
		true ->
			lists:mapfoldl(Fun, Acc0, List)
	end.

mapfoldr(Fun, Acc0, List) ->
	Len = erlang:length(List),
	if
		(Len > ?MAX_LOOP_COUNT) ->
			?INFO_LOG("Error ~p",[{?MODULE, ?LINE}]),
			lists:mapfoldr(Fun, Acc0, List);
		true ->
			lists:mapfoldr(Fun, Acc0, List)
	end.

%% 服务器已运行天数
get_server_pass_day() ->
	{ServerStartDate, _} = config_app:get_start_time(),
	ServerStartSec = datetime_to_seconds({ServerStartDate, {0,0,1}}),
	NowTime = now_seconds(),
	ServerRunDay = get_diff_days(ServerStartSec, NowTime) + 1,
	ServerRunDay.

%% 服务器已过月份 跨几个月
get_server_pass_month() ->
	{{ServerStartYear, ServerStartMon, _ServerStartDay}, _} = config_app:get_start_time(),
	{{NowDateYear, NowDateMon, _NowDateDay}, _} = server_time:localtime(),
	Month1 = (((NowDateYear - ServerStartYear)*12 + (NowDateMon - ServerStartMon))+1 )rem 12 ,
	if
		Month1 == 0 ->
			12;
		true ->
			Month1
	end.

check_battle_end_md5(EnterSeconds, Flag, ClientCheckString) ->
	StrParaLog = lists:concat([integer_to_list(EnterSeconds), integer_to_list(Flag)]),
	CheckSign = erlang:list_to_binary(util:md5(StrParaLog)),
	ClientCheckBin = erlang:list_to_binary(ClientCheckString),
	%io:format("check_battle_end_md5 ~p~n", [{ClientCheckBin, CheckSign}]),
	CheckSign == ClientCheckBin.

%%@doc 计算日期是当年中的第几周,简单算法（周日是每周的第一天）
week_of_year()->
	week_of_year( erlang:date() ).
week_of_year({_Year,_Month,_Day}=Date)->
	DaySum = get_date_sum(Date,0),
	((DaySum-1) div 7) + 1.

%%@doc 计算日期是当年中的第几周,简单算法（周日是每周的最后一天） (该判断第几周为物理周)
week_of_year2() ->
	week_of_year2( erlang:date() ).
week_of_year2(Date) ->
	case calendar:day_of_the_week(Date) =:= 7 of
		true ->
			week_of_year(Date) - 1;
		false ->
			week_of_year(Date)
	end.

get_date_sum({_Year,1,Day},DaysAccIn)->
	DaysAccIn+Day;
get_date_sum({Year,Month,Day},DaysAccIn)->
	NewDays = calendar:last_day_of_the_month(Year,Month-1) + DaysAccIn,
	get_date_sum({Year,Month-1,Day},NewDays).

%% @doc convert other type to atom
to_atom(Msg) when is_atom(Msg) ->
	Msg;
to_atom(Msg) when is_binary(Msg) ->
	list_to_atom(binary_to_list(Msg));
to_atom(Msg) when is_list(Msg) ->
	list_to_atom(Msg);
to_atom(_) ->
	throw(other_value).  %%list_to_atom("").

get_date_time_str(DayTime) ->
	{{Year1, Month1, Day1}, {Hour1, Min1, Sec1}} = DayTime,
	lists:concat([Year1, "-", Month1, "-", Day1, " ", Hour1, ":", Min1, ":", Sec1]).

update_keylist_data(Key, AddNum, List) ->
	case lists:keyfind(Key, 1, List) of
		false ->
			lists:keystore(Key, 1, List, {Key, AddNum});
		{_, OldNum} ->
			lists:keystore(Key, 1, List, {Key, AddNum + OldNum})
	end.

rank_history_db_time_to_timestamp(LastCheckDate)->
	<<Year:4/binary, "-", Month:2/binary, "-", Day:2/binary>> = list_to_binary(LastCheckDate),
    calendar:datetime_to_gregorian_seconds({{list_to_integer(binary_to_list(Year)),
        list_to_integer(binary_to_list(Month)),list_to_integer(binary_to_list(Day))},{0,0,0}}).