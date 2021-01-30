%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 三月 2018 16:06
%%%-------------------------------------------------------------------
-module(line_num_config_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, line_num_config).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get/1,
  get/0,
  write/1,
  t_write/1,
  delete/1
]).
%% =====
start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

%% =====

get(Key) ->
  dal:read_rpc(?DB_NAME, Key).

get()->
  {ok,List}=dal:read_rpc(?DB_NAME),
  List.

write(Info) ->
  dal:write_rpc(Info).

t_write(Info) ->
  dal:t_write(Info).

delete(Key) ->
  dal:delete_rpc(?DB_NAME, Key).