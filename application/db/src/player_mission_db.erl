%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 三月 2017 17:36
%%%-------------------------------------------------------------------
-module(player_mission_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_mission).

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
  get_first/0,
  get_next/1,
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
write(Info) ->
  dal:write_rpc(Info).

get(Key) ->  %%{player_id,mission_id}
  dal:read_rpc(?DB_NAME, Key).

%%get_by_player_id(Key)->
%%  dal:read_index_rpc(?DB_NAME, Key, player_id).

t_write(Info) ->
%%  ?INFO_LOG("player_mission~p~n",[Info]),
  dal:t_write(Info).

delete(Key)->
  dal:delete_rpc(?DB_NAME,Key).
clean()->
  dal:clear_rpc(?DB_NAME).
get()->
  {ok,List}=dal:read_rpc(?DB_NAME),
  List.

get_first() ->
  {ok, FirstKey} = dal:first_rpc(?DB_NAME),
  FirstKey.

get_next(Key) ->
  {ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
  NextKey.
