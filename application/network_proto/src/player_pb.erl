-file("src/player_pb.erl", 1).

-module(player_pb).

-export([encode_sc_lottery_draw_resp/1,
	 decode_sc_lottery_draw_resp/1,
	 encode_cs_lottery_draw_req/1,
	 decode_cs_lottery_draw_req/1,
	 encode_pb_lottery_reward_config/1,
	 decode_pb_lottery_reward_config/1,
	 encode_pb_lottery_item/1, decode_pb_lottery_item/1,
	 encode_sc_player_salary_draw_resp/1,
	 decode_sc_player_salary_draw_resp/1,
	 encode_cs_player_salary_draw_req/1,
	 decode_cs_player_salary_draw_req/1,
	 encode_sc_player_salary_query_resp/1,
	 decode_sc_player_salary_query_resp/1,
	 encode_cs_player_salary_query_req/1,
	 decode_cs_player_salary_query_req/1,
	 encode_sc_bet_lock_update_notify/1,
	 decode_sc_bet_lock_update_notify/1,
	 encode_sc_bet_lock_config_resp/1,
	 decode_sc_bet_lock_config_resp/1,
	 encode_cs_bet_lock_config_req/1,
	 decode_cs_bet_lock_config_req/1,
	 encode_pb_bet_lock_config_list_elem/1,
	 decode_pb_bet_lock_config_list_elem/1,
	 encode_sc_player_bet_stickiness_redpack_draw_resp/1,
	 decode_sc_player_bet_stickiness_redpack_draw_resp/1,
	 encode_cs_player_bet_stickiness_redpack_draw_req/1,
	 decode_cs_player_bet_stickiness_redpack_draw_req/1,
	 encode_sc_player_bet_stickiness_notify/1,
	 decode_sc_player_bet_stickiness_notify/1,
	 encode_pb_player_bet_stickiness_redpack_list_elem/1,
	 decode_pb_player_bet_stickiness_redpack_list_elem/1,
	 encode_cs_player_stickiness_redpack_info_notify_req/1,
	 decode_cs_player_stickiness_redpack_info_notify_req/1,
	 encode_sc_stickiness_redpack_draw_resp/1,
	 decode_sc_stickiness_redpack_draw_resp/1,
	 encode_cs_stickiness_redpack_draw_req/1,
	 decode_cs_stickiness_redpack_draw_req/1,
	 encode_sc_player_stickiness_redpack_info_notify/1,
	 decode_sc_player_stickiness_redpack_info_notify/1,
	 encode_pb_cur_stickiness_redpack_info/1,
	 decode_pb_cur_stickiness_redpack_info/1,
	 encode_sc_query_last_daily_rank_reward_reply/1,
	 decode_sc_query_last_daily_rank_reward_reply/1,
	 encode_cs_query_last_daily_rank_reward_req/1,
	 decode_cs_query_last_daily_rank_reward_req/1,
	 encode_sc_super_laba_last_week_rank_query_reply/1,
	 decode_sc_super_laba_last_week_rank_query_reply/1,
	 encode_cs_super_laba_last_week_rank_query_req/1,
	 decode_cs_super_laba_last_week_rank_query_req/1,
	 encode_sc_real_name_req/1, decode_sc_real_name_req/1,
	 encode_cs_real_name_req/1, decode_cs_real_name_req/1,
	 encode_sc_real_name_update/1,
	 decode_sc_real_name_update/1,
	 encode_cs_real_name_update/1,
	 decode_cs_real_name_update/1,
	 encode_pb_hundred_last_week_data/1,
	 decode_pb_hundred_last_week_data/1,
	 encode_sc_hundred_last_week_rank_query_reply/1,
	 decode_sc_hundred_last_week_rank_query_reply/1,
	 encode_cs_hundred_last_week_rank_query_req/1,
	 decode_cs_hundred_last_week_rank_query_req/1,
	 encode_sc_guide_next_step_reply/1,
	 decode_sc_guide_next_step_reply/1,
	 encode_cs_guide_next_step_req/1,
	 decode_cs_guide_next_step_req/1,
	 encode_sc_guide_info_update/1,
	 decode_sc_guide_info_update/1,
	 encode_sc_vip_daily_reward/1,
	 decode_sc_vip_daily_reward/1,
	 encode_cs_vip_daily_reward/1,
	 decode_cs_vip_daily_reward/1, encode_pb_rank_info/1,
	 decode_pb_rank_info/1, encode_sc_rank_qurey_reply/1,
	 decode_sc_rank_qurey_reply/1,
	 encode_cs_rank_query_req/1, decode_cs_rank_query_req/1,
	 encode_sc_niu_special_subsidy_info_update/1,
	 decode_sc_niu_special_subsidy_info_update/1,
	 encode_sc_player_bind_phone_num_draw_reply/1,
	 decode_sc_player_bind_phone_num_draw_reply/1,
	 encode_cs_player_bind_phone_num_draw/1,
	 decode_cs_player_bind_phone_num_draw/1,
	 encode_sc_player_bind_phone_num/1,
	 decode_sc_player_bind_phone_num/1,
	 encode_sc_player_phone_num_info_update/1,
	 decode_sc_player_phone_num_info_update/1,
	 encode_cs_make_up_for_checkin_req/1,
	 decode_cs_make_up_for_checkin_req/1,
	 encode_pb_checkin_info/1, decode_pb_checkin_info/1,
	 encode_sc_daily_checkin_info_update/1,
	 decode_sc_daily_checkin_info_update/1,
	 encode_sc_daily_checkin_reply/1,
	 decode_sc_daily_checkin_reply/1,
	 encode_cs_daily_checkin_req/1,
	 decode_cs_daily_checkin_req/1,
	 encode_sc_player_base_make_name_back/1,
	 decode_sc_player_base_make_name_back/1,
	 encode_cs_player_base_make_name/1,
	 decode_cs_player_base_make_name/1,
	 encode_sc_niu_special_subsidy_share/1,
	 decode_sc_niu_special_subsidy_share/1,
	 encode_cs_niu_special_subsidy_share/1,
	 decode_cs_niu_special_subsidy_share/1,
	 encode_sc_niu_subsidy_info_update/1,
	 decode_sc_niu_subsidy_info_update/1,
	 encode_sc_niu_subsidy_reply/1,
	 decode_sc_niu_subsidy_reply/1,
	 encode_cs_niu_subsidy_req/1,
	 decode_cs_niu_subsidy_req/1,
	 encode_sc_niu_query_in_game_player_num_reply/1,
	 decode_sc_niu_query_in_game_player_num_reply/1,
	 encode_pb_room_player_num/1,
	 decode_pb_room_player_num/1,
	 encode_cs_niu_query_in_game_player_num_req/1,
	 decode_cs_niu_query_in_game_player_num_req/1,
	 encode_sc_query_player_winning_rec_reply/1,
	 decode_sc_query_player_winning_rec_reply/1,
	 encode_cs_query_player_winning_rec_req/1,
	 decode_cs_query_player_winning_rec_req/1,
	 encode_sc_tips/1, decode_sc_tips/1,
	 encode_sc_player_sys_notice/1,
	 decode_sc_player_sys_notice/1, encode_sc_player_chat/1,
	 decode_sc_player_chat/1, encode_cs_player_chat/1,
	 decode_cs_player_chat/1,
	 encode_sc_player_change_headicon_reply/1,
	 decode_sc_player_change_headicon_reply/1,
	 encode_cs_player_change_headicon_req/1,
	 decode_cs_player_change_headicon_req/1,
	 encode_sc_player_change_name_reply/1,
	 decode_sc_player_change_name_reply/1,
	 encode_cs_player_change_name_req/1,
	 decode_cs_player_change_name_req/1,
	 encode_sc_player_base_info/1,
	 decode_sc_player_base_info/1, encode_pb_reward_info/1,
	 decode_pb_reward_info/1, encode_sc_item_use_reply/1,
	 decode_sc_item_use_reply/1, encode_cs_item_use_req/1,
	 decode_cs_item_use_req/1, encode_pb_item_info/1,
	 decode_pb_item_info/1, encode_sc_items_init_update/1,
	 decode_sc_items_init_update/1, encode_sc_items_delete/1,
	 decode_sc_items_delete/1, encode_sc_items_add/1,
	 decode_sc_items_add/1, encode_sc_items_update/1,
	 decode_sc_items_update/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2]).

-record(sc_lottery_draw_resp,
	{left_times, reward_item_id, reward_item_num, is_reward,
	 reward_configs}).

-record(cs_lottery_draw_req, {prize_cls}).

-record(pb_lottery_reward_config,
	{index, cost_item, reward_items}).

-record(pb_lottery_item, {item_id, item_num}).

-record(sc_player_salary_draw_resp, {salary, desc}).

-record(cs_player_salary_draw_req, {}).

-record(sc_player_salary_query_resp,
	{yesterday_earn, today_earn, yesterday_salary,
	 is_draw}).

-record(cs_player_salary_query_req, {}).

-record(sc_bet_lock_update_notify,
	{room_type, testtype, cur_level, total_amount}).

-record(sc_bet_lock_config_resp,
	{room_type, testtype, configs}).

-record(cs_bet_lock_config_req, {room_type, testtype}).

-record(pb_bet_lock_config_list_elem,
	{level, bet_gold_limit, next_gen_gold, next_gen_vip}).

-record(sc_player_bet_stickiness_redpack_draw_resp,
	{room_type, testtype, level, reward_amount, desc}).

-record(cs_player_bet_stickiness_redpack_draw_req,
	{room_type, testtype, level}).

-record(sc_player_bet_stickiness_notify,
	{room_type, testtype, cur_bet, total_bet, cur_level,
	 redpack_list}).

-record(pb_player_bet_stickiness_redpack_list_elem,
	{level, redpack_1, redpack_2, redpack_3}).

-record(cs_player_stickiness_redpack_info_notify_req,
	{room_type, testtype}).

-record(sc_stickiness_redpack_draw_resp,
	{cur_info, reward_type, reward_amount}).

-record(cs_stickiness_redpack_draw_req,
	{room_type, testtype}).

-record(sc_player_stickiness_redpack_info_notify,
	{cur_info}).

-record(pb_cur_stickiness_redpack_info,
	{room_type, testtype, level, reward_type, reward_amount,
	 reward_min, cur_total_amount, cur_trigger_next_amount,
	 cur_earn_gold, gold_cov_to_reward_item_rate,
	 holding_earn_gold, total_gold, end_time}).

-record(sc_query_last_daily_rank_reward_reply,
	{type, date, rank_info_list}).

-record(cs_query_last_daily_rank_reward_req, {type}).

-record(sc_super_laba_last_week_rank_query_reply,
	{list}).

-record(cs_super_laba_last_week_rank_query_req, {}).

-record(sc_real_name_req, {type}).

-record(cs_real_name_req, {}).

-record(sc_real_name_update, {result, err, rewards}).

-record(cs_real_name_update, {name, id_card_num}).

-record(pb_hundred_last_week_data,
	{rank, reward_gold, name1_round_win, name2_total_win}).

-record(sc_hundred_last_week_rank_query_reply, {list}).

-record(cs_hundred_last_week_rank_query_req, {}).

-record(sc_guide_next_step_reply, {result, reward}).

-record(cs_guide_next_step_req, {next_step_id}).

-record(sc_guide_info_update, {step_id}).

-record(sc_vip_daily_reward, {result, err, rewards}).

-record(cs_vip_daily_reward, {}).

-record(pb_rank_info,
	{rank, player_uuid, player_name, player_icon,
	 player_vip, gold_num, win_gold_num, cash_num, sex,
	 hundred_win, account, redpack}).

-record(sc_rank_qurey_reply,
	{rank_type, my_rank, rank_info_list, pool,
	 my_recharge_money, start_time, end_time}).

-record(cs_rank_query_req, {rank_type}).

-record(sc_niu_special_subsidy_info_update,
	{left_times, subsidy_gold, is_share}).

-record(sc_player_bind_phone_num_draw_reply,
	{result, err, rewards}).

-record(cs_player_bind_phone_num_draw, {}).

-record(sc_player_bind_phone_num, {result}).

-record(sc_player_phone_num_info_update,
	{phone_num, is_draw}).

-record(cs_make_up_for_checkin_req, {flag}).

-record(pb_checkin_info, {day, rewards, is_draw}).

-record(sc_daily_checkin_info_update,
	{list, all_checkin_day, is_checkin_today, vip_is_draw}).

-record(sc_daily_checkin_reply,
	{result, err, rewards, flag}).

-record(cs_daily_checkin_req, {flag}).

-record(sc_player_base_make_name_back, {name}).

-record(cs_player_base_make_name, {}).

-record(sc_niu_special_subsidy_share, {}).

-record(cs_niu_special_subsidy_share, {result}).

-record(sc_niu_subsidy_info_update,
	{left_times, subsidy_gold}).

-record(sc_niu_subsidy_reply, {result, err}).

-record(cs_niu_subsidy_req, {type}).

-record(sc_niu_query_in_game_player_num_reply, {list}).

-record(pb_room_player_num, {room_level, player_num}).

-record(cs_niu_query_in_game_player_num_req,
	{game_type}).

