%% lk
-module(daily_earn_gold_rank_reward_config_db).

-author("lk").

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, daily_earn_gold_rank_reward_config).

-export([clean/0, create_mnesia_table/1, delete/1,
	 get/0, get/1, get_base/0, get_base/1, get_first/0,
	 start/0, t_write/1, tables_info/0, write/1]).

%% =====
start() -> db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME,
			       record_info(fields, ?DB_NAME), #?DB_NAME{},
			       ?MODULE, [], set).

tables_info() -> [{?DB_NAME, disc}].

%% =====

get(Id) -> dal:read_rpc(?DB_NAME, Id).

get_first() ->
    {ok, FirstKey} = dal:first_rpc(?DB_NAME), FirstKey.

get() -> {ok, List} = dal:read_rpc(?DB_NAME), List.

write(Config) -> dal:write_rpc(Config).

t_write(Config) -> dal:t_write(Config).

delete(Key) -> dal:delete_rpc(?DB_NAME, Key).

clean() -> dal:clear_rpc(?DB_NAME).

%% ===
get_base(Id) -> dal:read_rpc(?DB_NAME, Id).

get_base() -> {ok, List} = dal:read_rpc(?DB_NAME), List.
