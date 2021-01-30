%% @author zouv
%% @doc @todo 模拟登陆

-module(test_client).

-compile(export_all).

-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("network_proto/include/niu_game_pb.hrl").
-include_lib("network_proto/include/hundred_niu_pb.hrl").

-include("common.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

%test_client:login("1358184").
login(Account) ->
	Password = "",
	PlatformFalg = 1000001,
	login(Account, Password, PlatformFalg).

login(Account, TempPassword, PlatformFalg) ->
	Fun =
		fun() ->
			%% 建立连接
			Port = config_app:get_tcp_port(),
			{ok, TcpSocket} = gen_tcp:connect("121.196.16.213", Port, [binary, {active, true}, {packet, 4}]),
			%% 发送登录请求
			Password = list_to_binary(TempPassword),
			LoginInfo =
				#cs_login{
					platform_flag = PlatformFalg,
					uid = Account,
					password = Password,
					sz_param = "MTM1ODE4NCwxNTkwMzI3NTA0LDAsMCwwLDAsMCwwLDAsODM5YWYzZTRiZDk5OGRhZDQ3ZGFiZjk3OGE3NWIyZWI",
					version = "",
					network_type = "",
					sys_type = 0,
					chnid = 1,
					sub_chnid = 1,
					ios_idfa = "",
					ios_idfv = "",
					mac_address = "",
					device_type = ""
				},
			{ok, Bin} = message_code:encode(LoginInfo),
			NewBin = <<0:32, Bin/binary>>,
			gen_tcp:send(TcpSocket, NewBin),
			A = gen_tcp:recv(TcpSocket,0),
			A
		end,
	Fun().

enter_room(PlayerId1, Level) ->
	PlayerId =
		if
			is_integer(PlayerId1) ->
				PlayerId1;
			true ->
				{ok, [Account]} = account_to_player_id_db:get_base(PlayerId1),
				Account#account_to_player_id.player_id
		end,

	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			Msg = #cs_niu_enter_room_req{room_type = Level},
			role_processor_mod:cast(PlayerPid, {'handle', player_niu_room_util, enter_room, [Msg]});
		_ ->
			offline
	end,
	ok.

get_player_id(PlayerId1) ->
	if
		is_integer(PlayerId1) ->
			PlayerId1;
		true ->
			{ok, [Account]} = account_to_player_id_db:get_base(PlayerId1),
			Account#account_to_player_id.player_id
	end.

leave_room(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_niu_room_util, leave_room, []});
		_ ->
			offline
	end,
	ok.

get_room_last_sec() ->
	[RoomInfo] = ets:lookup(?ETS_NIUNIU_ROOM, 1),
	Pid = RoomInfo#niu_room_info.room_pid,
	RoomId = RoomInfo#niu_room_info.room_id,
	PlayerRoom = #player_niu_room_info{
		room_id = RoomId,
		room_pid = Pid,
		player_id = 0
	},
	player_niu_room_util:get_room_last_sec(PlayerRoom),
	ok.

%% %% 退出登陆
%% %test_client:logout("zouwei1").
%% logout(Account) ->
%% 	tools_operation:kick_player(Account).


syn_player_game_all_the_time(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_niu_room_util, syn_player_game_all_the_time, []});
		_ ->
			offline
	end.

syn_player_game(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_niu_room_util, syn_player_game, []});
		_ ->
			offline
	end.

reward_item(PlayerId, ItemId, Num) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', item_use, imme_items_reward, [[{ItemId, Num}], 1]});
		_ ->
			offline
	end.

enter_hun_room(PlayerId) ->
	case role_manager:get_roleprocessor(get_player_id(PlayerId)) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, enter_room, []});
		_ ->
			offline
	end.

set_chips(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, cs_hundred_niu_free_set_chips_req, [1, 100, 1]});
		_ ->
			offline
	end.

sit_down(PlayerId, Flag) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, cs_hundred_niu_sit_down_req, [Flag]});
		_ ->
			offline
	end.

be_master(PlayerId,Flag) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, cs_hundred_be_master_req, [Flag]});
		_ ->
			offline
	end.

query_winning_rec(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, cs_hundred_query_winning_rec_req, []});
		_ ->
			offline
	end.

query_free_list(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_hundred_niu_util, cs_hundred_niu_player_list_query_req, []});
		_ ->
			offline
	end.

chat(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_chat, cs_chat, [1,0,"2123",""]});
		_ ->
			offline
	end.

rank(PlayerId, Type) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_rank_util, cs_rank_query_req, [Type]});
		_ ->
			offline
	end.

rechage_test(PlayerId, Flag) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', gm_cmd, rechage_test, [Flag]});
		_ ->
			offline
	end.

laba_test(PlayerId, Flag) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_laba_util, cs_laba_spin_req, [Flag, 500, 0, 1]});
		_ ->
			offline
	end.

prize(PlayerId, Flag) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, PlayerPid} ->
			role_processor_mod:cast(PlayerPid, {'handle', player_prize_util, cs_prize_exchange_req, [Flag, 1, "11111", 1]});
		_ ->
			offline
	end.

show_process() ->
	ets:foldl(fun(E, _Acc) ->
		RobotId = E#player_niu_room_info.player_id,
		case role_manager:get_roleprocessor(RobotId) of
			{ok, Pid} ->
				{memory, Memory} = erlang:process_info(Pid, memory),
				io:format("Memory ~p~n",[Memory]);
			_ ->
				skip
		end end, [], ?ETS_HUNDRED_PLAYER_IN_GAME),
	ok.

test_sgte() ->
	{ok, [Rec]} = announcement_db:load_announcement_by_condition({vip_level,1}),
	Content = Rec#announcement.content,
	{ok, _ComStr} = sgte:compile(Content).