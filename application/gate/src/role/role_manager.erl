%% 玩家进程Pid管理

-module(role_manager).
-behaviour(gen_server).

-include("common.hrl").

%% -define(DIC_PLAYER_PID_DICT, 		dic_player_pid_dict).	% 玩家进程Pid

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([
         start_link/0,
         %login_in/4,
		 login_in/5,
         login_out/2,
         
         get_roleprocessor/1,
         get_player_pid_only/1,
         
         get_roleprocessor_login_repeat/4
        ]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData) ->
%%     login_in_handle(PlayerId, IsNewPlayer, ClientIP, RLoginData).

login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData, IsRobot) ->
	login_in_handle(PlayerId, IsNewPlayer, ClientIP, RLoginData, IsRobot).

login_out(PlayerId, FromPid) ->
    case get_roleprocessor(PlayerId) of
        {ok, OldPlayerPid} when OldPlayerPid == FromPid ->
            del_role_pid(PlayerId);
        _ ->
            skip
    end.
    %gen_server:call(?MODULE, {'login_out', PlayerId, FromPid}).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------
init(Args) ->
    {ok, Args}.

%% ========================= call =========================
%% 登入
handle_call({'login_in', PlayerId, PlayerPid}, _From, State) ->
    add_role_pid(PlayerId, PlayerPid),
    {reply, ok, State};

%% 登出
handle_call({'login_out', PlayerId, FromPid}, _From, State) ->
    case get_roleprocessor(PlayerId) of
        {ok, OldPlayerPid} when OldPlayerPid == FromPid ->
            del_role_pid(PlayerId);
        _ ->
            skip
    end,
    {reply, ok, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%% ========================= cast =========================
handle_cast(Msg, State) ->
    ?ERROR_LOG("~n ~p cast no match =~p", [?MODULE, Msg]),
    {noreply, State}.

%% ========================= info =========================
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------
add_role_pid(PlayerId, PlayerPid) ->
    EtsRolePid = #ets_role_pid{player_id = PlayerId, player_pid = PlayerPid},
    ets:insert(?ETS_ROLE_PID, EtsRolePid),
    PlayerPid.

del_role_pid(PlayerId) ->
    ets:delete(?ETS_ROLE_PID, PlayerId).

login_in_handle(PlayerId, IsNewPlayer, ClientIP, RLoginData, IsRobot) ->
    case get_roleprocessor(PlayerId) of
        {ok, _OldPlayerPid} ->
            {error, "repeated"};
        _ ->
            %case supervisor:start_child(role_processor_sup, [[PlayerId, IsNewPlayer, ClientIP, RLoginData]]) of
            %    {ok, PlayerPid} ->
			ResourceId = {role_processor, PlayerId},
            UniqueRef = erlang:make_ref(),
			case global:set_lock({ResourceId, UniqueRef}, [node()], 3) of
				true ->
					Retrun = role_processor:start([PlayerId, IsNewPlayer, ClientIP, RLoginData, IsRobot]),
					global:del_lock({ResourceId, UniqueRef}, [node()]),
		            case Retrun of
		                {ok, PlayerPid} ->
		                    add_role_pid(PlayerId, PlayerPid),
		                    %gen_server:call(?MODULE, {'login_in', PlayerId, PlayerPid}),
		                    {ok, PlayerPid};
		                {ok, PlayerPid, _} ->
		                    add_role_pid(PlayerId, PlayerPid),
		                    %gen_server:call(?MODULE, {'login_in', PlayerId, PlayerPid}),
		                    {ok, PlayerPid};
		                {error, Reason} ->
		                    {error, Reason}
		            end;
				_ ->
					{error, "role processor is locked"}
			end
    end.

get_player_pid_only(PlayerId) ->
    ProcessName = misc:get_player_process_name(PlayerId),
    util_process:get_global_pid(ProcessName).

get_roleprocessor(PlayerId) ->
    case get_player_pid_only(PlayerId) of
        PlayerPid when is_pid(PlayerPid) ->
            case erlang:is_process_alive(PlayerPid) of
                true ->
                    {ok, PlayerPid};
                _ ->
                    del_role_pid(PlayerId),
                    {error, not_exist}
            end;
        _ ->
            {error, not_exist}
    end.

%% get_roleprocessor(PlayerId) ->
%%     case ets:lookup(?ETS_ROLE_PID, PlayerId) of
%%         [] ->
%%             {error, not_exist};
%%         [EtsOnline] ->
%%             PlayerPid = EtsOnline#ets_role_pid.player_pid,
%%             case erlang:is_process_alive(PlayerPid) of
%%                 true ->
%%                     {ok, PlayerPid};
%%                 _ ->
%%                     del_role_pid(PlayerId),
%%                     {error, not_exist}
%%             end 
%%     end.

get_roleprocessor_login_repeat(PlayerId, IsNewPlayer, ClientIP, RLoginData) ->
    case get_player_pid_only(PlayerId) of
        PlayerPid when is_pid(PlayerPid) ->
            case erlang:is_process_alive(PlayerPid) of
                true ->
                    role_processor:close_player_proc(PlayerPid, self()),
					case login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData, false) of
						{ok, NewPlayerPid} ->
							{ok, PlayerPid, NewPlayerPid};
						{error, Reason} ->
							{error, Reason}
					end;
					%之前版本
                    %{ok, NewPlayerPid} = login_in(PlayerId, IsNewPlayer, ClientIP, RLoginData),
                    %{ok, PlayerPid, NewPlayerPid};
                _ ->
                    {error, not_exist}
            end;
        _ ->
            {error, not_exist}
    end.


