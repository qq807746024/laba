%%%-------------------------------------------------------------------
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 四月 2017 0:37
%%%-------------------------------------------------------------------
-module(player_game_task_info_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_game_task_info).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
  start/0,
  create_mnesia_table/1,
  tables_info/0,

  get/1,
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
get(PlayerId) ->
  dal:read_rpc(?DB_NAME, PlayerId).

write(PlayerVip) ->
  dal:write_rpc(PlayerVip).

t_write(PlayerVip) ->
  dal:t_write(PlayerVip).



