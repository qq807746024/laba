%%%-------------------------------------------------------------------
%%% @author lk
%%%-------------------------------------------------------------------
-module(airlaba_plane_config_db).

-author("lk").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, airlaba_plane_config).

%% ====================================================================
%% API functions
%% ====================================================================
-export([create_mnesia_table/1, get/0, get/1, start/0,
	 tables_info/0]).

%% =====
start() -> db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME,
			       record_info(fields, ?DB_NAME), #?DB_NAME{},
			       ?MODULE, [], set).

tables_info() -> [{?DB_NAME, disc}].

%% =====

get(Key) -> dal:read_rpc(?DB_NAME, Key).

get() -> {ok, List} = dal:read_rpc(?DB_NAME), List.
