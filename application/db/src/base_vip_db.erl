%% @author zouv
%% @doc @todo VIP配置

-module(base_vip_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, base_vip).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start/0,
		 create_mnesia_table/1,
		 tables_info/0,
		 
		 get_base/1,
		get_base/0
		
		]).


%% =====
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% =====

get_base(Id) ->
	dal:read_rpc(?DB_NAME, Id).

get_base() ->
	{ok,List}=dal:read_rpc(?DB_NAME),
	List.