-record(sc_query_player_winning_rec_reply,
	{win_rate, win_count, defeated_count, max_property,
	 total_profit, week_profit, niu_10, niu_11, niu_12,
	 niu_13, niu_0_win, obj_player_uuid, obj_name, sex, gold,
	 icon, level, vip_level, account}).

-record(cs_query_player_winning_rec_req,
	{obj_player_uuid}).

-record(sc_tips, {type, text}).

-record(sc_player_sys_notice, {flag, content}).

-record(sc_player_chat,
	{room_type, content_type, content, player_uuid,
	 player_name, player_icon, player_vip, player_seat_pos,
	 send_time, des_player_uuid, des_player_name}).

-record(cs_player_chat,
	{room_type, content_type, content, obj_player_uuid}).

-record(sc_player_change_headicon_reply, {result}).

-record(cs_player_change_headicon_req, {icon, sex}).

-record(sc_player_change_name_reply, {result}).

-record(cs_player_change_name_req, {name}).

-record(sc_player_base_info,
	{player_uuid, account, name, gold, diamond, cash, exp,
	 level, icon, sex, vip_level, rmb, block}).

-record(pb_reward_info, {base_id, count}).

-record(sc_item_use_reply, {result, err_msg}).

-record(cs_item_use_req, {item_uuid, num}).

-record(pb_item_info, {uuid, base_id, count}).

-record(sc_items_init_update, {all_list}).

-record(sc_items_delete, {del_list}).

-record(sc_items_add, {add_list}).

-record(sc_items_update, {upd_list}).

encode(Record) -> encode(element(1, Record), Record).

encode_sc_lottery_draw_resp(Record)
    when is_record(Record, sc_lottery_draw_resp) ->
    encode(sc_lottery_draw_resp, Record).

encode_cs_lottery_draw_req(Record)
    when is_record(Record, cs_lottery_draw_req) ->
    encode(cs_lottery_draw_req, Record).

encode_pb_lottery_reward_config(Record)
    when is_record(Record, pb_lottery_reward_config) ->
    encode(pb_lottery_reward_config, Record).

encode_pb_lottery_item(Record)
    when is_record(Record, pb_lottery_item) ->
    encode(pb_lottery_item, Record).

encode_sc_player_salary_draw_resp(Record)
    when is_record(Record, sc_player_salary_draw_resp) ->
    encode(sc_player_salary_draw_resp, Record).

encode_cs_player_salary_draw_req(Record)
    when is_record(Record, cs_player_salary_draw_req) ->
    encode(cs_player_salary_draw_req, Record).

encode_sc_player_salary_query_resp(Record)
    when is_record(Record, sc_player_salary_query_resp) ->
    encode(sc_player_salary_query_resp, Record).

encode_cs_player_salary_query_req(Record)
    when is_record(Record, cs_player_salary_query_req) ->
    encode(cs_player_salary_query_req, Record).

encode_sc_bet_lock_update_notify(Record)
    when is_record(Record, sc_bet_lock_update_notify) ->
    encode(sc_bet_lock_update_notify, Record).

encode_sc_bet_lock_config_resp(Record)
    when is_record(Record, sc_bet_lock_config_resp) ->
    encode(sc_bet_lock_config_resp, Record).

encode_cs_bet_lock_config_req(Record)
    when is_record(Record, cs_bet_lock_config_req) ->
    encode(cs_bet_lock_config_req, Record).

encode_pb_bet_lock_config_list_elem(Record)
    when is_record(Record, pb_bet_lock_config_list_elem) ->
    encode(pb_bet_lock_config_list_elem, Record).

encode_sc_player_bet_stickiness_redpack_draw_resp(Record)
    when is_record(Record,
		   sc_player_bet_stickiness_redpack_draw_resp) ->
    encode(sc_player_bet_stickiness_redpack_draw_resp,
	   Record).

encode_cs_player_bet_stickiness_redpack_draw_req(Record)
    when is_record(Record,
		   cs_player_bet_stickiness_redpack_draw_req) ->
    encode(cs_player_bet_stickiness_redpack_draw_req,
	   Record).

encode_sc_player_bet_stickiness_notify(Record)
    when is_record(Record,
		   sc_player_bet_stickiness_notify) ->
    encode(sc_player_bet_stickiness_notify, Record).

encode_pb_player_bet_stickiness_redpack_list_elem(Record)
    when is_record(Record,
		   pb_player_bet_stickiness_redpack_list_elem) ->
    encode(pb_player_bet_stickiness_redpack_list_elem,
	   Record).

encode_cs_player_stickiness_redpack_info_notify_req(Record)
    when is_record(Record,
		   cs_player_stickiness_redpack_info_notify_req) ->
    encode(cs_player_stickiness_redpack_info_notify_req,
	   Record).

encode_sc_stickiness_redpack_draw_resp(Record)
    when is_record(Record,
		   sc_stickiness_redpack_draw_resp) ->
    encode(sc_stickiness_redpack_draw_resp, Record).

encode_cs_stickiness_redpack_draw_req(Record)
    when is_record(Record,
		   cs_stickiness_redpack_draw_req) ->
    encode(cs_stickiness_redpack_draw_req, Record).

encode_sc_player_stickiness_redpack_info_notify(Record)
    when is_record(Record,
		   sc_player_stickiness_redpack_info_notify) ->
    encode(sc_player_stickiness_redpack_info_notify,
	   Record).

encode_pb_cur_stickiness_redpack_info(Record)
    when is_record(Record,
		   pb_cur_stickiness_redpack_info) ->
    encode(pb_cur_stickiness_redpack_info, Record).

encode_sc_query_last_daily_rank_reward_reply(Record)
    when is_record(Record,
		   sc_query_last_daily_rank_reward_reply) ->
    encode(sc_query_last_daily_rank_reward_reply, Record).

encode_cs_query_last_daily_rank_reward_req(Record)
    when is_record(Record,
		   cs_query_last_daily_rank_reward_req) ->
    encode(cs_query_last_daily_rank_reward_req, Record).

encode_sc_super_laba_last_week_rank_query_reply(Record)
    when is_record(Record,
		   sc_super_laba_last_week_rank_query_reply) ->
    encode(sc_super_laba_last_week_rank_query_reply,
	   Record).

encode_cs_super_laba_last_week_rank_query_req(Record)
    when is_record(Record,
		   cs_super_laba_last_week_rank_query_req) ->
    encode(cs_super_laba_last_week_rank_query_req, Record).

encode_sc_real_name_req(Record)
    when is_record(Record, sc_real_name_req) ->
    encode(sc_real_name_req, Record).

encode_cs_real_name_req(Record)
    when is_record(Record, cs_real_name_req) ->
    encode(cs_real_name_req, Record).

encode_sc_real_name_update(Record)
    when is_record(Record, sc_real_name_update) ->
    encode(sc_real_name_update, Record).

encode_cs_real_name_update(Record)
    when is_record(Record, cs_real_name_update) ->
    encode(cs_real_name_update, Record).

encode_pb_hundred_last_week_data(Record)
    when is_record(Record, pb_hundred_last_week_data) ->
    encode(pb_hundred_last_week_data, Record).

encode_sc_hundred_last_week_rank_query_reply(Record)
    when is_record(Record,
		   sc_hundred_last_week_rank_query_reply) ->
    encode(sc_hundred_last_week_rank_query_reply, Record).

encode_cs_hundred_last_week_rank_query_req(Record)
    when is_record(Record,
		   cs_hundred_last_week_rank_query_req) ->
    encode(cs_hundred_last_week_rank_query_req, Record).

encode_sc_guide_next_step_reply(Record)
    when is_record(Record, sc_guide_next_step_reply) ->
    encode(sc_guide_next_step_reply, Record).

encode_cs_guide_next_step_req(Record)
    when is_record(Record, cs_guide_next_step_req) ->
    encode(cs_guide_next_step_req, Record).

encode_sc_guide_info_update(Record)
    when is_record(Record, sc_guide_info_update) ->
    encode(sc_guide_info_update, Record).

encode_sc_vip_daily_reward(Record)
    when is_record(Record, sc_vip_daily_reward) ->
    encode(sc_vip_daily_reward, Record).

encode_cs_vip_daily_reward(Record)
    when is_record(Record, cs_vip_daily_reward) ->
    encode(cs_vip_daily_reward, Record).

encode_pb_rank_info(Record)
    when is_record(Record, pb_rank_info) ->
    encode(pb_rank_info, Record).

encode_sc_rank_qurey_reply(Record)
    when is_record(Record, sc_rank_qurey_reply) ->
    encode(sc_rank_qurey_reply, Record).

encode_cs_rank_query_req(Record)
    when is_record(Record, cs_rank_query_req) ->
    encode(cs_rank_query_req, Record).

encode_sc_niu_special_subsidy_info_update(Record)
    when is_record(Record,
		   sc_niu_special_subsidy_info_update) ->
    encode(sc_niu_special_subsidy_info_update, Record).

encode_sc_player_bind_phone_num_draw_reply(Record)
    when is_record(Record,
		   sc_player_bind_phone_num_draw_reply) ->
    encode(sc_player_bind_phone_num_draw_reply, Record).

encode_cs_player_bind_phone_num_draw(Record)
    when is_record(Record, cs_player_bind_phone_num_draw) ->
    encode(cs_player_bind_phone_num_draw, Record).

encode_sc_player_bind_phone_num(Record)
    when is_record(Record, sc_player_bind_phone_num) ->
    encode(sc_player_bind_phone_num, Record).

encode_sc_player_phone_num_info_update(Record)
    when is_record(Record,
		   sc_player_phone_num_info_update) ->
    encode(sc_player_phone_num_info_update, Record).

encode_cs_make_up_for_checkin_req(Record)
    when is_record(Record, cs_make_up_for_checkin_req) ->
    encode(cs_make_up_for_checkin_req, Record).

encode_pb_checkin_info(Record)
    when is_record(Record, pb_checkin_info) ->
    encode(pb_checkin_info, Record).

encode_sc_daily_checkin_info_update(Record)
    when is_record(Record, sc_daily_checkin_info_update) ->
    encode(sc_daily_checkin_info_update, Record).

encode_sc_daily_checkin_reply(Record)
    when is_record(Record, sc_daily_checkin_reply) ->
    encode(sc_daily_checkin_reply, Record).

encode_cs_daily_checkin_req(Record)
    when is_record(Record, cs_daily_checkin_req) ->
    encode(cs_daily_checkin_req, Record).

encode_sc_player_base_make_name_back(Record)
    when is_record(Record, sc_player_base_make_name_back) ->
    encode(sc_player_base_make_name_back, Record).

encode_cs_player_base_make_name(Record)
    when is_record(Record, cs_player_base_make_name) ->
    encode(cs_player_base_make_name, Record).

encode_sc_niu_special_subsidy_share(Record)
    when is_record(Record, sc_niu_special_subsidy_share) ->
    encode(sc_niu_special_subsidy_share, Record).

encode_cs_niu_special_subsidy_share(Record)
    when is_record(Record, cs_niu_special_subsidy_share) ->
    encode(cs_niu_special_subsidy_share, Record).

encode_sc_niu_subsidy_info_update(Record)
    when is_record(Record, sc_niu_subsidy_info_update) ->
    encode(sc_niu_subsidy_info_update, Record).

encode_sc_niu_subsidy_reply(Record)
    when is_record(Record, sc_niu_subsidy_reply) ->
    encode(sc_niu_subsidy_reply, Record).

encode_cs_niu_subsidy_req(Record)
    when is_record(Record, cs_niu_subsidy_req) ->
    encode(cs_niu_subsidy_req, Record).

encode_sc_niu_query_in_game_player_num_reply(Record)
    when is_record(Record,
		   sc_niu_query_in_game_player_num_reply) ->
    encode(sc_niu_query_in_game_player_num_reply, Record).

encode_pb_room_player_num(Record)
    when is_record(Record, pb_room_player_num) ->
    encode(pb_room_player_num, Record).

encode_cs_niu_query_in_game_player_num_req(Record)
    when is_record(Record,
		   cs_niu_query_in_game_player_num_req) ->
    encode(cs_niu_query_in_game_player_num_req, Record).

encode_sc_query_player_winning_rec_reply(Record)
    when is_record(Record,
		   sc_query_player_winning_rec_reply) ->
    encode(sc_query_player_winning_rec_reply, Record).

encode_cs_query_player_winning_rec_req(Record)
    when is_record(Record,
		   cs_query_player_winning_rec_req) ->
    encode(cs_query_player_winning_rec_req, Record).

encode_sc_tips(Record)
    when is_record(Record, sc_tips) ->
    encode(sc_tips, Record).

encode_sc_player_sys_notice(Record)
    when is_record(Record, sc_player_sys_notice) ->
    encode(sc_player_sys_notice, Record).

encode_sc_player_chat(Record)
    when is_record(Record, sc_player_chat) ->
    encode(sc_player_chat, Record).

encode_cs_player_chat(Record)
    when is_record(Record, cs_player_chat) ->
    encode(cs_player_chat, Record).

encode_sc_player_change_headicon_reply(Record)
    when is_record(Record,
		   sc_player_change_headicon_reply) ->
    encode(sc_player_change_headicon_reply, Record).

encode_cs_player_change_headicon_req(Record)
    when is_record(Record, cs_player_change_headicon_req) ->
    encode(cs_player_change_headicon_req, Record).

