-module(player_statistics_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
		 get_player_statistics/1,
		 write_player_statistics/1,
		 t_write_player_statistics/1,
         get_first/0,
         get_next/1,
		 get_base/1,
			delete/1,

		 get_max_player_id/0,
		 get_player_statistics_role_id/1
		
		]).

-define(DB_NAME, player_statistics).

start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% 获取_by_playerId
get_player_statistics(PlayerId) ->
	{ok, [PlayerInfo]} = dal:read_rpc(?DB_NAME, PlayerId),
	PlayerInfo.

get_player_statistics_role_id(PlayerId) ->
	{ok, PlayerInfo} = dal:read_rpc(?DB_NAME, PlayerId),
	PlayerInfo.

get_base(PlayerId) ->
	dal:read_rpc(?DB_NAME, PlayerId).

write_player_statistics(PlayerInfo) ->
	dal:write_rpc(PlayerInfo).

t_write_player_statistics(PlayerInfo) ->
	dal:t_write(PlayerInfo).

get_first() ->
    {ok, FirstKey} = dal:first_rpc(?DB_NAME),
    FirstKey.

get_next(Key) ->
    {ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
    NextKey.

% 
get_max_player_id() ->
	case get_first() of
		'$end_of_table' ->
			0;
		FirstKey ->
			get_max_player_id1(FirstKey, FirstKey)
	end.

get_max_player_id1(Key, MaxId) ->
	case get_next(Key) of
		'$end_of_table' ->
			MaxId;
		NexKey ->
			if
				NexKey > MaxId ->
					NewMaxId = NexKey;
				true ->
					NewMaxId = MaxId
			end,
			get_max_player_id1(NexKey, NewMaxId)
	end.

delete(Key)->
	dal:delete_rpc(?DB_NAME,Key).



