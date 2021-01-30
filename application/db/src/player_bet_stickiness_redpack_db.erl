%%%-------------------------------------------------------------------
%%% @author lk
%%%-------------------------------------------------------------------
-module(player_bet_stickiness_redpack_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_bet_stickiness_redpack).

-export([create_mnesia_table/1, get_base/1, get_first/0,
	 start/0, t_write/1, tables_info/0, write/1]).

%% =====
start() -> db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME,
			       record_info(fields, ?DB_NAME), #?DB_NAME{},
			       ?MODULE, [], set).

tables_info() -> [{?DB_NAME, disc}].

%% =====

get_base(Id) -> dal:read_rpc(?DB_NAME, Id).

get_first() ->
    {ok, FirstKey} = dal:first_rpc(?DB_NAME), FirstKey.

write(PlayerInfo) -> dal:write_rpc(PlayerInfo).

t_write(PlayerInfo) -> dal:t_write(PlayerInfo).
