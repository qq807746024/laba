%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 二月 2017 10:46
%%%-------------------------------------------------------------------
-module(fruit_rank_history_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, fruit_rank_history).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
  get/1,
  write/1,
  get_list/0,
  get_last/0,
  get_first/0,
  clean/0
]).

%% ===
start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], ordered_set).

tables_info() ->
  [{?DB_NAME, disc}].

%% ===
write(Info) ->
  dal:write_rpc(Info).

get(DateStr) -> %% 每周一日期，格式如"YYYY-MM-DD"
  dal:read_rpc(?DB_NAME, DateStr).

get_list() ->
  dal:read_rpc(?DB_NAME).

get_last() ->
  dal:last_rpc(?DB_NAME).

get_first() ->
  dal:first_rpc(?DB_NAME).

clean()->
  dal:clear_rpc(?DB_NAME).

