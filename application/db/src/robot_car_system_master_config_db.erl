%%%-------------------------------------------------------------------
%%% @author lk
%%%-------------------------------------------------------------------
-module(robot_car_system_master_config_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, robot_car_system_master_config).

%% ====================================================================
%% API functions
%% ====================================================================
-export([clean/0, create_mnesia_table/1, get/0, start/0,
	 t_write/1, tables_info/0, write/1]).

%% =====
start() -> db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME,
			       record_info(fields, ?DB_NAME), #?DB_NAME{},
			       ?MODULE, [], set).

tables_info() -> [{?DB_NAME, disc}].

%% =====
write(Info) -> dal:write_rpc(Info).

t_write(Info) -> dal:t_write(Info).

clean() -> dal:clear_rpc(?DB_NAME).

get() -> dal:read_rpc(?DB_NAME).
