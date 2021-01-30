-module(player_level_upgrade_base_db).

-behaviour(db_operater_mod).

-export([load_player_level_upgrade_base/0,
         get_player_level_upgrade_base/1]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_level_upgrade_base).

start()->	
	db_operater_mod:start_module(?MODULE,[]).
	
create_mnesia_table(disc)	->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].
    
load_player_level_upgrade_base() ->
    dal:read_rpc(?DB_NAME).
    
get_player_level_upgrade_base(Level) ->
    dal:read_rpc(?DB_NAME, Level).


