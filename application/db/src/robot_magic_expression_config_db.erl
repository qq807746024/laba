%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 三月 2017 10:22
%%%-------------------------------------------------------------------
-module(robot_magic_expression_config_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, robot_magic_expression_config).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
  get_base/1,
  get_base/0
]).

%% ===
start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

%% ===
get_base(Id) ->
  dal:read_rpc(?DB_NAME, Id).

get_base() ->
  {ok, List} = dal:read_rpc(?DB_NAME),
  List.