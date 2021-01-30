-module(statistic_server).

-behaviour(gen_server).

-compile(export_all).


-export([
	start_link/0
]).

-include_lib("gate/include/common.hrl").
-include_lib("gate/include/mysql_log.hrl").
%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	terminate/2, code_change/3]).

-export([
	test_insert_data/0,

	check_exist_table/2,

	total_export_to_mysql/0
]).

-define(MAX_FLUSH_REC_NUM, 3000).		%% 每次最多同步3000条
-define(SERVER, ?MODULE).


-record(state, {
}).


start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
	mod_mysql:start(),

	send_after_gm_log(),
	send_after_item_use_log(),

	check_all_table_exist(),
	NowSeconds = util:now_seconds(),
	send_after_check_table_exist(NowSeconds),
	State = #state{},
	{ok, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

%% 导入到mysql
handle_info('flush_gm', State) ->
	send_after_gm_log(),

	MTableName1 = format_log_gm_success_name(),
	check_exist_table(MTableName1, gm_success),
	flush_ets_to_mysql(?MLOG_ETS_GM_success, MTableName1),

	MTableName2 = format_log_gm_error_name(),
	check_exist_table(MTableName2, gm_error),
	flush_ets_to_mysql(?MLOG_ETS_GM_error, MTableName2),

	MTableName3 = format_log_prize_exchange_name(),
	check_exist_table(MTableName3, prize_exchange),
	flush_ets_to_mysql(?MLOG_ETS_PRIZE_EXCHANGE, MTableName3),

	MTableName3_1 = format_log_prize_exchange_err_name(),
	check_exist_table(MTableName3_1, prize_exchange_err),
	flush_ets_to_mysql(?MLOG_ETS_PRIZE_EXCHANGE_ERR, MTableName3_1),

	% MTableName4 = format_log_hundred_settlement_name(),
	% check_exist_table(MTableName4, hundred_settlement),
	% flush_ets_to_mysql(?MLOG_ETS_HUNDRED_SETTLEMENT, MTableName4),

	% MTableName5 = format_log_car_settlement_name(),
	% check_exist_table(MTableName5, car_settlement),
	% flush_ets_to_mysql(?MLOG_ETS_CAR_SETTLEMENT, MTableName5),
	{noreply, State};

%% 导入到mysql
handle_info('flush_item_use', State) ->
	send_after_item_use_log(),

	MTableName = format_log_item_use_tab_name(),
	check_exist_table(MTableName, log_item),
	flush_ets_to_mysql(?MLOG_ETS_ITEM_USE, MTableName),
	{noreply, State};

%% 导入到mysql
handle_info({'check_table_exist', OldSeconds}, State) ->
	NowSeconds = util:now_seconds(),
	send_after_check_table_exist(NowSeconds),
	case util:is_same_date_spe(?DAY_SECOND - 120, NowSeconds, OldSeconds) of
		true ->
			skip;
		_ ->
			create_tomorow_table()
	end,
	{noreply, State};

handle_info(Info, State) ->
	?INFO_LOG(" statistic_server skip handle_info ~p~n",[Info]),
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


flush_ets_to_mysql(EtsTableName, TabName) ->
	List = ets:tab2list(EtsTableName),
	case List of
		[] ->
			skip;
		undefined->skip;
		_ ->
			QueuesInsert = lists:reverse(List),
			%%批量插入的数据
			FieldNames = get_key_list_by_tab(EtsTableName),
			%%每次批量插入3000条
			MySqlConfig = config_mysql:get_statistics_server_info(),
			MysqlDBName = MySqlConfig#mysql_server_info.database,
			mod_mysql:batch_insert({table, list_to_atom(MysqlDBName), TabName},FieldNames,QueuesInsert,?MAX_FLUSH_REC_NUM),
			ets:delete_all_objects(EtsTableName)
	end.


get_key_list_by_tab(?MLOG_ETS_GM_success) -> [gm_type,cmd_str,time];
get_key_list_by_tab(?MLOG_ETS_GM_error) -> [gm_type,cmd_str,time];
get_key_list_by_tab(?MLOG_ETS_ITEM_USE) -> [player_id,place,item_id,num,time];
get_key_list_by_tab(?MLOG_ETS_PRIZE_EXCHANGE) -> [player_id,obj_id,time];
get_key_list_by_tab(?MLOG_ETS_PRIZE_EXCHANGE_ERR) -> [player_id,obj_id,time,err];
%get_key_list_by_tab(?MLOG_ETS_HUNDRED_SETTLEMENT) -> [room_id,times_id,rate_list,total_set_list,real_set_list,master_win,time];
%get_key_list_by_tab(?MLOG_ETS_CAR_SETTLEMENT) -> [room_id,times_id,total_set_list,player_set_list,result,index,pool_reward_num,time];
get_key_list_by_tab(_EtsTableName) -> [].


%%@doc 格式化道具日志表名
format_log_item_use_tab_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_log_item,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_gm_error_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_gm_error,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_gm_success_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_gm_success,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_prize_exchange_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_prize_exchange,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_prize_exchange_err_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_prize_exchange_err,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_hundred_settlement_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_hundred_settlement,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

format_log_car_settlement_name()->
	{Y,M,D} = erlang:date(),
	util:to_atom( lists:concat([t_car_settlement,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ]) ).

tomorrow_log_tab_name(TabHead)->
	NowSecond = util:now_seconds(),
	{{Y,M,D}, _} = util:seconds_to_datetime(NowSecond+?DAY_SECOND),
	util:to_atom( lists:concat([TabHead,lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) )]) ).
