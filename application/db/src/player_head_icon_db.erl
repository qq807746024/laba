%%%-------------------------------------------------------------------
%%% @author wodong_0013
-module(player_head_icon_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, player_head_icon).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start/0,
	create_mnesia_table/1,
	tables_info/0,
	get_base/1
	%% ,get_by_tex_id/1
]).

%% =====
start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
	[{?DB_NAME, disc}].

%% =====
get_base(TexId) ->
	dal:read_rpc(?DB_NAME, TexId).

%% get_by_tex_id(TexId) ->
%% 	dal:read_index_rpc(?DB_NAME, TexId, tex_id).
