%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 三月 2017 15:05
%%%-------------------------------------------------------------------
-module(red_pack_total_info_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([
  get/1,
  get/0,
  t_write/1,

  t_delete/1,
  write/1,
  clean/0]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-define(DB_NAME, red_pack_total_info).

start() ->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
  db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
  [{?DB_NAME, disc}].


get(ID)    ->
  dal:read_rpc(?DB_NAME, ID).

get()    ->
  dal:read_rpc(?DB_NAME).

t_write(Info)  ->
  dal:t_write(Info).

t_delete(ID) ->
  dal:t_delete(?DB_NAME, ID).


write(Info) ->
  case catch mnesia:dirty_write(Info) of
    {'EXIT', Reason} ->
      ?ERROR_LOG("write error ~p~n Object ~p ~n", [Reason, Info]), {failed, Reason};
    ok ->
      {ok}
  end.


clean()->
  dal:clear_rpc(?DB_NAME).