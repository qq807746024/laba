%% @author zouv
%% @doc @todo 系统公告

-module(sys_notice_mod).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(DIC_SEND_MSG_NOTICE_TIME,       dic_send_msg_notice_time).  % 记录上次公告时间

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start_link/1,
		 get_mod_pid/0,
		 send_notice/1,
		 send_notice/3,
         package_sc_tips/1,
		 
		 send_notice_scroll/4, 
		 send_notice_scroll_interface/4,
		 test/1,
		send_to_all_player/1,
		pack_tips_msg/2
		
		]).


%% ====================================================================
%% Behavioural functions 
%% ====================================================================
-record(state, {}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).


%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, State}
			| {ok, State, Timeout}
			| {ok, State, hibernate}
			| {stop, Reason :: term()}
			| ignore,
	State :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([ModProcessName]) ->
    process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),
    {ok, #state{}}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
	Result :: {reply, Reply, NewState}
			| {reply, Reply, NewState, Timeout}
			| {reply, Reply, NewState, hibernate}
			| {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason, Reply, NewState}
			| {stop, Reason, NewState},
	Reply :: term(),
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_call(Request, From, State) ->
	try
		do_call(Request, From, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod call Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Request}, erlang:get_stacktrace()]),
			{reply, ok, State}
	end.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Msg, State) ->
	try
		do_cast(Msg, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
			{noreply, State}
	end.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(Info, State) ->
	try
		do_info(Info, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Info}, erlang:get_stacktrace()]),
			{noreply, State}
	end.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(_Reason, _State) ->
    ?ERROR_LOG("~p terminated ~n", [?MODULE]),
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
	Result :: {ok, NewState :: term()} | {error, Reason :: term()},
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ====================================================================
do_call(Request, From, State) ->
	?ERROR_LOG("~p call no match! info = ~p~n", [?MODULE, {Request, From}]),
	{reply, ok, State}.

%% ====================================================================
%% 广播协议
do_cast({'send_msg_to_all', Msg}, State) ->
	ets:foldl(fun(E, Acc) ->
				  #ets_online{
							  gate_pid = GatePid
							 } = E,
				  tcp_client:send_data(GatePid, Msg),
				  Acc
			  end, 
			  [], 
			  ?ETS_ONLINE),
	{noreply, State};

%% 发布公告
do_cast({'send_msg_notice_to_all', Flag, Content}, State) ->
    Msg =  #sc_player_sys_notice{
		flag = Flag, 
		content = Content
	},
	%% 不考虑时间cd
	ets:foldl(fun(E, Acc) ->
		#ets_online{
			gate_pid = GatePid
		} = E,
		tcp_client:send_data(GatePid, Msg),
		Acc
	end, [], ?ETS_ONLINE),
	{noreply, State};

do_cast(Msg, State) ->
	?ERROR_LOG("~p cast no match! info = ~p~n", [?MODULE, Msg]),
	{noreply, State}.

%% ====================================================================

	
do_info(Info, State) ->
	?ERROR_LOG("~p info no match! info = ~p~n", [?MODULE, Info]),
	{noreply, State}.
%% ====================================================================
%% Internal functions
%% ====================================================================

%% 发送提示
send_notice(StrMsg) ->
	case player_util:get_dic_gate_pid() of
		GatePid when is_pid(GatePid) ->
			ScTips =
				#sc_tips{
						 type = 1,
						 text = StrMsg
						},
			tcp_client:send_data(GatePid, ScTips);
		_ ->
			{error, gate_not_exist}
	end.

%% 发送提示
send_notice(GatePid, Type, StrMsg) ->
	ScTips = #sc_tips{
					  type = Type,
					  text = StrMsg
					 },
	tcp_client:send_data(GatePid, ScTips).

package_sc_tips(StrMsg) ->
    #sc_tips{
             type = 0,
             text = StrMsg
            }.

%% 定时按频率发送公告
send_notice_scroll(DelayTime,EndTime, Pinlv, Content) ->
	ModPid = sys_notice_mod:get_mod_pid(),
	erlang:send_after(DelayTime*1000, ModPid, {'send_msg_notice_scroll',Content, EndTime,Pinlv}).

%% 发送定时循环公告对外接口
%% Timer 间隔时间   Continue 发送持续时间 by sen
send_notice_scroll_interface(BeginTime,EndTime, Pinlv, Content) ->	
	Beginseconds = calendar:datetime_to_gregorian_seconds(BeginTime)-calendar:datetime_to_gregorian_seconds({{1970,1,1},{8,0,0}}),
	EndTimeseconds = calendar:datetime_to_gregorian_seconds(EndTime)-calendar:datetime_to_gregorian_seconds({{1970,1,1},{8,0,0}}),
	LocalTime = calendar:local_time(),
	Nowseconds = calendar:datetime_to_gregorian_seconds(LocalTime)-calendar:datetime_to_gregorian_seconds({{1970,1,1},{8,0,0}}),
	DelayTime = max(Beginseconds - Nowseconds, 5),
    send_notice_scroll(DelayTime,EndTimeseconds, Pinlv, Content).
 
test(StrContent) ->
	BeginTime = {{2015,11,10},{16,20,0}},
	Pinlv = 20,
	LocalTime = calendar:local_time(),
	LocalSencond = calendar:datetime_to_gregorian_seconds(LocalTime),
	EndSecond = LocalSencond+60*3,
	EndTime = calendar:gregorian_seconds_to_datetime(EndSecond),

	send_notice_scroll_interface(BeginTime,EndTime,Pinlv,StrContent).

%% 发送公告
send_to_all_player(Msg) ->
	ModPid = get_mod_pid(),
	gen_server:cast(ModPid, {'send_msg_to_all', Msg}).

pack_tips_msg(Type, StrMsg) ->
	#sc_tips{
		type = Type,
		text = StrMsg
	}.