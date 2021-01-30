%% @author zouv
%% @doc @todo 各种处理

-module(misc).

-include("logger.hrl").
-include("common.hrl").

-compile(export_all).


%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

%% ====================================================================
%% Internal functions
%% ====================================================================

%% 获取ModPid
get_mod_pid(Module) ->
	ModProcessName = get_local_process_name(Module),
	case util_process:get_local_pid(ModProcessName) of
		ModPid when is_pid(ModPid) ->
			case erlang:is_process_alive(ModPid) of
				true ->
					ModPid;
				_ ->
					get_mod_pid1(Module, ModProcessName)
			end;
		_ ->
			get_mod_pid1(Module, ModProcessName)
	end.

get_mod_pid1(Module, ModProcessName) ->
    global:set_lock({ModProcessName, undefined}),
    ModPid = 
    	case supervisor:start_child(gate_sup, {Module, {Module, start_link, [ModProcessName]}, permanent, 10000, worker, [Module]}) of
    		{ok, Pid} ->
    			Pid;
    		Error ->
    			?ERROR_LOG("start mod pid1 Error! module = ~p, info = ~p ~p", [Module, Error, erlang:get_stacktrace()]),
    			undefined
    	end,
    global:del_lock({ModProcessName, undefined}),
    ModPid.

%% 获取GolbaoModPid
get_global_mod_pid(Module) ->
    ModProcessName = get_global_process_name(Module),
    case util_process:get_global_pid(ModProcessName) of
        ModPid when is_pid(ModPid) ->
            case misc:is_process_alive(ModPid) of
                true ->
                    ModPid;
                _ ->
                    get_mod_pid1(Module, ModProcessName)
            end;
        _ ->
            get_mod_pid1(Module, ModProcessName)
    end.

get_global_mod_pid_simple(Module, ServerId) ->
    ModProcessName = get_global_process_name(Module, ServerId),
    case util_process:get_global_pid(ModProcessName) of
        ModPid when is_pid(ModPid) ->
            case misc:is_process_alive(ModPid) of
                true ->
                    ModPid;
                _ ->
                    undefined
            end;
        _ ->
            undefined
    end.

%% 获取CrossModPid
get_cross_mod_pid(Module) ->
    ModProcessName = get_cross_process_name(Module),
    case util_process:get_global_pid(ModProcessName) of
        ModPid when is_pid(ModPid) ->
            case misc:is_process_alive(ModPid) of
                true ->
                    ModPid;
                _ ->
                    get_mod_pid1(Module, ModProcessName)
            end;
        _ ->
            get_mod_pid1(Module, ModProcessName)
    end.

get_cross_mod_pid_simple(Module) ->
    ModProcessName = get_cross_process_name(Module),
    case util_process:get_global_pid(ModProcessName) of
        ModPid when is_pid(ModPid) ->
            case misc:is_process_alive(ModPid) of
                true ->
                    ModPid;
                _ ->
                    undefined
            end;
        _ ->
            undefined
    end.

%% 获取玩家进程名
get_player_process_name(PlayerId) when erlang:is_integer(PlayerId) ->
    lists:concat([role_process_, PlayerId]).

%% 获取本地进程名
get_local_process_name(Module) ->
	ServerId = config_app:get_server_id(),
	erlang:list_to_atom(lists:concat([Module, "_", ServerId])).

%% 获取跨节点进程名
get_global_process_name(Module) ->
    ServerId = config_app:get_server_id(),
    get_global_process_name(Module, ServerId).

get_global_process_name(Module, ServerId) ->
    erlang:list_to_atom(lists:concat([Module, "_", ServerId])).

%% 获取跨节点进程名
get_cross_process_name(Module) ->
    ServerId = config_app:get_cross_server_id(),
    erlang:list_to_atom(lists:concat([Module, "_", ServerId])).

%% 跨节点进程是否存活
is_process_alive(Pid) ->    
    try 
        if
            is_pid(Pid) ->
                case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
                    {badrpc, _Reason}  ->
                        false;
                    Res ->
                        Res
                end;
            true ->
                false
        end
    catch 
        _:_ -> 
            false
    end.

is_testtype_try_playe(TestType) ->
    ?TEST_TYPE_TRY_PLAY =:= TestType orelse (TestType >= ?TEST_TYPE_TRY_PLAY_CHNL_MIN_NUM andalso ?TEST_TYPE_TRY_PLAY_CHNL_MAX_NUM >= TestType).

