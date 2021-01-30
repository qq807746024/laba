%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 三月 2017 18:30
%%%-------------------------------------------------------------------
-module(prize_mod).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/prize_exchange_pb.hrl").

-define(TIMER_SEC_FRESH, 1).	%% 1s检测刷新一次
-define(DIC_POOL_NUM, dic_pool_num).	%% 1s检测刷新一次
-define(TIMER_DEF_DICT_UPDATE_STORAGE, timer_def_dict_update_storage).	%% 10S 延迟
-define(STORAGE_CHANGE_DICT, storage_change_dict).	%% 变化数据
%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start_link/1,
	get_mod_pid/0,
	pack_storage_info_msg/1,
	add_storage/2,
	init_ets/0
]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

start_link(ModProcessName) ->
	gen_server:start_link(?MODULE, [ModProcessName], []).

get_mod_pid() ->
	misc:get_mod_pid(?MODULE).

init([ModProcessName]) ->
	put(?STORAGE_CHANGE_DICT, dict:new()),
	process_flag(trap_exit, true),
	util_process:register_local(ModProcessName, self()),
	init_ets(),
	State = #state{},
	{ok, State}.

init_ets() ->
	ConfigList = prize_exchange_config_db:get_base(),
	lists:foreach(fun(E) ->
		ObjId = E#prize_exchange_config.id,
		case prize_storage_info_db:get(ObjId) of
			{ok, [Info]} ->
				{Flag,NewStoreInfo} = check_prize_config(Info,E),
				if
					Flag ->
						prize_storage_info_db:write(NewStoreInfo);
					true ->
						skip
				end;
			_ ->
				NewStoreInfo = #prize_storage_info{
					id = ObjId,            %%编号,
					day_times = E#prize_exchange_config.exchange,
					count = E#prize_exchange_config.stock,

					card_count =E#prize_exchange_config.stock2
				},
				prize_storage_info_db:write(NewStoreInfo)
		end,
		ets:insert(?ETS_PRIZE_STORAGE_INFO, NewStoreInfo) 
	end, ConfigList).

%% ====================================================================
handle_call(Request, From, State) ->
	try
		do_call(Request, From, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod call Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Request}, erlang:get_stacktrace()]),
			{reply, ok, State}
	end.

%% ====================================================================
handle_cast(Msg, State) ->
	try
		do_cast(Msg, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

%% ====================================================================
handle_info(Info, State) ->
	try
		do_info(Info, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Info}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

%% ====================================================================
terminate(_Reason, _State) ->
	?ERROR_LOG("~p terminated ~n", [?MODULE]),
	ok.

%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

do_call({'exchange_prize', ObjId, ChargeType}, _From, State) ->
	case ets:lookup(?ETS_PRIZE_STORAGE_INFO, ObjId) of
		[StorageInfo] ->
      {NewCount, NewCardCount} =
			  case ChargeType of
			    1 ->
            {StorageInfo#prize_storage_info.count-1, StorageInfo#prize_storage_info.card_count};
          _ ->
            {StorageInfo#prize_storage_info.count, StorageInfo#prize_storage_info.card_count-1}
			  end,

			if
        NewCount >= 0 andalso NewCardCount >= 0->
					NewStorageInfo = StorageInfo#prize_storage_info{count = NewCount, card_count = NewCardCount},
					Reply = {true, NewCount, NewCardCount},
					ets:insert(?ETS_PRIZE_STORAGE_INFO, NewStorageInfo),
					prize_storage_info_db:write(NewStorageInfo),
					update_storage_change_item(ObjId, {NewCount, NewCardCount});
				true ->
					Reply = false
			end;
		_ ->
			Reply = false
	end,
	{reply, Reply, State};

do_call(Request, From, State) ->
	?ERROR_LOG("mod call bad match! info = ~p~n", [{?MODULE, Request, From}]),
	{reply, ok, State}.

do_cast(Msg, State) ->
	?ERROR_LOG("mod cast bad match! info = ~p~n", [{?MODULE, Msg}]),
	{noreply, State}.

do_info('notice_prize_config_update', State) ->
	Dict = get(?STORAGE_CHANGE_DICT),
	List = dict:to_list(Dict),
	Msg = pack_storage_info_msg(List),
	sys_notice_mod:send_to_all_player(Msg),
	put(?STORAGE_CHANGE_DICT, dict:new()),
	OldTimer = get(?TIMER_DEF_DICT_UPDATE_STORAGE),
	if
		is_reference(OldTimer) ->
			erlang:cancel_timer(OldTimer);
		true ->
			skip
	end,
	{noreply, State};

do_info(Info, State) ->
	?ERROR_LOG("mod info bad match! info = ~p~n", [{?MODULE, Info}]),
	{noreply, State}.

update_storage_change_item(ObjId, NewLeft) ->
	OldDict = get(?STORAGE_CHANGE_DICT),
	NewDict = dict:store(ObjId, NewLeft, OldDict),
	put(?STORAGE_CHANGE_DICT, NewDict),
	OldTimer = get(?TIMER_DEF_DICT_UPDATE_STORAGE),
	if
		is_reference(OldTimer) ->
			erlang:cancel_timer(OldTimer);
		true ->
			skip
	end,
	TimerDef = erlang:send_after(5*1000, self(), 'notice_prize_config_update'),
	put(?TIMER_DEF_DICT_UPDATE_STORAGE, TimerDef).

pack_storage_info_msg(List) ->
	PbList =
		lists:foldl(fun({Key, {Count1, Count2}}, Acc) ->
			Pb =
				#pb_prize_query_one{
					obj_id = Key,
					store_num = Count1,
					crad_num = Count2
				},
			[Pb|Acc] end, [], List),
	#sc_prize_storage_red_point_update{
		list = PbList
	}.

add_storage(List, AddNum) ->
	lists:foreach(fun(E) ->
		case ets:lookup(?ETS_PRIZE_STORAGE_INFO, E) of
			[Info] ->
				NewInfo = Info#prize_storage_info{count = AddNum},
				ets:insert(?ETS_PRIZE_STORAGE_INFO, NewInfo);
			_ ->
				skip
		end end, List).
check_prize_config(Info,EConfig)->
	if
		EConfig#prize_exchange_config.exchange == Info#prize_storage_info.day_times->
			{false,Info};
		true ->
			NewInfo = Info#prize_storage_info{
				day_times = EConfig#prize_exchange_config.exchange
			},
			{true,NewInfo}
	end.