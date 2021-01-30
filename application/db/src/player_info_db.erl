-module(player_info_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
		 get_player_info/1,
		 get_player_info_by_account/1,
		 get_player_info_by_player_name/1,
		 write_player_info/1,
		 t_write_player_info/1,
         get_first/0,
         get_next/1,
		 get_base/1,
			delete/1,

		 get_max_player_id/0,
		 get_player_info_role_id/1
		
		]).

-define(DB_NAME, player_info).

start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [account], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% 获取_by_playerId
get_player_info(PlayerId) ->
	{ok, [PlayerInfo]} = dal:read_rpc(?DB_NAME, PlayerId),
	PlayerInfo.

get_player_info_role_id(PlayerId) ->
	{ok, PlayerInfo} = dal:read_rpc(?DB_NAME, PlayerId),
	PlayerInfo.

get_base(PlayerId) ->
	dal:read_rpc(?DB_NAME, PlayerId).

%% 获取_by_account
get_player_info_by_account(Account) ->
	{ok, List} = dal:read_index_rpc(?DB_NAME, Account, #player_info.account),
	List.

%% 获取_by_playername
get_player_info_by_player_name(PlayerName) ->
	MatchHead = #player_info{player_name = PlayerName, _ = '_'},
	MatchGuard = [],
	MatchResult = ['$_'],
	{ok, List} = dal:read_select_rpc(?DB_NAME, MatchHead, MatchGuard, MatchResult),
	List.

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