encode_sc_player_change_name_reply(Record)
    when is_record(Record, sc_player_change_name_reply) ->
    encode(sc_player_change_name_reply, Record).

encode_cs_player_change_name_req(Record)
    when is_record(Record, cs_player_change_name_req) ->
    encode(cs_player_change_name_req, Record).

encode_sc_player_base_info(Record)
    when is_record(Record, sc_player_base_info) ->
    encode(sc_player_base_info, Record).

encode_pb_reward_info(Record)
    when is_record(Record, pb_reward_info) ->
    encode(pb_reward_info, Record).

encode_sc_item_use_reply(Record)
    when is_record(Record, sc_item_use_reply) ->
    encode(sc_item_use_reply, Record).

encode_cs_item_use_req(Record)
    when is_record(Record, cs_item_use_req) ->
    encode(cs_item_use_req, Record).

encode_pb_item_info(Record)
    when is_record(Record, pb_item_info) ->
    encode(pb_item_info, Record).

encode_sc_items_init_update(Record)
    when is_record(Record, sc_items_init_update) ->
    encode(sc_items_init_update, Record).

encode_sc_items_delete(Record)
    when is_record(Record, sc_items_delete) ->
    encode(sc_items_delete, Record).

encode_sc_items_add(Record)
    when is_record(Record, sc_items_add) ->
    encode(sc_items_add, Record).

encode_sc_items_update(Record)
    when is_record(Record, sc_items_update) ->
    encode(sc_items_update, Record).

encode(sc_items_update, Record) ->
    [iolist(sc_items_update, Record)
     | encode_extensions(Record)];
encode(sc_items_add, Record) ->
    [iolist(sc_items_add, Record)
     | encode_extensions(Record)];
encode(sc_items_delete, Record) ->
    [iolist(sc_items_delete, Record)
     | encode_extensions(Record)];
encode(sc_items_init_update, Record) ->
    [iolist(sc_items_init_update, Record)
     | encode_extensions(Record)];
encode(pb_item_info, Record) ->
    [iolist(pb_item_info, Record)
     | encode_extensions(Record)];
encode(cs_item_use_req, Record) ->
    [iolist(cs_item_use_req, Record)
     | encode_extensions(Record)];
encode(sc_item_use_reply, Record) ->
    [iolist(sc_item_use_reply, Record)
     | encode_extensions(Record)];
encode(pb_reward_info, Record) ->
    [iolist(pb_reward_info, Record)
     | encode_extensions(Record)];
encode(sc_player_base_info, Record) ->
    [iolist(sc_player_base_info, Record)
     | encode_extensions(Record)];
encode(cs_player_change_name_req, Record) ->
    [iolist(cs_player_change_name_req, Record)
     | encode_extensions(Record)];
encode(sc_player_change_name_reply, Record) ->
    [iolist(sc_player_change_name_reply, Record)
     | encode_extensions(Record)];
encode(cs_player_change_headicon_req, Record) ->
    [iolist(cs_player_change_headicon_req, Record)
     | encode_extensions(Record)];
encode(sc_player_change_headicon_reply, Record) ->
    [iolist(sc_player_change_headicon_reply, Record)
     | encode_extensions(Record)];
encode(cs_player_chat, Record) ->
    [iolist(cs_player_chat, Record)
     | encode_extensions(Record)];
encode(sc_player_chat, Record) ->
    [iolist(sc_player_chat, Record)
     | encode_extensions(Record)];
encode(sc_player_sys_notice, Record) ->
    [iolist(sc_player_sys_notice, Record)
     | encode_extensions(Record)];
encode(sc_tips, Record) ->
    [iolist(sc_tips, Record) | encode_extensions(Record)];
encode(cs_query_player_winning_rec_req, Record) ->
    [iolist(cs_query_player_winning_rec_req, Record)
     | encode_extensions(Record)];
encode(sc_query_player_winning_rec_reply, Record) ->
    [iolist(sc_query_player_winning_rec_reply, Record)
     | encode_extensions(Record)];
encode(cs_niu_query_in_game_player_num_req, Record) ->
    [iolist(cs_niu_query_in_game_player_num_req, Record)
     | encode_extensions(Record)];
encode(pb_room_player_num, Record) ->
    [iolist(pb_room_player_num, Record)
     | encode_extensions(Record)];
encode(sc_niu_query_in_game_player_num_reply, Record) ->
    [iolist(sc_niu_query_in_game_player_num_reply, Record)
     | encode_extensions(Record)];
encode(cs_niu_subsidy_req, Record) ->
    [iolist(cs_niu_subsidy_req, Record)
     | encode_extensions(Record)];
encode(sc_niu_subsidy_reply, Record) ->
    [iolist(sc_niu_subsidy_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_subsidy_info_update, Record) ->
    [iolist(sc_niu_subsidy_info_update, Record)
     | encode_extensions(Record)];
encode(cs_niu_special_subsidy_share, Record) ->
    [iolist(cs_niu_special_subsidy_share, Record)
     | encode_extensions(Record)];
encode(sc_niu_special_subsidy_share, Record) ->
    [iolist(sc_niu_special_subsidy_share, Record)
     | encode_extensions(Record)];
encode(cs_player_base_make_name, Record) ->
    [iolist(cs_player_base_make_name, Record)
     | encode_extensions(Record)];
encode(sc_player_base_make_name_back, Record) ->
    [iolist(sc_player_base_make_name_back, Record)
     | encode_extensions(Record)];
encode(cs_daily_checkin_req, Record) ->
    [iolist(cs_daily_checkin_req, Record)
     | encode_extensions(Record)];
encode(sc_daily_checkin_reply, Record) ->
    [iolist(sc_daily_checkin_reply, Record)
     | encode_extensions(Record)];
encode(sc_daily_checkin_info_update, Record) ->
    [iolist(sc_daily_checkin_info_update, Record)
     | encode_extensions(Record)];
encode(pb_checkin_info, Record) ->
    [iolist(pb_checkin_info, Record)
     | encode_extensions(Record)];
encode(cs_make_up_for_checkin_req, Record) ->
    [iolist(cs_make_up_for_checkin_req, Record)
     | encode_extensions(Record)];
encode(sc_player_phone_num_info_update, Record) ->
    [iolist(sc_player_phone_num_info_update, Record)
     | encode_extensions(Record)];
encode(sc_player_bind_phone_num, Record) ->
    [iolist(sc_player_bind_phone_num, Record)
     | encode_extensions(Record)];
encode(cs_player_bind_phone_num_draw, Record) ->
    [iolist(cs_player_bind_phone_num_draw, Record)
     | encode_extensions(Record)];
encode(sc_player_bind_phone_num_draw_reply, Record) ->
    [iolist(sc_player_bind_phone_num_draw_reply, Record)
     | encode_extensions(Record)];
encode(sc_niu_special_subsidy_info_update, Record) ->
    [iolist(sc_niu_special_subsidy_info_update, Record)
     | encode_extensions(Record)];
encode(cs_rank_query_req, Record) ->
    [iolist(cs_rank_query_req, Record)
     | encode_extensions(Record)];
encode(sc_rank_qurey_reply, Record) ->
    [iolist(sc_rank_qurey_reply, Record)
     | encode_extensions(Record)];
encode(pb_rank_info, Record) ->
    [iolist(pb_rank_info, Record)
     | encode_extensions(Record)];
encode(cs_vip_daily_reward, Record) ->
    [iolist(cs_vip_daily_reward, Record)
     | encode_extensions(Record)];
encode(sc_vip_daily_reward, Record) ->
    [iolist(sc_vip_daily_reward, Record)
     | encode_extensions(Record)];
encode(sc_guide_info_update, Record) ->
    [iolist(sc_guide_info_update, Record)
     | encode_extensions(Record)];
encode(cs_guide_next_step_req, Record) ->
    [iolist(cs_guide_next_step_req, Record)
     | encode_extensions(Record)];
encode(sc_guide_next_step_reply, Record) ->
    [iolist(sc_guide_next_step_reply, Record)
     | encode_extensions(Record)];
encode(cs_hundred_last_week_rank_query_req, Record) ->
    [iolist(cs_hundred_last_week_rank_query_req, Record)
     | encode_extensions(Record)];
encode(sc_hundred_last_week_rank_query_reply, Record) ->
    [iolist(sc_hundred_last_week_rank_query_reply, Record)
     | encode_extensions(Record)];
encode(pb_hundred_last_week_data, Record) ->
    [iolist(pb_hundred_last_week_data, Record)
     | encode_extensions(Record)];
encode(cs_real_name_update, Record) ->
    [iolist(cs_real_name_update, Record)
     | encode_extensions(Record)];
encode(sc_real_name_update, Record) ->
    [iolist(sc_real_name_update, Record)
     | encode_extensions(Record)];
encode(cs_real_name_req, Record) ->
    [iolist(cs_real_name_req, Record)
     | encode_extensions(Record)];
encode(sc_real_name_req, Record) ->
    [iolist(sc_real_name_req, Record)
     | encode_extensions(Record)];
encode(cs_super_laba_last_week_rank_query_req,
       Record) ->
    [iolist(cs_super_laba_last_week_rank_query_req, Record)
     | encode_extensions(Record)];
encode(sc_super_laba_last_week_rank_query_reply,
       Record) ->
    [iolist(sc_super_laba_last_week_rank_query_reply,
	    Record)
     | encode_extensions(Record)];
encode(cs_query_last_daily_rank_reward_req, Record) ->
    [iolist(cs_query_last_daily_rank_reward_req, Record)
     | encode_extensions(Record)];
encode(sc_query_last_daily_rank_reward_reply, Record) ->
    [iolist(sc_query_last_daily_rank_reward_reply, Record)
     | encode_extensions(Record)];
encode(pb_cur_stickiness_redpack_info, Record) ->
    [iolist(pb_cur_stickiness_redpack_info, Record)
     | encode_extensions(Record)];
encode(sc_player_stickiness_redpack_info_notify,
       Record) ->
    [iolist(sc_player_stickiness_redpack_info_notify,
	    Record)
     | encode_extensions(Record)];
encode(cs_stickiness_redpack_draw_req, Record) ->
    [iolist(cs_stickiness_redpack_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_stickiness_redpack_draw_resp, Record) ->
    [iolist(sc_stickiness_redpack_draw_resp, Record)
     | encode_extensions(Record)];
encode(cs_player_stickiness_redpack_info_notify_req,
       Record) ->
    [iolist(cs_player_stickiness_redpack_info_notify_req,
	    Record)
     | encode_extensions(Record)];
encode(pb_player_bet_stickiness_redpack_list_elem,
       Record) ->
    [iolist(pb_player_bet_stickiness_redpack_list_elem,
	    Record)
     | encode_extensions(Record)];
encode(sc_player_bet_stickiness_notify, Record) ->
    [iolist(sc_player_bet_stickiness_notify, Record)
     | encode_extensions(Record)];
encode(cs_player_bet_stickiness_redpack_draw_req,
       Record) ->
    [iolist(cs_player_bet_stickiness_redpack_draw_req,
	    Record)
     | encode_extensions(Record)];
encode(sc_player_bet_stickiness_redpack_draw_resp,
       Record) ->
    [iolist(sc_player_bet_stickiness_redpack_draw_resp,
	    Record)
     | encode_extensions(Record)];
encode(pb_bet_lock_config_list_elem, Record) ->
    [iolist(pb_bet_lock_config_list_elem, Record)
     | encode_extensions(Record)];
encode(cs_bet_lock_config_req, Record) ->
    [iolist(cs_bet_lock_config_req, Record)
     | encode_extensions(Record)];
encode(sc_bet_lock_config_resp, Record) ->
    [iolist(sc_bet_lock_config_resp, Record)
     | encode_extensions(Record)];
encode(sc_bet_lock_update_notify, Record) ->
    [iolist(sc_bet_lock_update_notify, Record)
     | encode_extensions(Record)];
encode(cs_player_salary_query_req, Record) ->
    [iolist(cs_player_salary_query_req, Record)
     | encode_extensions(Record)];
encode(sc_player_salary_query_resp, Record) ->
    [iolist(sc_player_salary_query_resp, Record)
     | encode_extensions(Record)];
encode(cs_player_salary_draw_req, Record) ->
    [iolist(cs_player_salary_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_player_salary_draw_resp, Record) ->
    [iolist(sc_player_salary_draw_resp, Record)
     | encode_extensions(Record)];
encode(pb_lottery_item, Record) ->
    [iolist(pb_lottery_item, Record)
     | encode_extensions(Record)];
encode(pb_lottery_reward_config, Record) ->
    [iolist(pb_lottery_reward_config, Record)
     | encode_extensions(Record)];
encode(cs_lottery_draw_req, Record) ->
    [iolist(cs_lottery_draw_req, Record)
     | encode_extensions(Record)];
encode(sc_lottery_draw_resp, Record) ->
    [iolist(sc_lottery_draw_resp, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

iolist(sc_items_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_update.upd_list, none),
	  pb_item_info, [])];
iolist(sc_items_add, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_add.add_list, none),
	  pb_item_info, [])];
iolist(sc_items_delete, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_delete.del_list, none),
	  string, [])];
iolist(sc_items_init_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_items_init_update.all_list,
		       none),
	  pb_item_info, [])];
