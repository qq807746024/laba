-module(laba_const_config_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, laba_const_config).

-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get/1,
  get_first/0,
  write/1,
  t_write/1,
  delete/1,
  clean/0,
  get/0
]).


%% =====
start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

%% =====

get(Id) ->
  dal:read_rpc(?DB_NAME, Id).

get_first() ->
  {ok, FirstKey} = dal:first_rpc(?DB_NAME),
  FirstKey.

get()->
  {ok,List}=dal:read_rpc(?DB_NAME),
  List.

write(PlayerInfo) ->
  dal:write_rpc(PlayerInfo).

t_write(PlayerInfo) ->
  dal:t_write(PlayerInfo).

delete(Key)->
  dal:delete_rpc(?DB_NAME,Key).

clean()->
  dal:clear_rpc(?DB_NAME).
