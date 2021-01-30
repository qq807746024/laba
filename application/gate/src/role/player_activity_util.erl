%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 三月 2017 15:31
%%% 活动公告模块
%%%-------------------------------------------------------------------
-module(player_activity_util).
-include_lib("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/activity_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").

%% API
-export([
	send_init_msg/0,
	cs_activity_info_query_req/1,
	cs_activity_draw_req/2,
	pack_activity_config/0,
	check_activity_time/1,
	get_activity_time/1
]).


send_init_msg() ->
	Msg = #sc_activity_config_info_update{
		activity_list = pack_activity_config(),
		hide_function_flag = config_app:get_function_switch()
	},
	%?INFO_LOG("sc_activity_config_info_update ~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

pack_activity_config() ->
	ConfigList = [?ACTIVITY_TYPE_NIU, ?ACTIVITY_TYPE_FRUIT],
	pack_activity_config(ConfigList, []).

pack_activity_config([], Acc) -> Acc;
pack_activity_config([Config | T], Acc) ->
	This =
		case Config of
			?ACTIVITY_TYPE_NIU ->
				#pb_activity_config{
					activity_data = pack_activity_data(?ACTIVITY_TYPE_NIU),
					sub_list = pack_pack_task_activity_sub_config_list(?ACTIVITY_TYPE_NIU)
				};
			?ACTIVITY_TYPE_FRUIT ->
				#pb_activity_config{
					activity_data = pack_activity_data(?ACTIVITY_TYPE_FRUIT),
					sub_list = pack_pack_task_activity_sub_config_list(?ACTIVITY_TYPE_FRUIT)
				};
			_ ->
				#pb_activity_config{
					activity_data = [],
					sub_list = []
				}
		end,
	pack_activity_config(T, [This | Acc]).

pack_activity_data(ActivityType) ->
	case ActivityType of
		?ACTIVITY_TYPE_NIU ->
			get_activity_data_from_packtask(?ACTIVITY_TYPE_NIU);
		?ACTIVITY_TYPE_FRUIT ->
			get_activity_data_from_packtask(?ACTIVITY_TYPE_FRUIT);
		_ ->
			[]
	end.

get_activity_data_from_packtask(Type) ->
	PlayerTaskData = player_pack_task:get_dict_pack_task(),
	case lists:keyfind(Type, #pb_redpack_task_draw_info.game_type, PlayerTaskData#player_pack_task_info.task_info_list) of
		false ->
			[];
		TaskInfo ->
			#pb_activity_data{
				id = Type,
				current_data = TaskInfo#pb_redpack_task_draw_info.gold_num,
				draw_info_list = TaskInfo#pb_redpack_task_draw_info.draw_list
			}
	end.


pack_pack_task_activity_sub_config_list(ActivityType) ->
	{ok, RedPackList} = redpack_task_reward_config_db:get_by_type(ActivityType),
	lists:map(fun(EData) ->
		{_, Id} = EData#redpack_task_reward_config.key,
		#pb_sub_activity_config{
			id = Id,
			data = EData#redpack_task_reward_config.need_gold,
			reward_list = item_use:get_pb_reward_info([{?ITEM_ID_GOLD, EData#redpack_task_reward_config.reward_pack_num}])
		} end, RedPackList).

cs_activity_info_query_req(ActivityId) ->
	case check_have_the_activity(ActivityId) of
		true ->
			Data = pack_activity_data(ActivityId),
			Msg = #sc_activity_info_query_reply{
				activity_data = Data
			},
			tcp_client:send_data(player_util:get_dic_gate_pid(), Msg);
		_ ->
			sys_notice_mod:send_notice("活动id错误")
	end.

check_have_the_activity(ActivityId) ->
	ActivityId > 0 andalso ActivityId =< 2.

cs_activity_draw_req(ActivityId, SubId) ->
	GameType = ActivityId,
	player_pack_task:cs_redpack_task_draw_req(GameType, SubId, 'lobby').

check_activity_time(Type)->
	case activity_time_config_db:get(Type) of
		{ok,[Cnonfig]}->
			NowSec = util:now_seconds(),
			StartTime = util:datetime_to_seconds(Cnonfig#activity_time_config.time1),
			EndTime = util:datetime_to_seconds(Cnonfig#activity_time_config.time2),
			NowSec >= StartTime andalso NowSec =< EndTime;
		_->
			false
	end.

get_activity_time(Type)->
	case activity_time_config_db:get(Type) of
		{ok,[Cnonfig]}->

			StartTime = util:datetime_to_seconds(Cnonfig#activity_time_config.time1),
			EndTime = util:datetime_to_seconds(Cnonfig#activity_time_config.time2),
			{StartTime ,EndTime};
		_->
			{0,0}
	end.