%% %%@doc 格式化机器人信息日志表名
%% format_log_robot_tab_name()->
%% 	{Y,M,D} = erlang:date(),
%% 	Date = lists:flatten( io_lib:format("_~4..0B_~2..0B_~2..0B", [Y,M,D]) ) ,
%% 	TabName = lists:concat([t_log_robot_,Date]),
%% 	{table, statistics,util:to_atom( TabName )}.


%% test_batch_insert() ->
%% 	lists:foreach(fun(E) ->
%% 		Rec = {E,2,3,4},
%% 		ets:insert(?STATISTIC_LOG_ETS_TABLE, Rec)
%% 	end, lists:seq(1, 100)),
%% 	TabName = format_log_item_tab_name(),
%% 	List = ets:tab2list(?STATISTIC_LOG_ETS_TABLE),
%% 	%QueuesInsert = lists:map(fun(E) -> {E,2,3,4} end, lists:seq(1, 10000)),
%% 	%%批量插入的数据
%% 	FieldNames = [ user_id, item_id, place, num ],
%% 	%%每次批量插入3000条
%% 	mod_mysql:batch_insert(TabName,FieldNames,List,?MAX_FLUSH_REC_NUM).

create_table_by_str(TableName, SqlStr) ->
	case check_table_exists(TableName) of
		true ->
			skip;
		_ ->
			mod_mysql:do_sql(SqlStr, 10000)
	end.

