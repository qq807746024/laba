%%%-------------------------------------------------------------------
%%% @author JIM
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2016 16:13
%%%-------------------------------------------------------------------
-module(config_mysql).
-include_lib("gate/include/record.hrl").

%% API
-export([get_statistics_server_info/0
]).

%% 获取配置文件sys.config信息
get_config_statistics() ->
  case application:get_env(mysql, 'statistics') of
    {ok, Statistics} ->
      %?INFO_LOG("statistics info:~p~n", [Statistics]),
      Statistics;
    _ ->
      erlang:exit({'config_error', {statistics}})
  end.

%% 获取数据库（MYSQL）的配置
get_mysql_server_info(ServerNode) ->
  [
    {host, Host},
    {port, Port},
    {user, User},
    {password, Password},
    {database, Database}
  ] = ServerNode,
  MysqlServerInfo = #mysql_server_info{
    host = Host,
    port = Port,
    user = User,
    password = Password,
    database = Database
  },
  MysqlServerInfo.

%% 获取统计库的服务器信息
get_statistics_server_info() ->
  Statistics = get_config_statistics(),
  ServerInfo = get_mysql_server_info(Statistics),
  ServerInfo.

