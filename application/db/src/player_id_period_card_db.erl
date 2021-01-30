-module(player_id_period_card_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_id_period_card).

%% ====================================================================
%% API functions
%% ====================================================================
-export([   
            load_player_id_period_card/1,
            t_write_player_id_period_card/1
        ]).

-export([
		 start/0,
		 create_mnesia_table/1,
		 tables_info/0		
		]).


%% =====
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].
    
load_player_id_period_card(Key)    ->
    dal:read_rpc(?DB_NAME, Key).
   
t_write_player_id_period_card(Obj)  ->
    dal:t_write(Obj).
    
    
        