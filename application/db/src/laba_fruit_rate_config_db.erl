%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 三月 2017 14:35
%%%-------------------------------------------------------------------
-module(laba_fruit_rate_config_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, laba_fruit_rate_config).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
	get_base/1,
	get_base/0
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
	{ok, List} = dal:read_rpc(?DB_NAME, Id),
    List.

get_base() ->
	{ok, List} = dal:read_rpc(?DB_NAME),
	List.



