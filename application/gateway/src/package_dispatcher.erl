-module(package_dispatcher).
-include("../../gate/include/logger.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/niu_game_pb.hrl").
-include_lib("network_proto/include/shop_pb.hrl").
-include_lib("network_proto/include/hundred_niu_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include_lib("network_proto/include/laba_pb.hrl").
-include_lib("network_proto/include/prize_exchange_pb.hrl").
-include_lib("network_proto/include/mail_pb.hrl").
-include_lib("network_proto/include/red_pack_pb.hrl").
-include_lib("network_proto/include/activity_pb.hrl").
-include_lib("network_proto/include/share_pb.hrl").
-include_lib("network_proto/include/car_pb.hrl").
-include_lib("network_proto/include/chest_pb.hrl").
-export([dispatch/4]).

dispatch(Msg, FromPid, ClientSocket, PlayerPid) ->
	%catch io:format("tcp _______________ ~p ~ts ~p ~w~n", [erlang:localtime(), get(dic_account), element(1, Msg), erlang:process_info(self(), memory)]),
	%io:format("tcp _______________ ~p ~ts ~p ~w~n", [erlang:localtime(), get(dic_account), element(1, Msg), erlang:process_info(self(), memory)]),
	case Msg of
	%% 登陆请
		#cs_login{} ->
			tcp_client:login(FromPid, Msg);
	%% 退出登陆
		#cs_login_out{} ->
			tcp_client:login_out(FromPid);
	%% 请求重登
		#cs_login_reconnection{} ->
			tcp_client:login_reconnection(FromPid, Msg);
	%% 心跳
		#cs_common_heartbeat{} ->
			tcp_client:heartbeat();
	%% 更新客户端已接收的协议计数
		#cs_common_proto_clean{} ->
			socket_buffer:cs_clean(Msg);
	%% 通知服务端清理协议缓存3
		#cs_common_proto_count{} ->
			socket_buffer:cs_count(ClientSocket, Msg);

	%% 玩家相关 -------------
	%% 改名
		#cs_player_change_name_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
	%% 改头像
		#cs_player_change_headicon_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_player_chat{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_query_player_winning_rec_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_niu_subsidy_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_niu_query_in_game_player_num_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_common_bug_feedback{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_draw_mission_request{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_rank_query_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_read_mail{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_mail_draw_request{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_guide_next_step_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_game_task_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_game_task_box_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_hundred_last_week_rank_query_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		%% --- 粘性红包 ----
		#cs_stickiness_redpack_draw_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_player_stickiness_redpack_info_notify_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_player_bet_stickiness_redpack_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		% --- 下注锁 ---
		#cs_bet_lock_config_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		% --- 每日工资 ---
		#cs_player_salary_query_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		%%
		#cs_prize_query_one_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_prize', Msg});
		#cs_prize_address_change_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_prize', Msg});
		#cs_prize_exchange_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_prize', Msg});
		#cs_prize_query_phonecard_key_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_prize', Msg});

		#cs_real_name_update{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_real_name_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_super_laba_last_week_rank_query_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_query_last_daily_rank_reward_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
	%% 玩家相关 -------------


	%% 牛牛 -------------
		#cs_niu_enter_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_choose_master_rate_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_choose_free_rate_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_leave_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_submit_card_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_syn_in_game_state_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});
		#cs_niu_query_player_room_info_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_redpack_relive_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_niu_room', Msg});

	%% 牛牛 -------------

	%%-------商店--------------
		#cs_shop_buy_query{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_golden_bull_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_month_card_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_period_card_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_redpack_task_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});

		#cs_activity_info_query_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_activity_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
		#cs_golden_bull_mission{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_shop', Msg});
	%%--------------------------

	%% ------百人------------
		#cs_hundred_niu_enter_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_niu_player_list_query_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_niu_free_set_chips_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_niu_sit_down_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_be_master_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_niu_in_game_syn_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_leave_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_query_master_list_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_query_winning_rec_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});
		#cs_hundred_query_pool_win_player_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_hundred', Msg});

	%% ------百人------------

	%% ------拉霸------------
		#cs_laba_enter_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_enter_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_laba_leave_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_leave_room_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_laba_spin_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_win_player_list{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_fire_bet_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_switch_phase_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_use_item_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
		#cs_airlaba_impov_sub_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_laba', Msg});
	%% ------拉霸------------
	%% ------签到----------
		#cs_daily_checkin_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_make_up_for_checkin_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_vip_daily_reward{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		%---------抽奖---------
		#cs_lottery_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
	% ----------------------
		#cs_player_niu_room_chest_draw{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		#cs_player_bind_phone_num_draw{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_player', Msg});
		%---------分享------------
	 #cs_share_new_bee_reward_req{}->
		 role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_share_mission_reward_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_share_draw_request{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_share_friend_request{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_share_rank_request{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_task_seven_award_request{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
		#cs_share_with_friends_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_share', Msg});
	%% ------红包---------
		#cs_red_pack_query_list_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		#cs_red_pack_open_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		#cs_red_pack_create_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		#cs_red_pack_cancel_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});

		#cs_redpack_room_draw_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		#cs_red_pack_do_select_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		#cs_red_pack_search_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_redpack', Msg});
		%%---------豪车--------
		#cs_car_enter_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_exit_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_master_list_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_add_money_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_user_list_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_rebet_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_bet_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_syn_in_game_state_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_master_req{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		#cs_car_query_pool_win_player_req{} ->
			role_processor:send_gate_event(PlayerPid, {'gate_event_car', Msg});
		%% --- 活动 ----
	 	#cs_task_pay_award_request{}->
		 	role_processor:send_gate_event(PlayerPid, {'gate_event_activity', Msg});
		#cs_task_pay_info_request{}->
			role_processor:send_gate_event(PlayerPid, {'gate_event_activity', Msg});
		_ ->
			?INFO_LOG("~p dispatch not match! Msg = ~p~n", [?MODULE, Msg])
	end.


