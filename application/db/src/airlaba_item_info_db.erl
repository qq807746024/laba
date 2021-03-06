-module(airlaba_item_info_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, airlaba_item_info).

%% ====================================================================
%% API functions
%% ====================================================================
-export([create_mnesia_table/1, get/1, get_list/0,
	 start/0, tables_info/0, write/1]).

%% =====
start() -> db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME,
			       record_info(fields, ?DB_NAME), #?DB_NAME{},
			       ?MODULE, [], set).

tables_info() -> [{?DB_NAME, disc}].

%% =====
get(Key) -> dal:read_rpc(?DB_NAME, Key).

get_list() -> dal:read_rpc(?DB_NAME).

write(Info) -> dal:write_rpc(Info).
