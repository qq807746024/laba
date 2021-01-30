%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 三月 2015 16:18
%%%-------------------------------------------------------------------
-module(player_name_random_info_db).
-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_name_random_info).

-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get_base/1,
  get_first/0
]).


%% =====
start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].

%% =====

get_base(Id) ->
  dal:read_rpc(?DB_NAME, Id).

get_first() ->
  {ok, FirstKey} = dal:first_rpc(?DB_NAME),
  FirstKey.