%% 玩家物品

-module(player_items_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_items).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-export([
		get_player_item/1,
		get_player_item_list/1,
		
		write_player_items/1,
		t_write_player_items/1,
		
		delete_player_items/1,
		t_delete_player_items/1,
		delete_player_item_list/1,
		
		get_first/0,
		get_next/1

		]).

%% =====
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)	->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [player_id], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% =====
%% 读取
get_player_item(ItemId)	->
	dal:read_rpc(?DB_NAME, ItemId).

get_player_item_list(PlayerId)	->
	{ok, Items} = dal:read_index_rpc(?DB_NAME, PlayerId, player_id),
	Items.

%% get_player_item_by_cls(Cls) ->
%% 	MatchHead = #player_items{cls = Cls, _ = '_'},
%% 	MatchGuard = [],
%% 	MatchResult = ['$_'],
%% 	{ok, List} = dal:read_select_rpc(?DB_NAME, MatchHead, MatchGuard, MatchResult),
%% 	List.

%% 更新
write_player_items(PlayerItem)	->
	dal:write_rpc(PlayerItem).

t_write_player_items(PlayerItem)	->
	dal:t_write(PlayerItem).

%% 删除
delete_player_items(ItemId)	->
	{ok} = dal:delete_rpc(?DB_NAME, ItemId).

t_delete_player_items(ItemID)	->
	dal:t_delete(?DB_NAME, ItemID).

get_first() ->
	{ok, FirstKey} = dal:first_rpc(?DB_NAME),
	FirstKey.

get_next(Key) ->
	{ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
	NextKey.

delete_player_item_list(PlayerId) ->
	List = get_player_item_list(PlayerId),
	lists:foreach(fun (Elem) ->
		delete_player_items(Elem#player_items.id)
	end, List).
