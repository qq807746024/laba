%% @author zouv
%% @doc @todo 应用配置参数获取接口

-module(config_app).

-compile([export_all]).

-include("common.hrl").

%% ====================================================================
%% Internal functions
%% ====================================================================

%% 获取服务器id
get_server_id() ->
	case application:get_env(?APP, 'server_id') of
		{ok, ServerId} ->
			ServerId;
		_ ->
			erlang:exit({'config_error', {server_id}})
	end.

%% 是否开启统计
get_static_normal_open() ->
	case application:get_env(?APP, 'static_normal_open') of
		{ok, Flag} ->
			Flag == 0;
		_ ->
			true
	end.

%% 是否开启统计
get_static_exchange_open() ->
	case application:get_env(?APP, 'static_exchange_open') of
		{ok, Flag} ->
			Flag == 0;
		_ ->
			true
	end.

%% 获取tcp端口
get_tcp_port() ->
	case application:get_env(?APP, 'tcp_ports') of
		{ok, PortList} ->
			NodeIndex = get_node_index(),
			case lists:keyfind(NodeIndex, 1, PortList) of
				{NodeIndex, Port} ->
					Port;
				_ ->
					erlang:exit({'config_error', {tcp_ports, PortList}})
			end;
		_ ->
			erlang:exit({'config_error', {tcp_ports}})
	end.

%% 设置结点编号
set_node_index(NodeIndex) ->
	application:set_env(?APP, 'node_index', NodeIndex).

%% 获取结点编号
get_node_index() ->
	case application:get_env(?APP, 'node_index') of
		{ok, NodeIndex} ->
			NodeIndex;
		%% 默认为结点1
		_ ->
			1
	end.

%% GM命令是否开启 
%%：1生效，0失效
get_gm_cmd_on() ->
	case application:get_env(?APP, 'gm_cmd') of
		{ok, Flag} ->
			Flag;
		_ ->
			0
	end.

%% 获取服务器类型
get_server_type() ->
	case application:get_env(?APP, 'server_type') of
		{ok, Type} ->
			Type;
		_ ->
			?SERVER_TYPE_RELEASE
	end.

%% 是否开发服
is_server_type_dev() ->
    ?SERVER_TYPE_DEV == config_app:get_server_type().

%% 是否正式服
is_server_type_release() ->
	?SERVER_TYPE_RELEASE == config_app:get_server_type().



%% 接入的平台列表
get_platform_list() ->
    case application:get_env(?APP, 'platform_list') of
        {ok, Type} ->
            Type;
        _ ->
            []
    end.

set_platform_list(List) ->
    application:set_env(?APP, 'platform_list', List).

%% 在线人数限制
get_online_limit() ->
    case application:get_env(?APP, 'online_limit') of
        {ok, Type} ->
            Type;
        _ ->
            5000
    end.

set_online_limit(Num) ->
    application:set_env(?APP, 'online_limit', Num).

%% 错误日志目录
get_logfile_path() ->
    case application:get_env(?APP, 'logfile_path') of
        {ok, Path} ->
            Path;
        _ ->
            "../log"
    end.

%% 获取开服时间
get_start_time() ->
    case application:get_env(?APP, 'start_time') of
        {ok, DataTime} ->
            DataTime;
        _ ->
            {{2014,11,7},{9,0,0}}
    end.

%% 获取统计http地址
get_statis_http_url() ->
	case application:get_env(?APP, 'statis_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			"http://123.57.214.206:9802/api/"
	end.

%% 获取统计http地址
get_exchange_http_url() ->
	case application:get_env(?APP, 'exchange_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			"http://123.57.214.206:9800/exchange/"
	end.

%% 分享活动http地址
get_share_http_url()->
	case application:get_env(?APP, 'share_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			"http://123.57.214.206:9800/server_api/"
	end.

%% user相关
get_user_http_url()->
	case application:get_env(?APP, 'user_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			"http://123.57.214.206:9800/StatApi/"
	end.

%%  超级管理员后台
get_superadm_http_url() ->
	case application:get_env(?APP, 'super_admin_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			undefined
	end.

get_redismaster_http_url() ->
	case application:get_env(?APP, 'redis_master_http_url') of
		{ok, HttpUrl} ->
			HttpUrl;
		_ ->
			undefined
	end.

% 功能开关
%%：0开 1关
get_function_switch() ->
	case application:get_env(?APP, 'function_switch') of
		{ok, Flag} ->
			Flag;
		_ ->
			0
	end.

get_cross_server_id() -> 0.