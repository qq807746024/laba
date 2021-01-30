-module(tcp_client).
-include("../../gate/include/logger.hrl").
-behaviour(gen_fsm).

-define(ALIVE_CHECK_TIMER, 60).            % 60秒钟检测一次
-define(HEARTBEAT_INTERVAL, 300).           % 5分钟客户端心跳间隔限制
-define(BXOR_PASSWORD_TABLE,
  [193,99,190,162,68,114,121,28,140,17,9,71,5,7,189,79,135,239,114,186,61,60,
  203,29,106,98,194,62,38,1,131,1,239,112,117,121,195,62,118,146,162,90,110,
  42,28,68,102,141,0,86,88,77,0,159,22,209,84,114,90,139,57,209,75,65,162,226,
  6,82,235,0,170,81,77,52,111,8,237,200,190,53,8,172,177,42,14,248,176,246,19,
  139,235,234,168,244,133,126,246,220,21,52,89,174,243,203,126,58,157,34,146,
  216,202,59,102,228,172,51,117,187,238,25,134,24,188,191,23,0,216,182,40,25,
  84,37,182,139,20,38,162,69,46,144,142,125,128,204,107,0,204,135,82,107,111,
  145,42,254,162,123,198,188,24,174,232,166,145,169,41,57,224,248,55,213,6,122,
  156,243,121,135,152,218,137,84,155,198,133,68,244,60,59,54,189,65,180,137,20,
  245,163,117,20,44,159,253,241,207,85,247,195,46,53,112,67,150,230,174,41,149,
  180,123,42,237,131,107,194,130,139,154,177,135,92,99,187,4,83,10,144,138,120,
  189,215,81,56,61,212,144,32,215,18,132,19,65,102,229,83,188,11,184,144,51]).

%% -define(TCP_OPTIONS, [binary, {active, once}, {packet, 4}, {packet_size, 65535}, {linger, {true,0}},
%%                       {nodelay, true}, {keepalive,true}, 
%%                       {recbuf, 4*1024},{sndbuff, 64*1024}, 
%%                       {delay_send, true}, {send_timeout, 3000}, 
%%                       {high_watermark, 128*1024}, {low_watermark, 64*1024}]).
%Options = [binary, {active, once}, {packet, 4}, {packet_size, 65535}, {delay_send, true}],

-define(TCP_OPTIONS, [binary, {active, once}, {packet, 4}, {packet_size, 1966050}, {linger, {true, 0}},
  {nodelay, false}, {keepalive, true},
  {send_timeout, 3000},
  {delay_send, true},
  {sndbuf, 64 * 1024}, {recbuf, 16 * 1024},
  {high_watermark, 128 * 1024}, {low_watermark, 64 * 1024}]).

-define(DIC_ON_SOCKET_RECEIVE, dic_on_socket_receive).
-define(DIC_ON_SOCKET_CLOSE, dic_on_socket_close).
-define(DIC_HEARTBEAT_TIME, dic_heartbeat_time).

-record(state, {
  client_socket = undefined,
  client_ip = "",
  player_pid = undefined,     % 不再直接使用这个Pid，通过get_player_pid获取 by_zouv_20150123
  player_id = undefined,
  account = "",
  proto_key = <<>>
}).

-export([
  init/1,
  connecting/2,
  connected/2,
  handle_event/3,
  handle_sync_event/4,
  handle_info/3,
  terminate/3,
  code_change/4
]).

-export([
  start_link/2,

  socket_ready/3,
  socket_disable/3,

  login/2,
  login_out/1,
  login_reconnection/2,
  heartbeat/0,
  send_data/2,
  send_bin/2
]).

start_link(OnSocketReceive, OnSocketClose) ->
  gen_fsm:start_link(?MODULE, [OnSocketReceive, OnSocketClose], []).

