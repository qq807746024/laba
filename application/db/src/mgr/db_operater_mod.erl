-module(db_operater_mod).

-define(ETS_DB_OPERATER_MODS, 	ets_db_operater_mods).

-export([
		 behaviour_info/1, 
		 init/0,
		 start/0, 
		 start/1,
		 start_module/2, 
		 create_all_disc_table/0,
		 get_ets_table_list/0
		]).

behaviour_info(callbacks) ->
	[
	 {start,0},
	 {create_mnesia_table,1},
	 {tables_info,0}
	];
behaviour_info(_Other) ->
    undefined.

init()	->
	?ETS_DB_OPERATER_MODS = ets:new(?ETS_DB_OPERATER_MODS, [public, set, named_table, {keypos, 1}]),
	ok.

start() ->
	mod_util:behaviour_apply(db_operater_mod,start,[]),
    ok.

start(Path) ->
	mod_util:behaviour_apply(Path, db_operater_mod, start, []),
	ok.

start_module(Module, Opts)->
	TablesInfo = Module:tables_info(),
	true = ets:insert(?ETS_DB_OPERATER_MODS, {Module, Opts, TablesInfo}).


create_all_disc_table() ->
	ets:foldl(fun({Module, _, _},_)->
				  Module:create_mnesia_table(disc)
			  end,
			  [], 
			  ?ETS_DB_OPERATER_MODS).

get_ets_table_list() ->
	ets:tab2list(?ETS_DB_OPERATER_MODS).
	

