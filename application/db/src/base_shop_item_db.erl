%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 二月 2017 10:41
%%%-------------------------------------------------------------------
-module(base_shop_item_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, base_shop_item).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get/1,
  get_list/0,

  write/1,
  t_write/1

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

get_list() ->
   dal:read_rpc(?DB_NAME).

write(Info) ->
  dal:write_rpc(Info).

t_write(Info) ->
  dal:t_write(Info).