%% ------------------------------------------------------------------
%% init
%% ------------------------------------------------------------------
init([OnSocketReceive, OnSocketClose]) ->
  process_flag(trap_exit, true),
  put(?DIC_ON_SOCKET_RECEIVE, OnSocketReceive),
  put(?DIC_ON_SOCKET_CLOSE, OnSocketClose),
  random:seed(now()),
  erlang:send_after(?ALIVE_CHECK_TIMER * 1000, self(), {'alive_check'}),
  {ok, connecting, #state{}}.

%% ------------------------------------------------------------------
%% handle_event
%% ------------------------------------------------------------------
%% 同步socket缓存
handle_event({'update_socket_buffer', _SocketBuffer}, StateName, State) ->
%%     ClientSocket = State#state.client_socket,
%%     socket_buffer:update_socket_buffer(SocketBuffer, ClientSocket),
  {next_state, StateName, State};

handle_event(_Event, StateName, State) ->
  {next_state, StateName, State}.

%% ------------------------------------------------------------------
%% handle_sync_event
%% ------------------------------------------------------------------
%% 关闭旧网关
handle_sync_event({'close_old_gate_proc', _LastClientIp, Flag}, _From, _StateName, State) ->
  %?INFO_LOG("~nclose old gate! info = ~s ~s ~s ~w~n", [State#state.account, State#state.client_ip, LastClientIp, {Flag, erlang:localtime()}]),
  if
  %% 重连
    Flag == 'login_rec' ->
      SocketBuffer = socket_buffer:get_socket_buffer(),
      {stop, normal, SocketBuffer, State};
  %% 重复登陆
    true ->
      %ScLoginRepeat = player_util:package_login_repeat(),
      ScLoginRepeat = sys_notice_mod:pack_tips_msg(1, "在其他地方登入了该账号"),
      send_to_client(ScLoginRepeat, State#state.client_socket, State#state.proto_key),
      {stop, normal, [], State}
  end;

handle_sync_event(Event, From, StateName, State) ->
  ?ERROR_LOG("~p sync_event no match =~p ~p ~n", [?MODULE, Event, From]),
  {reply, ok, StateName, State}.

%% ------------------------------------------------------------------
%% handle_info
%% ------------------------------------------------------------------
%% 客户端心跳检测
handle_info({'alive_check'}, StateName, State) ->
  case get(?DIC_HEARTBEAT_TIME) of
    undefined ->
      NowTime = util:now_seconds(),
      update_heartbeat_time(NowTime),
      erlang:send_after(?ALIVE_CHECK_TIMER * 1000, self(), {'alive_check'});
    OldTime ->
      NowTime = util:now_seconds(),
      case NowTime - OldTime > ?HEARTBEAT_INTERVAL of
        true ->
          self() ! {'tcp_closed', 0};
        _ ->
          erlang:send_after(?ALIVE_CHECK_TIMER * 1000, self(), {'alive_check'})
      end
  end,
  {next_state, StateName, State};

%% handle_info({'heartbeat_timer'}, StateName, State) ->
%%     erlang:send_after(3 * 1000, self(), {'heartbeat_timer'}),
%%     Msg = player_util:packet_heartbeat(),
%%     send_to_client(Msg, State#state.client_socket),
%%     {next_state, StateName, State};

%% 连接中断
handle_info({'tcp_closed', _Socket}, _StateName, State) ->
  cast_player_close_gate_proc(State),
  {stop, normal, State};

%% 发送数据
handle_info({'send_data', Msg}, StateName, State) ->
  send_to_client(Msg, State#state.client_socket, State#state.proto_key),
  {next_state, StateName, State};

handle_info({tcp, Socket, BinData}, StateName, State) ->
  {M, F, A} = get(?DIC_ON_SOCKET_RECEIVE),
  #state{
    client_socket = ClientSocket,
    client_ip = ClientIp,
    proto_key = ProtoKey
  } = State,
  GatePid = self(),
  PlayerPid = get_player_pid(State),
  apply(M, F, A ++ [GatePid, BinData, ClientSocket, ClientIp, PlayerPid, ProtoKey]),
  inet:setopts(Socket, [{active, once}]),
  {next_state, StateName, State};

handle_info({tcp_error, Socket, Reason}, StateName, State) ->
  case Reason of
    etimedout ->
      case get(?DIC_HEARTBEAT_TIME) of
        OldTime when is_integer(OldTime) ->
          HeartBeatInterval = util:now_seconds() - OldTime;
        _ ->
          HeartBeatInterval = 0
      end,
      io:format("tcp error_______________ ~p~n", [{Reason, StateName, HeartBeatInterval, State#state.account}]);
    _ ->
      ?ERROR_LOG("~n ~p tcp error : ~p ~p ~p ~p", [?MODULE, Socket, Reason, StateName, State])
  end,
  {next_state, StateName, State};

handle_info({inet_reply, _Socket, _Reply}, StateName, State) ->
  {next_state, StateName, State};

handle_info(Info, StateName, State) ->
  ?ERROR_LOG("~n ~p info no match = ~p ~p ~p", [?MODULE, Info, StateName, State]),
  {next_state, StateName, State}.

terminate(Reason, _StateName, State) ->
  {M, F, A} = get(?DIC_ON_SOCKET_CLOSE),
  ClientSocket = State#state.client_socket,
  PlayerPid = get_player_pid(State),
  PlayerId = State#state.player_id,
  Account = State#state.account,
  case erlang:is_port(ClientSocket) of
    true ->
      gen_tcp:close(ClientSocket);
    _ ->
      skip
  end,
  apply(M, F, A ++ [Reason, ClientSocket, PlayerPid, PlayerId, Account]).

code_change(_OldVsn, StateName, StateData, _Extra) ->
  {ok, StateName, StateData}.

%% ------------------------------------------------------------------
%% Module:StateName
%% ------------------------------------------------------------------
%% 完成socket连接
connecting({socket_ready, ClientSocket, ClientIP}, State) ->
  inet:setopts(ClientSocket, ?TCP_OPTIONS),
  case inet:peername(ClientSocket) of
    {ok, {PeerIPAddress, _Port}} ->
      put(clientaddr, PeerIPAddress),
      NewState =
        State#state{
          client_socket = ClientSocket,
          client_ip = ClientIP
        },
      {next_state, connected, NewState};
    {error, Error} ->
      ?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE, Error}]),
      {stop, normal, State}
  end;

connecting({socket_disable, ClientSocket}, State) ->
  self() ! {kick_client, "socket is disable"},
  NewState =
    State#state{
      client_socket = ClientSocket
    },
  {stop, normal, NewState};

connecting(_Event, StateData) ->
  {next_state, connecting, StateData}.

%% 请求登陆
connected({'login', Message}, State) ->
  case get_player_pid(State) of
    PlayerPid when is_pid(PlayerPid) ->
      ScLoginReply = player_util:package_login_reply(0, "repeated", "", <<>>),
      send_to_client(ScLoginReply, State#state.client_socket, State#state.proto_key),
      {next_state, connected, State};
    _ ->
      login_handle(Message, State)
  end;

%% 退出登陆
connected({'login_out'}, State) ->
  call_player_close_player_proc(State),
  self() ! {'tcp_closed', 1},
  {next_state, connected, State};

%% 重连
connected({'login_reconnection', Message}, State) ->
  case login_check:is_validate_reconnection(Message) of
    {ok, PlayerId, PlayerPid, Account} ->
      NewState = init_player_info(State, Account, PlayerId, PlayerPid),
      role_processor:set_gate_proc(PlayerPid, self(), NewState#state.proto_key, 'login_rec', false),
      {next_state, connected, NewState};
    {false, Reason} ->
      ScLoginReconReply = player_util:package_login_reconnection_reply(0, Reason, <<>>),
      send_to_client(ScLoginReconReply, State#state.client_socket, State#state.proto_key),
      {next_state, connected, State}
  end;

connected(_Event, State) ->
  {next_state, connected, State}.

%% ==================================================
socket_ready(GatePid, ClientSocket, ClientIP) ->
  gen_fsm:send_event(GatePid, {'socket_ready', ClientSocket, ClientIP}).

socket_disable(_GateNode, GatePid, ClientSocket) ->
  gen_fsm:send_event(GatePid, {'socket_disable', ClientSocket}).

login(GatePid, Message) ->
  gen_fsm:send_event(GatePid, {'login', Message}).

login_out(GatePid) ->
  gen_fsm:send_event(GatePid, {'login_out'}).

%% 取消重连功能
login_reconnection(_GatePid, _Message) ->
  ok.
%gen_fsm:send_event(GatePid, {'login_reconnection', Message}).

%% 心跳包
heartbeat() ->
  NowTime = util:now_seconds(),
  update_heartbeat_time(NowTime),
  player_util:send_heartbeat_reply(self(), NowTime).

%% 发送协议
send_data(GatePid, Msg) ->
% 	%% *************打印发送的消息*************
%  		TempMsg = tuple_to_list(Msg),
%  		[MsgName | _] = TempMsg,
%  		io:format("~n ##########    send_to_client Msg,  MsgName = ~p", [MsgName]),
% 	%% ***********************************

  if
    GatePid == undefined ->
      skip;
    true ->
      GatePid ! {'send_data', Msg}
  end.

%% 初始化玩家信息
init_player_info(State, Account, PlayerId, PlayerPid) ->
  NowTime = util:now_seconds(),
  update_heartbeat_time(NowTime),
  put(dic_account, Account),
  ProtoKey = crypto:rand_bytes(16),
  State#state{
    player_pid = PlayerPid,
    player_id = PlayerId,
    account = Account,
    proto_key = ProtoKey
  }.

%% 通知网关中断
cast_player_close_gate_proc(State) ->
  case get_player_pid(State) of
    PlayerPid when is_pid(PlayerPid) ->
      SocketBuffer = socket_buffer:get_socket_buffer(),
      role_processor:close_gate_proc(PlayerPid, SocketBuffer);
    _ ->
      skip
  end.

%% 通知关闭玩家进程
call_player_close_player_proc(State) ->
  case get_player_pid(State) of
    PlayerPid when is_pid(PlayerPid) ->
      role_processor:close_player_proc(PlayerPid, self());
    _ ->
      skip
  end.

login_handle(Message, State) ->
  ClientIP = State#state.client_ip,
  case login_check:is_validate_login(Message, ClientIP) of
    {ok, Account, StrUid, RLoginData} ->
      case login_check:check_server_full() of
        false ->
          case player_util:check_account_login(Account) of
            %% 老玩家
            {true, PlayerId, 0} ->
              IsNewPlayer = false,
              case role_manager:get_roleprocessor_login_repeat(PlayerId, IsNewPlayer, ClientIP, RLoginData) of
                %% 重复登陆
                {ok, _OldPlayerPid, PlayerPid} ->
                  NewState = init_player_info(State, Account, PlayerId, PlayerPid),
                  role_processor:set_gate_proc(PlayerPid, self(), NewState#state.proto_key, 'login_request', IsNewPlayer);
                _ ->
                  case role_manager:login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData, false) of
                    {ok, PlayerPid} ->
                      NewState = init_player_info(State, Account, PlayerId, PlayerPid),
                      role_processor:set_gate_proc(PlayerPid, self(), NewState#state.proto_key, 'login_request', IsNewPlayer);
                    {error, Reason} ->
                      NewState = State,
                      ?INFO_LOG("tcp_client Error ~p~n", [{?MODULE, ?LINE, Reason}])
                  end
              end,
              {next_state, connected, NewState};
            %% 老玩家，禁登
            {true, _PlayerId, _ForbidLoginLeftTime} ->
              %Reason = io_lib:format("您已经被禁止登陆（剩余时间：~s）", [util:format_second_time(ForbidLoginLeftTime)]),
              Reason = "您的账号由于数据异常被禁止登陆，请联系客服！",
              ScLoginReply = player_util:package_login_reply(0, Reason, "", <<>>),
              send_to_client(ScLoginReply, State#state.client_socket, State#state.proto_key),
              {next_state, connected, State};
            %% 新玩家
            _ ->
              IsNewPlayer = true,
              PlayerId = roleid_generator:get_auto_player_id(), % TODO
              role_processor:create_role(PlayerId, Account, RLoginData),
              role_processor:init_account_to_id(PlayerId, StrUid),
              {ok, PlayerPid} = role_manager:login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData, false),
              NewState = init_player_info(State, Account, PlayerId, PlayerPid),
              role_processor:set_gate_proc(PlayerPid, self(), NewState#state.proto_key, 'login_request', IsNewPlayer),
              {next_state, connected, NewState}
          end;
        true ->
          ScLoginReply = player_util:package_login_reply(0, "服务器已满！请稍后再试！", "", <<>>),
          send_to_client(ScLoginReply, State#state.client_socket, State#state.proto_key),
          {next_state, connected, State}
      end;
    {false, Reason} ->
      ScLoginReply = player_util:package_login_reply(0, Reason, "", <<>>),
      send_to_client(ScLoginReply, State#state.client_socket, State#state.proto_key),
      {next_state, connected, State};
    {false, Reason, stop} ->
      ScLoginReply = player_util:package_login_reply(0, Reason, "", <<>>),
      send_to_client(ScLoginReply, State#state.client_socket, State#state.proto_key),
      {stop, normal, State}
  end.

send_to_client(Msg, ClientSocket, ProtoKey) ->
  try
    %% 加密
    {ok, IsCrypto, MsgBin} = message_code:encode_msg_bin(Msg),
    if
      IsCrypto == 1 ->
        NextServerProtoCount = socket_buffer:get_next_server_proto_count(Msg),
        BxorRandNum = get_proto_bxor_rand_num(ProtoKey),
        BxorNum = lists:nth((NextServerProtoCount + BxorRandNum) rem length(?BXOR_PASSWORD_TABLE) + 1, ?BXOR_PASSWORD_TABLE),
        Binary = util_crypto:bxor_binary(MsgBin, BxorNum);
      true ->
        Binary = MsgBin
    end,
    {ok, Binary1} = message_code:merge_bin(Msg, Binary),
    NewBinData = socket_buffer:encode(Msg, Binary1),
    send_bin(ClientSocket, NewBinData)
  catch
    E:R ->
      ?ERROR_LOG("send to client error! ~n msg = ~p~n E = ~p~n R = ~p~n ~p~n", [{Msg, get(dic_account)}, E, R, erlang:get_stacktrace()])
  end.

send_bin(ClientSocket, BinData) ->
  try
    erlang:port_command(ClientSocket, BinData, [force])
  catch
    error:badarg ->
      io:format("send to client error:badarg ~n msg = ~p~n ~p~n", [{get(dic_account)}, erlang:get_stacktrace()])
  end.

update_heartbeat_time(NowTime) ->
  put(?DIC_HEARTBEAT_TIME, NowTime).

get_proto_bxor_rand_num(ProtoKey) ->
  <<BxorNum:8, _/binary>> = ProtoKey,
  BxorNum.

get_player_pid(State) ->
  State#state.player_pid.
%PlayerId = State#state.player_id,
%role_manager:get_player_pid_only(PlayerId).