iolist(pb_item_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_item_info.uuid, none), string,
	  []),
     pack(2, required,
	  with_default(Record#pb_item_info.base_id, none), uint32,
	  []),
     pack(3, required,
	  with_default(Record#pb_item_info.count, none), uint32,
	  [])];
iolist(cs_item_use_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_item_use_req.item_uuid, none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_item_use_req.num, none), uint32,
	  [])];
iolist(sc_item_use_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_item_use_reply.result, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_item_use_reply.err_msg, none),
	  bytes, [])];
iolist(pb_reward_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_reward_info.base_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_reward_info.count, none), uint64,
	  [])];
iolist(sc_player_base_info, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_base_info.player_uuid,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#sc_player_base_info.account, none),
	  string, []),
     pack(3, required,
	  with_default(Record#sc_player_base_info.name, none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#sc_player_base_info.gold, none),
	  uint64, []),
     pack(5, required,
	  with_default(Record#sc_player_base_info.diamond, none),
	  uint32, []),
     pack(6, required,
	  with_default(Record#sc_player_base_info.cash, none),
	  uint32, []),
     pack(7, required,
	  with_default(Record#sc_player_base_info.exp, none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#sc_player_base_info.level, none),
	  uint32, []),
     pack(9, required,
	  with_default(Record#sc_player_base_info.icon, none),
	  string, []),
     pack(10, required,
	  with_default(Record#sc_player_base_info.sex, none),
	  uint32, []),
     pack(11, required,
	  with_default(Record#sc_player_base_info.vip_level,
		       none),
	  uint32, []),
     pack(12, required,
	  with_default(Record#sc_player_base_info.rmb, none),
	  uint32, []),
     pack(13, required,
	  with_default(Record#sc_player_base_info.block, none),
	  int32, [])];
iolist(cs_player_change_name_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_player_change_name_req.name,
		       none),
	  bytes, [])];
iolist(sc_player_change_name_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_change_name_reply.result,
		       none),
	  uint32, [])];
iolist(cs_player_change_headicon_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_player_change_headicon_req.icon,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#cs_player_change_headicon_req.sex,
		       none),
	  uint32, [])];
iolist(sc_player_change_headicon_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_change_headicon_reply.result,
		       none),
	  uint32, [])];
iolist(cs_player_chat, Record) ->
    [pack(1, required,
	  with_default(Record#cs_player_chat.room_type, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#cs_player_chat.content_type, none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#cs_player_chat.content, none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#cs_player_chat.obj_player_uuid,
		       none),
	  string, [])];
iolist(sc_player_chat, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_chat.room_type, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_player_chat.content_type, none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_player_chat.content, none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#sc_player_chat.player_uuid, none),
	  string, []),
     pack(5, required,
	  with_default(Record#sc_player_chat.player_name, none),
	  bytes, []),
     pack(6, required,
	  with_default(Record#sc_player_chat.player_icon, none),
	  bytes, []),
     pack(7, required,
	  with_default(Record#sc_player_chat.player_vip, none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#sc_player_chat.player_seat_pos,
		       none),
	  uint32, []),
     pack(9, required,
	  with_default(Record#sc_player_chat.send_time, none),
	  uint32, []),
     pack(10, optional,
	  with_default(Record#sc_player_chat.des_player_uuid,
		       none),
	  string, []),
     pack(11, optional,
	  with_default(Record#sc_player_chat.des_player_name,
		       none),
	  bytes, [])];
iolist(sc_player_sys_notice, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_sys_notice.flag, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_player_sys_notice.content, none),
	  bytes, [])];
iolist(sc_tips, Record) ->
    [pack(1, required,
	  with_default(Record#sc_tips.type, none), uint32, []),
     pack(2, required,
	  with_default(Record#sc_tips.text, none), bytes, [])];
iolist(cs_query_player_winning_rec_req, Record) ->
    [pack(1, optional,
	  with_default(Record#cs_query_player_winning_rec_req.obj_player_uuid,
		       none),
	  string, [])];
iolist(sc_query_player_winning_rec_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_query_player_winning_rec_reply.win_rate,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_query_player_winning_rec_reply.win_count,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_query_player_winning_rec_reply.defeated_count,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#sc_query_player_winning_rec_reply.max_property,
		       none),
	  int64, []),
     pack(5, required,
	  with_default(Record#sc_query_player_winning_rec_reply.total_profit,
		       none),
	  int64, []),
     pack(6, required,
	  with_default(Record#sc_query_player_winning_rec_reply.week_profit,
		       none),
	  int64, []),
     pack(7, required,
	  with_default(Record#sc_query_player_winning_rec_reply.niu_10,
		       none),
	  uint32, []),
     pack(8, required,
	  with_default(Record#sc_query_player_winning_rec_reply.niu_11,
		       none),
	  uint32, []),
     pack(9, required,
	  with_default(Record#sc_query_player_winning_rec_reply.niu_12,
		       none),
	  uint32, []),
     pack(10, required,
	  with_default(Record#sc_query_player_winning_rec_reply.niu_13,
		       none),
	  uint32, []),
     pack(11, required,
	  with_default(Record#sc_query_player_winning_rec_reply.niu_0_win,
		       none),
	  uint32, []),
     pack(12, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.obj_player_uuid,
		       none),
	  string, []),
     pack(13, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.obj_name,
		       none),
	  bytes, []),
     pack(14, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.sex,
		       none),
	  uint32, []),
     pack(15, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.gold,
		       none),
	  uint64, []),
     pack(16, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.icon,
		       none),
	  string, []),
     pack(17, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.level,
		       none),
	  uint32, []),
     pack(18, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.vip_level,
		       none),
	  uint32, []),
     pack(19, optional,
	  with_default(Record#sc_query_player_winning_rec_reply.account,
		       none),
	  string, [])];
iolist(cs_niu_query_in_game_player_num_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_query_in_game_player_num_req.game_type,
		       none),
	  uint32, [])];
iolist(pb_room_player_num, Record) ->
    [pack(1, required,
	  with_default(Record#pb_room_player_num.room_level,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_room_player_num.player_num,
		       none),
	  uint32, [])];
iolist(sc_niu_query_in_game_player_num_reply, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_niu_query_in_game_player_num_reply.list,
		       none),
	  pb_room_player_num, [])];
iolist(cs_niu_subsidy_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_subsidy_req.type, none),
	  uint32, [])];
iolist(sc_niu_subsidy_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_subsidy_reply.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_niu_subsidy_reply.err, none),
	  bytes, [])];
iolist(sc_niu_subsidy_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_subsidy_info_update.left_times,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_subsidy_info_update.subsidy_gold,
		       none),
	  uint32, [])];
iolist(cs_niu_special_subsidy_share, Record) ->
    [pack(1, required,
	  with_default(Record#cs_niu_special_subsidy_share.result,
		       none),
	  uint32, [])];
iolist(sc_niu_special_subsidy_share, _Record) -> [];
iolist(cs_player_base_make_name, _Record) -> [];
iolist(sc_player_base_make_name_back, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_base_make_name_back.name,
		       none),
	  bytes, [])];
iolist(cs_daily_checkin_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_daily_checkin_req.flag, none),
	  uint32, [])];
iolist(sc_daily_checkin_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_daily_checkin_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_daily_checkin_reply.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_daily_checkin_reply.rewards,
		       none),
	  pb_reward_info, []),
     pack(4, required,
	  with_default(Record#sc_daily_checkin_reply.flag, none),
	  uint32, [])];
iolist(sc_daily_checkin_info_update, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_daily_checkin_info_update.list,
		       none),
	  pb_checkin_info, []),
     pack(2, required,
	  with_default(Record#sc_daily_checkin_info_update.all_checkin_day,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_daily_checkin_info_update.is_checkin_today,
		       none),
	  bool, []),
     pack(4, required,
	  with_default(Record#sc_daily_checkin_info_update.vip_is_draw,
		       none),
	  bool, [])];
iolist(pb_checkin_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_checkin_info.day, none), uint32,
	  []),
     pack(2, repeated,
	  with_default(Record#pb_checkin_info.rewards, none),
	  pb_reward_info, []),
     pack(3, required,
	  with_default(Record#pb_checkin_info.is_draw, none),
	  bool, [])];
iolist(cs_make_up_for_checkin_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_make_up_for_checkin_req.flag,
		       none),
	  uint32, [])];
iolist(sc_player_phone_num_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_phone_num_info_update.phone_num,
		       none),
	  string, []),
     pack(2, required,
	  with_default(Record#sc_player_phone_num_info_update.is_draw,
		       none),
	  bool, [])];
iolist(sc_player_bind_phone_num, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_bind_phone_num.result,
		       none),
	  uint32, [])];
iolist(cs_player_bind_phone_num_draw, _Record) -> [];
iolist(sc_player_bind_phone_num_draw_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_bind_phone_num_draw_reply.result,
		       none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_player_bind_phone_num_draw_reply.err,
		       none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_player_bind_phone_num_draw_reply.rewards,
		       none),
	  pb_reward_info, [])];
iolist(sc_niu_special_subsidy_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_niu_special_subsidy_info_update.left_times,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_niu_special_subsidy_info_update.subsidy_gold,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_niu_special_subsidy_info_update.is_share,
		       none),
	  bool, [])];
iolist(cs_rank_query_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_rank_query_req.rank_type, none),
	  uint32, [])];
iolist(sc_rank_qurey_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_rank_qurey_reply.rank_type,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_rank_qurey_reply.my_rank, none),
	  uint32, []),
     pack(3, repeated,
	  with_default(Record#sc_rank_qurey_reply.rank_info_list,
		       none),
	  pb_rank_info, []),
     pack(4, optional,
	  with_default(Record#sc_rank_qurey_reply.pool, none),
	  uint32, []),
     pack(5, optional,
	  with_default(Record#sc_rank_qurey_reply.my_recharge_money,
		       none),
	  uint32, []),
     pack(6, optional,
	  with_default(Record#sc_rank_qurey_reply.start_time,
		       none),
	  uint32, []),
     pack(7, optional,
	  with_default(Record#sc_rank_qurey_reply.end_time, none),
	  uint32, [])];
iolist(pb_rank_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_rank_info.rank, none), uint32,
	  []),
     pack(2, required,
	  with_default(Record#pb_rank_info.player_uuid, none),
	  string, []),
     pack(3, required,
	  with_default(Record#pb_rank_info.player_name, none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#pb_rank_info.player_icon, none),
	  string, []),
     pack(5, required,
	  with_default(Record#pb_rank_info.player_vip, none),
	  uint32, []),
     pack(6, optional,
	  with_default(Record#pb_rank_info.gold_num, none),
	  uint64, []),
     pack(7, optional,
	  with_default(Record#pb_rank_info.win_gold_num, none),
	  uint64, []),
     pack(8, optional,
	  with_default(Record#pb_rank_info.cash_num, none),
	  uint64, []),
     pack(9, optional,
	  with_default(Record#pb_rank_info.sex, none), uint32,
	  []),
     pack(10, optional,
	  with_default(Record#pb_rank_info.hundred_win, none),
	  uint64, []),
     pack(11, required,
	  with_default(Record#pb_rank_info.account, none), string,
	  []),
     pack(12, optional,
	  with_default(Record#pb_rank_info.redpack, none), uint64,
	  [])];
iolist(cs_vip_daily_reward, _Record) -> [];
iolist(sc_vip_daily_reward, Record) ->
    [pack(1, required,
	  with_default(Record#sc_vip_daily_reward.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_vip_daily_reward.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_vip_daily_reward.rewards, none),
	  pb_reward_info, [])];
iolist(sc_guide_info_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_guide_info_update.step_id, none),
	  uint32, [])];
iolist(cs_guide_next_step_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_guide_next_step_req.next_step_id,
		       none),
	  uint32, [])];
iolist(sc_guide_next_step_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_guide_next_step_reply.result,
		       none),
	  uint32, []),
     pack(2, repeated,
	  with_default(Record#sc_guide_next_step_reply.reward,
		       none),
	  pb_reward_info, [])];
iolist(cs_hundred_last_week_rank_query_req, _Record) ->
    [];
iolist(sc_hundred_last_week_rank_query_reply, Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_hundred_last_week_rank_query_reply.list,
		       none),
	  pb_hundred_last_week_data, [])];
iolist(pb_hundred_last_week_data, Record) ->
    [pack(1, required,
	  with_default(Record#pb_hundred_last_week_data.rank,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_hundred_last_week_data.reward_gold,
		       none),
	  uint64, []),
     pack(3, required,
	  with_default(Record#pb_hundred_last_week_data.name1_round_win,
		       none),
	  bytes, []),
     pack(4, required,
	  with_default(Record#pb_hundred_last_week_data.name2_total_win,
		       none),
	  bytes, [])];
iolist(cs_real_name_update, Record) ->
    [pack(1, required,
	  with_default(Record#cs_real_name_update.name, none),
	  bytes, []),
     pack(2, required,
	  with_default(Record#cs_real_name_update.id_card_num,
		       none),
	  string, [])];
iolist(sc_real_name_update, Record) ->
    [pack(1, required,
	  with_default(Record#sc_real_name_update.result, none),
	  uint32, []),
     pack(2, optional,
	  with_default(Record#sc_real_name_update.err, none),
	  bytes, []),
     pack(3, repeated,
	  with_default(Record#sc_real_name_update.rewards, none),
	  pb_reward_info, [])];
iolist(cs_real_name_req, _Record) -> [];
iolist(sc_real_name_req, Record) ->
    [pack(1, required,
	  with_default(Record#sc_real_name_req.type, none), int32,
	  [])];
iolist(cs_super_laba_last_week_rank_query_req,
       _Record) ->
    [];
iolist(sc_super_laba_last_week_rank_query_reply,
       Record) ->
    [pack(1, repeated,
	  with_default(Record#sc_super_laba_last_week_rank_query_reply.list,
		       none),
	  pb_hundred_last_week_data, [])];
iolist(cs_query_last_daily_rank_reward_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_query_last_daily_rank_reward_req.type,
		       none),
	  int32, [])];
iolist(sc_query_last_daily_rank_reward_reply, Record) ->
    [pack(1, required,
	  with_default(Record#sc_query_last_daily_rank_reward_reply.type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_query_last_daily_rank_reward_reply.date,
		       none),
	  uint64, []),
     pack(3, repeated,
	  with_default(Record#sc_query_last_daily_rank_reward_reply.rank_info_list,
		       none),
	  pb_rank_info, [])];
iolist(pb_cur_stickiness_redpack_info, Record) ->
    [pack(1, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.testtype,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.level,
		       none),
	  int32, []),
     pack(4, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.reward_type,
		       none),
	  int32, []),
     pack(5, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.reward_amount,
		       none),
	  uint64, []),
     pack(6, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.reward_min,
		       none),
	  uint64, []),
     pack(7, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.cur_total_amount,
		       none),
	  uint64, []),
     pack(8, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.cur_trigger_next_amount,
		       none),
	  uint64, []),
     pack(9, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.cur_earn_gold,
		       none),
	  uint64, []),
     pack(10, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.gold_cov_to_reward_item_rate,
		       none),
	  uint64, []),
     pack(11, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.holding_earn_gold,
		       none),
	  uint64, []),
     pack(12, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.total_gold,
		       none),
	  uint64, []),
     pack(13, required,
	  with_default(Record#pb_cur_stickiness_redpack_info.end_time,
		       none),
	  uint64, [])];
