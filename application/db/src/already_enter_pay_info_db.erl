%% @author zouv
%% @doc @todo 技能配置

-module(already_enter_pay_info_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-define(DB_NAME, already_enter_pay_info).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
            load_already_enter_pay_info/1,
            load_already_enter_pay_info_by_openid/1,
            t_write_already_enter_pay_info/1
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
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [openid], set).

tables_info() ->
	[{?DB_NAME, disc}].

load_already_enter_pay_info(OrderID)   ->
    dal:read_rpc(?DB_NAME, OrderID).
    
load_already_enter_pay_info_by_openid(OpenID)   ->
    dal:read_index_rpc(?DB_NAME, OpenID, openid).
    
t_write_already_enter_pay_info(AlreadyEnterPayInfo) ->
    dal:t_write(AlreadyEnterPayInfo).
    
    
        