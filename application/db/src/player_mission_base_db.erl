%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 二月 2017 15:17
%%%-------------------------------------------------------------------
-module(player_mission_base_db).
-author("Administrator").

-behaviour(db_operater_mod).

-export([get/0,
  get/1]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_mission_base).

start()->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)	->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

get()  ->
  dal:read_rpc(?DB_NAME).

get(MissionBaseID)  ->
  dal:read_rpc(?DB_NAME, MissionBaseID).