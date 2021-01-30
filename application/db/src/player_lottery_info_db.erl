-module(player_lottery_info_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
		 get_player_info/1,
		 write_player_info/1,
		 t_write_player_info/1,
         get_first/0,
         get_next/1,
		 get_base/1,
			delete/1
		]).

-define(DB_NAME, player_lottery_info).

start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% 获取_by_playerId
get_player_info(PlayerId) ->
	{ok, [PlayerInfo]} = dal:read_rpc(?DB_NAME, PlayerId),
	PlayerInfo.

get_base(PlayerId) ->
	dal:read_rpc(?DB_NAME, PlayerId).

write_player_info(PlayerInfo) ->
	dal:write_rpc(PlayerInfo).

t_write_player_info(PlayerInfo) ->
	dal:t_write(PlayerInfo).

get_first() ->
    {ok, FirstKey} = dal:first_rpc(?DB_NAME),
    FirstKey.

get_next(Key) ->
    {ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
    NextKey.

delete(Key)->
	dal:delete_rpc(?DB_NAME,Key).