iolist(sc_player_stickiness_redpack_info_notify,
       Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_stickiness_redpack_info_notify.cur_info,
		       none),
	  pb_cur_stickiness_redpack_info, [])];
iolist(cs_stickiness_redpack_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_stickiness_redpack_draw_req.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_stickiness_redpack_draw_req.testtype,
		       none),
	  int32, [])];
iolist(sc_stickiness_redpack_draw_resp, Record) ->
    [pack(1, required,
	  with_default(Record#sc_stickiness_redpack_draw_resp.cur_info,
		       none),
	  pb_cur_stickiness_redpack_info, []),
     pack(2, required,
	  with_default(Record#sc_stickiness_redpack_draw_resp.reward_type,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_stickiness_redpack_draw_resp.reward_amount,
		       none),
	  uint64, [])];
iolist(cs_player_stickiness_redpack_info_notify_req,
       Record) ->
    [pack(1, required,
	  with_default(Record#cs_player_stickiness_redpack_info_notify_req.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_player_stickiness_redpack_info_notify_req.testtype,
		       none),
	  int32, [])];
iolist(pb_player_bet_stickiness_redpack_list_elem,
       Record) ->
    [pack(1, required,
	  with_default(Record#pb_player_bet_stickiness_redpack_list_elem.level,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#pb_player_bet_stickiness_redpack_list_elem.redpack_1,
		       none),
	  float, []),
     pack(3, required,
	  with_default(Record#pb_player_bet_stickiness_redpack_list_elem.redpack_2,
		       none),
	  float, []),
     pack(4, required,
	  with_default(Record#pb_player_bet_stickiness_redpack_list_elem.redpack_3,
		       none),
	  float, [])];
iolist(sc_player_bet_stickiness_notify, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_bet_stickiness_notify.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_player_bet_stickiness_notify.testtype,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_player_bet_stickiness_notify.cur_bet,
		       none),
	  uint64, []),
     pack(4, required,
	  with_default(Record#sc_player_bet_stickiness_notify.total_bet,
		       none),
	  uint64, []),
     pack(5, required,
	  with_default(Record#sc_player_bet_stickiness_notify.cur_level,
		       none),
	  int32, []),
     pack(6, repeated,
	  with_default(Record#sc_player_bet_stickiness_notify.redpack_list,
		       none),
	  pb_player_bet_stickiness_redpack_list_elem, [])];
iolist(cs_player_bet_stickiness_redpack_draw_req,
       Record) ->
    [pack(1, required,
	  with_default(Record#cs_player_bet_stickiness_redpack_draw_req.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_player_bet_stickiness_redpack_draw_req.testtype,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#cs_player_bet_stickiness_redpack_draw_req.level,
		       none),
	  int32, [])];
iolist(sc_player_bet_stickiness_redpack_draw_resp,
       Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_bet_stickiness_redpack_draw_resp.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_player_bet_stickiness_redpack_draw_resp.testtype,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_player_bet_stickiness_redpack_draw_resp.level,
		       none),
	  int32, []),
     pack(4, required,
	  with_default(Record#sc_player_bet_stickiness_redpack_draw_resp.reward_amount,
		       none),
	  uint32, []),
     pack(5, required,
	  with_default(Record#sc_player_bet_stickiness_redpack_draw_resp.desc,
		       none),
	  string, [])];
iolist(pb_bet_lock_config_list_elem, Record) ->
    [pack(1, required,
	  with_default(Record#pb_bet_lock_config_list_elem.level,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#pb_bet_lock_config_list_elem.bet_gold_limit,
		       none),
	  uint64, []),
     pack(3, required,
	  with_default(Record#pb_bet_lock_config_list_elem.next_gen_gold,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#pb_bet_lock_config_list_elem.next_gen_vip,
		       none),
	  uint32, [])];
iolist(cs_bet_lock_config_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_bet_lock_config_req.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#cs_bet_lock_config_req.testtype,
		       none),
	  int32, [])];
iolist(sc_bet_lock_config_resp, Record) ->
    [pack(1, required,
	  with_default(Record#sc_bet_lock_config_resp.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_bet_lock_config_resp.testtype,
		       none),
	  int32, []),
     pack(3, repeated,
	  with_default(Record#sc_bet_lock_config_resp.configs,
		       none),
	  pb_bet_lock_config_list_elem, [])];
iolist(sc_bet_lock_update_notify, Record) ->
    [pack(1, required,
	  with_default(Record#sc_bet_lock_update_notify.room_type,
		       none),
	  int32, []),
     pack(2, required,
	  with_default(Record#sc_bet_lock_update_notify.testtype,
		       none),
	  int32, []),
     pack(3, required,
	  with_default(Record#sc_bet_lock_update_notify.cur_level,
		       none),
	  pb_bet_lock_config_list_elem, []),
     pack(4, required,
	  with_default(Record#sc_bet_lock_update_notify.total_amount,
		       none),
	  uint64, [])];
iolist(cs_player_salary_query_req, _Record) -> [];
iolist(sc_player_salary_query_resp, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_salary_query_resp.yesterday_earn,
		       none),
	  uint64, []),
     pack(2, required,
	  with_default(Record#sc_player_salary_query_resp.today_earn,
		       none),
	  uint64, []),
     pack(3, required,
	  with_default(Record#sc_player_salary_query_resp.yesterday_salary,
		       none),
	  uint64, []),
     pack(4, required,
	  with_default(Record#sc_player_salary_query_resp.is_draw,
		       none),
	  bool, [])];
iolist(cs_player_salary_draw_req, _Record) -> [];
iolist(sc_player_salary_draw_resp, Record) ->
    [pack(1, required,
	  with_default(Record#sc_player_salary_draw_resp.salary,
		       none),
	  uint64, []),
     pack(2, required,
	  with_default(Record#sc_player_salary_draw_resp.desc,
		       none),
	  string, [])];
iolist(pb_lottery_item, Record) ->
    [pack(1, required,
	  with_default(Record#pb_lottery_item.item_id, none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_lottery_item.item_num, none),
	  uint32, [])];
iolist(pb_lottery_reward_config, Record) ->
    [pack(1, required,
	  with_default(Record#pb_lottery_reward_config.index,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#pb_lottery_reward_config.cost_item,
		       none),
	  pb_lottery_item, []),
     pack(3, repeated,
	  with_default(Record#pb_lottery_reward_config.reward_items,
		       none),
	  pb_lottery_item, [])];
iolist(cs_lottery_draw_req, Record) ->
    [pack(1, required,
	  with_default(Record#cs_lottery_draw_req.prize_cls,
		       none),
	  uint32, [])];
iolist(sc_lottery_draw_resp, Record) ->
    [pack(1, required,
	  with_default(Record#sc_lottery_draw_resp.left_times,
		       none),
	  uint32, []),
     pack(2, required,
	  with_default(Record#sc_lottery_draw_resp.reward_item_id,
		       none),
	  uint32, []),
     pack(3, required,
	  with_default(Record#sc_lottery_draw_resp.reward_item_num,
		       none),
	  uint32, []),
     pack(4, required,
	  with_default(Record#sc_lottery_draw_resp.is_reward,
		       none),
	  bool, []),
     pack(5, repeated,
	  with_default(Record#sc_lottery_draw_resp.reward_configs,
		       none),
	  pb_lottery_reward_config, [])].

with_default(Default, Default) -> undefined;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(_, repeated_packed, undefined, _, _) -> [];
pack(_, repeated_packed, [], _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, repeated_packed, Data, Type, _) ->
    protobuffs:encode_packed(FNum, Data, Type);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    [RecName | _] = tuple_to_list(Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _)
    when Type =:= bool;
	 Type =:= int32;
	 Type =:= uint32;
	 Type =:= int64;
	 Type =:= uint64;
	 Type =:= sint32;
	 Type =:= sint64;
	 Type =:= fixed32;
	 Type =:= sfixed32;
	 Type =:= fixed64;
	 Type =:= sfixed64;
	 Type =:= string;
	 Type =:= bytes;
	 Type =:= float;
	 Type =:= double ->
    protobuffs:encode(FNum, Data, Type);
pack(FNum, _, Data, Type, _) when is_atom(Data) ->
    protobuffs:encode(FNum, enum_to_int(Type, Data), enum).

enum_to_int(pikachu, value) -> 1.

int_to_enum(_, Val) -> Val.

decode_sc_lottery_draw_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_lottery_draw_resp, Bytes).

decode_cs_lottery_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_lottery_draw_req, Bytes).

decode_pb_lottery_reward_config(Bytes)
    when is_binary(Bytes) ->
    decode(pb_lottery_reward_config, Bytes).

decode_pb_lottery_item(Bytes) when is_binary(Bytes) ->
    decode(pb_lottery_item, Bytes).

decode_sc_player_salary_draw_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_salary_draw_resp, Bytes).

decode_cs_player_salary_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_salary_draw_req, Bytes).

decode_sc_player_salary_query_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_salary_query_resp, Bytes).

decode_cs_player_salary_query_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_salary_query_req, Bytes).

decode_sc_bet_lock_update_notify(Bytes)
    when is_binary(Bytes) ->
    decode(sc_bet_lock_update_notify, Bytes).

decode_sc_bet_lock_config_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_bet_lock_config_resp, Bytes).

decode_cs_bet_lock_config_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_bet_lock_config_req, Bytes).

decode_pb_bet_lock_config_list_elem(Bytes)
    when is_binary(Bytes) ->
    decode(pb_bet_lock_config_list_elem, Bytes).

decode_sc_player_bet_stickiness_redpack_draw_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_bet_stickiness_redpack_draw_resp,
	   Bytes).

decode_cs_player_bet_stickiness_redpack_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_bet_stickiness_redpack_draw_req,
	   Bytes).

decode_sc_player_bet_stickiness_notify(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_bet_stickiness_notify, Bytes).

decode_pb_player_bet_stickiness_redpack_list_elem(Bytes)
    when is_binary(Bytes) ->
    decode(pb_player_bet_stickiness_redpack_list_elem,
	   Bytes).

decode_cs_player_stickiness_redpack_info_notify_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_stickiness_redpack_info_notify_req,
	   Bytes).

decode_sc_stickiness_redpack_draw_resp(Bytes)
    when is_binary(Bytes) ->
    decode(sc_stickiness_redpack_draw_resp, Bytes).

decode_cs_stickiness_redpack_draw_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_stickiness_redpack_draw_req, Bytes).

decode_sc_player_stickiness_redpack_info_notify(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_stickiness_redpack_info_notify, Bytes).

decode_pb_cur_stickiness_redpack_info(Bytes)
    when is_binary(Bytes) ->
    decode(pb_cur_stickiness_redpack_info, Bytes).

decode_sc_query_last_daily_rank_reward_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_query_last_daily_rank_reward_reply, Bytes).

decode_cs_query_last_daily_rank_reward_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_query_last_daily_rank_reward_req, Bytes).

decode_sc_super_laba_last_week_rank_query_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_super_laba_last_week_rank_query_reply, Bytes).

decode_cs_super_laba_last_week_rank_query_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_super_laba_last_week_rank_query_req, Bytes).

decode_sc_real_name_req(Bytes) when is_binary(Bytes) ->
    decode(sc_real_name_req, Bytes).

