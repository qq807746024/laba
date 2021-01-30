-module(announcement_db).

-behaviour(db_operater_mod).

-export([load_announcement_by_condition/1,
        write_announcement/1]).

-export([start/0, create_mnesia_table/1, tables_info/0]).


-include("mnesia_table_def.hrl").

-define(DB_NAME, announcement).

start() ->	
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [condition], set).

tables_info() ->
	[{?DB_NAME, disc}].

load_announcement_by_condition(Condition) ->
	dal:read_index_rpc(?DB_NAME, Condition, condition).
    
write_announcement(Obj)   ->
    dal:write_rpc(Obj).
    


