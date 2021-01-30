%% @author zouv
%% @doc @todo 商城充值配置

-module(base_vip_recharge_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, base_vip_recharge).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
         load_pay_item_info/1,
         get_list/0,
        clean_info/0,
        write/1
        ]).

-export([
         start/0,
         create_mnesia_table/1,
         tables_info/0

        ]).

%% =====
start() ->
    db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
    db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [], set).

tables_info() ->
    [{?DB_NAME, disc}].

%% =====
load_pay_item_info(Pid)    ->
    dal:read_rpc(?DB_NAME, Pid).

get_list() ->
    {ok, List} = dal:read_rpc(?DB_NAME),
    List.

clean_info()->
  dal:clear_rpc(?DB_NAME).

write(Info)->
  dal:write_rpc(Info).