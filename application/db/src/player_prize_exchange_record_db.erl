%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 三月 2017 14:23
%%%-------------------------------------------------------------------
-module(player_prize_exchange_record_db).
-author("Administrator").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_prize_exchange_record).

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
	get/0,
	get_by_player_id/1
]).
%% =====
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [player_id], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% =====
write(Info) ->
	dal:write_rpc(Info).

get(Key) ->
	dal:read_rpc(?DB_NAME, Key).

get_by_player_id(Key) ->
	{ok, List} = dal:read_index_rpc(?DB_NAME, Key, #player_prize_exchange_record.player_id),
	List.

t_write(Info) ->
	dal:t_write(Info).

delete(Key)->
	dal:delete_rpc(?DB_NAME,Key).
clean()->
	dal:clear_rpc(?DB_NAME).
get()->
	{ok,List}=dal:read_rpc(?DB_NAME),
	List.


