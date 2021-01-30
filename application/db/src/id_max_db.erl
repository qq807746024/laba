-module(id_max_db).

-behaviour(db_operater_mod).

-export([
		 get_id_max/1, 
		 get_id_max/2, 
		 update_id_max/2
		]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-include("mnesia_table_def.hrl").

-define(DB_NAME, id_max).

start()->	
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

get_id_max(Type)->
	case dal:read_rpc(?DB_NAME,Type) of
		{ok,[R]} ->
			{_, _, Counter} = R,
			Counter;
		_->
			0
	end.

get_id_max(Type, OrigId)->
	case dal:read_rpc(?DB_NAME,Type) of
		{ok, [R]} ->
			{ _, _, Counter} = R,
			Counter;
		_->
			OrigId
	end.

update_id_max(Type, NewValue)->
	dal:write_rpc({?DB_NAME,Type,NewValue}).