decode_cs_real_name_req(Bytes) when is_binary(Bytes) ->
    decode(cs_real_name_req, Bytes).

decode_sc_real_name_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_real_name_update, Bytes).

decode_cs_real_name_update(Bytes)
    when is_binary(Bytes) ->
    decode(cs_real_name_update, Bytes).

decode_pb_hundred_last_week_data(Bytes)
    when is_binary(Bytes) ->
    decode(pb_hundred_last_week_data, Bytes).

decode_sc_hundred_last_week_rank_query_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_hundred_last_week_rank_query_reply, Bytes).

decode_cs_hundred_last_week_rank_query_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_hundred_last_week_rank_query_req, Bytes).

decode_sc_guide_next_step_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_guide_next_step_reply, Bytes).

decode_cs_guide_next_step_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_guide_next_step_req, Bytes).

decode_sc_guide_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_guide_info_update, Bytes).

decode_sc_vip_daily_reward(Bytes)
    when is_binary(Bytes) ->
    decode(sc_vip_daily_reward, Bytes).

decode_cs_vip_daily_reward(Bytes)
    when is_binary(Bytes) ->
    decode(cs_vip_daily_reward, Bytes).

decode_pb_rank_info(Bytes) when is_binary(Bytes) ->
    decode(pb_rank_info, Bytes).

decode_sc_rank_qurey_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_rank_qurey_reply, Bytes).

decode_cs_rank_query_req(Bytes) when is_binary(Bytes) ->
    decode(cs_rank_query_req, Bytes).

decode_sc_niu_special_subsidy_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_special_subsidy_info_update, Bytes).

decode_sc_player_bind_phone_num_draw_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_bind_phone_num_draw_reply, Bytes).

decode_cs_player_bind_phone_num_draw(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_bind_phone_num_draw, Bytes).

decode_sc_player_bind_phone_num(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_bind_phone_num, Bytes).

decode_sc_player_phone_num_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_phone_num_info_update, Bytes).

decode_cs_make_up_for_checkin_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_make_up_for_checkin_req, Bytes).

decode_pb_checkin_info(Bytes) when is_binary(Bytes) ->
    decode(pb_checkin_info, Bytes).

decode_sc_daily_checkin_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_daily_checkin_info_update, Bytes).

decode_sc_daily_checkin_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_daily_checkin_reply, Bytes).

decode_cs_daily_checkin_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_daily_checkin_req, Bytes).

decode_sc_player_base_make_name_back(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_base_make_name_back, Bytes).

decode_cs_player_base_make_name(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_base_make_name, Bytes).

decode_sc_niu_special_subsidy_share(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_special_subsidy_share, Bytes).

decode_cs_niu_special_subsidy_share(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_special_subsidy_share, Bytes).

decode_sc_niu_subsidy_info_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_subsidy_info_update, Bytes).

decode_sc_niu_subsidy_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_subsidy_reply, Bytes).

decode_cs_niu_subsidy_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_subsidy_req, Bytes).

decode_sc_niu_query_in_game_player_num_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_niu_query_in_game_player_num_reply, Bytes).

decode_pb_room_player_num(Bytes)
    when is_binary(Bytes) ->
    decode(pb_room_player_num, Bytes).

decode_cs_niu_query_in_game_player_num_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_niu_query_in_game_player_num_req, Bytes).

decode_sc_query_player_winning_rec_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_query_player_winning_rec_reply, Bytes).

decode_cs_query_player_winning_rec_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_query_player_winning_rec_req, Bytes).

decode_sc_tips(Bytes) when is_binary(Bytes) ->
    decode(sc_tips, Bytes).

decode_sc_player_sys_notice(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_sys_notice, Bytes).

decode_sc_player_chat(Bytes) when is_binary(Bytes) ->
    decode(sc_player_chat, Bytes).

decode_cs_player_chat(Bytes) when is_binary(Bytes) ->
    decode(cs_player_chat, Bytes).

decode_sc_player_change_headicon_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_change_headicon_reply, Bytes).

decode_cs_player_change_headicon_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_change_headicon_req, Bytes).

decode_sc_player_change_name_reply(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_change_name_reply, Bytes).

decode_cs_player_change_name_req(Bytes)
    when is_binary(Bytes) ->
    decode(cs_player_change_name_req, Bytes).

decode_sc_player_base_info(Bytes)
    when is_binary(Bytes) ->
    decode(sc_player_base_info, Bytes).

decode_pb_reward_info(Bytes) when is_binary(Bytes) ->
    decode(pb_reward_info, Bytes).

decode_sc_item_use_reply(Bytes) when is_binary(Bytes) ->
    decode(sc_item_use_reply, Bytes).

decode_cs_item_use_req(Bytes) when is_binary(Bytes) ->
    decode(cs_item_use_req, Bytes).

decode_pb_item_info(Bytes) when is_binary(Bytes) ->
    decode(pb_item_info, Bytes).

decode_sc_items_init_update(Bytes)
    when is_binary(Bytes) ->
    decode(sc_items_init_update, Bytes).

decode_sc_items_delete(Bytes) when is_binary(Bytes) ->
    decode(sc_items_delete, Bytes).

decode_sc_items_add(Bytes) when is_binary(Bytes) ->
    decode(sc_items_add, Bytes).

decode_sc_items_update(Bytes) when is_binary(Bytes) ->
    decode(sc_items_update, Bytes).

