%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 二月 2017 10:46
%%%-------------------------------------------------------------------
-module(account_to_player_id_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, account_to_player_id).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
	get_base/1,
	get_base/0,
	t_write/1,
	write/1
]).

%% ===
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% ===
get_base(Id) ->
	dal:read_rpc(?DB_NAME, Id).

get_base() ->
	{ok, List} = dal:read_rpc(?DB_NAME),
	List.

t_write(Info) ->
	dal:t_write(Info).

write(Info) ->
	dal:write_rpc(Info).


