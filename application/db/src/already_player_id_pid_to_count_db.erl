%% @author zouv
%% @doc @todo 技能配置

-module(already_player_id_pid_to_count_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, already_player_id_pid_to_count).

%% ====================================================================
%% API functions
%% ====================================================================
-export([   
            load_already_player_id_pid_to_count/2,
            t_write_already_player_id_pid_to_count/1
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
    
load_already_player_id_pid_to_count(PlayerID, Pid)   ->
    dal:read_rpc(?DB_NAME, {PlayerID, Pid}).
    
t_write_already_player_id_pid_to_count(Obj) ->
    dal:t_write(Obj).

    
    
    
        