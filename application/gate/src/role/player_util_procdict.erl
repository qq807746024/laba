%% @author zouv
%% @doc @todo 玩家进程字典接口

-module(player_util_procdict).

-include("common.hrl").

%% 进程字典
-define(DIC_IS_NEW_PLAYER,                  dic_is_new_player).             % 是否新玩家
-define(DIC_PLAYER_TIMER,                   dic_player_timer).              % 玩家进程定时器
-define(DIC_LOGIN_RECONNECTION_KEY,         dic_login_reconnection_key).    % 重连密码
-define(DIC_SOCKET_BUFFER,                  dic_socket_buffer).             % socket缓存
-define(DIC_GARBAGE_COLLECT_TIME,           dic_garbage_collect_time).      % 垃圾回收时间
-define(DIC_PLAYER_UID,                     dic_player_uid).                % 玩家uid
-define(DIC_GATE_PROC_CLOSE_TIME,           dic_gate_proc_close_time).      % 网关进程关闭时间

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	is_new_player/0,
	update_dic_is_new_player/1,
	get_dic_player_timer/0,
	update_dic_player_timer/1,
	get_dic_login_reconnection/0,
	make_login_reconnection_key/0,
	get_login_reconnection_key/0,
	update_dic_socket_buffer/1,
	get_dic_socket_buffer/0,
	update_dic_garbage_collect_time/1,
	get_dic_garbage_collect_time/0,
	update_dic_player_uid/1,
	get_dic_player_uid/0,
	update_dic_gate_proc_close_time/1,
	get_dic_gate_proc_close_time/0

]).

%% ====================================================================
%% Internal functions
%% ====================================================================
%% --------------- 是否新玩家 ---------------
%% 是否新账号
is_new_player() ->
	case get(?DIC_IS_NEW_PLAYER) of
		undefined ->
			false;
		Value ->
			Value == true
	end.

update_dic_is_new_player(Value) ->
	put(?DIC_IS_NEW_PLAYER, Value).

%% --------------- 玩家进程定时器信息 ---------------
get_dic_player_timer() ->
	case get(?DIC_PLAYER_TIMER) of
		undefined ->
			#player_timer{};
		PlayerTimer ->
			PlayerTimer
	end.

update_dic_player_timer(PlayerTimer) ->
	put(?DIC_PLAYER_TIMER, PlayerTimer).

%% --------------- 重连密码 ---------------
get_dic_login_reconnection() ->
	case get(?DIC_LOGIN_RECONNECTION_KEY) of
		{Source, Key} ->
			{Source, Key};
		R ->
			?ERROR_LOG("get dic login reconnection Error! ~p~n", [{R, player_util:get_dic_player_info()}]),
			{0, ""}
	end.

update_dic_login_reconnection({Source, Key}) ->
	put(?DIC_LOGIN_RECONNECTION_KEY, {Source, Key}).

make_login_reconnection_key() ->
	NowLongSeconds = util:now_long_seconds(),
	Binary = list_to_binary(integer_to_list(NowLongSeconds)),
	Key = erlang:md5(Binary),
	StrKey = binary_to_list(Key),
	update_dic_login_reconnection({NowLongSeconds, StrKey}),
	StrKey.

get_login_reconnection_key() ->
	{_Source, Key} = get_dic_login_reconnection(),
	Key.

%% --------------- socket缓存 ---------------
%% 因为gate_proc可能中途被关闭，此时需把gate_proc里缓存的数据转移到玩家进程
update_dic_socket_buffer(SocketBuffer) ->
	put(?DIC_SOCKET_BUFFER, SocketBuffer),
	ok.

get_dic_socket_buffer() ->
	case get(?DIC_SOCKET_BUFFER) of
		undefined ->
			[];
		SocketBuffer ->
			SocketBuffer
	end.

%% --------------- 垃圾回收时间 ---------------
update_dic_garbage_collect_time(Time) ->
	put(?DIC_GARBAGE_COLLECT_TIME, Time).

get_dic_garbage_collect_time() ->
	case get(?DIC_GARBAGE_COLLECT_TIME) of
		undefined ->
			0;
		Time ->
			Time
	end.

update_dic_player_uid(UidInfo) ->
	put(?DIC_PLAYER_UID, UidInfo).

get_dic_player_uid() ->
	case get(?DIC_PLAYER_UID) of
		undefined ->
			[];
		UidInfo ->
			UidInfo
	end.

%% --------------- 垃圾回收时间 ---------------
update_dic_gate_proc_close_time(Time) ->
	put(?DIC_GATE_PROC_CLOSE_TIME, Time).

get_dic_gate_proc_close_time() ->
	case get(?DIC_GATE_PROC_CLOSE_TIME) of
		undefined ->
			[];
		Time ->
			Time
	end.