decode(enummsg_values, 1) -> value1;
decode(sc_items_update, Bytes) when is_binary(Bytes) ->
    Types = [{1, upd_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, upd_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_update, Decoded);
decode(sc_items_add, Bytes) when is_binary(Bytes) ->
    Types = [{1, add_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, add_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_add, Decoded);
decode(sc_items_delete, Bytes) when is_binary(Bytes) ->
    Types = [{1, del_list, string, [repeated]}],
    Defaults = [{1, del_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_delete, Decoded);
decode(sc_items_init_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, all_list, pb_item_info,
	      [is_record, repeated]}],
    Defaults = [{1, all_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_items_init_update, Decoded);
decode(pb_item_info, Bytes) when is_binary(Bytes) ->
    Types = [{3, count, uint32, []},
	     {2, base_id, uint32, []}, {1, uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_item_info, Decoded);
decode(cs_item_use_req, Bytes) when is_binary(Bytes) ->
    Types = [{2, num, uint32, []},
	     {1, item_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_item_use_req, Decoded);
decode(sc_item_use_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err_msg, bytes, []},
	     {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_item_use_reply, Decoded);
decode(pb_reward_info, Bytes) when is_binary(Bytes) ->
    Types = [{2, count, uint64, []},
	     {1, base_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_reward_info, Decoded);
decode(sc_player_base_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{13, block, int32, []}, {12, rmb, uint32, []},
	     {11, vip_level, uint32, []}, {10, sex, uint32, []},
	     {9, icon, string, []}, {8, level, uint32, []},
	     {7, exp, uint32, []}, {6, cash, uint32, []},
	     {5, diamond, uint32, []}, {4, gold, uint64, []},
	     {3, name, bytes, []}, {2, account, string, []},
	     {1, player_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_base_info, Decoded);
decode(cs_player_change_name_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, name, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_change_name_req, Decoded);
decode(sc_player_change_name_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_change_name_reply, Decoded);
decode(cs_player_change_headicon_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, sex, uint32, []}, {1, icon, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_change_headicon_req, Decoded);
decode(sc_player_change_headicon_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_change_headicon_reply, Decoded);
decode(cs_player_chat, Bytes) when is_binary(Bytes) ->
    Types = [{4, obj_player_uuid, string, []},
	     {3, content, bytes, []}, {2, content_type, uint32, []},
	     {1, room_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_chat, Decoded);
decode(sc_player_chat, Bytes) when is_binary(Bytes) ->
    Types = [{11, des_player_name, bytes, []},
	     {10, des_player_uuid, string, []},
	     {9, send_time, uint32, []},
	     {8, player_seat_pos, uint32, []},
	     {7, player_vip, uint32, []},
	     {6, player_icon, bytes, []},
	     {5, player_name, bytes, []},
	     {4, player_uuid, string, []}, {3, content, bytes, []},
	     {2, content_type, uint32, []},
	     {1, room_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_chat, Decoded);
decode(sc_player_sys_notice, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, content, bytes, []},
	     {1, flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_sys_notice, Decoded);
decode(sc_tips, Bytes) when is_binary(Bytes) ->
    Types = [{2, text, bytes, []}, {1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_tips, Decoded);
decode(cs_query_player_winning_rec_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, obj_player_uuid, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_query_player_winning_rec_req, Decoded);
decode(sc_query_player_winning_rec_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{19, account, string, []},
	     {18, vip_level, uint32, []}, {17, level, uint32, []},
	     {16, icon, string, []}, {15, gold, uint64, []},
	     {14, sex, uint32, []}, {13, obj_name, bytes, []},
	     {12, obj_player_uuid, string, []},
	     {11, niu_0_win, uint32, []}, {10, niu_13, uint32, []},
	     {9, niu_12, uint32, []}, {8, niu_11, uint32, []},
	     {7, niu_10, uint32, []}, {6, week_profit, int64, []},
	     {5, total_profit, int64, []},
	     {4, max_property, int64, []},
	     {3, defeated_count, uint32, []},
	     {2, win_count, uint32, []}, {1, win_rate, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_query_player_winning_rec_reply, Decoded);
decode(cs_niu_query_in_game_player_num_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, game_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_query_in_game_player_num_req, Decoded);
decode(pb_room_player_num, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, player_num, uint32, []},
	     {1, room_level, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_room_player_num, Decoded);
decode(sc_niu_query_in_game_player_num_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_room_player_num,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_query_in_game_player_num_reply,
	      Decoded);
decode(cs_niu_subsidy_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_subsidy_req, Decoded);
decode(sc_niu_subsidy_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_subsidy_reply, Decoded);
decode(sc_niu_subsidy_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, subsidy_gold, uint32, []},
	     {1, left_times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_subsidy_info_update, Decoded);
decode(cs_niu_special_subsidy_share, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_niu_special_subsidy_share, Decoded);
decode(sc_niu_special_subsidy_share, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_special_subsidy_share, Decoded);
decode(cs_player_base_make_name, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_base_make_name, Decoded);
decode(sc_player_base_make_name_back, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, name, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_base_make_name_back, Decoded);
decode(cs_daily_checkin_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_daily_checkin_req, Decoded);
decode(sc_daily_checkin_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, flag, uint32, []},
	     {3, rewards, pb_reward_info, [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_daily_checkin_reply, Decoded);
decode(sc_daily_checkin_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, vip_is_draw, bool, []},
	     {3, is_checkin_today, bool, []},
	     {2, all_checkin_day, uint32, []},
	     {1, list, pb_checkin_info, [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_daily_checkin_info_update, Decoded);
decode(pb_checkin_info, Bytes) when is_binary(Bytes) ->
    Types = [{3, is_draw, bool, []},
	     {2, rewards, pb_reward_info, [is_record, repeated]},
	     {1, day, uint32, []}],
    Defaults = [{2, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_checkin_info, Decoded);
decode(cs_make_up_for_checkin_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, flag, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_make_up_for_checkin_req, Decoded);
decode(sc_player_phone_num_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, is_draw, bool, []},
	     {1, phone_num, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_phone_num_info_update, Decoded);
decode(sc_player_bind_phone_num, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, result, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_bind_phone_num, Decoded);
decode(cs_player_bind_phone_num_draw, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_bind_phone_num_draw, Decoded);
decode(sc_player_bind_phone_num_draw_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rewards, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_bind_phone_num_draw_reply, Decoded);
decode(sc_niu_special_subsidy_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, is_share, bool, []},
	     {2, subsidy_gold, uint32, []},
	     {1, left_times, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_niu_special_subsidy_info_update, Decoded);
decode(cs_rank_query_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, rank_type, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_rank_query_req, Decoded);
decode(sc_rank_qurey_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{7, end_time, uint32, []},
	     {6, start_time, uint32, []},
	     {5, my_recharge_money, uint32, []},
	     {4, pool, uint32, []},
	     {3, rank_info_list, pb_rank_info,
	      [is_record, repeated]},
	     {2, my_rank, uint32, []}, {1, rank_type, uint32, []}],
    Defaults = [{3, rank_info_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_rank_qurey_reply, Decoded);
decode(pb_rank_info, Bytes) when is_binary(Bytes) ->
    Types = [{12, redpack, uint64, []},
	     {11, account, string, []},
	     {10, hundred_win, uint64, []}, {9, sex, uint32, []},
	     {8, cash_num, uint64, []},
	     {7, win_gold_num, uint64, []},
	     {6, gold_num, uint64, []}, {5, player_vip, uint32, []},
	     {4, player_icon, string, []},
	     {3, player_name, bytes, []},
	     {2, player_uuid, string, []}, {1, rank, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_rank_info, Decoded);
decode(cs_vip_daily_reward, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_vip_daily_reward, Decoded);
decode(sc_vip_daily_reward, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rewards, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_vip_daily_reward, Decoded);
decode(sc_guide_info_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, step_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_guide_info_update, Decoded);
decode(cs_guide_next_step_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, next_step_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_guide_next_step_req, Decoded);
decode(sc_guide_next_step_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, reward, pb_reward_info,
	      [is_record, repeated]},
	     {1, result, uint32, []}],
    Defaults = [{2, reward, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_guide_next_step_reply, Decoded);
decode(cs_hundred_last_week_rank_query_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_hundred_last_week_rank_query_req, Decoded);
decode(sc_hundred_last_week_rank_query_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_hundred_last_week_data,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_hundred_last_week_rank_query_reply,
	      Decoded);
decode(pb_hundred_last_week_data, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, name2_total_win, bytes, []},
	     {3, name1_round_win, bytes, []},
	     {2, reward_gold, uint64, []}, {1, rank, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_hundred_last_week_data, Decoded);
decode(cs_real_name_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, id_card_num, string, []},
	     {1, name, bytes, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_real_name_update, Decoded);
decode(sc_real_name_update, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rewards, pb_reward_info,
	      [is_record, repeated]},
	     {2, err, bytes, []}, {1, result, uint32, []}],
    Defaults = [{3, rewards, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_real_name_update, Decoded);
decode(cs_real_name_req, Bytes) when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_real_name_req, Decoded);
decode(sc_real_name_req, Bytes) when is_binary(Bytes) ->
    Types = [{1, type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_real_name_req, Decoded);
decode(cs_super_laba_last_week_rank_query_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_super_laba_last_week_rank_query_req,
	      Decoded);
decode(sc_super_laba_last_week_rank_query_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, list, pb_hundred_last_week_data,
	      [is_record, repeated]}],
    Defaults = [{1, list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_super_laba_last_week_rank_query_reply,
	      Decoded);
decode(cs_query_last_daily_rank_reward_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_query_last_daily_rank_reward_req, Decoded);
decode(sc_query_last_daily_rank_reward_reply, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, rank_info_list, pb_rank_info,
	      [is_record, repeated]},
	     {2, date, uint64, []}, {1, type, int32, []}],
    Defaults = [{3, rank_info_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_query_last_daily_rank_reward_reply,
	      Decoded);
decode(pb_cur_stickiness_redpack_info, Bytes)
    when is_binary(Bytes) ->
    Types = [{13, end_time, uint64, []},
	     {12, total_gold, uint64, []},
	     {11, holding_earn_gold, uint64, []},
	     {10, gold_cov_to_reward_item_rate, uint64, []},
	     {9, cur_earn_gold, uint64, []},
	     {8, cur_trigger_next_amount, uint64, []},
	     {7, cur_total_amount, uint64, []},
	     {6, reward_min, uint64, []},
	     {5, reward_amount, uint64, []},
	     {4, reward_type, int32, []}, {3, level, int32, []},
	     {2, testtype, int32, []}, {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_cur_stickiness_redpack_info, Decoded);
decode(sc_player_stickiness_redpack_info_notify, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, cur_info, pb_cur_stickiness_redpack_info,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_stickiness_redpack_info_notify,
	      Decoded);
decode(cs_stickiness_redpack_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, testtype, int32, []},
	     {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_stickiness_redpack_draw_req, Decoded);
decode(sc_stickiness_redpack_draw_resp, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward_amount, uint64, []},
	     {2, reward_type, int32, []},
	     {1, cur_info, pb_cur_stickiness_redpack_info,
	      [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_stickiness_redpack_draw_resp, Decoded);
decode(cs_player_stickiness_redpack_info_notify_req,
       Bytes)
    when is_binary(Bytes) ->
    Types = [{2, testtype, int32, []},
	     {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_stickiness_redpack_info_notify_req,
	      Decoded);
decode(pb_player_bet_stickiness_redpack_list_elem,
       Bytes)
    when is_binary(Bytes) ->
    Types = [{4, redpack_3, float, []},
	     {3, redpack_2, float, []}, {2, redpack_1, float, []},
	     {1, level, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_player_bet_stickiness_redpack_list_elem,
	      Decoded);
decode(sc_player_bet_stickiness_notify, Bytes)
    when is_binary(Bytes) ->
    Types = [{6, redpack_list,
	      pb_player_bet_stickiness_redpack_list_elem,
	      [is_record, repeated]},
	     {5, cur_level, int32, []}, {4, total_bet, uint64, []},
	     {3, cur_bet, uint64, []}, {2, testtype, int32, []},
	     {1, room_type, int32, []}],
    Defaults = [{6, redpack_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_bet_stickiness_notify, Decoded);
decode(cs_player_bet_stickiness_redpack_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, level, int32, []},
	     {2, testtype, int32, []}, {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_bet_stickiness_redpack_draw_req,
	      Decoded);
decode(sc_player_bet_stickiness_redpack_draw_resp,
       Bytes)
    when is_binary(Bytes) ->
    Types = [{5, desc, string, []},
	     {4, reward_amount, uint32, []}, {3, level, int32, []},
	     {2, testtype, int32, []}, {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_bet_stickiness_redpack_draw_resp,
	      Decoded);
decode(pb_bet_lock_config_list_elem, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, next_gen_vip, uint32, []},
	     {3, next_gen_gold, uint32, []},
	     {2, bet_gold_limit, uint64, []}, {1, level, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_bet_lock_config_list_elem, Decoded);
decode(cs_bet_lock_config_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, testtype, int32, []},
	     {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_bet_lock_config_req, Decoded);
decode(sc_bet_lock_config_resp, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, configs, pb_bet_lock_config_list_elem,
	      [is_record, repeated]},
	     {2, testtype, int32, []}, {1, room_type, int32, []}],
    Defaults = [{3, configs, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_bet_lock_config_resp, Decoded);
decode(sc_bet_lock_update_notify, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, total_amount, uint64, []},
	     {3, cur_level, pb_bet_lock_config_list_elem,
	      [is_record]},
	     {2, testtype, int32, []}, {1, room_type, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_bet_lock_update_notify, Decoded);
decode(cs_player_salary_query_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_salary_query_req, Decoded);
decode(sc_player_salary_query_resp, Bytes)
    when is_binary(Bytes) ->
    Types = [{4, is_draw, bool, []},
	     {3, yesterday_salary, uint64, []},
	     {2, today_earn, uint64, []},
	     {1, yesterday_earn, uint64, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_salary_query_resp, Decoded);
decode(cs_player_salary_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_player_salary_draw_req, Decoded);
decode(sc_player_salary_draw_resp, Bytes)
    when is_binary(Bytes) ->
    Types = [{2, desc, string, []},
	     {1, salary, uint64, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_player_salary_draw_resp, Decoded);
decode(pb_lottery_item, Bytes) when is_binary(Bytes) ->
    Types = [{2, item_num, uint32, []},
	     {1, item_id, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_lottery_item, Decoded);
decode(pb_lottery_reward_config, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, reward_items, pb_lottery_item,
	      [is_record, repeated]},
	     {2, cost_item, pb_lottery_item, [is_record]},
	     {1, index, uint32, []}],
    Defaults = [{3, reward_items, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(pb_lottery_reward_config, Decoded);
decode(cs_lottery_draw_req, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, prize_cls, uint32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_lottery_draw_req, Decoded);
decode(sc_lottery_draw_resp, Bytes)
    when is_binary(Bytes) ->
    Types = [{5, reward_configs, pb_lottery_reward_config,
	      [is_record, repeated]},
	     {4, is_reward, bool, []},
	     {3, reward_item_num, uint32, []},
	     {2, reward_item_id, uint32, []},
	     {1, left_times, uint32, []}],
    Defaults = [{5, reward_configs, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_lottery_draw_resp, Decoded).

decode(<<>>, Types, Acc) ->
    reverse_repeated_fields(Acc, Types);
decode(Bytes, Types, Acc) ->
    {ok, FNum} = protobuffs:next_field_num(Bytes),
    case lists:keyfind(FNum, 1, Types) of
      {FNum, Name, Type, Opts} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {{FNum, V}, R} = protobuffs:decode(Bytes,
								     bytes),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  case lists:member(repeated_packed, Opts) of
				    true ->
					{{FNum, V}, R} =
					    protobuffs:decode_packed(Bytes,
								     Type),
					{V, R};
				    false ->
					{{FNum, V}, R} =
					    protobuffs:decode(Bytes, Type),
					{unpack_value(V, Type), R}
				  end
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1) | List]}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1)]} | Acc])
		end;
	    false ->
		decode(Rest1, Types,
		       [{FNum, Name, int_to_enum(Type, Value1)} | Acc])
	  end;
      false ->
	  case lists:keyfind('$extensions', 2, Acc) of
	    {_, _, Dict} ->
		{{FNum, _V}, R} = protobuffs:decode(Bytes, bytes),
		Diff = size(Bytes) - size(R),
		<<V:Diff/binary, _/binary>> = Bytes,
		NewDict = dict:store(FNum, V, Dict),
		NewAcc = lists:keyreplace('$extensions', 2, Acc,
					  {false, '$extensions', NewDict}),
		decode(R, Types, NewAcc);
	    _ ->
		{ok, Skipped} = protobuffs:skip_next_field(Bytes),
		decode(Skipped, Types, Acc)
	  end
    end.

reverse_repeated_fields(FieldList, Types) ->
    [begin
       case lists:keyfind(FNum, 1, Types) of
	 {FNum, Name, _Type, Opts} ->
	     case lists:member(repeated, Opts) of
	       true -> {FNum, Name, lists:reverse(Value)};
	       _ -> Field
	     end;
	 _ -> Field
       end
     end
     || {FNum, Name, Value} = Field <- FieldList].

unpack_value(Binary, string) when is_binary(Binary) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(sc_items_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_update),
						   Record, Name, Val)
			  end,
			  #sc_items_update{}, DecodedTuples),
    Record1;
to_record(sc_items_add, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_add),
						   Record, Name, Val)
			  end,
			  #sc_items_add{}, DecodedTuples),
    Record1;
to_record(sc_items_delete, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_delete),
						   Record, Name, Val)
			  end,
			  #sc_items_delete{}, DecodedTuples),
    Record1;
to_record(sc_items_init_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_items_init_update),
						   Record, Name, Val)
			  end,
			  #sc_items_init_update{}, DecodedTuples),
    Record1;
to_record(pb_item_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_item_info),
						   Record, Name, Val)
			  end,
			  #pb_item_info{}, DecodedTuples),
    Record1;
to_record(cs_item_use_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_item_use_req),
						   Record, Name, Val)
			  end,
			  #cs_item_use_req{}, DecodedTuples),
    Record1;
to_record(sc_item_use_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_item_use_reply),
						   Record, Name, Val)
			  end,
			  #sc_item_use_reply{}, DecodedTuples),
    Record1;
to_record(pb_reward_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_reward_info),
						   Record, Name, Val)
			  end,
			  #pb_reward_info{}, DecodedTuples),
    Record1;
to_record(sc_player_base_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_base_info),
						   Record, Name, Val)
			  end,
			  #sc_player_base_info{}, DecodedTuples),
    Record1;
to_record(cs_player_change_name_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_change_name_req),
						   Record, Name, Val)
			  end,
			  #cs_player_change_name_req{}, DecodedTuples),
    Record1;
to_record(sc_player_change_name_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_change_name_reply),
						   Record, Name, Val)
			  end,
			  #sc_player_change_name_reply{}, DecodedTuples),
    Record1;
to_record(cs_player_change_headicon_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_change_headicon_req),
						   Record, Name, Val)
			  end,
			  #cs_player_change_headicon_req{}, DecodedTuples),
    Record1;
to_record(sc_player_change_headicon_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_change_headicon_reply),
						   Record, Name, Val)
			  end,
			  #sc_player_change_headicon_reply{}, DecodedTuples),
    Record1;
to_record(cs_player_chat, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_chat),
						   Record, Name, Val)
			  end,
			  #cs_player_chat{}, DecodedTuples),
    Record1;
to_record(sc_player_chat, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_chat),
						   Record, Name, Val)
			  end,
			  #sc_player_chat{}, DecodedTuples),
    Record1;
to_record(sc_player_sys_notice, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_sys_notice),
						   Record, Name, Val)
			  end,
			  #sc_player_sys_notice{}, DecodedTuples),
    Record1;
to_record(sc_tips, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields, sc_tips),
						   Record, Name, Val)
			  end,
			  #sc_tips{}, DecodedTuples),
    Record1;
to_record(cs_query_player_winning_rec_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_query_player_winning_rec_req),
						   Record, Name, Val)
			  end,
			  #cs_query_player_winning_rec_req{}, DecodedTuples),
    Record1;
to_record(sc_query_player_winning_rec_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_query_player_winning_rec_reply),
						   Record, Name, Val)
			  end,
			  #sc_query_player_winning_rec_reply{}, DecodedTuples),
    Record1;
to_record(cs_niu_query_in_game_player_num_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_query_in_game_player_num_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_query_in_game_player_num_req{},
			  DecodedTuples),
    Record1;
to_record(pb_room_player_num, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_room_player_num),
						   Record, Name, Val)
			  end,
			  #pb_room_player_num{}, DecodedTuples),
    Record1;
to_record(sc_niu_query_in_game_player_num_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_query_in_game_player_num_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_query_in_game_player_num_reply{},
			  DecodedTuples),
    Record1;
to_record(cs_niu_subsidy_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_subsidy_req),
						   Record, Name, Val)
			  end,
			  #cs_niu_subsidy_req{}, DecodedTuples),
    Record1;
