%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 三月 2017 14:47
%%%-------------------------------------------------------------------
-module(red_pack_notice_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([get_by_player_id/1,
  get/1,
  get/0,
  t_write/1,
  delete/1,
  get_first/0,
  get_next/1,
  t_delete/1,
  write/1,
  clean/0]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-define(DB_NAME, red_pack_notice).

start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [create_player_id], set).

tables_info() ->
  [{?DB_NAME, disc}].

get_by_player_id(PlayerID)    ->
  dal:read_index_rpc(?DB_NAME, PlayerID, create_player_id).

get(ID)    ->
  dal:read_rpc(?DB_NAME, ID).

get()    ->
  dal:read_rpc(?DB_NAME).

t_write(Info)  ->
  dal:t_write(Info).

t_delete(ID) ->
  dal:t_delete(?DB_NAME, ID).

delete(ID) ->
  case catch mnesia:dirty_delete({?DB_NAME,ID}) of
    {'EXIT',Reason} -> {failed, Reason};
    ok -> {ok}
  end.

write(Info) ->
  case catch mnesia:dirty_write(Info) of
    {'EXIT', Reason} ->
      ?ERROR_LOG("write error ~p~n Object ~p ~n", [Reason, Info]), {failed, Reason};
    ok ->
      {ok}
  end.

get_first() ->
  {ok, FirstKey} = dal:first_rpc(?DB_NAME),
  FirstKey.

get_next(Key) ->
  {ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
  NextKey.

clean()->
  dal:clear_rpc(?DB_NAME).