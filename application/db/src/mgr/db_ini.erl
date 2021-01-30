-module(db_ini).

-export([
         db_init/0, 
         db_modules_list_init/1, 
         db_init_disc_tables/0
        ]).

db_init()->
    db_operater_mod:init(),
    case mnesia:system_info(is_running) of
        yes -> mnesia:stop();
        no -> o;
        starting -> mnesia:stop()
    end,
    %mnesia:create_schema([node(), 'test@127.0.0.1']).
    mnesia:create_schema([node()]).

db_modules_list_init(PathLists)	->
    util:map(fun db_operater_mod:start/1, PathLists).

db_init_disc_tables()->
    mnesia:start(),
    db_tools:wait_tables_in_dbnode(),
    %rpc:call(node(), mnesia, change_config, [extra_db_nodes, ['test@127.0.0.1']]),
    db_operater_mod:create_all_disc_table().