to_record(sc_niu_subsidy_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_subsidy_reply),
						   Record, Name, Val)
			  end,
			  #sc_niu_subsidy_reply{}, DecodedTuples),
    Record1;
to_record(sc_niu_subsidy_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_subsidy_info_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_subsidy_info_update{}, DecodedTuples),
    Record1;
to_record(cs_niu_special_subsidy_share,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_niu_special_subsidy_share),
						   Record, Name, Val)
			  end,
			  #cs_niu_special_subsidy_share{}, DecodedTuples),
    Record1;
to_record(sc_niu_special_subsidy_share,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_special_subsidy_share),
						   Record, Name, Val)
			  end,
			  #sc_niu_special_subsidy_share{}, DecodedTuples),
    Record1;
to_record(cs_player_base_make_name, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_base_make_name),
						   Record, Name, Val)
			  end,
			  #cs_player_base_make_name{}, DecodedTuples),
    Record1;
to_record(sc_player_base_make_name_back,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_base_make_name_back),
						   Record, Name, Val)
			  end,
			  #sc_player_base_make_name_back{}, DecodedTuples),
    Record1;
to_record(cs_daily_checkin_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_daily_checkin_req),
						   Record, Name, Val)
			  end,
			  #cs_daily_checkin_req{}, DecodedTuples),
    Record1;
to_record(sc_daily_checkin_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_daily_checkin_reply),
						   Record, Name, Val)
			  end,
			  #sc_daily_checkin_reply{}, DecodedTuples),
    Record1;
to_record(sc_daily_checkin_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_daily_checkin_info_update),
						   Record, Name, Val)
			  end,
			  #sc_daily_checkin_info_update{}, DecodedTuples),
    Record1;
to_record(pb_checkin_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_checkin_info),
						   Record, Name, Val)
			  end,
			  #pb_checkin_info{}, DecodedTuples),
    Record1;
to_record(cs_make_up_for_checkin_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_make_up_for_checkin_req),
						   Record, Name, Val)
			  end,
			  #cs_make_up_for_checkin_req{}, DecodedTuples),
    Record1;
to_record(sc_player_phone_num_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_phone_num_info_update),
						   Record, Name, Val)
			  end,
			  #sc_player_phone_num_info_update{}, DecodedTuples),
    Record1;
to_record(sc_player_bind_phone_num, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_bind_phone_num),
						   Record, Name, Val)
			  end,
			  #sc_player_bind_phone_num{}, DecodedTuples),
    Record1;
to_record(cs_player_bind_phone_num_draw,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_bind_phone_num_draw),
						   Record, Name, Val)
			  end,
			  #cs_player_bind_phone_num_draw{}, DecodedTuples),
    Record1;
to_record(sc_player_bind_phone_num_draw_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_bind_phone_num_draw_reply),
						   Record, Name, Val)
			  end,
			  #sc_player_bind_phone_num_draw_reply{},
			  DecodedTuples),
    Record1;
to_record(sc_niu_special_subsidy_info_update,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_niu_special_subsidy_info_update),
						   Record, Name, Val)
			  end,
			  #sc_niu_special_subsidy_info_update{}, DecodedTuples),
    Record1;
to_record(cs_rank_query_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_rank_query_req),
						   Record, Name, Val)
			  end,
			  #cs_rank_query_req{}, DecodedTuples),
    Record1;
to_record(sc_rank_qurey_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_rank_qurey_reply),
						   Record, Name, Val)
			  end,
			  #sc_rank_qurey_reply{}, DecodedTuples),
    Record1;
to_record(pb_rank_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_rank_info),
						   Record, Name, Val)
			  end,
			  #pb_rank_info{}, DecodedTuples),
    Record1;
to_record(cs_vip_daily_reward, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_vip_daily_reward),
						   Record, Name, Val)
			  end,
			  #cs_vip_daily_reward{}, DecodedTuples),
    Record1;
to_record(sc_vip_daily_reward, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_vip_daily_reward),
						   Record, Name, Val)
			  end,
			  #sc_vip_daily_reward{}, DecodedTuples),
    Record1;
to_record(sc_guide_info_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_guide_info_update),
						   Record, Name, Val)
			  end,
			  #sc_guide_info_update{}, DecodedTuples),
    Record1;
to_record(cs_guide_next_step_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_guide_next_step_req),
						   Record, Name, Val)
			  end,
			  #cs_guide_next_step_req{}, DecodedTuples),
    Record1;
to_record(sc_guide_next_step_reply, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_guide_next_step_reply),
						   Record, Name, Val)
			  end,
			  #sc_guide_next_step_reply{}, DecodedTuples),
    Record1;
to_record(cs_hundred_last_week_rank_query_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_hundred_last_week_rank_query_req),
						   Record, Name, Val)
			  end,
			  #cs_hundred_last_week_rank_query_req{},
			  DecodedTuples),
    Record1;
to_record(sc_hundred_last_week_rank_query_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_hundred_last_week_rank_query_reply),
						   Record, Name, Val)
			  end,
			  #sc_hundred_last_week_rank_query_reply{},
			  DecodedTuples),
    Record1;
to_record(pb_hundred_last_week_data, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_hundred_last_week_data),
						   Record, Name, Val)
			  end,
			  #pb_hundred_last_week_data{}, DecodedTuples),
    Record1;
to_record(cs_real_name_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_real_name_update),
						   Record, Name, Val)
			  end,
			  #cs_real_name_update{}, DecodedTuples),
    Record1;
to_record(sc_real_name_update, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_real_name_update),
						   Record, Name, Val)
			  end,
			  #sc_real_name_update{}, DecodedTuples),
    Record1;
to_record(cs_real_name_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_real_name_req),
						   Record, Name, Val)
			  end,
			  #cs_real_name_req{}, DecodedTuples),
    Record1;
to_record(sc_real_name_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_real_name_req),
						   Record, Name, Val)
			  end,
			  #sc_real_name_req{}, DecodedTuples),
    Record1;
to_record(cs_super_laba_last_week_rank_query_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_super_laba_last_week_rank_query_req),
						   Record, Name, Val)
			  end,
			  #cs_super_laba_last_week_rank_query_req{},
			  DecodedTuples),
    Record1;
to_record(sc_super_laba_last_week_rank_query_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_super_laba_last_week_rank_query_reply),
						   Record, Name, Val)
			  end,
			  #sc_super_laba_last_week_rank_query_reply{},
			  DecodedTuples),
    Record1;
to_record(cs_query_last_daily_rank_reward_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_query_last_daily_rank_reward_req),
						   Record, Name, Val)
			  end,
			  #cs_query_last_daily_rank_reward_req{},
			  DecodedTuples),
    Record1;
to_record(sc_query_last_daily_rank_reward_reply,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_query_last_daily_rank_reward_reply),
						   Record, Name, Val)
			  end,
			  #sc_query_last_daily_rank_reward_reply{},
			  DecodedTuples),
    Record1;
to_record(pb_cur_stickiness_redpack_info,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_cur_stickiness_redpack_info),
						   Record, Name, Val)
			  end,
			  #pb_cur_stickiness_redpack_info{}, DecodedTuples),
    Record1;
to_record(sc_player_stickiness_redpack_info_notify,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_stickiness_redpack_info_notify),
						   Record, Name, Val)
			  end,
			  #sc_player_stickiness_redpack_info_notify{},
			  DecodedTuples),
    Record1;
to_record(cs_stickiness_redpack_draw_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_stickiness_redpack_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_stickiness_redpack_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_stickiness_redpack_draw_resp,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_stickiness_redpack_draw_resp),
						   Record, Name, Val)
			  end,
			  #sc_stickiness_redpack_draw_resp{}, DecodedTuples),
    Record1;
to_record(cs_player_stickiness_redpack_info_notify_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_stickiness_redpack_info_notify_req),
						   Record, Name, Val)
			  end,
			  #cs_player_stickiness_redpack_info_notify_req{},
			  DecodedTuples),
    Record1;
to_record(pb_player_bet_stickiness_redpack_list_elem,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_player_bet_stickiness_redpack_list_elem),
						   Record, Name, Val)
			  end,
			  #pb_player_bet_stickiness_redpack_list_elem{},
			  DecodedTuples),
    Record1;
to_record(sc_player_bet_stickiness_notify,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_bet_stickiness_notify),
						   Record, Name, Val)
			  end,
			  #sc_player_bet_stickiness_notify{}, DecodedTuples),
    Record1;
to_record(cs_player_bet_stickiness_redpack_draw_req,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_bet_stickiness_redpack_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_player_bet_stickiness_redpack_draw_req{},
			  DecodedTuples),
    Record1;
to_record(sc_player_bet_stickiness_redpack_draw_resp,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_bet_stickiness_redpack_draw_resp),
						   Record, Name, Val)
			  end,
			  #sc_player_bet_stickiness_redpack_draw_resp{},
			  DecodedTuples),
    Record1;
to_record(pb_bet_lock_config_list_elem,
	  DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_bet_lock_config_list_elem),
						   Record, Name, Val)
			  end,
			  #pb_bet_lock_config_list_elem{}, DecodedTuples),
    Record1;
to_record(cs_bet_lock_config_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_bet_lock_config_req),
						   Record, Name, Val)
			  end,
			  #cs_bet_lock_config_req{}, DecodedTuples),
    Record1;
to_record(sc_bet_lock_config_resp, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_bet_lock_config_resp),
						   Record, Name, Val)
			  end,
			  #sc_bet_lock_config_resp{}, DecodedTuples),
    Record1;
to_record(sc_bet_lock_update_notify, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_bet_lock_update_notify),
						   Record, Name, Val)
			  end,
			  #sc_bet_lock_update_notify{}, DecodedTuples),
    Record1;
to_record(cs_player_salary_query_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_salary_query_req),
						   Record, Name, Val)
			  end,
			  #cs_player_salary_query_req{}, DecodedTuples),
    Record1;
to_record(sc_player_salary_query_resp, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_salary_query_resp),
						   Record, Name, Val)
			  end,
			  #sc_player_salary_query_resp{}, DecodedTuples),
    Record1;
to_record(cs_player_salary_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_player_salary_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_player_salary_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_player_salary_draw_resp, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_player_salary_draw_resp),
						   Record, Name, Val)
			  end,
			  #sc_player_salary_draw_resp{}, DecodedTuples),
    Record1;
to_record(pb_lottery_item, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_lottery_item),
						   Record, Name, Val)
			  end,
			  #pb_lottery_item{}, DecodedTuples),
    Record1;
to_record(pb_lottery_reward_config, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       pb_lottery_reward_config),
						   Record, Name, Val)
			  end,
			  #pb_lottery_reward_config{}, DecodedTuples),
    Record1;
to_record(cs_lottery_draw_req, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_lottery_draw_req),
						   Record, Name, Val)
			  end,
			  #cs_lottery_draw_req{}, DecodedTuples),
    Record1;
to_record(sc_lottery_draw_resp, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_lottery_draw_resp),
						   Record, Name, Val)
			  end,
			  #sc_lottery_draw_resp{}, DecodedTuples),
    Record1.

decode_extensions(Record) -> Record.

decode_extensions(_Types, [], Acc) ->
    dict:from_list(Acc);
decode_extensions(Types, [{Fnum, Bytes} | Tail], Acc) ->
    NewAcc = case lists:keyfind(Fnum, 1, Types) of
	       {Fnum, Name, Type, Opts} ->
		   {Value1, Rest1} = case lists:member(is_record, Opts) of
				       true ->
					   {{FNum, V}, R} =
					       protobuffs:decode(Bytes, bytes),
					   RecVal = decode(Type, V),
					   {RecVal, R};
				       false ->
					   case lists:member(repeated_packed,
							     Opts)
					       of
					     true ->
						 {{FNum, V}, R} =
						     protobuffs:decode_packed(Bytes,
									      Type),
						 {V, R};
					     false ->
						 {{FNum, V}, R} =
						     protobuffs:decode(Bytes,
								       Type),
						 {unpack_value(V, Type), R}
					   end
				     end,
		   case lists:member(repeated, Opts) of
		     true ->
			 case lists:keytake(FNum, 1, Acc) of
			   {value, {FNum, Name, List}, Acc1} ->
			       decode(Rest1, Types,
				      [{FNum, Name,
					lists:reverse([int_to_enum(Type, Value1)
						       | lists:reverse(List)])}
				       | Acc1]);
			   false ->
			       decode(Rest1, Types,
				      [{FNum, Name, [int_to_enum(Type, Value1)]}
				       | Acc])
			 end;
		     false ->
			 [{Fnum,
			   {optional, int_to_enum(Type, Value1), Type, Opts}}
			  | Acc]
		   end;
	       false -> [{Fnum, Bytes} | Acc]
	     end,
    decode_extensions(Types, Tail, NewAcc).

set_record_field(Fields, Record, '$extensions',
		 Value) ->
    Decodable = [],
    NewValue = decode_extensions(element(1, Record),
				 Decodable, dict:to_list(Value)),
    Index = list_index('$extensions', Fields),
    erlang:setelement(Index + 1, Record, NewValue);
set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> -1.

extension_size(_) -> 0.

has_extension(_Record, _FieldName) -> false.

get_extension(_Record, _FieldName) -> undefined.

set_extension(Record, _, _) -> {error, Record}.