sql_create_table(log_item, TabName) ->	
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `player_id` BIGINT(20) NULL DEFAULT 0,
	            `place` INT(11) NULL DEFAULT '0',
	            `item_id` INT(11) NULL DEFAULT '0',
	            `num` BIGINT(20) NULL DEFAULT '0',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(gm_error, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `gm_type` VARCHAR(50) NULL DEFAULT '',
		        `cmd_str` VARCHAR(500) NULL DEFAULT '',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(gm_success, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `gm_type` VARCHAR(50) NULL DEFAULT '',
		        `cmd_str` VARCHAR(500) NULL DEFAULT '',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(prize_exchange, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `player_id` BIGINT(20) NULL DEFAULT 0,
	            `obj_id` INT(11) NULL DEFAULT '0',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(prize_exchange_err, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `player_id` BIGINT(20) NULL DEFAULT 0,
	            `obj_id` INT(11) NULL DEFAULT '0',
	            `time` DATETIME NULL DEFAULT NULL,
	            `err` INT(4) NULL DEFAULT '0'
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(hundred_settlement, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `room_id` INT(11) NULL DEFAULT 0,
	            `times_id` BIGINT(20) NULL DEFAULT '0',
	            `rate_list` VARCHAR(50) NULL DEFAULT '',
	            `total_set_list` VARCHAR(100) NULL DEFAULT '',
	            `real_set_list` VARCHAR(100) NULL DEFAULT '',
	            `master_win` BIGINT(20) NULL DEFAULT '0',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(car_settlement, TabName) ->
	lists:concat(["CREATE TABLE `", TabName, "` (
		        `room_id` INT(11) NULL DEFAULT 0,
	            `times_id` BIGINT(20) NULL DEFAULT '0',
	            `total_set_list` VARCHAR(100) NULL DEFAULT '',
	            `player_set_list` VARCHAR(100) NULL DEFAULT '',
	            `result` INT(11) NULL DEFAULT 0,
	            `index` INT(11) NULL DEFAULT 0,
	            `pool_reward_num` BIGINT(20) NULL DEFAULT '0',
	            `time` DATETIME NULL DEFAULT NULL
              )
              COLLATE='utf8_general_ci'
              ENGINE=InnoDB"]);

sql_create_table(rank, TabName) ->
		lists:concat(["CREATE TABLE `", TabName , "` (
							`player_id` bigint(12) NOT NULL,
							`gold` bigint(14) NOT NULL DEFAULT '0',
							`profit` bigint(14) NOT NULL DEFAULT '0',
							`diamond` bigint(14) NOT NULL DEFAULT '0',
							`fruit` bigint(14) NOT NULL DEFAULT '0',
							`redpack` bigint(14) NOT NULL DEFAULT '0',
							`car` bigint(14) NOT NULL DEFAULT '0',
							`hundred_niu` bigint(14) NOT NULL DEFAULT '0',
							`airlaba_bet` bigint(14) NOT NULL DEFAULT '0',
							`updtime` DATETIME NULL DEFAULT NULL,
							PRIMARY KEY (`player_id`)
						)
						COLLATE='utf8_general_ci'
						ENGINE=InnoDB"]).

check_table_exists(TableName) ->
	MySqlConfig = config_mysql:get_statistics_server_info(),
	MysqlDBName = MySqlConfig#mysql_server_info.database,
	{data, Result} = mod_mysql:do_sql(lists:concat(["select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA='",
		MysqlDBName,"' and TABLE_NAME='",TableName,"';"]), 5000),
	case mysql:get_result_rows(Result) of
		[] -> false;
		_Table -> true
	end.

check_exist_table(TabName, TableType) ->
	case check_table_exists(TabName) of
		true ->
			skip;
		_ ->
			mod_mysql:do_sql(sql_create_table(TableType, TabName), 10000)
	end.

send_after_gm_log() ->
	erlang:send_after(?MLOG_ETS_GM_TIMER_INTERVAL*1000, self(), 'flush_gm').

send_after_item_use_log() ->
	erlang:send_after(?MLOG_ETS_ITEM_USE_TIMER_INTERVAL*1000, self(), 'flush_item_use').

send_after_check_table_exist(NowSeconds) ->
	erlang:send_after(60 * 1000, self(), {'check_table_exist', NowSeconds}).

check_all_table_exist() ->
	lists:foreach(fun({ETabName, EType}) ->
		check_exist_table(ETabName, EType) end,
		[
			{format_log_gm_success_name(), gm_success},
			{format_log_item_use_tab_name(), log_item},
			{format_log_gm_error_name(), gm_error},
			{format_log_prize_exchange_name(), prize_exchange},
			{format_log_prize_exchange_err_name(), prize_exchange_err},
			{format_log_hundred_settlement_name(), hundred_settlement},
			{format_log_car_settlement_name(), car_settlement}
		]).

create_tomorow_table() ->
	lists:foreach(fun({ETabName, EType}) ->
		mod_mysql:do_sql(sql_create_table(EType, ETabName), 10000) end,
		[
			{tomorrow_log_tab_name(t_gm_success), gm_success},
			{tomorrow_log_tab_name(t_log_item), log_item},
			{tomorrow_log_tab_name(t_gm_error), gm_error},
			{tomorrow_log_tab_name(t_prize_exchange), prize_exchange},
			{tomorrow_log_tab_name(t_prize_exchange_err), prize_exchange_err},
			{tomorrow_log_tab_name(t_hundred_settlement), hundred_settlement},
			{tomorrow_log_tab_name(t_car_settlement), car_settlement}
		]).

test_insert_data() ->
	log_util:add_gm_oprate(?MLOG_ETS_GM_success, send_mail, ["asda", "asda", "1231231", "1231", "123+123"]),
	log_util:add_gm_oprate(?MLOG_ETS_GM_error, send_mail, ["asda", "asda", "1231231", "1231", "123+123"]).


total_export_to_mysql() ->
	MTableName1 = format_log_gm_success_name(),
	check_exist_table(MTableName1, gm_success),
	flush_ets_to_mysql(?MLOG_ETS_GM_success, MTableName1),

	MTableName2 = format_log_gm_error_name(),
	check_exist_table(MTableName2, gm_error),
	flush_ets_to_mysql(?MLOG_ETS_GM_error, MTableName2),

	MTableName3 = format_log_prize_exchange_name(),
	check_exist_table(MTableName3, prize_exchange),
	flush_ets_to_mysql(?MLOG_ETS_PRIZE_EXCHANGE, MTableName3),

	MTableName3_1 = format_log_prize_exchange_err_name(),
	check_exist_table(MTableName3_1, prize_exchange_err),
	flush_ets_to_mysql(?MLOG_ETS_PRIZE_EXCHANGE_ERR, MTableName3_1),

	% MTableName4 = format_log_hundred_settlement_name(),
	% check_exist_table(MTableName4, hundred_settlement),
	% flush_ets_to_mysql(?MLOG_ETS_HUNDRED_SETTLEMENT, MTableName4),

	% MTableName5 = format_log_car_settlement_name(),
	% check_exist_table(MTableName5, car_settlement),
	% flush_ets_to_mysql(?MLOG_ETS_CAR_SETTLEMENT, MTableName5),

	MTableName = format_log_item_use_tab_name(),
	check_exist_table(MTableName, log_item),
	flush_ets_to_mysql(?MLOG_ETS_ITEM_USE, MTableName),
	ok.