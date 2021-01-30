%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 十月 2017 15:40
%%%-------------------------------------------------------------------
-module(recharge_activity_info_db).
-author("Administrator").


-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, recharge_activity_info).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get/1,
  write/1,
  t_write/1,
  delete/1,
  clean/0,
  get/0
]).
%% =====
start() ->
  db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

%% =====
write(Info) ->
  dal:write_rpc(Info).

get(Key) ->  %%{player_id,mission_id}
  dal:read_rpc(?DB_NAME, Key).

t_write(Info) ->
  dal:t_write(Info).

delete(Key) ->
  dal:delete_rpc(?DB_NAME, Key).
clean() ->
  dal:clear_rpc(?DB_NAME).
get() ->
  {ok, List} = dal:read_rpc(?DB_NAME),
  List.
