-module(message_code).

-export([decode/1, decode_msg_bin/2, encode/1,
	 encode_msg_bin/1, merge_bin/2, split_bin/1]).

-include_lib("eunit/include/eunit.hrl").

-include_lib("network_proto/include/activity_pb.hrl").

-include_lib("network_proto/include/car_pb.hrl").

-include_lib("network_proto/include/chest_pb.hrl").

-include_lib("network_proto/include/common_pb.hrl").

-include_lib("network_proto/include/hundred_niu_pb.hrl").

-include_lib("network_proto/include/item_pb.hrl").

-include_lib("network_proto/include/laba_pb.hrl").

-include_lib("network_proto/include/login_pb.hrl").

-include_lib("network_proto/include/mail_pb.hrl").

-include_lib("network_proto/include/mission_pb.hrl").

-include_lib("network_proto/include/niu_game_pb.hrl").

-include_lib("network_proto/include/player_pb.hrl").

-include_lib("network_proto/include/prize_exchange_pb.hrl").

-include_lib("network_proto/include/red_pack_pb.hrl").

-include_lib("network_proto/include/share_pb.hrl").

-include_lib("network_proto/include/shop_pb.hrl").

-define(INT_PROTO_ID, 16 / unsigned - big - integer).

encode(#cs_login{} = Msg) ->
    {ok,
     <<1:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_cs_login(Msg)))/binary>>};
encode(#sc_login_reply{} = Msg) ->
    {ok,
     <<2:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_sc_login_reply(Msg)))/binary>>};
encode(#cs_login_out{} = Msg) ->
    {ok,
     <<3:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_cs_login_out(Msg)))/binary>>};
encode(#cs_login_reconnection{} = Msg) ->
    {ok,
     <<4:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_cs_login_reconnection(Msg)))/binary>>};
encode(#sc_login_reconnection_reply{} = Msg) ->
    {ok,
     <<5:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_sc_login_reconnection_reply(Msg)))/binary>>};
encode(#sc_login_repeat{} = Msg) ->
    {ok,
     <<6:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_sc_login_repeat(Msg)))/binary>>};
encode(#sc_login_proto_complete{} = Msg) ->
    {ok,
     <<7:?INT_PROTO_ID,
       (erlang:iolist_to_binary(login_pb:encode_sc_login_proto_complete(Msg)))/binary>>};
encode(#cs_common_heartbeat{} = Msg) ->
    {ok,
     <<8:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_cs_common_heartbeat(Msg)))/binary>>};
encode(#sc_common_heartbeat_reply{} = Msg) ->
    {ok,
     <<9:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_sc_common_heartbeat_reply(Msg)))/binary>>};
encode(#cs_common_proto_count{} = Msg) ->
    {ok,
     <<10:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_cs_common_proto_count(Msg)))/binary>>};
encode(#sc_common_proto_count{} = Msg) ->
    {ok,
     <<11:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_sc_common_proto_count(Msg)))/binary>>};
encode(#cs_common_proto_clean{} = Msg) ->
    {ok,
     <<12:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_cs_common_proto_clean(Msg)))/binary>>};
encode(#sc_common_proto_clean{} = Msg) ->
    {ok,
     <<13:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_sc_common_proto_clean(Msg)))/binary>>};
encode(#sc_player_base_info{} = Msg) ->
    {ok,
     <<14:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_base_info(Msg)))/binary>>};
encode(#cs_player_change_name_req{} = Msg) ->
    {ok,
     <<15:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_change_name_req(Msg)))/binary>>};
encode(#sc_player_change_name_reply{} = Msg) ->
    {ok,
     <<16:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_change_name_reply(Msg)))/binary>>};
encode(#cs_player_change_headicon_req{} = Msg) ->
    {ok,
     <<17:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_change_headicon_req(Msg)))/binary>>};
encode(#sc_player_change_headicon_reply{} = Msg) ->
    {ok,
     <<18:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_change_headicon_reply(Msg)))/binary>>};
encode(#cs_player_chat{} = Msg) ->
    {ok,
     <<19:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_chat(Msg)))/binary>>};
encode(#sc_player_chat{} = Msg) ->
    {ok,
     <<20:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_chat(Msg)))/binary>>};
encode(#sc_player_sys_notice{} = Msg) ->
    {ok,
     <<21:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_sys_notice(Msg)))/binary>>};
encode(#sc_tips{} = Msg) ->
    {ok,
     <<22:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_tips(Msg)))/binary>>};
encode(#cs_query_player_winning_rec_req{} = Msg) ->
    {ok,
     <<23:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_query_player_winning_rec_req(Msg)))/binary>>};
encode(#sc_query_player_winning_rec_reply{} = Msg) ->
    {ok,
     <<24:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_query_player_winning_rec_reply(Msg)))/binary>>};
encode(#cs_niu_query_in_game_player_num_req{} = Msg) ->
    {ok,
     <<25:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_niu_query_in_game_player_num_req(Msg)))/binary>>};
encode(#sc_niu_query_in_game_player_num_reply{} =
	   Msg) ->
    {ok,
     <<26:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_niu_query_in_game_player_num_reply(Msg)))/binary>>};
encode(#cs_common_bug_feedback{} = Msg) ->
    {ok,
     <<28:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_cs_common_bug_feedback(Msg)))/binary>>};
encode(#sc_common_bug_feedback{} = Msg) ->
    {ok,
     <<29:?INT_PROTO_ID,
       (erlang:iolist_to_binary(common_pb:encode_sc_common_bug_feedback(Msg)))/binary>>};
encode(#sc_items_update{} = Msg) ->
    {ok,
     <<30:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_sc_items_update(Msg)))/binary>>};
encode(#sc_items_add{} = Msg) ->
    {ok,
     <<31:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_sc_items_add(Msg)))/binary>>};
encode(#sc_items_delete{} = Msg) ->
    {ok,
     <<32:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_sc_items_delete(Msg)))/binary>>};
encode(#sc_items_init_update{} = Msg) ->
    {ok,
     <<33:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_sc_items_init_update(Msg)))/binary>>};
encode(#cs_item_use_req{} = Msg) ->
    {ok,
     <<34:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_cs_item_use_req(Msg)))/binary>>};
encode(#sc_item_use_reply{} = Msg) ->
    {ok,
     <<35:?INT_PROTO_ID,
       (erlang:iolist_to_binary(item_pb:encode_sc_item_use_reply(Msg)))/binary>>};
encode(#sc_mails_init_update{} = Msg) ->
    {ok,
     <<40:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_sc_mails_init_update(Msg)))/binary>>};
encode(#sc_mail_add{} = Msg) ->
    {ok,
     <<41:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_sc_mail_add(Msg)))/binary>>};
encode(#cs_mail_delete_request{} = Msg) ->
    {ok,
     <<42:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_cs_mail_delete_request(Msg)))/binary>>};
encode(#sc_mail_delete_reply{} = Msg) ->
    {ok,
     <<43:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_sc_mail_delete_reply(Msg)))/binary>>};
encode(#cs_read_mail{} = Msg) ->
    {ok,
     <<44:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_cs_read_mail(Msg)))/binary>>};
encode(#cs_mail_draw_request{} = Msg) ->
    {ok,
     <<45:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_cs_mail_draw_request(Msg)))/binary>>};
encode(#sc_mail_draw_reply{} = Msg) ->
    {ok,
     <<46:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mail_pb:encode_sc_mail_draw_reply(Msg)))/binary>>};
encode(#sc_niu_room_state_update{} = Msg) ->
    {ok,
     <<50:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_room_state_update(Msg)))/binary>>};
encode(#cs_niu_enter_room_req{} = Msg) ->
    {ok,
     <<51:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_enter_room_req(Msg)))/binary>>};
encode(#sc_niu_enter_room_reply{} = Msg) ->
    {ok,
     <<52:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_enter_room_reply(Msg)))/binary>>};
encode(#sc_niu_enter_room_player_info_update{} = Msg) ->
    {ok,
     <<53:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_enter_room_player_info_update(Msg)))/binary>>};
encode(#cs_niu_choose_master_rate_req{} = Msg) ->
    {ok,
     <<54:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_choose_master_rate_req(Msg)))/binary>>};
encode(#sc_niu_choose_master_rate_reply{} = Msg) ->
    {ok,
     <<55:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_choose_master_rate_reply(Msg)))/binary>>};
encode(#sc_niu_player_choose_master_rate_update{} =
	   Msg) ->
    {ok,
     <<56:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_choose_master_rate_update(Msg)))/binary>>};
encode(#cs_niu_choose_free_rate_req{} = Msg) ->
    {ok,
     <<57:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_choose_free_rate_req(Msg)))/binary>>};
encode(#sc_niu_choose_free_rate_reply{} = Msg) ->
    {ok,
     <<58:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_choose_free_rate_reply(Msg)))/binary>>};
encode(#sc_niu_player_choose_free_rate_update{} =
	   Msg) ->
    {ok,
     <<59:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_choose_free_rate_update(Msg)))/binary>>};
encode(#cs_niu_leave_room_req{} = Msg) ->
    {ok,
     <<60:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_leave_room_req(Msg)))/binary>>};
encode(#sc_niu_leave_room_reply{} = Msg) ->
    {ok,
     <<61:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_leave_room_reply(Msg)))/binary>>};
encode(#sc_niu_leave_room_player_pos_update{} = Msg) ->
    {ok,
     <<62:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_leave_room_player_pos_update(Msg)))/binary>>};
encode(#cs_niu_submit_card_req{} = Msg) ->
    {ok,
     <<63:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_submit_card_req(Msg)))/binary>>};
encode(#sc_niu_submit_card_reply{} = Msg) ->
    {ok,
     <<64:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_submit_card_reply(Msg)))/binary>>};
encode(#sc_niu_player_submit_card_update{} = Msg) ->
    {ok,
     <<65:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_submit_card_update(Msg)))/binary>>};
encode(#cs_niu_syn_in_game_state_req{} = Msg) ->
    {ok,
     <<66:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_syn_in_game_state_req(Msg)))/binary>>};
encode(#sc_niu_player_room_info_update{} = Msg) ->
    {ok,
     <<67:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_room_info_update(Msg)))/binary>>};
encode(#sc_niu_player_back_to_room_info_update{} =
	   Msg) ->
    {ok,
     <<68:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_back_to_room_info_update(Msg)))/binary>>};
encode(#cs_niu_subsidy_req{} = Msg) ->
    {ok,
     <<69:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_niu_subsidy_req(Msg)))/binary>>};
encode(#sc_niu_subsidy_reply{} = Msg) ->
    {ok,
     <<70:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_niu_subsidy_reply(Msg)))/binary>>};
encode(#sc_niu_subsidy_info_update{} = Msg) ->
    {ok,
     <<71:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_niu_subsidy_info_update(Msg)))/binary>>};
encode(#cs_niu_query_player_room_info_req{} = Msg) ->
    {ok,
     <<72:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_query_player_room_info_req(Msg)))/binary>>};
encode(#cs_niu_special_subsidy_share{} = Msg) ->
    {ok,
     <<73:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_niu_special_subsidy_share(Msg)))/binary>>};
encode(#sc_niu_special_subsidy_share{} = Msg) ->
    {ok,
     <<74:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_niu_special_subsidy_share(Msg)))/binary>>};
encode(#cs_daily_checkin_req{} = Msg) ->
    {ok,
     <<75:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_daily_checkin_req(Msg)))/binary>>};
encode(#sc_daily_checkin_reply{} = Msg) ->
    {ok,
     <<76:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_daily_checkin_reply(Msg)))/binary>>};
encode(#sc_daily_checkin_info_update{} = Msg) ->
    {ok,
     <<77:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_daily_checkin_info_update(Msg)))/binary>>};
encode(#cs_make_up_for_checkin_req{} = Msg) ->
    {ok,
     <<78:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_make_up_for_checkin_req(Msg)))/binary>>};
encode(#sc_shop_all_item_base_config{} = Msg) ->
    {ok,
     <<80:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_shop_all_item_base_config(Msg)))/binary>>};
encode(#cs_shop_buy_query{} = Msg) ->
    {ok,
     <<81:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_shop_buy_query(Msg)))/binary>>};
encode(#sc_shop_buy_reply{} = Msg) ->
    {ok,
     <<82:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_shop_buy_reply(Msg)))/binary>>};
encode(#sc_golden_bull_info_update{} = Msg) ->
    {ok,
     <<83:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_info_update(Msg)))/binary>>};
encode(#cs_golden_bull_draw_req{} = Msg) ->
    {ok,
     <<84:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_golden_bull_draw_req(Msg)))/binary>>};
encode(#sc_golden_bull_draw_reply{} = Msg) ->
    {ok,
     <<85:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_draw_reply(Msg)))/binary>>};
encode(#sc_month_card_info_update{} = Msg) ->
    {ok,
     <<86:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_month_card_info_update(Msg)))/binary>>};
encode(#cs_month_card_draw_req{} = Msg) ->
    {ok,
     <<87:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_month_card_draw_req(Msg)))/binary>>};
encode(#sc_month_card_draw_reply{} = Msg) ->
    {ok,
     <<88:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_month_card_draw_reply(Msg)))/binary>>};
encode(#sc_hundred_niu_room_state_update{} = Msg) ->
    {ok,
     <<90:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_room_state_update(Msg)))/binary>>};
encode(#cs_hundred_niu_enter_room_req{} = Msg) ->
    {ok,
     <<91:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_enter_room_req(Msg)))/binary>>};
encode(#sc_hundred_niu_enter_room_reply{} = Msg) ->
    {ok,
     <<92:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_enter_room_reply(Msg)))/binary>>};
encode(#cs_hundred_niu_player_list_query_req{} = Msg) ->
    {ok,
     <<93:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_player_list_query_req(Msg)))/binary>>};
encode(#sc_hundred_niu_player_list_query_reply{} =
	   Msg) ->
    {ok,
     <<94:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_player_list_query_reply(Msg)))/binary>>};
encode(#cs_hundred_niu_free_set_chips_req{} = Msg) ->
    {ok,
     <<95:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_free_set_chips_req(Msg)))/binary>>};
encode(#sc_hundred_niu_free_set_chips_reply{} = Msg) ->
    {ok,
     <<96:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_free_set_chips_reply(Msg)))/binary>>};
encode(#sc_hundred_niu_free_set_chips_update{} = Msg) ->
    {ok,
     <<97:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_free_set_chips_update(Msg)))/binary>>};
encode(#cs_hundred_niu_sit_down_req{} = Msg) ->
    {ok,
     <<98:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_sit_down_req(Msg)))/binary>>};
encode(#sc_hundred_niu_sit_down_reply{} = Msg) ->
    {ok,
     <<99:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_sit_down_reply(Msg)))/binary>>};
encode(#sc_hundred_niu_seat_player_info_update{} =
	   Msg) ->
    {ok,
     <<100:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_seat_player_info_update(Msg)))/binary>>};
encode(#cs_hundred_be_master_req{} = Msg) ->
    {ok,
     <<101:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_be_master_req(Msg)))/binary>>};
encode(#sc_hundred_be_master_reply{} = Msg) ->
    {ok,
     <<102:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_be_master_reply(Msg)))/binary>>};
encode(#cs_hundred_query_master_list_req{} = Msg) ->
    {ok,
     <<103:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_master_list_req(Msg)))/binary>>};
encode(#sc_hundred_query_master_list_reply{} = Msg) ->
    {ok,
     <<104:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_master_list_reply(Msg)))/binary>>};
encode(#cs_hundred_niu_in_game_syn_req{} = Msg) ->
    {ok,
     <<105:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_in_game_syn_req(Msg)))/binary>>};
encode(#cs_hundred_leave_room_req{} = Msg) ->
    {ok,
     <<106:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_leave_room_req(Msg)))/binary>>};
encode(#sc_hundred_leave_room_reply{} = Msg) ->
    {ok,
     <<107:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_leave_room_reply(Msg)))/binary>>};
encode(#cs_hundred_query_winning_rec_req{} = Msg) ->
    {ok,
     <<108:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_winning_rec_req(Msg)))/binary>>};
encode(#sc_hundred_query_winning_rec_reply{} = Msg) ->
    {ok,
     <<109:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_winning_rec_reply(Msg)))/binary>>};
encode(#cs_draw_mission_request{} = Msg) ->
    {ok,
     <<110:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_cs_draw_mission_request(Msg)))/binary>>};
encode(#sc_draw_mission_result_reply{} = Msg) ->
    {ok,
     <<111:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_draw_mission_result_reply(Msg)))/binary>>};
encode(#sc_mission{} = Msg) ->
    {ok,
     <<112:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_mission(Msg)))/binary>>};
encode(#sc_mission_update{} = Msg) ->
    {ok,
     <<113:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_mission_update(Msg)))/binary>>};
encode(#sc_mission_add{} = Msg) ->
    {ok,
     <<114:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_mission_add(Msg)))/binary>>};
encode(#sc_mission_del{} = Msg) ->
    {ok,
     <<115:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_mission_del(Msg)))/binary>>};
encode(#sc_hundred_player_gold_change_update{} = Msg) ->
    {ok,
     <<120:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_player_gold_change_update(Msg)))/binary>>};
encode(#cs_hundred_query_pool_win_player_req{} = Msg) ->
    {ok,
     <<121:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_pool_win_player_req(Msg)))/binary>>};
encode(#sc_hundred_query_pool_win_player_reply{} =
	   Msg) ->
    {ok,
     <<122:?INT_PROTO_ID,
       (erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_pool_win_player_reply(Msg)))/binary>>};
encode(#cs_rank_query_req{} = Msg) ->
    {ok,
     <<123:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_rank_query_req(Msg)))/binary>>};
encode(#sc_rank_qurey_reply{} = Msg) ->
    {ok,
     <<124:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_rank_qurey_reply(Msg)))/binary>>};
encode(#cs_cash_transformation_req{} = Msg) ->
    {ok,
     <<130:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_cash_transformation_req(Msg)))/binary>>};
encode(#sc_cash_transformation_reply{} = Msg) ->
    {ok,
     <<131:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_cash_transformation_reply(Msg)))/binary>>};
encode(#cs_golden_bull_mission{} = Msg) ->
    {ok,
     <<132:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_golden_bull_mission(Msg)))/binary>>};
encode(#sc_golden_bull_mission{} = Msg) ->
    {ok,
     <<133:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_mission(Msg)))/binary>>};
encode(#sc_player_phone_num_info_update{} = Msg) ->
    {ok,
     <<140:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_phone_num_info_update(Msg)))/binary>>};
encode(#sc_player_bind_phone_num{} = Msg) ->
    {ok,
     <<141:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_bind_phone_num(Msg)))/binary>>};
encode(#cs_player_niu_room_chest_draw{} = Msg) ->
    {ok,
     <<142:?INT_PROTO_ID,
       (erlang:iolist_to_binary(chest_pb:encode_cs_player_niu_room_chest_draw(Msg)))/binary>>};
encode(#sc_niu_room_chest_draw_reply{} = Msg) ->
    {ok,
     <<143:?INT_PROTO_ID,
       (erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_draw_reply(Msg)))/binary>>};
encode(#sc_niu_room_chest_info_update{} = Msg) ->
    {ok,
     <<144:?INT_PROTO_ID,
       (erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_info_update(Msg)))/binary>>};
encode(#cs_player_bind_phone_num_draw{} = Msg) ->
    {ok,
     <<145:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_bind_phone_num_draw(Msg)))/binary>>};
encode(#sc_player_bind_phone_num_draw_reply{} = Msg) ->
    {ok,
     <<146:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_bind_phone_num_draw_reply(Msg)))/binary>>};
encode(#sc_niu_special_subsidy_info_update{} = Msg) ->
    {ok,
     <<147:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_niu_special_subsidy_info_update(Msg)))/binary>>};
encode(#sc_niu_room_chest_times_update{} = Msg) ->
    {ok,
     <<148:?INT_PROTO_ID,
       (erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_times_update(Msg)))/binary>>};
encode(#sc_guide_info_update{} = Msg) ->
    {ok,
     <<150:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_guide_info_update(Msg)))/binary>>};
encode(#cs_guide_next_step_req{} = Msg) ->
    {ok,
     <<151:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_guide_next_step_req(Msg)))/binary>>};
encode(#sc_guide_next_step_reply{} = Msg) ->
    {ok,
     <<152:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_guide_next_step_reply(Msg)))/binary>>};
encode(#cs_hundred_last_week_rank_query_req{} = Msg) ->
    {ok,
     <<153:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_hundred_last_week_rank_query_req(Msg)))/binary>>};
encode(#sc_hundred_last_week_rank_query_reply{} =
	   Msg) ->
    {ok,
     <<154:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_hundred_last_week_rank_query_reply(Msg)))/binary>>};
encode(#cs_real_name_update{} = Msg) ->
    {ok,
     <<155:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_real_name_update(Msg)))/binary>>};
encode(#sc_real_name_update{} = Msg) ->
    {ok,
     <<156:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_real_name_update(Msg)))/binary>>};
encode(#cs_real_name_req{} = Msg) ->
    {ok,
     <<157:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_real_name_req(Msg)))/binary>>};
encode(#sc_real_name_req{} = Msg) ->
    {ok,
     <<158:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_real_name_req(Msg)))/binary>>};
encode(#sc_redpack_room_reset_times_update{} = Msg) ->
    {ok,
     <<160:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_reset_times_update(Msg)))/binary>>};
encode(#sc_redpack_room_player_times_update{} = Msg) ->
    {ok,
     <<161:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_player_times_update(Msg)))/binary>>};
encode(#sc_redpack_room_redpack_notice_update{} =
	   Msg) ->
    {ok,
     <<162:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_redpack_notice_update(Msg)))/binary>>};
encode(#cs_redpack_room_draw_req{} = Msg) ->
    {ok,
     <<163:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_redpack_room_draw_req(Msg)))/binary>>};
encode(#sc_redpack_room_draw_reply{} = Msg) ->
    {ok,
     <<164:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_draw_reply(Msg)))/binary>>};
encode(#sc_redpack_redpack_timer_sec_update{} = Msg) ->
    {ok,
     <<165:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_redpack_timer_sec_update(Msg)))/binary>>};
encode(#cs_redpack_relive_req{} = Msg) ->
    {ok,
     <<166:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_cs_redpack_relive_req(Msg)))/binary>>};
encode(#sc_redpack_relive_reply{} = Msg) ->
    {ok,
     <<167:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_relive_reply(Msg)))/binary>>};
encode(#sc_redpack_relive_times{} = Msg) ->
    {ok,
     <<168:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_relive_times(Msg)))/binary>>};
encode(#sc_fudai_pool_update{} = Msg) ->
    {ok,
     <<169:?INT_PROTO_ID,
       (erlang:iolist_to_binary(niu_game_pb:encode_sc_fudai_pool_update(Msg)))/binary>>};
encode(#cs_laba_enter_room_req{} = Msg) ->
    {ok,
     <<201:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_laba_enter_room_req(Msg)))/binary>>};
encode(#sc_laba_enter_room_reply{} = Msg) ->
    {ok,
     <<202:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_laba_enter_room_reply(Msg)))/binary>>};
encode(#cs_laba_leave_room_req{} = Msg) ->
    {ok,
     <<203:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_laba_leave_room_req(Msg)))/binary>>};
encode(#sc_laba_leave_room_reply{} = Msg) ->
    {ok,
     <<204:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_laba_leave_room_reply(Msg)))/binary>>};
encode(#sc_laba_pool_num_update{} = Msg) ->
    {ok,
     <<205:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_laba_pool_num_update(Msg)))/binary>>};
encode(#cs_laba_spin_req{} = Msg) ->
    {ok,
     <<206:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_laba_spin_req(Msg)))/binary>>};
encode(#sc_laba_spin_reply{} = Msg) ->
    {ok,
     <<207:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_laba_spin_reply(Msg)))/binary>>};
encode(#sc_game_task_info_update{} = Msg) ->
    {ok,
     <<208:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_game_task_info_update(Msg)))/binary>>};
encode(#sc_game_task_box_info_update{} = Msg) ->
    {ok,
     <<209:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_game_task_box_info_update(Msg)))/binary>>};
encode(#cs_game_task_draw_req{} = Msg) ->
    {ok,
     <<210:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_cs_game_task_draw_req(Msg)))/binary>>};
encode(#sc_game_task_draw_reply{} = Msg) ->
    {ok,
     <<211:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_game_task_draw_reply(Msg)))/binary>>};
encode(#cs_game_task_box_draw_req{} = Msg) ->
    {ok,
     <<212:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_cs_game_task_box_draw_req(Msg)))/binary>>};
encode(#sc_game_task_box_draw_reply{} = Msg) ->
    {ok,
     <<213:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_game_task_box_draw_reply(Msg)))/binary>>};
encode(#sc_redpack_task_draw_list_update{} = Msg) ->
    {ok,
     <<214:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_redpack_task_draw_list_update(Msg)))/binary>>};
encode(#cs_redpack_task_draw_req{} = Msg) ->
    {ok,
     <<215:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_cs_redpack_task_draw_req(Msg)))/binary>>};
encode(#sc_redpack_task_draw_reply{} = Msg) ->
    {ok,
     <<216:?INT_PROTO_ID,
       (erlang:iolist_to_binary(mission_pb:encode_sc_redpack_task_draw_reply(Msg)))/binary>>};
encode(#cs_win_player_list{} = Msg) ->
    {ok,
     <<217:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_win_player_list(Msg)))/binary>>};
encode(#sc_win_player_list{} = Msg) ->
    {ok,
     <<218:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_win_player_list(Msg)))/binary>>};
encode(#cs_red_pack_query_list_req{} = Msg) ->
    {ok,
     <<220:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_query_list_req(Msg)))/binary>>};
encode(#sc_red_pack_query_list_reply{} = Msg) ->
    {ok,
     <<221:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_query_list_reply(Msg)))/binary>>};
encode(#cs_red_pack_open_req{} = Msg) ->
    {ok,
     <<222:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_open_req(Msg)))/binary>>};
encode(#sc_red_pack_open_reply{} = Msg) ->
    {ok,
     <<223:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_open_reply(Msg)))/binary>>};
encode(#cs_red_pack_create_req{} = Msg) ->
    {ok,
     <<224:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_create_req(Msg)))/binary>>};
encode(#sc_red_pack_create_reply{} = Msg) ->
    {ok,
     <<225:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_create_reply(Msg)))/binary>>};
encode(#sc_red_pack_notice_update{} = Msg) ->
    {ok,
     <<226:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_notice_update(Msg)))/binary>>};
encode(#cs_red_pack_cancel_req{} = Msg) ->
    {ok,
     <<227:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_cancel_req(Msg)))/binary>>};
encode(#sc_red_pack_cancel_reply{} = Msg) ->
    {ok,
     <<228:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_cancel_reply(Msg)))/binary>>};
encode(#sc_self_red_pack_info{} = Msg) ->
    {ok,
     <<229:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_self_red_pack_info(Msg)))/binary>>};
encode(#sc_prize_config_update{} = Msg) ->
    {ok,
     <<230:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_config_update(Msg)))/binary>>};
encode(#cs_prize_query_one_req{} = Msg) ->
    {ok,
     <<231:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_query_one_req(Msg)))/binary>>};
encode(#sc_prize_query_one_reply{} = Msg) ->
    {ok,
     <<232:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_query_one_reply(Msg)))/binary>>};
encode(#cs_prize_exchange_req{} = Msg) ->
    {ok,
     <<233:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_exchange_req(Msg)))/binary>>};
encode(#sc_prize_exchange_reply{} = Msg) ->
    {ok,
     <<234:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_exchange_reply(Msg)))/binary>>};
encode(#sc_prize_exchange_record_update{} = Msg) ->
    {ok,
     <<235:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_exchange_record_update(Msg)))/binary>>};
encode(#sc_prize_address_info_update{} = Msg) ->
    {ok,
     <<236:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_address_info_update(Msg)))/binary>>};
encode(#cs_prize_address_change_req{} = Msg) ->
    {ok,
     <<237:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_address_change_req(Msg)))/binary>>};
encode(#sc_prize_address_change_reply{} = Msg) ->
    {ok,
     <<238:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_address_change_reply(Msg)))/binary>>};
encode(#sc_prize_storage_red_point_update{} = Msg) ->
    {ok,
     <<239:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_storage_red_point_update(Msg)))/binary>>};
encode(#cs_vip_daily_reward{} = Msg) ->
    {ok,
     <<240:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_vip_daily_reward(Msg)))/binary>>};
encode(#sc_vip_daily_reward{} = Msg) ->
    {ok,
     <<241:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_vip_daily_reward(Msg)))/binary>>};
encode(#sc_activity_config_info_update{} = Msg) ->
    {ok,
     <<250:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_sc_activity_config_info_update(Msg)))/binary>>};
encode(#cs_activity_info_query_req{} = Msg) ->
    {ok,
     <<251:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_cs_activity_info_query_req(Msg)))/binary>>};
encode(#sc_activity_info_query_reply{} = Msg) ->
    {ok,
     <<252:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_sc_activity_info_query_reply(Msg)))/binary>>};
encode(#cs_activity_draw_req{} = Msg) ->
    {ok,
     <<253:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_cs_activity_draw_req(Msg)))/binary>>};
encode(#sc_activity_draw_reply{} = Msg) ->
    {ok,
     <<254:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_sc_activity_draw_reply(Msg)))/binary>>};
encode(#cs_prize_query_phonecard_key_req{} = Msg) ->
    {ok,
     <<255:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_query_phonecard_key_req(Msg)))/binary>>};
encode(#sc_prize_query_phonecard_key_reply{} = Msg) ->
    {ok,
     <<256:?INT_PROTO_ID,
       (erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_query_phonecard_key_reply(Msg)))/binary>>};
encode(#cs_task_pay_award_request{} = Msg) ->
    {ok,
     <<257:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_cs_task_pay_award_request(Msg)))/binary>>};
encode(#sc_task_pay_award_response{} = Msg) ->
    {ok,
     <<258:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_sc_task_pay_award_response(Msg)))/binary>>};
encode(#sc_task_pay_info_response{} = Msg) ->
    {ok,
     <<259:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_sc_task_pay_info_response(Msg)))/binary>>};
encode(#cs_red_pack_do_select_req{} = Msg) ->
    {ok,
     <<260:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_do_select_req(Msg)))/binary>>};
encode(#sc_red_pack_do_select_reply{} = Msg) ->
    {ok,
     <<261:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_do_select_reply(Msg)))/binary>>};
encode(#cs_red_pack_search_req{} = Msg) ->
    {ok,
     <<262:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_search_req(Msg)))/binary>>};
encode(#sc_red_pack_search_reply{} = Msg) ->
    {ok,
     <<263:?INT_PROTO_ID,
       (erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_search_reply(Msg)))/binary>>};
encode(#cs_task_pay_info_request{} = Msg) ->
    {ok,
     <<264:?INT_PROTO_ID,
       (erlang:iolist_to_binary(activity_pb:encode_cs_task_pay_info_request(Msg)))/binary>>};
encode(#cs_share_new_bee_reward_req{} = Msg) ->
    {ok,
     <<266:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_new_bee_reward_req(Msg)))/binary>>};
encode(#sc_share_new_bee_reward_reply{} = Msg) ->
    {ok,
     <<267:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_new_bee_reward_reply(Msg)))/binary>>};
encode(#cs_share_mission_reward_req{} = Msg) ->
    {ok,
     <<268:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_mission_reward_req(Msg)))/binary>>};
encode(#sc_share_mission_reward_reply{} = Msg) ->
    {ok,
     <<269:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_mission_reward_reply(Msg)))/binary>>};
encode(#sc_share_info{} = Msg) ->
    {ok,
     <<270:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_info(Msg)))/binary>>};
encode(#sc_share_mission_update{} = Msg) ->
    {ok,
     <<271:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_mission_update(Msg)))/binary>>};
encode(#cs_share_draw_request{} = Msg) ->
    {ok,
     <<272:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_draw_request(Msg)))/binary>>};
encode(#cs_share_friend_request{} = Msg) ->
    {ok,
     <<273:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_friend_request(Msg)))/binary>>};
encode(#cs_share_rank_request{} = Msg) ->
    {ok,
     <<274:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_rank_request(Msg)))/binary>>};
encode(#sc_share_draw_response{} = Msg) ->
    {ok,
     <<275:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_draw_response(Msg)))/binary>>};
encode(#sc_share_history_response{} = Msg) ->
    {ok,
     <<276:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_history_response(Msg)))/binary>>};
encode(#sc_share_rank_response{} = Msg) ->
    {ok,
     <<277:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_share_rank_response(Msg)))/binary>>};
encode(#sc_draw_count_response{} = Msg) ->
    {ok,
     <<278:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_draw_count_response(Msg)))/binary>>};
encode(#cs_car_enter_req{} = Msg) ->
    {ok,
     <<280:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_enter_req(Msg)))/binary>>};
encode(#sc_car_enter_reply{} = Msg) ->
    {ok,
     <<281:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_enter_reply(Msg)))/binary>>};
encode(#cs_car_exit_req{} = Msg) ->
    {ok,
     <<282:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_exit_req(Msg)))/binary>>};
encode(#sc_car_exit_reply{} = Msg) ->
    {ok,
     <<283:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_exit_reply(Msg)))/binary>>};
encode(#cs_car_master_req{} = Msg) ->
    {ok,
     <<284:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_master_req(Msg)))/binary>>};
encode(#sc_car_master_reply{} = Msg) ->
    {ok,
     <<285:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_master_reply(Msg)))/binary>>};
encode(#cs_car_bet_req{} = Msg) ->
    {ok,
     <<286:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_bet_req(Msg)))/binary>>};
encode(#sc_car_bet_reply{} = Msg) ->
    {ok,
     <<287:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_bet_reply(Msg)))/binary>>};
encode(#cs_car_rebet_req{} = Msg) ->
    {ok,
     <<288:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_rebet_req(Msg)))/binary>>};
encode(#sc_car_rebet_reply{} = Msg) ->
    {ok,
     <<289:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_rebet_reply(Msg)))/binary>>};
encode(#cs_car_master_list_req{} = Msg) ->
    {ok,
     <<290:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_master_list_req(Msg)))/binary>>};
encode(#cs_car_user_list_req{} = Msg) ->
    {ok,
     <<291:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_user_list_req(Msg)))/binary>>};
encode(#sc_car_user_list_reply{} = Msg) ->
    {ok,
     <<292:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_user_list_reply(Msg)))/binary>>};
encode(#sc_car_result_history_req{} = Msg) ->
    {ok,
     <<294:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_result_history_req(Msg)))/binary>>};
encode(#sc_car_master_wait_list_reply{} = Msg) ->
    {ok,
     <<295:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_master_wait_list_reply(Msg)))/binary>>};
encode(#sc_car_master_info_reply{} = Msg) ->
    {ok,
     <<296:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_master_info_reply(Msg)))/binary>>};
encode(#sc_car_status_reply{} = Msg) ->
    {ok,
     <<297:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_status_reply(Msg)))/binary>>};
encode(#sc_car_room_info_reply{} = Msg) ->
    {ok,
     <<298:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_room_info_reply(Msg)))/binary>>};
encode(#sc_car_hint_reply{} = Msg) ->
    {ok,
     <<299:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_hint_reply(Msg)))/binary>>};
encode(#sc_car_result_reply{} = Msg) ->
    {ok,
     <<300:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_result_reply(Msg)))/binary>>};
encode(#sc_car_pool_reply{} = Msg) ->
    {ok,
     <<301:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_pool_reply(Msg)))/binary>>};
encode(#cs_car_add_money_req{} = Msg) ->
    {ok,
     <<303:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_add_money_req(Msg)))/binary>>};
encode(#sc_car_add_money_reply{} = Msg) ->
    {ok,
     <<304:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_add_money_reply(Msg)))/binary>>};
encode(#cs_car_syn_in_game_state_req{} = Msg) ->
    {ok,
     <<305:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_syn_in_game_state_req(Msg)))/binary>>};
encode(#sc_task_seven_info_response{} = Msg) ->
    {ok,
     <<310:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_task_seven_info_response(Msg)))/binary>>};
encode(#cs_task_seven_award_request{} = Msg) ->
    {ok,
     <<311:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_task_seven_award_request(Msg)))/binary>>};
encode(#sc_task_seven_award_response{} = Msg) ->
    {ok,
     <<312:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_sc_task_seven_award_response(Msg)))/binary>>};
encode(#cs_share_with_friends_req{} = Msg) ->
    {ok,
     <<313:?INT_PROTO_ID,
       (erlang:iolist_to_binary(share_pb:encode_cs_share_with_friends_req(Msg)))/binary>>};
encode(#cs_super_laba_last_week_rank_query_req{} =
	   Msg) ->
    {ok,
     <<320:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_super_laba_last_week_rank_query_req(Msg)))/binary>>};
encode(#sc_super_laba_last_week_rank_query_reply{} =
	   Msg) ->
    {ok,
     <<321:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_super_laba_last_week_rank_query_reply(Msg)))/binary>>};
encode(#cs_query_last_daily_rank_reward_req{} = Msg) ->
    {ok,
     <<322:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_query_last_daily_rank_reward_req(Msg)))/binary>>};
encode(#sc_query_last_daily_rank_reward_reply{} =
	   Msg) ->
    {ok,
     <<323:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_query_last_daily_rank_reward_reply(Msg)))/binary>>};
encode(#sc_player_stickiness_redpack_info_notify{} =
	   Msg) ->
    {ok,
     <<324:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_stickiness_redpack_info_notify(Msg)))/binary>>};
encode(#cs_stickiness_redpack_draw_req{} =
	   Msg) ->
    {ok,
     <<325:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_stickiness_redpack_draw_req(Msg)))/binary>>};
encode(#sc_stickiness_redpack_draw_resp{} =
	   Msg) ->
    {ok,
     <<326:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_stickiness_redpack_draw_resp(Msg)))/binary>>};
encode(#cs_player_stickiness_redpack_info_notify_req{} =
	   Msg) ->
    {ok,
     <<327:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_stickiness_redpack_info_notify_req(Msg)))/binary>>};
encode(#sc_period_card_info_update{} =
	   Msg) ->
    {ok,
     <<328:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_period_card_info_update(Msg)))/binary>>};
encode(#cs_period_card_draw_req{} =
	   Msg) ->
    {ok,
     <<329:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_cs_period_card_draw_req(Msg)))/binary>>};
encode(#sc_period_card_draw_reply{} =
	   Msg) ->
    {ok,
     <<330:?INT_PROTO_ID,
       (erlang:iolist_to_binary(shop_pb:encode_sc_period_card_draw_reply(Msg)))/binary>>};
encode(#sc_car_query_pool_win_player_reply{} =
	   Msg) ->
    {ok,
     <<331:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_sc_car_query_pool_win_player_reply(Msg)))/binary>>};
encode(#cs_car_query_pool_win_player_req{} =
	   Msg) ->
    {ok,
     <<332:?INT_PROTO_ID,
       (erlang:iolist_to_binary(car_pb:encode_cs_car_query_pool_win_player_req(Msg)))/binary>>};
encode(#sc_player_bet_stickiness_notify{} =
	   Msg) ->
    {ok,
     <<333:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_bet_stickiness_notify(Msg)))/binary>>};
encode(#cs_player_bet_stickiness_redpack_draw_req{} =
	   Msg) ->
    {ok,
     <<334:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_bet_stickiness_redpack_draw_req(Msg)))/binary>>};
encode(#sc_player_bet_stickiness_redpack_draw_resp{} =
	   Msg) ->
    {ok,
     <<335:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_bet_stickiness_redpack_draw_resp(Msg)))/binary>>};
encode(#cs_bet_lock_config_req{} =
	   Msg) ->
    {ok,
     <<336:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_bet_lock_config_req(Msg)))/binary>>};
encode(#sc_bet_lock_config_resp{} =
	   Msg) ->
    {ok,
     <<337:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_bet_lock_config_resp(Msg)))/binary>>};
encode(#sc_bet_lock_update_notify{} =
	   Msg) ->
    {ok,
     <<338:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_bet_lock_update_notify(Msg)))/binary>>};
encode(#cs_player_salary_query_req {} = Msg) ->
    {ok, <<339:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_player_salary_query_req(Msg)))/binary>>};
encode(#sc_player_salary_query_resp {} = Msg) ->
    {ok, <<340:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_player_salary_query_resp(Msg)))/binary>>};
encode(#cs_airlaba_enter_room_req {} = Msg) ->
    {ok, <<341:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_enter_room_req(Msg)))/binary>>};
encode(#sc_airlaba_enter_room_reply {} = Msg) ->
    {ok, <<342:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_enter_room_reply(Msg)))/binary>>};
encode(#cs_airlaba_leave_room_req {} = Msg) ->
    {ok, <<343:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_leave_room_req(Msg)))/binary>>};
encode(#sc_airlaba_leave_room_reply {} = Msg) ->
    {ok, <<344:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_leave_room_reply(Msg)))/binary>>};
encode(#cs_airlaba_fire_bet_req {} = Msg) ->
    {ok, <<345:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_fire_bet_req(Msg)))/binary>>};
encode(#sc_airlaba_fire_bet_reply {} = Msg) ->
    {ok, <<346:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_fire_bet_reply(Msg)))/binary>>};
encode(#cs_airlaba_switch_phase_req {} = Msg) ->
    {ok, <<347:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_switch_phase_req(Msg)))/binary>>};
encode(#sc_airlaba_switch_phase_reply {} = Msg) ->
    {ok, <<348:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_switch_phase_reply(Msg)))/binary>>};
encode(#sc_airlaba_pool_num_update {} = Msg) ->
    {ok, <<349:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_pool_num_update(Msg)))/binary>>};
encode(#cs_airlaba_use_item_req {} = Msg) ->
    {ok, <<350:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_use_item_req(Msg)))/binary>>};
encode(#sc_airlaba_use_item_reply {} = Msg) ->
    {ok, <<351:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_use_item_reply(Msg)))/binary>>};
encode(#cs_airlaba_impov_sub_req {} = Msg) ->
    {ok, <<352:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_impov_sub_req(Msg)))/binary>>};
encode(#sc_airlaba_impov_sub_reply {} = Msg) ->
    {ok, <<353:?INT_PROTO_ID,
       (erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_impov_sub_reply(Msg)))/binary>>};
encode(#cs_lottery_draw_req {} = Msg) ->
    {ok, <<354:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_cs_lottery_draw_req(Msg)))/binary>>};
encode(#sc_lottery_draw_resp {} = Msg) ->
    {ok, <<355:?INT_PROTO_ID,
       (erlang:iolist_to_binary(player_pb:encode_sc_lottery_draw_resp(Msg)))/binary>>};
encode(_) -> error.

decode(<<1:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_cs_login(B)};
decode(<<2:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_sc_login_reply(B)};
decode(<<3:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_cs_login_out(B)};
decode(<<4:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_cs_login_reconnection(B)};
decode(<<5:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_sc_login_reconnection_reply(B)};
decode(<<6:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_sc_login_repeat(B)};
decode(<<7:?INT_PROTO_ID, B/binary>>) ->
    {ok, login_pb:decode_sc_login_proto_complete(B)};
decode(<<8:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_cs_common_heartbeat(B)};
decode(<<9:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_sc_common_heartbeat_reply(B)};
decode(<<10:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_cs_common_proto_count(B)};
decode(<<11:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_sc_common_proto_count(B)};
decode(<<12:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_cs_common_proto_clean(B)};
decode(<<13:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_sc_common_proto_clean(B)};
decode(<<14:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_player_base_info(B)};
decode(<<15:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_player_change_name_req(B)};
decode(<<16:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_player_change_name_reply(B)};
decode(<<17:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_player_change_headicon_req(B)};
decode(<<18:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_change_headicon_reply(B)};
decode(<<19:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_player_chat(B)};
decode(<<20:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_player_chat(B)};
decode(<<21:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_player_sys_notice(B)};
decode(<<22:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_tips(B)};
decode(<<23:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_query_player_winning_rec_req(B)};
decode(<<24:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_query_player_winning_rec_reply(B)};
decode(<<25:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_niu_query_in_game_player_num_req(B)};
decode(<<26:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_niu_query_in_game_player_num_reply(B)};
decode(<<28:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_cs_common_bug_feedback(B)};
decode(<<29:?INT_PROTO_ID, B/binary>>) ->
    {ok, common_pb:decode_sc_common_bug_feedback(B)};
decode(<<30:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_sc_items_update(B)};
decode(<<31:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_sc_items_add(B)};
decode(<<32:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_sc_items_delete(B)};
decode(<<33:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_sc_items_init_update(B)};
decode(<<34:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_cs_item_use_req(B)};
decode(<<35:?INT_PROTO_ID, B/binary>>) ->
    {ok, item_pb:decode_sc_item_use_reply(B)};
decode(<<40:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_sc_mails_init_update(B)};
decode(<<41:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_sc_mail_add(B)};
decode(<<42:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_cs_mail_delete_request(B)};
decode(<<43:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_sc_mail_delete_reply(B)};
decode(<<44:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_cs_read_mail(B)};
decode(<<45:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_cs_mail_draw_request(B)};
decode(<<46:?INT_PROTO_ID, B/binary>>) ->
    {ok, mail_pb:decode_sc_mail_draw_reply(B)};
decode(<<50:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_niu_room_state_update(B)};
decode(<<51:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_niu_enter_room_req(B)};
decode(<<52:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_niu_enter_room_reply(B)};
decode(<<53:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_enter_room_player_info_update(B)};
decode(<<54:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_cs_niu_choose_master_rate_req(B)};
decode(<<55:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_choose_master_rate_reply(B)};
decode(<<56:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_choose_master_rate_update(B)};
decode(<<57:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_niu_choose_free_rate_req(B)};
decode(<<58:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_choose_free_rate_reply(B)};
decode(<<59:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_choose_free_rate_update(B)};
decode(<<60:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_niu_leave_room_req(B)};
decode(<<61:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_niu_leave_room_reply(B)};
decode(<<62:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_leave_room_player_pos_update(B)};
decode(<<63:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_niu_submit_card_req(B)};
decode(<<64:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_niu_submit_card_reply(B)};
decode(<<65:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_submit_card_update(B)};
decode(<<66:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_cs_niu_syn_in_game_state_req(B)};
decode(<<67:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_room_info_update(B)};
decode(<<68:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_back_to_room_info_update(B)};
decode(<<69:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_niu_subsidy_req(B)};
decode(<<70:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_niu_subsidy_reply(B)};
decode(<<71:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_niu_subsidy_info_update(B)};
decode(<<72:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_cs_niu_query_player_room_info_req(B)};
decode(<<73:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_niu_special_subsidy_share(B)};
decode(<<74:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_niu_special_subsidy_share(B)};
decode(<<75:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_daily_checkin_req(B)};
decode(<<76:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_daily_checkin_reply(B)};
decode(<<77:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_daily_checkin_info_update(B)};
decode(<<78:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_make_up_for_checkin_req(B)};
decode(<<80:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_shop_all_item_base_config(B)};
decode(<<81:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_cs_shop_buy_query(B)};
decode(<<82:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_shop_buy_reply(B)};
decode(<<83:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_golden_bull_info_update(B)};
decode(<<84:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_cs_golden_bull_draw_req(B)};
decode(<<85:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_golden_bull_draw_reply(B)};
decode(<<86:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_month_card_info_update(B)};
decode(<<87:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_cs_month_card_draw_req(B)};
decode(<<88:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_month_card_draw_reply(B)};
decode(<<90:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_room_state_update(B)};
decode(<<91:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_enter_room_req(B)};
decode(<<92:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_enter_room_reply(B)};
decode(<<93:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_player_list_query_req(B)};
decode(<<94:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_player_list_query_reply(B)};
decode(<<95:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_free_set_chips_req(B)};
decode(<<96:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_free_set_chips_reply(B)};
decode(<<97:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_free_set_chips_update(B)};
decode(<<98:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_sit_down_req(B)};
decode(<<99:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_sit_down_reply(B)};
decode(<<100:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_seat_player_info_update(B)};
decode(<<101:?INT_PROTO_ID, B/binary>>) ->
    {ok, hundred_niu_pb:decode_cs_hundred_be_master_req(B)};
decode(<<102:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_be_master_reply(B)};
decode(<<103:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_master_list_req(B)};
decode(<<104:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_master_list_reply(B)};
decode(<<105:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_in_game_syn_req(B)};
decode(<<106:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_leave_room_req(B)};
decode(<<107:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_leave_room_reply(B)};
decode(<<108:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_winning_rec_req(B)};
decode(<<109:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_winning_rec_reply(B)};
decode(<<110:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_cs_draw_mission_request(B)};
decode(<<111:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_draw_mission_result_reply(B)};
decode(<<112:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_mission(B)};
decode(<<113:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_mission_update(B)};
decode(<<114:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_mission_add(B)};
decode(<<115:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_mission_del(B)};
decode(<<120:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_player_gold_change_update(B)};
decode(<<121:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_pool_win_player_req(B)};
decode(<<122:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_pool_win_player_reply(B)};
decode(<<123:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_rank_query_req(B)};
decode(<<124:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_rank_qurey_reply(B)};
decode(<<130:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_cs_cash_transformation_req(B)};
decode(<<131:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_cash_transformation_reply(B)};
decode(<<132:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_cs_golden_bull_mission(B)};
decode(<<133:?INT_PROTO_ID, B/binary>>) ->
    {ok, shop_pb:decode_sc_golden_bull_mission(B)};
decode(<<140:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_phone_num_info_update(B)};
decode(<<141:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_player_bind_phone_num(B)};
decode(<<142:?INT_PROTO_ID, B/binary>>) ->
    {ok, chest_pb:decode_cs_player_niu_room_chest_draw(B)};
decode(<<143:?INT_PROTO_ID, B/binary>>) ->
    {ok, chest_pb:decode_sc_niu_room_chest_draw_reply(B)};
decode(<<144:?INT_PROTO_ID, B/binary>>) ->
    {ok, chest_pb:decode_sc_niu_room_chest_info_update(B)};
decode(<<145:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_player_bind_phone_num_draw(B)};
decode(<<146:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_bind_phone_num_draw_reply(B)};
decode(<<147:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_niu_special_subsidy_info_update(B)};
decode(<<148:?INT_PROTO_ID, B/binary>>) ->
    {ok, chest_pb:decode_sc_niu_room_chest_times_update(B)};
decode(<<150:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_guide_info_update(B)};
decode(<<151:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_guide_next_step_req(B)};
decode(<<152:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_guide_next_step_reply(B)};
decode(<<153:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_hundred_last_week_rank_query_req(B)};
decode(<<154:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_hundred_last_week_rank_query_reply(B)};
decode(<<155:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_real_name_update(B)};
decode(<<156:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_real_name_update(B)};
decode(<<157:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_real_name_req(B)};
decode(<<158:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_real_name_req(B)};
decode(<<160:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_reset_times_update(B)};
decode(<<161:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_player_times_update(B)};
decode(<<162:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_redpack_notice_update(B)};
decode(<<163:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_redpack_room_draw_req(B)};
decode(<<164:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_redpack_room_draw_reply(B)};
decode(<<165:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     niu_game_pb:decode_sc_redpack_redpack_timer_sec_update(B)};
decode(<<166:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_cs_redpack_relive_req(B)};
decode(<<167:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_redpack_relive_reply(B)};
decode(<<168:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_redpack_relive_times(B)};
decode(<<169:?INT_PROTO_ID, B/binary>>) ->
    {ok, niu_game_pb:decode_sc_fudai_pool_update(B)};
decode(<<201:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_cs_laba_enter_room_req(B)};
decode(<<202:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_sc_laba_enter_room_reply(B)};
decode(<<203:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_cs_laba_leave_room_req(B)};
decode(<<204:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_sc_laba_leave_room_reply(B)};
decode(<<205:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_sc_laba_pool_num_update(B)};
decode(<<206:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_cs_laba_spin_req(B)};
decode(<<207:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_sc_laba_spin_reply(B)};
decode(<<208:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_game_task_info_update(B)};
decode(<<209:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_game_task_box_info_update(B)};
decode(<<210:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_cs_game_task_draw_req(B)};
decode(<<211:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_game_task_draw_reply(B)};
decode(<<212:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_cs_game_task_box_draw_req(B)};
decode(<<213:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_game_task_box_draw_reply(B)};
decode(<<214:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     mission_pb:decode_sc_redpack_task_draw_list_update(B)};
decode(<<215:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_cs_redpack_task_draw_req(B)};
decode(<<216:?INT_PROTO_ID, B/binary>>) ->
    {ok, mission_pb:decode_sc_redpack_task_draw_reply(B)};
decode(<<217:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_cs_win_player_list(B)};
decode(<<218:?INT_PROTO_ID, B/binary>>) ->
    {ok, laba_pb:decode_sc_win_player_list(B)};
decode(<<220:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_query_list_req(B)};
decode(<<221:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_query_list_reply(B)};
decode(<<222:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_open_req(B)};
decode(<<223:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_open_reply(B)};
decode(<<224:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_create_req(B)};
decode(<<225:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_create_reply(B)};
decode(<<226:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_notice_update(B)};
decode(<<227:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_cancel_req(B)};
decode(<<228:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_cancel_reply(B)};
decode(<<229:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_self_red_pack_info(B)};
decode(<<230:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_config_update(B)};
decode(<<231:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_query_one_req(B)};
decode(<<232:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_query_one_reply(B)};
decode(<<233:?INT_PROTO_ID, B/binary>>) ->
    {ok, prize_exchange_pb:decode_cs_prize_exchange_req(B)};
decode(<<234:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_exchange_reply(B)};
decode(<<235:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_exchange_record_update(B)};
decode(<<236:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_address_info_update(B)};
decode(<<237:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_address_change_req(B)};
decode(<<238:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_address_change_reply(B)};
decode(<<239:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_storage_red_point_update(B)};
decode(<<240:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_vip_daily_reward(B)};
decode(<<241:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_sc_vip_daily_reward(B)};
decode(<<250:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     activity_pb:decode_sc_activity_config_info_update(B)};
decode(<<251:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_cs_activity_info_query_req(B)};
decode(<<252:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     activity_pb:decode_sc_activity_info_query_reply(B)};
decode(<<253:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_cs_activity_draw_req(B)};
decode(<<254:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_sc_activity_draw_reply(B)};
decode(<<255:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_query_phonecard_key_req(B)};
decode(<<256:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_query_phonecard_key_reply(B)};
decode(<<257:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_cs_task_pay_award_request(B)};
decode(<<258:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_sc_task_pay_award_response(B)};
decode(<<259:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_sc_task_pay_info_response(B)};
decode(<<260:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_do_select_req(B)};
decode(<<261:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_do_select_reply(B)};
decode(<<262:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_cs_red_pack_search_req(B)};
decode(<<263:?INT_PROTO_ID, B/binary>>) ->
    {ok, red_pack_pb:decode_sc_red_pack_search_reply(B)};
decode(<<264:?INT_PROTO_ID, B/binary>>) ->
    {ok, activity_pb:decode_cs_task_pay_info_request(B)};
decode(<<266:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_new_bee_reward_req(B)};
decode(<<267:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_new_bee_reward_reply(B)};
decode(<<268:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_mission_reward_req(B)};
decode(<<269:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_mission_reward_reply(B)};
decode(<<270:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_info(B)};
decode(<<271:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_mission_update(B)};
decode(<<272:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_draw_request(B)};
decode(<<273:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_friend_request(B)};
decode(<<274:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_rank_request(B)};
decode(<<275:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_draw_response(B)};
decode(<<276:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_history_response(B)};
decode(<<277:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_share_rank_response(B)};
decode(<<278:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_draw_count_response(B)};
decode(<<280:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_enter_req(B)};
decode(<<281:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_enter_reply(B)};
decode(<<282:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_exit_req(B)};
decode(<<283:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_exit_reply(B)};
decode(<<284:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_master_req(B)};
decode(<<285:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_master_reply(B)};
decode(<<286:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_bet_req(B)};
decode(<<287:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_bet_reply(B)};
decode(<<288:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_rebet_req(B)};
decode(<<289:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_rebet_reply(B)};
decode(<<290:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_master_list_req(B)};
decode(<<291:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_user_list_req(B)};
decode(<<292:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_user_list_reply(B)};
decode(<<294:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_result_history_req(B)};
decode(<<295:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_master_wait_list_reply(B)};
decode(<<296:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_master_info_reply(B)};
decode(<<297:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_status_reply(B)};
decode(<<298:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_room_info_reply(B)};
decode(<<299:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_hint_reply(B)};
decode(<<300:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_result_reply(B)};
decode(<<301:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_pool_reply(B)};
decode(<<303:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_add_money_req(B)};
decode(<<304:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_sc_car_add_money_reply(B)};
decode(<<305:?INT_PROTO_ID, B/binary>>) ->
    {ok, car_pb:decode_cs_car_syn_in_game_state_req(B)};
decode(<<310:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_task_seven_info_response(B)};
decode(<<311:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_task_seven_award_request(B)};
decode(<<312:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_sc_task_seven_award_response(B)};
decode(<<313:?INT_PROTO_ID, B/binary>>) ->
    {ok, share_pb:decode_cs_share_with_friends_req(B)};
decode(<<320:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_super_laba_last_week_rank_query_req(B)};
decode(<<321:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_super_laba_last_week_rank_query_reply(B)};
decode(<<322:?INT_PROTO_ID, B/binary>>) ->
    {ok, player_pb:decode_cs_query_last_daily_rank_reward_req(B)};
decode(<<323:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_query_last_daily_rank_reward_reply(B)};
decode(<<324:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_stickiness_redpack_info_notify(B)};
decode(<<325:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_stickiness_redpack_draw_req(B)};
decode(<<326:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_stickiness_redpack_draw_resp(B)};
decode(<<327:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_player_stickiness_redpack_info_notify_req(B)};
decode(<<328:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     shop_pb:decode_sc_period_card_info_update(B)};
decode(<<329:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     shop_pb:decode_cs_period_card_draw_req(B)};
decode(<<330:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     shop_pb:decode_sc_period_card_draw_reply(B)};
decode(<<331:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     car_pb:decode_sc_car_query_pool_win_player_reply(B)};
decode(<<332:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     car_pb:decode_cs_car_query_pool_win_player_req(B)};
decode(<<333:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_bet_stickiness_notify(B)};
decode(<<334:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_player_bet_stickiness_redpack_draw_req(B)};
decode(<<335:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_bet_stickiness_redpack_draw_resp(B)};
decode(<<336:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_bet_lock_config_req(B)};
decode(<<337:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_bet_lock_config_resp(B)};
decode(<<338:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_bet_lock_update_notify(B)};
decode(<<339:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_cs_player_salary_query_req(B)};
decode(<<340:?INT_PROTO_ID, B/binary>>) ->
    {ok,
     player_pb:decode_sc_player_salary_query_resp(B)};
decode(<<341:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_enter_room_req(B)};
decode(<<342:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_enter_room_reply(B)};
decode(<<343:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_leave_room_req(B)};
decode(<<344:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_leave_room_reply(B)};
decode(<<345:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_fire_bet_req(B)};
decode(<<346:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_fire_bet_reply(B)};
decode(<<347:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_switch_phase_req(B)};
decode(<<348:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_switch_phase_reply(B)};
decode(<<349:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_pool_num_update(B)};
decode(<<350:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_use_item_req(B)};
decode(<<351:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_use_item_reply(B)};
decode(<<352:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_cs_airlaba_impov_sub_req(B)};
decode(<<353:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    laba_pb:decode_sc_airlaba_impov_sub_reply(B)};
decode(<<354:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    player_pb:decode_cs_lottery_draw_req(B)};
decode(<<355:?INT_PROTO_ID, B/binary>>) ->
    {ok,
    player_pb:decode_sc_lottery_draw_resp(B)};
decode(_) -> error.

encode_msg_bin(#cs_login{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_cs_login(Msg))};
encode_msg_bin(#sc_login_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_sc_login_reply(Msg))};
encode_msg_bin(#cs_login_out{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_cs_login_out(Msg))};
encode_msg_bin(#cs_login_reconnection{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_cs_login_reconnection(Msg))};
encode_msg_bin(#sc_login_reconnection_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_sc_login_reconnection_reply(Msg))};
encode_msg_bin(#sc_login_repeat{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_sc_login_repeat(Msg))};
encode_msg_bin(#sc_login_proto_complete{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(login_pb:encode_sc_login_proto_complete(Msg))};
encode_msg_bin(#cs_common_heartbeat{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_cs_common_heartbeat(Msg))};
encode_msg_bin(#sc_common_heartbeat_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_sc_common_heartbeat_reply(Msg))};
encode_msg_bin(#cs_common_proto_count{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_cs_common_proto_count(Msg))};
encode_msg_bin(#sc_common_proto_count{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_sc_common_proto_count(Msg))};
encode_msg_bin(#cs_common_proto_clean{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_cs_common_proto_clean(Msg))};
encode_msg_bin(#sc_common_proto_clean{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_sc_common_proto_clean(Msg))};
encode_msg_bin(#sc_player_base_info{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_base_info(Msg))};
encode_msg_bin(#cs_player_change_name_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_change_name_req(Msg))};
encode_msg_bin(#sc_player_change_name_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_change_name_reply(Msg))};
encode_msg_bin(#cs_player_change_headicon_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_change_headicon_req(Msg))};
encode_msg_bin(#sc_player_change_headicon_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_change_headicon_reply(Msg))};
encode_msg_bin(#cs_player_chat{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_chat(Msg))};
encode_msg_bin(#sc_player_chat{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_chat(Msg))};
encode_msg_bin(#sc_player_sys_notice{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_sys_notice(Msg))};
encode_msg_bin(#sc_tips{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_tips(Msg))};
encode_msg_bin(#cs_query_player_winning_rec_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_query_player_winning_rec_req(Msg))};
encode_msg_bin(#sc_query_player_winning_rec_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_query_player_winning_rec_reply(Msg))};
encode_msg_bin(#cs_niu_query_in_game_player_num_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_niu_query_in_game_player_num_req(Msg))};
encode_msg_bin(#sc_niu_query_in_game_player_num_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_niu_query_in_game_player_num_reply(Msg))};
encode_msg_bin(#cs_common_bug_feedback{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_cs_common_bug_feedback(Msg))};
encode_msg_bin(#sc_common_bug_feedback{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(common_pb:encode_sc_common_bug_feedback(Msg))};
encode_msg_bin(#sc_items_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_sc_items_update(Msg))};
encode_msg_bin(#sc_items_add{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_sc_items_add(Msg))};
encode_msg_bin(#sc_items_delete{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_sc_items_delete(Msg))};
encode_msg_bin(#sc_items_init_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_sc_items_init_update(Msg))};
encode_msg_bin(#cs_item_use_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_cs_item_use_req(Msg))};
encode_msg_bin(#sc_item_use_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(item_pb:encode_sc_item_use_reply(Msg))};
encode_msg_bin(#sc_mails_init_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_sc_mails_init_update(Msg))};
encode_msg_bin(#sc_mail_add{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_sc_mail_add(Msg))};
encode_msg_bin(#cs_mail_delete_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_cs_mail_delete_request(Msg))};
encode_msg_bin(#sc_mail_delete_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_sc_mail_delete_reply(Msg))};
encode_msg_bin(#cs_read_mail{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_cs_read_mail(Msg))};
encode_msg_bin(#cs_mail_draw_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_cs_mail_draw_request(Msg))};
encode_msg_bin(#sc_mail_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mail_pb:encode_sc_mail_draw_reply(Msg))};
encode_msg_bin(#sc_niu_room_state_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_room_state_update(Msg))};
encode_msg_bin(#cs_niu_enter_room_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_enter_room_req(Msg))};
encode_msg_bin(#sc_niu_enter_room_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_enter_room_reply(Msg))};
encode_msg_bin(#sc_niu_enter_room_player_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_enter_room_player_info_update(Msg))};
encode_msg_bin(#cs_niu_choose_master_rate_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_choose_master_rate_req(Msg))};
encode_msg_bin(#sc_niu_choose_master_rate_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_choose_master_rate_reply(Msg))};
encode_msg_bin(#sc_niu_player_choose_master_rate_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_choose_master_rate_update(Msg))};
encode_msg_bin(#cs_niu_choose_free_rate_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_choose_free_rate_req(Msg))};
encode_msg_bin(#sc_niu_choose_free_rate_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_choose_free_rate_reply(Msg))};
encode_msg_bin(#sc_niu_player_choose_free_rate_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_choose_free_rate_update(Msg))};
encode_msg_bin(#cs_niu_leave_room_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_leave_room_req(Msg))};
encode_msg_bin(#sc_niu_leave_room_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_leave_room_reply(Msg))};
encode_msg_bin(#sc_niu_leave_room_player_pos_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_leave_room_player_pos_update(Msg))};
encode_msg_bin(#cs_niu_submit_card_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_submit_card_req(Msg))};
encode_msg_bin(#sc_niu_submit_card_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_submit_card_reply(Msg))};
encode_msg_bin(#sc_niu_player_submit_card_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_submit_card_update(Msg))};
encode_msg_bin(#cs_niu_syn_in_game_state_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_syn_in_game_state_req(Msg))};
encode_msg_bin(#sc_niu_player_room_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_room_info_update(Msg))};
encode_msg_bin(#sc_niu_player_back_to_room_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_niu_player_back_to_room_info_update(Msg))};
encode_msg_bin(#cs_niu_subsidy_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_niu_subsidy_req(Msg))};
encode_msg_bin(#sc_niu_subsidy_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_niu_subsidy_reply(Msg))};
encode_msg_bin(#sc_niu_subsidy_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_niu_subsidy_info_update(Msg))};
encode_msg_bin(#cs_niu_query_player_room_info_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_niu_query_player_room_info_req(Msg))};
encode_msg_bin(#cs_niu_special_subsidy_share{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_niu_special_subsidy_share(Msg))};
encode_msg_bin(#sc_niu_special_subsidy_share{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_niu_special_subsidy_share(Msg))};
encode_msg_bin(#cs_daily_checkin_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_daily_checkin_req(Msg))};
encode_msg_bin(#sc_daily_checkin_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_daily_checkin_reply(Msg))};
encode_msg_bin(#sc_daily_checkin_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_daily_checkin_info_update(Msg))};
encode_msg_bin(#cs_make_up_for_checkin_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_make_up_for_checkin_req(Msg))};
encode_msg_bin(#sc_shop_all_item_base_config{} = Msg) ->
    {ok, 1,
     erlang:iolist_to_binary(shop_pb:encode_sc_shop_all_item_base_config(Msg))};
encode_msg_bin(#cs_shop_buy_query{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_shop_buy_query(Msg))};
encode_msg_bin(#sc_shop_buy_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_shop_buy_reply(Msg))};
encode_msg_bin(#sc_golden_bull_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_info_update(Msg))};
encode_msg_bin(#cs_golden_bull_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_golden_bull_draw_req(Msg))};
encode_msg_bin(#sc_golden_bull_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_draw_reply(Msg))};
encode_msg_bin(#sc_month_card_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_month_card_info_update(Msg))};
encode_msg_bin(#cs_month_card_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_month_card_draw_req(Msg))};
encode_msg_bin(#sc_month_card_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_month_card_draw_reply(Msg))};
encode_msg_bin(#sc_hundred_niu_room_state_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_room_state_update(Msg))};
encode_msg_bin(#cs_hundred_niu_enter_room_req{} =
		   Msg) ->
    {ok, 1,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_enter_room_req(Msg))};
encode_msg_bin(#sc_hundred_niu_enter_room_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_enter_room_reply(Msg))};
encode_msg_bin(#cs_hundred_niu_player_list_query_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_player_list_query_req(Msg))};
encode_msg_bin(#sc_hundred_niu_player_list_query_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_player_list_query_reply(Msg))};
encode_msg_bin(#cs_hundred_niu_free_set_chips_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_free_set_chips_req(Msg))};
encode_msg_bin(#sc_hundred_niu_free_set_chips_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_free_set_chips_reply(Msg))};
encode_msg_bin(#sc_hundred_niu_free_set_chips_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_free_set_chips_update(Msg))};
encode_msg_bin(#cs_hundred_niu_sit_down_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_sit_down_req(Msg))};
encode_msg_bin(#sc_hundred_niu_sit_down_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_sit_down_reply(Msg))};
encode_msg_bin(#sc_hundred_niu_seat_player_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_niu_seat_player_info_update(Msg))};
encode_msg_bin(#cs_hundred_be_master_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_be_master_req(Msg))};
encode_msg_bin(#sc_hundred_be_master_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_be_master_reply(Msg))};
encode_msg_bin(#cs_hundred_query_master_list_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_master_list_req(Msg))};
encode_msg_bin(#sc_hundred_query_master_list_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_master_list_reply(Msg))};
encode_msg_bin(#cs_hundred_niu_in_game_syn_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_niu_in_game_syn_req(Msg))};
encode_msg_bin(#cs_hundred_leave_room_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_leave_room_req(Msg))};
encode_msg_bin(#sc_hundred_leave_room_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_leave_room_reply(Msg))};
encode_msg_bin(#cs_hundred_query_winning_rec_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_winning_rec_req(Msg))};
encode_msg_bin(#sc_hundred_query_winning_rec_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_winning_rec_reply(Msg))};
encode_msg_bin(#cs_draw_mission_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_cs_draw_mission_request(Msg))};
encode_msg_bin(#sc_draw_mission_result_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_draw_mission_result_reply(Msg))};
encode_msg_bin(#sc_mission{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_mission(Msg))};
encode_msg_bin(#sc_mission_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_mission_update(Msg))};
encode_msg_bin(#sc_mission_add{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_mission_add(Msg))};
encode_msg_bin(#sc_mission_del{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_mission_del(Msg))};
encode_msg_bin(#sc_hundred_player_gold_change_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_player_gold_change_update(Msg))};
encode_msg_bin(#cs_hundred_query_pool_win_player_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_cs_hundred_query_pool_win_player_req(Msg))};
encode_msg_bin(#sc_hundred_query_pool_win_player_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(hundred_niu_pb:encode_sc_hundred_query_pool_win_player_reply(Msg))};
encode_msg_bin(#cs_rank_query_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_rank_query_req(Msg))};
encode_msg_bin(#sc_rank_qurey_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_rank_qurey_reply(Msg))};
encode_msg_bin(#cs_cash_transformation_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_cash_transformation_req(Msg))};
encode_msg_bin(#sc_cash_transformation_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_cash_transformation_reply(Msg))};
encode_msg_bin(#cs_golden_bull_mission{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_golden_bull_mission(Msg))};
encode_msg_bin(#sc_golden_bull_mission{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_golden_bull_mission(Msg))};
encode_msg_bin(#sc_player_phone_num_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_phone_num_info_update(Msg))};
encode_msg_bin(#sc_player_bind_phone_num{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_bind_phone_num(Msg))};
encode_msg_bin(#cs_player_niu_room_chest_draw{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(chest_pb:encode_cs_player_niu_room_chest_draw(Msg))};
encode_msg_bin(#sc_niu_room_chest_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_draw_reply(Msg))};
encode_msg_bin(#sc_niu_room_chest_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_info_update(Msg))};
encode_msg_bin(#cs_player_bind_phone_num_draw{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_bind_phone_num_draw(Msg))};
encode_msg_bin(#sc_player_bind_phone_num_draw_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_bind_phone_num_draw_reply(Msg))};
encode_msg_bin(#sc_niu_special_subsidy_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_niu_special_subsidy_info_update(Msg))};
encode_msg_bin(#sc_niu_room_chest_times_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(chest_pb:encode_sc_niu_room_chest_times_update(Msg))};
encode_msg_bin(#sc_guide_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_guide_info_update(Msg))};
encode_msg_bin(#cs_guide_next_step_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_guide_next_step_req(Msg))};
encode_msg_bin(#sc_guide_next_step_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_guide_next_step_reply(Msg))};
encode_msg_bin(#cs_hundred_last_week_rank_query_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_hundred_last_week_rank_query_req(Msg))};
encode_msg_bin(#sc_hundred_last_week_rank_query_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_hundred_last_week_rank_query_reply(Msg))};
encode_msg_bin(#cs_real_name_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_real_name_update(Msg))};
encode_msg_bin(#sc_real_name_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_real_name_update(Msg))};
encode_msg_bin(#cs_real_name_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_real_name_req(Msg))};
encode_msg_bin(#sc_real_name_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_real_name_req(Msg))};
encode_msg_bin(#sc_redpack_room_reset_times_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_reset_times_update(Msg))};
encode_msg_bin(#sc_redpack_room_player_times_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_player_times_update(Msg))};
encode_msg_bin(#sc_redpack_room_redpack_notice_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_redpack_notice_update(Msg))};
encode_msg_bin(#cs_redpack_room_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_redpack_room_draw_req(Msg))};
encode_msg_bin(#sc_redpack_room_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_room_draw_reply(Msg))};
encode_msg_bin(#sc_redpack_redpack_timer_sec_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_redpack_timer_sec_update(Msg))};
encode_msg_bin(#cs_redpack_relive_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_cs_redpack_relive_req(Msg))};
encode_msg_bin(#sc_redpack_relive_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_relive_reply(Msg))};
encode_msg_bin(#sc_redpack_relive_times{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_redpack_relive_times(Msg))};
encode_msg_bin(#sc_fudai_pool_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(niu_game_pb:encode_sc_fudai_pool_update(Msg))};
encode_msg_bin(#cs_laba_enter_room_req{} = Msg) ->
    {ok, 1,
     erlang:iolist_to_binary(laba_pb:encode_cs_laba_enter_room_req(Msg))};
encode_msg_bin(#sc_laba_enter_room_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_laba_enter_room_reply(Msg))};
encode_msg_bin(#cs_laba_leave_room_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_laba_leave_room_req(Msg))};
encode_msg_bin(#sc_laba_leave_room_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_laba_leave_room_reply(Msg))};
encode_msg_bin(#sc_laba_pool_num_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_laba_pool_num_update(Msg))};
encode_msg_bin(#cs_laba_spin_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_laba_spin_req(Msg))};
encode_msg_bin(#sc_laba_spin_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_laba_spin_reply(Msg))};
encode_msg_bin(#sc_game_task_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_game_task_info_update(Msg))};
encode_msg_bin(#sc_game_task_box_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_game_task_box_info_update(Msg))};
encode_msg_bin(#cs_game_task_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_cs_game_task_draw_req(Msg))};
encode_msg_bin(#sc_game_task_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_game_task_draw_reply(Msg))};
encode_msg_bin(#cs_game_task_box_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_cs_game_task_box_draw_req(Msg))};
encode_msg_bin(#sc_game_task_box_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_game_task_box_draw_reply(Msg))};
encode_msg_bin(#sc_redpack_task_draw_list_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_redpack_task_draw_list_update(Msg))};
encode_msg_bin(#cs_redpack_task_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_cs_redpack_task_draw_req(Msg))};
encode_msg_bin(#sc_redpack_task_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(mission_pb:encode_sc_redpack_task_draw_reply(Msg))};
encode_msg_bin(#cs_win_player_list{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_win_player_list(Msg))};
encode_msg_bin(#sc_win_player_list{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_win_player_list(Msg))};
encode_msg_bin(#cs_red_pack_query_list_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_query_list_req(Msg))};
encode_msg_bin(#sc_red_pack_query_list_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_query_list_reply(Msg))};
encode_msg_bin(#cs_red_pack_open_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_open_req(Msg))};
encode_msg_bin(#sc_red_pack_open_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_open_reply(Msg))};
encode_msg_bin(#cs_red_pack_create_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_create_req(Msg))};
encode_msg_bin(#sc_red_pack_create_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_create_reply(Msg))};
encode_msg_bin(#sc_red_pack_notice_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_notice_update(Msg))};
encode_msg_bin(#cs_red_pack_cancel_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_cancel_req(Msg))};
encode_msg_bin(#sc_red_pack_cancel_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_cancel_reply(Msg))};
encode_msg_bin(#sc_self_red_pack_info{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_self_red_pack_info(Msg))};
encode_msg_bin(#sc_prize_config_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_config_update(Msg))};
encode_msg_bin(#cs_prize_query_one_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_query_one_req(Msg))};
encode_msg_bin(#sc_prize_query_one_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_query_one_reply(Msg))};
encode_msg_bin(#cs_prize_exchange_req{} = Msg) ->
    {ok, 1,
     erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_exchange_req(Msg))};
encode_msg_bin(#sc_prize_exchange_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_exchange_reply(Msg))};
encode_msg_bin(#sc_prize_exchange_record_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_exchange_record_update(Msg))};
encode_msg_bin(#sc_prize_address_info_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_address_info_update(Msg))};
encode_msg_bin(#cs_prize_address_change_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_address_change_req(Msg))};
encode_msg_bin(#sc_prize_address_change_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_address_change_reply(Msg))};
encode_msg_bin(#sc_prize_storage_red_point_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_storage_red_point_update(Msg))};
encode_msg_bin(#cs_vip_daily_reward{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_vip_daily_reward(Msg))};
encode_msg_bin(#sc_vip_daily_reward{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_vip_daily_reward(Msg))};
encode_msg_bin(#sc_activity_config_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_sc_activity_config_info_update(Msg))};
encode_msg_bin(#cs_activity_info_query_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_cs_activity_info_query_req(Msg))};
encode_msg_bin(#sc_activity_info_query_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_sc_activity_info_query_reply(Msg))};
encode_msg_bin(#cs_activity_draw_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_cs_activity_draw_req(Msg))};
encode_msg_bin(#sc_activity_draw_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_sc_activity_draw_reply(Msg))};
encode_msg_bin(#cs_prize_query_phonecard_key_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_cs_prize_query_phonecard_key_req(Msg))};
encode_msg_bin(#sc_prize_query_phonecard_key_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(prize_exchange_pb:encode_sc_prize_query_phonecard_key_reply(Msg))};
encode_msg_bin(#cs_task_pay_award_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_cs_task_pay_award_request(Msg))};
encode_msg_bin(#sc_task_pay_award_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_sc_task_pay_award_response(Msg))};
encode_msg_bin(#sc_task_pay_info_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_sc_task_pay_info_response(Msg))};
encode_msg_bin(#cs_red_pack_do_select_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_do_select_req(Msg))};
encode_msg_bin(#sc_red_pack_do_select_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_do_select_reply(Msg))};
encode_msg_bin(#cs_red_pack_search_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_cs_red_pack_search_req(Msg))};
encode_msg_bin(#sc_red_pack_search_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(red_pack_pb:encode_sc_red_pack_search_reply(Msg))};
encode_msg_bin(#cs_task_pay_info_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(activity_pb:encode_cs_task_pay_info_request(Msg))};
encode_msg_bin(#cs_share_new_bee_reward_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_new_bee_reward_req(Msg))};
encode_msg_bin(#sc_share_new_bee_reward_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_new_bee_reward_reply(Msg))};
encode_msg_bin(#cs_share_mission_reward_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_mission_reward_req(Msg))};
encode_msg_bin(#sc_share_mission_reward_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_mission_reward_reply(Msg))};
encode_msg_bin(#sc_share_info{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_info(Msg))};
encode_msg_bin(#sc_share_mission_update{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_mission_update(Msg))};
encode_msg_bin(#cs_share_draw_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_draw_request(Msg))};
encode_msg_bin(#cs_share_friend_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_friend_request(Msg))};
encode_msg_bin(#cs_share_rank_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_rank_request(Msg))};
encode_msg_bin(#sc_share_draw_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_draw_response(Msg))};
encode_msg_bin(#sc_share_history_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_history_response(Msg))};
encode_msg_bin(#sc_share_rank_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_share_rank_response(Msg))};
encode_msg_bin(#sc_draw_count_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_draw_count_response(Msg))};
encode_msg_bin(#cs_car_enter_req{} = Msg) ->
    {ok, 1,
     erlang:iolist_to_binary(car_pb:encode_cs_car_enter_req(Msg))};
encode_msg_bin(#sc_car_enter_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_enter_reply(Msg))};
encode_msg_bin(#cs_car_exit_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_exit_req(Msg))};
encode_msg_bin(#sc_car_exit_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_exit_reply(Msg))};
encode_msg_bin(#cs_car_master_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_master_req(Msg))};
encode_msg_bin(#sc_car_master_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_master_reply(Msg))};
encode_msg_bin(#cs_car_bet_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_bet_req(Msg))};
encode_msg_bin(#sc_car_bet_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_bet_reply(Msg))};
encode_msg_bin(#cs_car_rebet_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_rebet_req(Msg))};
encode_msg_bin(#sc_car_rebet_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_rebet_reply(Msg))};
encode_msg_bin(#cs_car_master_list_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_master_list_req(Msg))};
encode_msg_bin(#cs_car_user_list_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_user_list_req(Msg))};
encode_msg_bin(#sc_car_user_list_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_user_list_reply(Msg))};
encode_msg_bin(#sc_car_result_history_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_result_history_req(Msg))};
encode_msg_bin(#sc_car_master_wait_list_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_master_wait_list_reply(Msg))};
encode_msg_bin(#sc_car_master_info_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_master_info_reply(Msg))};
encode_msg_bin(#sc_car_status_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_status_reply(Msg))};
encode_msg_bin(#sc_car_room_info_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_room_info_reply(Msg))};
encode_msg_bin(#sc_car_hint_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_hint_reply(Msg))};
encode_msg_bin(#sc_car_result_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_result_reply(Msg))};
encode_msg_bin(#sc_car_pool_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_pool_reply(Msg))};
encode_msg_bin(#cs_car_add_money_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_add_money_req(Msg))};
encode_msg_bin(#sc_car_add_money_reply{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_add_money_reply(Msg))};
encode_msg_bin(#cs_car_syn_in_game_state_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_cs_car_syn_in_game_state_req(Msg))};
encode_msg_bin(#sc_task_seven_info_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_task_seven_info_response(Msg))};
encode_msg_bin(#cs_task_seven_award_request{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_task_seven_award_request(Msg))};
encode_msg_bin(#sc_task_seven_award_response{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_sc_task_seven_award_response(Msg))};
encode_msg_bin(#cs_share_with_friends_req{} = Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(share_pb:encode_cs_share_with_friends_req(Msg))};
encode_msg_bin(#cs_super_laba_last_week_rank_query_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_super_laba_last_week_rank_query_req(Msg))};
encode_msg_bin(#sc_super_laba_last_week_rank_query_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_super_laba_last_week_rank_query_reply(Msg))};
encode_msg_bin(#cs_query_last_daily_rank_reward_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_query_last_daily_rank_reward_req(Msg))};
encode_msg_bin(#sc_query_last_daily_rank_reward_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_query_last_daily_rank_reward_reply(Msg))};
encode_msg_bin(#sc_player_stickiness_redpack_info_notify{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_stickiness_redpack_info_notify(Msg))};
encode_msg_bin(#cs_stickiness_redpack_draw_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_stickiness_redpack_draw_req(Msg))};
encode_msg_bin(#sc_stickiness_redpack_draw_resp{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_stickiness_redpack_draw_resp(Msg))};
encode_msg_bin(#sc_period_card_info_update{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_period_card_info_update(Msg))};
encode_msg_bin(#cs_period_card_draw_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_cs_period_card_draw_req(Msg))};
encode_msg_bin(#sc_period_card_draw_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(shop_pb:encode_sc_period_card_draw_reply(Msg))};
encode_msg_bin(#sc_car_query_pool_win_player_reply{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(car_pb:encode_sc_car_query_pool_win_player_reply(Msg))};
encode_msg_bin(#sc_player_bet_stickiness_notify{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_bet_stickiness_notify(Msg))};
encode_msg_bin(#cs_player_bet_stickiness_redpack_draw_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_bet_stickiness_redpack_draw_req(Msg))};
encode_msg_bin(#sc_player_bet_stickiness_redpack_draw_resp{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_bet_stickiness_redpack_draw_resp(Msg))};
encode_msg_bin(#cs_bet_lock_config_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_bet_lock_config_req(Msg))};
encode_msg_bin(#sc_bet_lock_config_resp{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_bet_lock_config_resp(Msg))};
encode_msg_bin(#sc_bet_lock_update_notify{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_bet_lock_update_notify(Msg))};
encode_msg_bin(#cs_player_salary_query_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_player_salary_query_req(Msg))};
encode_msg_bin(#sc_player_salary_query_resp{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_player_salary_query_resp(Msg))};
encode_msg_bin(#cs_airlaba_enter_room_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_enter_room_req(Msg))};
encode_msg_bin(#sc_airlaba_enter_room_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_enter_room_reply(Msg))};
encode_msg_bin(#cs_airlaba_leave_room_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_leave_room_req(Msg))};
encode_msg_bin(#sc_airlaba_leave_room_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_leave_room_reply(Msg))};
encode_msg_bin(#cs_airlaba_fire_bet_req{} =
		   Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_fire_bet_req(Msg))};
encode_msg_bin(#sc_airlaba_fire_bet_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_fire_bet_reply(Msg))};
encode_msg_bin(#cs_airlaba_switch_phase_req{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_switch_phase_req(Msg))};
encode_msg_bin(#sc_airlaba_switch_phase_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_switch_phase_reply(Msg))};
encode_msg_bin(#sc_airlaba_pool_num_update{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_pool_num_update(Msg))};
encode_msg_bin(#cs_airlaba_use_item_req{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_use_item_req(Msg))};
encode_msg_bin(#sc_airlaba_use_item_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_use_item_reply(Msg))};
encode_msg_bin(#cs_airlaba_impov_sub_req{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_cs_airlaba_impov_sub_req(Msg))};
encode_msg_bin(#sc_airlaba_impov_sub_reply{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(laba_pb:encode_sc_airlaba_impov_sub_reply(Msg))};
encode_msg_bin(#cs_lottery_draw_req{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_cs_lottery_draw_req(Msg))};
encode_msg_bin(#sc_lottery_draw_resp{} =
           Msg) ->
    {ok, 0,
     erlang:iolist_to_binary(player_pb:encode_sc_lottery_draw_resp(Msg))};
encode_msg_bin(_) -> error.

merge_bin(#cs_login{} = _Msg, MsgBin) ->
    {ok, <<1:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_login_reply{} = _Msg, MsgBin) ->
    {ok, <<2:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_login_out{} = _Msg, MsgBin) ->
    {ok, <<3:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_login_reconnection{} = _Msg, MsgBin) ->
    {ok, <<4:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_login_reconnection_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<5:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_login_repeat{} = _Msg, MsgBin) ->
    {ok, <<6:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_login_proto_complete{} = _Msg, MsgBin) ->
    {ok, <<7:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_common_heartbeat{} = _Msg, MsgBin) ->
    {ok, <<8:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_common_heartbeat_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<9:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_common_proto_count{} = _Msg, MsgBin) ->
    {ok, <<10:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_common_proto_count{} = _Msg, MsgBin) ->
    {ok, <<11:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_common_proto_clean{} = _Msg, MsgBin) ->
    {ok, <<12:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_common_proto_clean{} = _Msg, MsgBin) ->
    {ok, <<13:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_base_info{} = _Msg, MsgBin) ->
    {ok, <<14:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_change_name_req{} = _Msg,
	  MsgBin) ->
    {ok, <<15:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_change_name_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<16:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_change_headicon_req{} = _Msg,
	  MsgBin) ->
    {ok, <<17:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_change_headicon_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<18:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_chat{} = _Msg, MsgBin) ->
    {ok, <<19:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_chat{} = _Msg, MsgBin) ->
    {ok, <<20:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_sys_notice{} = _Msg, MsgBin) ->
    {ok, <<21:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_tips{} = _Msg, MsgBin) ->
    {ok, <<22:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_query_player_winning_rec_req{} = _Msg,
	  MsgBin) ->
    {ok, <<23:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_query_player_winning_rec_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<24:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_query_in_game_player_num_req{} = _Msg,
	  MsgBin) ->
    {ok, <<25:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_query_in_game_player_num_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<26:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_common_bug_feedback{} = _Msg, MsgBin) ->
    {ok, <<28:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_common_bug_feedback{} = _Msg, MsgBin) ->
    {ok, <<29:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_items_update{} = _Msg, MsgBin) ->
    {ok, <<30:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_items_add{} = _Msg, MsgBin) ->
    {ok, <<31:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_items_delete{} = _Msg, MsgBin) ->
    {ok, <<32:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_items_init_update{} = _Msg, MsgBin) ->
    {ok, <<33:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_item_use_req{} = _Msg, MsgBin) ->
    {ok, <<34:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_item_use_reply{} = _Msg, MsgBin) ->
    {ok, <<35:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mails_init_update{} = _Msg, MsgBin) ->
    {ok, <<40:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mail_add{} = _Msg, MsgBin) ->
    {ok, <<41:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_mail_delete_request{} = _Msg, MsgBin) ->
    {ok, <<42:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mail_delete_reply{} = _Msg, MsgBin) ->
    {ok, <<43:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_read_mail{} = _Msg, MsgBin) ->
    {ok, <<44:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_mail_draw_request{} = _Msg, MsgBin) ->
    {ok, <<45:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mail_draw_reply{} = _Msg, MsgBin) ->
    {ok, <<46:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_room_state_update{} = _Msg, MsgBin) ->
    {ok, <<50:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_enter_room_req{} = _Msg, MsgBin) ->
    {ok, <<51:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_enter_room_reply{} = _Msg, MsgBin) ->
    {ok, <<52:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_enter_room_player_info_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<53:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_choose_master_rate_req{} = _Msg,
	  MsgBin) ->
    {ok, <<54:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_choose_master_rate_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<55:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_player_choose_master_rate_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<56:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_choose_free_rate_req{} = _Msg,
	  MsgBin) ->
    {ok, <<57:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_choose_free_rate_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<58:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_player_choose_free_rate_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<59:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_leave_room_req{} = _Msg, MsgBin) ->
    {ok, <<60:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_leave_room_reply{} = _Msg, MsgBin) ->
    {ok, <<61:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_leave_room_player_pos_update{} = _Msg,
	  MsgBin) ->
    {ok, <<62:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_submit_card_req{} = _Msg, MsgBin) ->
    {ok, <<63:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_submit_card_reply{} = _Msg, MsgBin) ->
    {ok, <<64:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_player_submit_card_update{} = _Msg,
	  MsgBin) ->
    {ok, <<65:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_syn_in_game_state_req{} = _Msg,
	  MsgBin) ->
    {ok, <<66:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_player_room_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<67:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_player_back_to_room_info_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<68:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_subsidy_req{} = _Msg, MsgBin) ->
    {ok, <<69:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_subsidy_reply{} = _Msg, MsgBin) ->
    {ok, <<70:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_subsidy_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<71:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_query_player_room_info_req{} = _Msg,
	  MsgBin) ->
    {ok, <<72:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_niu_special_subsidy_share{} = _Msg,
	  MsgBin) ->
    {ok, <<73:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_special_subsidy_share{} = _Msg,
	  MsgBin) ->
    {ok, <<74:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_daily_checkin_req{} = _Msg, MsgBin) ->
    {ok, <<75:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_daily_checkin_reply{} = _Msg, MsgBin) ->
    {ok, <<76:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_daily_checkin_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<77:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_make_up_for_checkin_req{} = _Msg,
	  MsgBin) ->
    {ok, <<78:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_shop_all_item_base_config{} = _Msg,
	  MsgBin) ->
    {ok, <<80:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_shop_buy_query{} = _Msg, MsgBin) ->
    {ok, <<81:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_shop_buy_reply{} = _Msg, MsgBin) ->
    {ok, <<82:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_golden_bull_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<83:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_golden_bull_draw_req{} = _Msg, MsgBin) ->
    {ok, <<84:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_golden_bull_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<85:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_month_card_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<86:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_month_card_draw_req{} = _Msg, MsgBin) ->
    {ok, <<87:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_month_card_draw_reply{} = _Msg, MsgBin) ->
    {ok, <<88:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_room_state_update{} = _Msg,
	  MsgBin) ->
    {ok, <<90:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_niu_enter_room_req{} = _Msg,
	  MsgBin) ->
    {ok, <<91:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_enter_room_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<92:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_niu_player_list_query_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<93:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_player_list_query_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<94:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_niu_free_set_chips_req{} = _Msg,
	  MsgBin) ->
    {ok, <<95:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_free_set_chips_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<96:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_free_set_chips_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<97:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_niu_sit_down_req{} = _Msg,
	  MsgBin) ->
    {ok, <<98:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_sit_down_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<99:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_niu_seat_player_info_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<100:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_be_master_req{} = _Msg, MsgBin) ->
    {ok, <<101:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_be_master_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<102:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_query_master_list_req{} = _Msg,
	  MsgBin) ->
    {ok, <<103:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_query_master_list_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<104:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_niu_in_game_syn_req{} = _Msg,
	  MsgBin) ->
    {ok, <<105:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_leave_room_req{} = _Msg,
	  MsgBin) ->
    {ok, <<106:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_leave_room_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<107:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_query_winning_rec_req{} = _Msg,
	  MsgBin) ->
    {ok, <<108:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_query_winning_rec_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<109:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_draw_mission_request{} = _Msg, MsgBin) ->
    {ok, <<110:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_draw_mission_result_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<111:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mission{} = _Msg, MsgBin) ->
    {ok, <<112:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mission_update{} = _Msg, MsgBin) ->
    {ok, <<113:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mission_add{} = _Msg, MsgBin) ->
    {ok, <<114:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_mission_del{} = _Msg, MsgBin) ->
    {ok, <<115:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_player_gold_change_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<120:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_query_pool_win_player_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<121:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_query_pool_win_player_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<122:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_rank_query_req{} = _Msg, MsgBin) ->
    {ok, <<123:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_rank_qurey_reply{} = _Msg, MsgBin) ->
    {ok, <<124:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_cash_transformation_req{} = _Msg,
	  MsgBin) ->
    {ok, <<130:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_cash_transformation_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<131:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_golden_bull_mission{} = _Msg, MsgBin) ->
    {ok, <<132:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_golden_bull_mission{} = _Msg, MsgBin) ->
    {ok, <<133:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_phone_num_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<140:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_bind_phone_num{} = _Msg, MsgBin) ->
    {ok, <<141:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_niu_room_chest_draw{} = _Msg,
	  MsgBin) ->
    {ok, <<142:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_room_chest_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<143:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_room_chest_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<144:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_bind_phone_num_draw{} = _Msg,
	  MsgBin) ->
    {ok, <<145:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_bind_phone_num_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<146:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_special_subsidy_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<147:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_niu_room_chest_times_update{} = _Msg,
	  MsgBin) ->
    {ok, <<148:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_guide_info_update{} = _Msg, MsgBin) ->
    {ok, <<150:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_guide_next_step_req{} = _Msg, MsgBin) ->
    {ok, <<151:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_guide_next_step_reply{} = _Msg, MsgBin) ->
    {ok, <<152:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_hundred_last_week_rank_query_req{} = _Msg,
	  MsgBin) ->
    {ok, <<153:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_hundred_last_week_rank_query_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<154:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_real_name_update{} = _Msg, MsgBin) ->
    {ok, <<155:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_real_name_update{} = _Msg, MsgBin) ->
    {ok, <<156:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_real_name_req{} = _Msg, MsgBin) ->
    {ok, <<157:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_real_name_req{} = _Msg, MsgBin) ->
    {ok, <<158:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_room_reset_times_update{} = _Msg,
	  MsgBin) ->
    {ok, <<160:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_room_player_times_update{} = _Msg,
	  MsgBin) ->
    {ok, <<161:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_room_redpack_notice_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<162:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_redpack_room_draw_req{} = _Msg, MsgBin) ->
    {ok, <<163:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_room_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<164:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_redpack_timer_sec_update{} = _Msg,
	  MsgBin) ->
    {ok, <<165:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_redpack_relive_req{} = _Msg, MsgBin) ->
    {ok, <<166:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_relive_reply{} = _Msg, MsgBin) ->
    {ok, <<167:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_relive_times{} = _Msg, MsgBin) ->
    {ok, <<168:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_fudai_pool_update{} = _Msg, MsgBin) ->
    {ok, <<169:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_laba_enter_room_req{} = _Msg, MsgBin) ->
    {ok, <<201:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_laba_enter_room_reply{} = _Msg, MsgBin) ->
    {ok, <<202:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_laba_leave_room_req{} = _Msg, MsgBin) ->
    {ok, <<203:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_laba_leave_room_reply{} = _Msg, MsgBin) ->
    {ok, <<204:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_laba_pool_num_update{} = _Msg, MsgBin) ->
    {ok, <<205:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_laba_spin_req{} = _Msg, MsgBin) ->
    {ok, <<206:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_laba_spin_reply{} = _Msg, MsgBin) ->
    {ok, <<207:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_game_task_info_update{} = _Msg, MsgBin) ->
    {ok, <<208:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_game_task_box_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<209:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_game_task_draw_req{} = _Msg, MsgBin) ->
    {ok, <<210:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_game_task_draw_reply{} = _Msg, MsgBin) ->
    {ok, <<211:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_game_task_box_draw_req{} = _Msg,
	  MsgBin) ->
    {ok, <<212:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_game_task_box_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<213:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_task_draw_list_update{} = _Msg,
	  MsgBin) ->
    {ok, <<214:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_redpack_task_draw_req{} = _Msg, MsgBin) ->
    {ok, <<215:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_redpack_task_draw_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<216:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_win_player_list{} = _Msg, MsgBin) ->
    {ok, <<217:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_win_player_list{} = _Msg, MsgBin) ->
    {ok, <<218:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_query_list_req{} = _Msg,
	  MsgBin) ->
    {ok, <<220:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_query_list_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<221:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_open_req{} = _Msg, MsgBin) ->
    {ok, <<222:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_open_reply{} = _Msg, MsgBin) ->
    {ok, <<223:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_create_req{} = _Msg, MsgBin) ->
    {ok, <<224:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_create_reply{} = _Msg, MsgBin) ->
    {ok, <<225:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_notice_update{} = _Msg,
	  MsgBin) ->
    {ok, <<226:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_cancel_req{} = _Msg, MsgBin) ->
    {ok, <<227:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_cancel_reply{} = _Msg, MsgBin) ->
    {ok, <<228:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_self_red_pack_info{} = _Msg, MsgBin) ->
    {ok, <<229:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_config_update{} = _Msg, MsgBin) ->
    {ok, <<230:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_prize_query_one_req{} = _Msg, MsgBin) ->
    {ok, <<231:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_query_one_reply{} = _Msg, MsgBin) ->
    {ok, <<232:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_prize_exchange_req{} = _Msg, MsgBin) ->
    {ok, <<233:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_exchange_reply{} = _Msg, MsgBin) ->
    {ok, <<234:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_exchange_record_update{} = _Msg,
	  MsgBin) ->
    {ok, <<235:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_address_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<236:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_prize_address_change_req{} = _Msg,
	  MsgBin) ->
    {ok, <<237:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_address_change_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<238:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_storage_red_point_update{} = _Msg,
	  MsgBin) ->
    {ok, <<239:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_vip_daily_reward{} = _Msg, MsgBin) ->
    {ok, <<240:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_vip_daily_reward{} = _Msg, MsgBin) ->
    {ok, <<241:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_activity_config_info_update{} = _Msg,
	  MsgBin) ->
    {ok, <<250:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_activity_info_query_req{} = _Msg,
	  MsgBin) ->
    {ok, <<251:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_activity_info_query_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<252:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_activity_draw_req{} = _Msg, MsgBin) ->
    {ok, <<253:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_activity_draw_reply{} = _Msg, MsgBin) ->
    {ok, <<254:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_prize_query_phonecard_key_req{} = _Msg,
	  MsgBin) ->
    {ok, <<255:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_prize_query_phonecard_key_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<256:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_task_pay_award_request{} = _Msg,
	  MsgBin) ->
    {ok, <<257:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_task_pay_award_response{} = _Msg,
	  MsgBin) ->
    {ok, <<258:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_task_pay_info_response{} = _Msg,
	  MsgBin) ->
    {ok, <<259:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_do_select_req{} = _Msg,
	  MsgBin) ->
    {ok, <<260:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_do_select_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<261:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_red_pack_search_req{} = _Msg, MsgBin) ->
    {ok, <<262:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_red_pack_search_reply{} = _Msg, MsgBin) ->
    {ok, <<263:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_task_pay_info_request{} = _Msg, MsgBin) ->
    {ok, <<264:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_new_bee_reward_req{} = _Msg,
	  MsgBin) ->
    {ok, <<266:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_new_bee_reward_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<267:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_mission_reward_req{} = _Msg,
	  MsgBin) ->
    {ok, <<268:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_mission_reward_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<269:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_info{} = _Msg, MsgBin) ->
    {ok, <<270:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_mission_update{} = _Msg, MsgBin) ->
    {ok, <<271:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_draw_request{} = _Msg, MsgBin) ->
    {ok, <<272:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_friend_request{} = _Msg, MsgBin) ->
    {ok, <<273:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_rank_request{} = _Msg, MsgBin) ->
    {ok, <<274:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_draw_response{} = _Msg, MsgBin) ->
    {ok, <<275:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_history_response{} = _Msg,
	  MsgBin) ->
    {ok, <<276:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_share_rank_response{} = _Msg, MsgBin) ->
    {ok, <<277:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_draw_count_response{} = _Msg, MsgBin) ->
    {ok, <<278:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_enter_req{} = _Msg, MsgBin) ->
    {ok, <<280:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_enter_reply{} = _Msg, MsgBin) ->
    {ok, <<281:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_exit_req{} = _Msg, MsgBin) ->
    {ok, <<282:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_exit_reply{} = _Msg, MsgBin) ->
    {ok, <<283:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_master_req{} = _Msg, MsgBin) ->
    {ok, <<284:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_master_reply{} = _Msg, MsgBin) ->
    {ok, <<285:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_bet_req{} = _Msg, MsgBin) ->
    {ok, <<286:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_bet_reply{} = _Msg, MsgBin) ->
    {ok, <<287:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_rebet_req{} = _Msg, MsgBin) ->
    {ok, <<288:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_rebet_reply{} = _Msg, MsgBin) ->
    {ok, <<289:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_master_list_req{} = _Msg, MsgBin) ->
    {ok, <<290:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_user_list_req{} = _Msg, MsgBin) ->
    {ok, <<291:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_user_list_reply{} = _Msg, MsgBin) ->
    {ok, <<292:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_result_history_req{} = _Msg,
	  MsgBin) ->
    {ok, <<294:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_master_wait_list_reply{} = _Msg,
	  MsgBin) ->
    {ok, <<295:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_master_info_reply{} = _Msg, MsgBin) ->
    {ok, <<296:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_status_reply{} = _Msg, MsgBin) ->
    {ok, <<297:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_room_info_reply{} = _Msg, MsgBin) ->
    {ok, <<298:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_hint_reply{} = _Msg, MsgBin) ->
    {ok, <<299:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_result_reply{} = _Msg, MsgBin) ->
    {ok, <<300:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_pool_reply{} = _Msg, MsgBin) ->
    {ok, <<301:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_add_money_req{} = _Msg, MsgBin) ->
    {ok, <<303:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_add_money_reply{} = _Msg, MsgBin) ->
    {ok, <<304:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_syn_in_game_state_req{} = _Msg,
	  MsgBin) ->
    {ok, <<305:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_task_seven_info_response{} = _Msg,
	  MsgBin) ->
    {ok, <<310:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_task_seven_award_request{} = _Msg,
	  MsgBin) ->
    {ok, <<311:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_task_seven_award_response{} = _Msg,
	  MsgBin) ->
    {ok, <<312:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_share_with_friends_req{} = _Msg,
	  MsgBin) ->
    {ok, <<313:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_super_laba_last_week_rank_query_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<320:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_super_laba_last_week_rank_query_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<321:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_query_last_daily_rank_reward_req{} = _Msg,
	  MsgBin) ->
    {ok, <<322:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_query_last_daily_rank_reward_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<323:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_stickiness_redpack_info_notify{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<324:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_stickiness_redpack_draw_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<325:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_stickiness_redpack_draw_resp{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<326:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_stickiness_redpack_info_notify_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<327:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_period_card_info_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<328:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_period_card_draw_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<329:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_period_card_draw_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<330:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_car_query_pool_win_player_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<331:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_car_query_pool_win_player_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<332:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_bet_stickiness_notify{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<333:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_bet_stickiness_redpack_draw_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<334:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_bet_stickiness_redpack_draw_resp{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<335:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_bet_lock_config_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<336:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_bet_lock_config_resp{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<337:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_bet_lock_update_notify{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<338:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_player_salary_query_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<339:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_player_salary_query_resp{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<340:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_enter_room_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<341:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_enter_room_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<342:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_leave_room_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<343:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_leave_room_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<344:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_fire_bet_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<345:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_fire_bet_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<346:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_switch_phase_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<347:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_switch_phase_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<348:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_pool_num_update{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<349:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_use_item_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<350:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_use_item_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<351:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_airlaba_impov_sub_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<352:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_airlaba_impov_sub_reply{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<353:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#cs_lottery_draw_req{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<354:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(#sc_lottery_draw_resp{} =
	      _Msg,
	  MsgBin) ->
    {ok, <<355:?INT_PROTO_ID, MsgBin/binary>>};
merge_bin(_, _) -> error.

decode_msg_bin(1, MsgBin) ->
    {ok, login_pb:decode_cs_login(MsgBin)};
decode_msg_bin(2, MsgBin) ->
    {ok, login_pb:decode_sc_login_reply(MsgBin)};
decode_msg_bin(3, MsgBin) ->
    {ok, login_pb:decode_cs_login_out(MsgBin)};
decode_msg_bin(4, MsgBin) ->
    {ok, login_pb:decode_cs_login_reconnection(MsgBin)};
decode_msg_bin(5, MsgBin) ->
    {ok,
     login_pb:decode_sc_login_reconnection_reply(MsgBin)};
decode_msg_bin(6, MsgBin) ->
    {ok, login_pb:decode_sc_login_repeat(MsgBin)};
decode_msg_bin(7, MsgBin) ->
    {ok, login_pb:decode_sc_login_proto_complete(MsgBin)};
decode_msg_bin(8, MsgBin) ->
    {ok, common_pb:decode_cs_common_heartbeat(MsgBin)};
decode_msg_bin(9, MsgBin) ->
    {ok,
     common_pb:decode_sc_common_heartbeat_reply(MsgBin)};
decode_msg_bin(10, MsgBin) ->
    {ok, common_pb:decode_cs_common_proto_count(MsgBin)};
decode_msg_bin(11, MsgBin) ->
    {ok, common_pb:decode_sc_common_proto_count(MsgBin)};
decode_msg_bin(12, MsgBin) ->
    {ok, common_pb:decode_cs_common_proto_clean(MsgBin)};
decode_msg_bin(13, MsgBin) ->
    {ok, common_pb:decode_sc_common_proto_clean(MsgBin)};
decode_msg_bin(14, MsgBin) ->
    {ok, player_pb:decode_sc_player_base_info(MsgBin)};
decode_msg_bin(15, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_change_name_req(MsgBin)};
decode_msg_bin(16, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_change_name_reply(MsgBin)};
decode_msg_bin(17, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_change_headicon_req(MsgBin)};
decode_msg_bin(18, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_change_headicon_reply(MsgBin)};
decode_msg_bin(19, MsgBin) ->
    {ok, player_pb:decode_cs_player_chat(MsgBin)};
decode_msg_bin(20, MsgBin) ->
    {ok, player_pb:decode_sc_player_chat(MsgBin)};
decode_msg_bin(21, MsgBin) ->
    {ok, player_pb:decode_sc_player_sys_notice(MsgBin)};
decode_msg_bin(22, MsgBin) ->
    {ok, player_pb:decode_sc_tips(MsgBin)};
decode_msg_bin(23, MsgBin) ->
    {ok,
     player_pb:decode_cs_query_player_winning_rec_req(MsgBin)};
decode_msg_bin(24, MsgBin) ->
    {ok,
     player_pb:decode_sc_query_player_winning_rec_reply(MsgBin)};
decode_msg_bin(25, MsgBin) ->
    {ok,
     player_pb:decode_cs_niu_query_in_game_player_num_req(MsgBin)};
decode_msg_bin(26, MsgBin) ->
    {ok,
     player_pb:decode_sc_niu_query_in_game_player_num_reply(MsgBin)};
decode_msg_bin(28, MsgBin) ->
    {ok, common_pb:decode_cs_common_bug_feedback(MsgBin)};
decode_msg_bin(29, MsgBin) ->
    {ok, common_pb:decode_sc_common_bug_feedback(MsgBin)};
decode_msg_bin(30, MsgBin) ->
    {ok, item_pb:decode_sc_items_update(MsgBin)};
decode_msg_bin(31, MsgBin) ->
    {ok, item_pb:decode_sc_items_add(MsgBin)};
decode_msg_bin(32, MsgBin) ->
    {ok, item_pb:decode_sc_items_delete(MsgBin)};
decode_msg_bin(33, MsgBin) ->
    {ok, item_pb:decode_sc_items_init_update(MsgBin)};
decode_msg_bin(34, MsgBin) ->
    {ok, item_pb:decode_cs_item_use_req(MsgBin)};
decode_msg_bin(35, MsgBin) ->
    {ok, item_pb:decode_sc_item_use_reply(MsgBin)};
decode_msg_bin(40, MsgBin) ->
    {ok, mail_pb:decode_sc_mails_init_update(MsgBin)};
decode_msg_bin(41, MsgBin) ->
    {ok, mail_pb:decode_sc_mail_add(MsgBin)};
decode_msg_bin(42, MsgBin) ->
    {ok, mail_pb:decode_cs_mail_delete_request(MsgBin)};
decode_msg_bin(43, MsgBin) ->
    {ok, mail_pb:decode_sc_mail_delete_reply(MsgBin)};
decode_msg_bin(44, MsgBin) ->
    {ok, mail_pb:decode_cs_read_mail(MsgBin)};
decode_msg_bin(45, MsgBin) ->
    {ok, mail_pb:decode_cs_mail_draw_request(MsgBin)};
decode_msg_bin(46, MsgBin) ->
    {ok, mail_pb:decode_sc_mail_draw_reply(MsgBin)};
decode_msg_bin(50, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_room_state_update(MsgBin)};
decode_msg_bin(51, MsgBin) ->
    {ok, niu_game_pb:decode_cs_niu_enter_room_req(MsgBin)};
decode_msg_bin(52, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_enter_room_reply(MsgBin)};
decode_msg_bin(53, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_enter_room_player_info_update(MsgBin)};
decode_msg_bin(54, MsgBin) ->
    {ok,
     niu_game_pb:decode_cs_niu_choose_master_rate_req(MsgBin)};
decode_msg_bin(55, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_choose_master_rate_reply(MsgBin)};
decode_msg_bin(56, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_choose_master_rate_update(MsgBin)};
decode_msg_bin(57, MsgBin) ->
    {ok,
     niu_game_pb:decode_cs_niu_choose_free_rate_req(MsgBin)};
decode_msg_bin(58, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_choose_free_rate_reply(MsgBin)};
decode_msg_bin(59, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_choose_free_rate_update(MsgBin)};
decode_msg_bin(60, MsgBin) ->
    {ok, niu_game_pb:decode_cs_niu_leave_room_req(MsgBin)};
decode_msg_bin(61, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_leave_room_reply(MsgBin)};
decode_msg_bin(62, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_leave_room_player_pos_update(MsgBin)};
decode_msg_bin(63, MsgBin) ->
    {ok, niu_game_pb:decode_cs_niu_submit_card_req(MsgBin)};
decode_msg_bin(64, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_submit_card_reply(MsgBin)};
decode_msg_bin(65, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_submit_card_update(MsgBin)};
decode_msg_bin(66, MsgBin) ->
    {ok,
     niu_game_pb:decode_cs_niu_syn_in_game_state_req(MsgBin)};
decode_msg_bin(67, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_room_info_update(MsgBin)};
decode_msg_bin(68, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_niu_player_back_to_room_info_update(MsgBin)};
decode_msg_bin(69, MsgBin) ->
    {ok, player_pb:decode_cs_niu_subsidy_req(MsgBin)};
decode_msg_bin(70, MsgBin) ->
    {ok, player_pb:decode_sc_niu_subsidy_reply(MsgBin)};
decode_msg_bin(71, MsgBin) ->
    {ok,
     player_pb:decode_sc_niu_subsidy_info_update(MsgBin)};
decode_msg_bin(72, MsgBin) ->
    {ok,
     niu_game_pb:decode_cs_niu_query_player_room_info_req(MsgBin)};
decode_msg_bin(73, MsgBin) ->
    {ok,
     player_pb:decode_cs_niu_special_subsidy_share(MsgBin)};
decode_msg_bin(74, MsgBin) ->
    {ok,
     player_pb:decode_sc_niu_special_subsidy_share(MsgBin)};
decode_msg_bin(75, MsgBin) ->
    {ok, player_pb:decode_cs_daily_checkin_req(MsgBin)};
decode_msg_bin(76, MsgBin) ->
    {ok, player_pb:decode_sc_daily_checkin_reply(MsgBin)};
decode_msg_bin(77, MsgBin) ->
    {ok,
     player_pb:decode_sc_daily_checkin_info_update(MsgBin)};
decode_msg_bin(78, MsgBin) ->
    {ok,
     player_pb:decode_cs_make_up_for_checkin_req(MsgBin)};
decode_msg_bin(80, MsgBin) ->
    {ok,
     shop_pb:decode_sc_shop_all_item_base_config(MsgBin)};
decode_msg_bin(81, MsgBin) ->
    {ok, shop_pb:decode_cs_shop_buy_query(MsgBin)};
decode_msg_bin(82, MsgBin) ->
    {ok, shop_pb:decode_sc_shop_buy_reply(MsgBin)};
decode_msg_bin(83, MsgBin) ->
    {ok, shop_pb:decode_sc_golden_bull_info_update(MsgBin)};
decode_msg_bin(84, MsgBin) ->
    {ok, shop_pb:decode_cs_golden_bull_draw_req(MsgBin)};
decode_msg_bin(85, MsgBin) ->
    {ok, shop_pb:decode_sc_golden_bull_draw_reply(MsgBin)};
decode_msg_bin(86, MsgBin) ->
    {ok, shop_pb:decode_sc_month_card_info_update(MsgBin)};
decode_msg_bin(87, MsgBin) ->
    {ok, shop_pb:decode_cs_month_card_draw_req(MsgBin)};
decode_msg_bin(88, MsgBin) ->
    {ok, shop_pb:decode_sc_month_card_draw_reply(MsgBin)};
decode_msg_bin(90, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_room_state_update(MsgBin)};
decode_msg_bin(91, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_enter_room_req(MsgBin)};
decode_msg_bin(92, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_enter_room_reply(MsgBin)};
decode_msg_bin(93, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_player_list_query_req(MsgBin)};
decode_msg_bin(94, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_player_list_query_reply(MsgBin)};
decode_msg_bin(95, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_free_set_chips_req(MsgBin)};
decode_msg_bin(96, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_free_set_chips_reply(MsgBin)};
decode_msg_bin(97, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_free_set_chips_update(MsgBin)};
decode_msg_bin(98, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_sit_down_req(MsgBin)};
decode_msg_bin(99, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_sit_down_reply(MsgBin)};
decode_msg_bin(100, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_niu_seat_player_info_update(MsgBin)};
decode_msg_bin(101, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_be_master_req(MsgBin)};
decode_msg_bin(102, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_be_master_reply(MsgBin)};
decode_msg_bin(103, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_master_list_req(MsgBin)};
decode_msg_bin(104, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_master_list_reply(MsgBin)};
decode_msg_bin(105, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_niu_in_game_syn_req(MsgBin)};
decode_msg_bin(106, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_leave_room_req(MsgBin)};
decode_msg_bin(107, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_leave_room_reply(MsgBin)};
decode_msg_bin(108, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_winning_rec_req(MsgBin)};
decode_msg_bin(109, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_winning_rec_reply(MsgBin)};
decode_msg_bin(110, MsgBin) ->
    {ok, mission_pb:decode_cs_draw_mission_request(MsgBin)};
decode_msg_bin(111, MsgBin) ->
    {ok,
     mission_pb:decode_sc_draw_mission_result_reply(MsgBin)};
decode_msg_bin(112, MsgBin) ->
    {ok, mission_pb:decode_sc_mission(MsgBin)};
decode_msg_bin(113, MsgBin) ->
    {ok, mission_pb:decode_sc_mission_update(MsgBin)};
decode_msg_bin(114, MsgBin) ->
    {ok, mission_pb:decode_sc_mission_add(MsgBin)};
decode_msg_bin(115, MsgBin) ->
    {ok, mission_pb:decode_sc_mission_del(MsgBin)};
decode_msg_bin(120, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_player_gold_change_update(MsgBin)};
decode_msg_bin(121, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_cs_hundred_query_pool_win_player_req(MsgBin)};
decode_msg_bin(122, MsgBin) ->
    {ok,
     hundred_niu_pb:decode_sc_hundred_query_pool_win_player_reply(MsgBin)};
decode_msg_bin(123, MsgBin) ->
    {ok, player_pb:decode_cs_rank_query_req(MsgBin)};
decode_msg_bin(124, MsgBin) ->
    {ok, player_pb:decode_sc_rank_qurey_reply(MsgBin)};
decode_msg_bin(130, MsgBin) ->
    {ok, shop_pb:decode_cs_cash_transformation_req(MsgBin)};
decode_msg_bin(131, MsgBin) ->
    {ok,
     shop_pb:decode_sc_cash_transformation_reply(MsgBin)};
decode_msg_bin(132, MsgBin) ->
    {ok, shop_pb:decode_cs_golden_bull_mission(MsgBin)};
decode_msg_bin(133, MsgBin) ->
    {ok, shop_pb:decode_sc_golden_bull_mission(MsgBin)};
decode_msg_bin(140, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_phone_num_info_update(MsgBin)};
decode_msg_bin(141, MsgBin) ->
    {ok, player_pb:decode_sc_player_bind_phone_num(MsgBin)};
decode_msg_bin(142, MsgBin) ->
    {ok,
     chest_pb:decode_cs_player_niu_room_chest_draw(MsgBin)};
decode_msg_bin(143, MsgBin) ->
    {ok,
     chest_pb:decode_sc_niu_room_chest_draw_reply(MsgBin)};
decode_msg_bin(144, MsgBin) ->
    {ok,
     chest_pb:decode_sc_niu_room_chest_info_update(MsgBin)};
decode_msg_bin(145, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_bind_phone_num_draw(MsgBin)};
decode_msg_bin(146, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_bind_phone_num_draw_reply(MsgBin)};
decode_msg_bin(147, MsgBin) ->
    {ok,
     player_pb:decode_sc_niu_special_subsidy_info_update(MsgBin)};
decode_msg_bin(148, MsgBin) ->
    {ok,
     chest_pb:decode_sc_niu_room_chest_times_update(MsgBin)};
decode_msg_bin(150, MsgBin) ->
    {ok, player_pb:decode_sc_guide_info_update(MsgBin)};
decode_msg_bin(151, MsgBin) ->
    {ok, player_pb:decode_cs_guide_next_step_req(MsgBin)};
decode_msg_bin(152, MsgBin) ->
    {ok, player_pb:decode_sc_guide_next_step_reply(MsgBin)};
decode_msg_bin(153, MsgBin) ->
    {ok,
     player_pb:decode_cs_hundred_last_week_rank_query_req(MsgBin)};
decode_msg_bin(154, MsgBin) ->
    {ok,
     player_pb:decode_sc_hundred_last_week_rank_query_reply(MsgBin)};
decode_msg_bin(155, MsgBin) ->
    {ok, player_pb:decode_cs_real_name_update(MsgBin)};
decode_msg_bin(156, MsgBin) ->
    {ok, player_pb:decode_sc_real_name_update(MsgBin)};
decode_msg_bin(157, MsgBin) ->
    {ok, player_pb:decode_cs_real_name_req(MsgBin)};
decode_msg_bin(158, MsgBin) ->
    {ok, player_pb:decode_sc_real_name_req(MsgBin)};
decode_msg_bin(160, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_reset_times_update(MsgBin)};
decode_msg_bin(161, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_player_times_update(MsgBin)};
decode_msg_bin(162, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_redpack_notice_update(MsgBin)};
decode_msg_bin(163, MsgBin) ->
    {ok,
     niu_game_pb:decode_cs_redpack_room_draw_req(MsgBin)};
decode_msg_bin(164, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_room_draw_reply(MsgBin)};
decode_msg_bin(165, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_redpack_timer_sec_update(MsgBin)};
decode_msg_bin(166, MsgBin) ->
    {ok, niu_game_pb:decode_cs_redpack_relive_req(MsgBin)};
decode_msg_bin(167, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_relive_reply(MsgBin)};
decode_msg_bin(168, MsgBin) ->
    {ok,
     niu_game_pb:decode_sc_redpack_relive_times(MsgBin)};
decode_msg_bin(169, MsgBin) ->
    {ok, niu_game_pb:decode_sc_fudai_pool_update(MsgBin)};
decode_msg_bin(201, MsgBin) ->
    {ok, laba_pb:decode_cs_laba_enter_room_req(MsgBin)};
decode_msg_bin(202, MsgBin) ->
    {ok, laba_pb:decode_sc_laba_enter_room_reply(MsgBin)};
decode_msg_bin(203, MsgBin) ->
    {ok, laba_pb:decode_cs_laba_leave_room_req(MsgBin)};
decode_msg_bin(204, MsgBin) ->
    {ok, laba_pb:decode_sc_laba_leave_room_reply(MsgBin)};
decode_msg_bin(205, MsgBin) ->
    {ok, laba_pb:decode_sc_laba_pool_num_update(MsgBin)};
decode_msg_bin(206, MsgBin) ->
    {ok, laba_pb:decode_cs_laba_spin_req(MsgBin)};
decode_msg_bin(207, MsgBin) ->
    {ok, laba_pb:decode_sc_laba_spin_reply(MsgBin)};
decode_msg_bin(208, MsgBin) ->
    {ok,
     mission_pb:decode_sc_game_task_info_update(MsgBin)};
decode_msg_bin(209, MsgBin) ->
    {ok,
     mission_pb:decode_sc_game_task_box_info_update(MsgBin)};
decode_msg_bin(210, MsgBin) ->
    {ok, mission_pb:decode_cs_game_task_draw_req(MsgBin)};
decode_msg_bin(211, MsgBin) ->
    {ok, mission_pb:decode_sc_game_task_draw_reply(MsgBin)};
decode_msg_bin(212, MsgBin) ->
    {ok,
     mission_pb:decode_cs_game_task_box_draw_req(MsgBin)};
decode_msg_bin(213, MsgBin) ->
    {ok,
     mission_pb:decode_sc_game_task_box_draw_reply(MsgBin)};
decode_msg_bin(214, MsgBin) ->
    {ok,
     mission_pb:decode_sc_redpack_task_draw_list_update(MsgBin)};
decode_msg_bin(215, MsgBin) ->
    {ok,
     mission_pb:decode_cs_redpack_task_draw_req(MsgBin)};
decode_msg_bin(216, MsgBin) ->
    {ok,
     mission_pb:decode_sc_redpack_task_draw_reply(MsgBin)};
decode_msg_bin(217, MsgBin) ->
    {ok, laba_pb:decode_cs_win_player_list(MsgBin)};
decode_msg_bin(218, MsgBin) ->
    {ok, laba_pb:decode_sc_win_player_list(MsgBin)};
decode_msg_bin(220, MsgBin) ->
    {ok,
     red_pack_pb:decode_cs_red_pack_query_list_req(MsgBin)};
decode_msg_bin(221, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_query_list_reply(MsgBin)};
decode_msg_bin(222, MsgBin) ->
    {ok, red_pack_pb:decode_cs_red_pack_open_req(MsgBin)};
decode_msg_bin(223, MsgBin) ->
    {ok, red_pack_pb:decode_sc_red_pack_open_reply(MsgBin)};
decode_msg_bin(224, MsgBin) ->
    {ok, red_pack_pb:decode_cs_red_pack_create_req(MsgBin)};
decode_msg_bin(225, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_create_reply(MsgBin)};
decode_msg_bin(226, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_notice_update(MsgBin)};
decode_msg_bin(227, MsgBin) ->
    {ok, red_pack_pb:decode_cs_red_pack_cancel_req(MsgBin)};
decode_msg_bin(228, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_cancel_reply(MsgBin)};
decode_msg_bin(229, MsgBin) ->
    {ok, red_pack_pb:decode_sc_self_red_pack_info(MsgBin)};
decode_msg_bin(230, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_config_update(MsgBin)};
decode_msg_bin(231, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_query_one_req(MsgBin)};
decode_msg_bin(232, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_query_one_reply(MsgBin)};
decode_msg_bin(233, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_exchange_req(MsgBin)};
decode_msg_bin(234, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_exchange_reply(MsgBin)};
decode_msg_bin(235, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_exchange_record_update(MsgBin)};
decode_msg_bin(236, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_address_info_update(MsgBin)};
decode_msg_bin(237, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_address_change_req(MsgBin)};
decode_msg_bin(238, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_address_change_reply(MsgBin)};
decode_msg_bin(239, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_storage_red_point_update(MsgBin)};
decode_msg_bin(240, MsgBin) ->
    {ok, player_pb:decode_cs_vip_daily_reward(MsgBin)};
decode_msg_bin(241, MsgBin) ->
    {ok, player_pb:decode_sc_vip_daily_reward(MsgBin)};
decode_msg_bin(250, MsgBin) ->
    {ok,
     activity_pb:decode_sc_activity_config_info_update(MsgBin)};
decode_msg_bin(251, MsgBin) ->
    {ok,
     activity_pb:decode_cs_activity_info_query_req(MsgBin)};
decode_msg_bin(252, MsgBin) ->
    {ok,
     activity_pb:decode_sc_activity_info_query_reply(MsgBin)};
decode_msg_bin(253, MsgBin) ->
    {ok, activity_pb:decode_cs_activity_draw_req(MsgBin)};
decode_msg_bin(254, MsgBin) ->
    {ok, activity_pb:decode_sc_activity_draw_reply(MsgBin)};
decode_msg_bin(255, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_cs_prize_query_phonecard_key_req(MsgBin)};
decode_msg_bin(256, MsgBin) ->
    {ok,
     prize_exchange_pb:decode_sc_prize_query_phonecard_key_reply(MsgBin)};
decode_msg_bin(257, MsgBin) ->
    {ok,
     activity_pb:decode_cs_task_pay_award_request(MsgBin)};
decode_msg_bin(258, MsgBin) ->
    {ok,
     activity_pb:decode_sc_task_pay_award_response(MsgBin)};
decode_msg_bin(259, MsgBin) ->
    {ok,
     activity_pb:decode_sc_task_pay_info_response(MsgBin)};
decode_msg_bin(260, MsgBin) ->
    {ok,
     red_pack_pb:decode_cs_red_pack_do_select_req(MsgBin)};
decode_msg_bin(261, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_do_select_reply(MsgBin)};
decode_msg_bin(262, MsgBin) ->
    {ok, red_pack_pb:decode_cs_red_pack_search_req(MsgBin)};
decode_msg_bin(263, MsgBin) ->
    {ok,
     red_pack_pb:decode_sc_red_pack_search_reply(MsgBin)};
decode_msg_bin(264, MsgBin) ->
    {ok,
     activity_pb:decode_cs_task_pay_info_request(MsgBin)};
decode_msg_bin(266, MsgBin) ->
    {ok,
     share_pb:decode_cs_share_new_bee_reward_req(MsgBin)};
decode_msg_bin(267, MsgBin) ->
    {ok,
     share_pb:decode_sc_share_new_bee_reward_reply(MsgBin)};
decode_msg_bin(268, MsgBin) ->
    {ok,
     share_pb:decode_cs_share_mission_reward_req(MsgBin)};
decode_msg_bin(269, MsgBin) ->
    {ok,
     share_pb:decode_sc_share_mission_reward_reply(MsgBin)};
decode_msg_bin(270, MsgBin) ->
    {ok, share_pb:decode_sc_share_info(MsgBin)};
decode_msg_bin(271, MsgBin) ->
    {ok, share_pb:decode_sc_share_mission_update(MsgBin)};
decode_msg_bin(272, MsgBin) ->
    {ok, share_pb:decode_cs_share_draw_request(MsgBin)};
decode_msg_bin(273, MsgBin) ->
    {ok, share_pb:decode_cs_share_friend_request(MsgBin)};
decode_msg_bin(274, MsgBin) ->
    {ok, share_pb:decode_cs_share_rank_request(MsgBin)};
decode_msg_bin(275, MsgBin) ->
    {ok, share_pb:decode_sc_share_draw_response(MsgBin)};
decode_msg_bin(276, MsgBin) ->
    {ok, share_pb:decode_sc_share_history_response(MsgBin)};
decode_msg_bin(277, MsgBin) ->
    {ok, share_pb:decode_sc_share_rank_response(MsgBin)};
decode_msg_bin(278, MsgBin) ->
    {ok, share_pb:decode_sc_draw_count_response(MsgBin)};
decode_msg_bin(280, MsgBin) ->
    {ok, car_pb:decode_cs_car_enter_req(MsgBin)};
decode_msg_bin(281, MsgBin) ->
    {ok, car_pb:decode_sc_car_enter_reply(MsgBin)};
decode_msg_bin(282, MsgBin) ->
    {ok, car_pb:decode_cs_car_exit_req(MsgBin)};
decode_msg_bin(283, MsgBin) ->
    {ok, car_pb:decode_sc_car_exit_reply(MsgBin)};
decode_msg_bin(284, MsgBin) ->
    {ok, car_pb:decode_cs_car_master_req(MsgBin)};
decode_msg_bin(285, MsgBin) ->
    {ok, car_pb:decode_sc_car_master_reply(MsgBin)};
decode_msg_bin(286, MsgBin) ->
    {ok, car_pb:decode_cs_car_bet_req(MsgBin)};
decode_msg_bin(287, MsgBin) ->
    {ok, car_pb:decode_sc_car_bet_reply(MsgBin)};
decode_msg_bin(288, MsgBin) ->
    {ok, car_pb:decode_cs_car_rebet_req(MsgBin)};
decode_msg_bin(289, MsgBin) ->
    {ok, car_pb:decode_sc_car_rebet_reply(MsgBin)};
decode_msg_bin(290, MsgBin) ->
    {ok, car_pb:decode_cs_car_master_list_req(MsgBin)};
decode_msg_bin(291, MsgBin) ->
    {ok, car_pb:decode_cs_car_user_list_req(MsgBin)};
decode_msg_bin(292, MsgBin) ->
    {ok, car_pb:decode_sc_car_user_list_reply(MsgBin)};
decode_msg_bin(294, MsgBin) ->
    {ok, car_pb:decode_sc_car_result_history_req(MsgBin)};
decode_msg_bin(295, MsgBin) ->
    {ok,
     car_pb:decode_sc_car_master_wait_list_reply(MsgBin)};
decode_msg_bin(296, MsgBin) ->
    {ok, car_pb:decode_sc_car_master_info_reply(MsgBin)};
decode_msg_bin(297, MsgBin) ->
    {ok, car_pb:decode_sc_car_status_reply(MsgBin)};
decode_msg_bin(298, MsgBin) ->
    {ok, car_pb:decode_sc_car_room_info_reply(MsgBin)};
decode_msg_bin(299, MsgBin) ->
    {ok, car_pb:decode_sc_car_hint_reply(MsgBin)};
decode_msg_bin(300, MsgBin) ->
    {ok, car_pb:decode_sc_car_result_reply(MsgBin)};
decode_msg_bin(301, MsgBin) ->
    {ok, car_pb:decode_sc_car_pool_reply(MsgBin)};
decode_msg_bin(303, MsgBin) ->
    {ok, car_pb:decode_cs_car_add_money_req(MsgBin)};
decode_msg_bin(304, MsgBin) ->
    {ok, car_pb:decode_sc_car_add_money_reply(MsgBin)};
decode_msg_bin(305, MsgBin) ->
    {ok,
     car_pb:decode_cs_car_syn_in_game_state_req(MsgBin)};
decode_msg_bin(310, MsgBin) ->
    {ok,
     share_pb:decode_sc_task_seven_info_response(MsgBin)};
decode_msg_bin(311, MsgBin) ->
    {ok,
     share_pb:decode_cs_task_seven_award_request(MsgBin)};
decode_msg_bin(312, MsgBin) ->
    {ok,
     share_pb:decode_sc_task_seven_award_response(MsgBin)};
decode_msg_bin(313, MsgBin) ->
    {ok, share_pb:decode_cs_share_with_friends_req(MsgBin)};
decode_msg_bin(320, MsgBin) ->
    {ok,
     player_pb:decode_cs_super_laba_last_week_rank_query_req(MsgBin)};
decode_msg_bin(321, MsgBin) ->
    {ok,
     player_pb:decode_sc_super_laba_last_week_rank_query_reply(MsgBin)};
decode_msg_bin(322, MsgBin) ->
    {ok,
     player_pb:decode_cs_query_last_daily_rank_reward_req(MsgBin)};
decode_msg_bin(323, MsgBin) ->
    {ok,
     player_pb:decode_sc_query_last_daily_rank_reward_reply(MsgBin)};
decode_msg_bin(324, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_stickiness_redpack_info_notify(MsgBin)};
decode_msg_bin(325, MsgBin) ->
    {ok,
     player_pb:decode_cs_stickiness_redpack_draw_req(MsgBin)};
decode_msg_bin(326, MsgBin) ->
    {ok,
     player_pb:decode_sc_stickiness_redpack_draw_resp(MsgBin)};
decode_msg_bin(327, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_stickiness_redpack_info_notify_req(MsgBin)};
decode_msg_bin(328, MsgBin) ->
    {ok,
     shop_pb:decode_sc_period_card_info_update(MsgBin)};
decode_msg_bin(329, MsgBin) ->
    {ok,
     shop_pb:decode_cs_period_card_draw_req(MsgBin)};
decode_msg_bin(330, MsgBin) ->
    {ok,
     shop_pb:decode_sc_period_card_draw_reply(MsgBin)};
decode_msg_bin(331, MsgBin) ->
    {ok,
     car_pb:decode_sc_car_query_pool_win_player_reply(MsgBin)};
decode_msg_bin(332, MsgBin) ->
    {ok,
     car_pb:decode_cs_car_query_pool_win_player_req(MsgBin)};
decode_msg_bin(333, MsgBin) ->
    {ok,
     player_bp:decode_sc_player_bet_stickiness_notify(MsgBin)};
decode_msg_bin(334, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_bet_stickiness_redpack_draw_req(MsgBin)};
decode_msg_bin(335, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_bet_stickiness_redpack_draw_resp(MsgBin)};
decode_msg_bin(336, MsgBin) ->
    {ok,
     player_pb:decode_cs_bet_lock_config_req(MsgBin)};
decode_msg_bin(337, MsgBin) ->
    {ok,
     player_pb:decode_sc_bet_lock_config_resp(MsgBin)};
decode_msg_bin(338, MsgBin) ->
    {ok,
     player_pb:decode_sc_bet_lock_update_notify(MsgBin)};
decode_msg_bin(339, MsgBin) ->
    {ok,
     player_pb:decode_cs_player_salary_query_req(MsgBin)};
decode_msg_bin(340, MsgBin) ->
    {ok,
     player_pb:decode_sc_player_salary_query_resp(MsgBin)};
decode_msg_bin(341, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_enter_room_req(MsgBin)};
decode_msg_bin(342, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_enter_room_reply(MsgBin)};
decode_msg_bin(343, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_leave_room_req(MsgBin)};
decode_msg_bin(344, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_leave_room_reply(MsgBin)};
decode_msg_bin(345, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_fire_bet_req(MsgBin)};
decode_msg_bin(346, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_fire_bet_reply(MsgBin)};
decode_msg_bin(347, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_switch_phase_req(MsgBin)};
decode_msg_bin(348, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_switch_phase_reply(MsgBin)};
decode_msg_bin(349, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_pool_num_update(MsgBin)};
decode_msg_bin(350, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_use_item_req(MsgBin)};
decode_msg_bin(351, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_use_item_reply(MsgBin)};
decode_msg_bin(352, MsgBin) ->
    {ok,
     laba_pb:decode_cs_airlaba_impov_sub_req(MsgBin)};
decode_msg_bin(353, MsgBin) ->
    {ok,
     laba_pb:decode_sc_airlaba_impov_sub_reply(MsgBin)};
decode_msg_bin(354, MsgBin) ->
    {ok,
     player_pb:decode_cs_lottery_draw_req(MsgBin)};
decode_msg_bin(355, MsgBin) ->
    {ok,
     player_pb:decode_sc_lottery_draw_resp(MsgBin)};
decode_msg_bin(_, _) -> error.

split_bin(<<1:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 1, 0, MsgBin};
split_bin(<<2:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 2, 0, MsgBin};
split_bin(<<3:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 3, 0, MsgBin};
split_bin(<<4:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 4, 0, MsgBin};
split_bin(<<5:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 5, 0, MsgBin};
split_bin(<<6:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 6, 0, MsgBin};
split_bin(<<7:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 7, 0, MsgBin};
split_bin(<<8:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 8, 0, MsgBin};
split_bin(<<9:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 9, 0, MsgBin};
split_bin(<<10:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 10, 0, MsgBin};
split_bin(<<11:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 11, 0, MsgBin};
split_bin(<<12:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 12, 0, MsgBin};
split_bin(<<13:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 13, 0, MsgBin};
split_bin(<<14:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 14, 0, MsgBin};
split_bin(<<15:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 15, 0, MsgBin};
split_bin(<<16:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 16, 0, MsgBin};
split_bin(<<17:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 17, 0, MsgBin};
split_bin(<<18:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 18, 0, MsgBin};
split_bin(<<19:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 19, 0, MsgBin};
split_bin(<<20:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 20, 0, MsgBin};
split_bin(<<21:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 21, 0, MsgBin};
split_bin(<<22:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 22, 0, MsgBin};
split_bin(<<23:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 23, 0, MsgBin};
split_bin(<<24:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 24, 0, MsgBin};
split_bin(<<25:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 25, 0, MsgBin};
split_bin(<<26:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 26, 0, MsgBin};
split_bin(<<28:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 28, 0, MsgBin};
split_bin(<<29:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 29, 0, MsgBin};
split_bin(<<30:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 30, 0, MsgBin};
split_bin(<<31:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 31, 0, MsgBin};
split_bin(<<32:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 32, 0, MsgBin};
split_bin(<<33:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 33, 0, MsgBin};
split_bin(<<34:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 34, 0, MsgBin};
split_bin(<<35:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 35, 0, MsgBin};
split_bin(<<40:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 40, 0, MsgBin};
split_bin(<<41:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 41, 0, MsgBin};
split_bin(<<42:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 42, 0, MsgBin};
split_bin(<<43:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 43, 0, MsgBin};
split_bin(<<44:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 44, 0, MsgBin};
split_bin(<<45:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 45, 0, MsgBin};
split_bin(<<46:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 46, 0, MsgBin};
split_bin(<<50:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 50, 0, MsgBin};
split_bin(<<51:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 51, 0, MsgBin};
split_bin(<<52:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 52, 0, MsgBin};
split_bin(<<53:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 53, 0, MsgBin};
split_bin(<<54:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 54, 0, MsgBin};
split_bin(<<55:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 55, 0, MsgBin};
split_bin(<<56:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 56, 0, MsgBin};
split_bin(<<57:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 57, 0, MsgBin};
split_bin(<<58:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 58, 0, MsgBin};
split_bin(<<59:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 59, 0, MsgBin};
split_bin(<<60:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 60, 0, MsgBin};
split_bin(<<61:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 61, 0, MsgBin};
split_bin(<<62:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 62, 0, MsgBin};
split_bin(<<63:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 63, 0, MsgBin};
split_bin(<<64:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 64, 0, MsgBin};
split_bin(<<65:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 65, 0, MsgBin};
split_bin(<<66:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 66, 0, MsgBin};
split_bin(<<67:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 67, 0, MsgBin};
split_bin(<<68:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 68, 0, MsgBin};
split_bin(<<69:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 69, 0, MsgBin};
split_bin(<<70:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 70, 0, MsgBin};
split_bin(<<71:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 71, 0, MsgBin};
split_bin(<<72:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 72, 0, MsgBin};
split_bin(<<73:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 73, 0, MsgBin};
split_bin(<<74:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 74, 0, MsgBin};
split_bin(<<75:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 75, 0, MsgBin};
split_bin(<<76:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 76, 0, MsgBin};
split_bin(<<77:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 77, 0, MsgBin};
split_bin(<<78:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 78, 0, MsgBin};
split_bin(<<80:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 80, 1, MsgBin};
split_bin(<<81:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 81, 0, MsgBin};
split_bin(<<82:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 82, 0, MsgBin};
split_bin(<<83:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 83, 0, MsgBin};
split_bin(<<84:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 84, 0, MsgBin};
split_bin(<<85:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 85, 0, MsgBin};
split_bin(<<86:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 86, 0, MsgBin};
split_bin(<<87:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 87, 0, MsgBin};
split_bin(<<88:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 88, 0, MsgBin};
split_bin(<<90:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 90, 0, MsgBin};
split_bin(<<91:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 91, 1, MsgBin};
split_bin(<<92:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 92, 0, MsgBin};
split_bin(<<93:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 93, 0, MsgBin};
split_bin(<<94:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 94, 0, MsgBin};
split_bin(<<95:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 95, 0, MsgBin};
split_bin(<<96:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 96, 0, MsgBin};
split_bin(<<97:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 97, 0, MsgBin};
split_bin(<<98:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 98, 0, MsgBin};
split_bin(<<99:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 99, 0, MsgBin};
split_bin(<<100:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 100, 0, MsgBin};
split_bin(<<101:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 101, 0, MsgBin};
split_bin(<<102:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 102, 0, MsgBin};
split_bin(<<103:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 103, 0, MsgBin};
split_bin(<<104:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 104, 0, MsgBin};
split_bin(<<105:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 105, 0, MsgBin};
split_bin(<<106:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 106, 0, MsgBin};
split_bin(<<107:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 107, 0, MsgBin};
split_bin(<<108:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 108, 0, MsgBin};
split_bin(<<109:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 109, 0, MsgBin};
split_bin(<<110:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 110, 0, MsgBin};
split_bin(<<111:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 111, 0, MsgBin};
split_bin(<<112:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 112, 0, MsgBin};
split_bin(<<113:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 113, 0, MsgBin};
split_bin(<<114:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 114, 0, MsgBin};
split_bin(<<115:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 115, 0, MsgBin};
split_bin(<<120:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 120, 0, MsgBin};
split_bin(<<121:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 121, 0, MsgBin};
split_bin(<<122:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 122, 0, MsgBin};
split_bin(<<123:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 123, 0, MsgBin};
split_bin(<<124:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 124, 0, MsgBin};
split_bin(<<130:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 130, 0, MsgBin};
split_bin(<<131:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 131, 0, MsgBin};
split_bin(<<132:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 132, 0, MsgBin};
split_bin(<<133:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 133, 0, MsgBin};
split_bin(<<140:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 140, 0, MsgBin};
split_bin(<<141:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 141, 0, MsgBin};
split_bin(<<142:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 142, 0, MsgBin};
split_bin(<<143:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 143, 0, MsgBin};
split_bin(<<144:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 144, 0, MsgBin};
split_bin(<<145:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 145, 0, MsgBin};
split_bin(<<146:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 146, 0, MsgBin};
split_bin(<<147:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 147, 0, MsgBin};
split_bin(<<148:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 148, 0, MsgBin};
split_bin(<<150:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 150, 0, MsgBin};
split_bin(<<151:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 151, 0, MsgBin};
split_bin(<<152:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 152, 0, MsgBin};
split_bin(<<153:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 153, 0, MsgBin};
split_bin(<<154:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 154, 0, MsgBin};
split_bin(<<155:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 155, 0, MsgBin};
split_bin(<<156:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 156, 0, MsgBin};
split_bin(<<157:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 157, 0, MsgBin};
split_bin(<<158:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 158, 0, MsgBin};
split_bin(<<160:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 160, 0, MsgBin};
split_bin(<<161:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 161, 0, MsgBin};
split_bin(<<162:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 162, 0, MsgBin};
split_bin(<<163:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 163, 0, MsgBin};
split_bin(<<164:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 164, 0, MsgBin};
split_bin(<<165:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 165, 0, MsgBin};
split_bin(<<166:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 166, 0, MsgBin};
split_bin(<<167:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 167, 0, MsgBin};
split_bin(<<168:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 168, 0, MsgBin};
split_bin(<<169:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 169, 0, MsgBin};
split_bin(<<201:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 201, 1, MsgBin};
split_bin(<<202:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 202, 0, MsgBin};
split_bin(<<203:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 203, 0, MsgBin};
split_bin(<<204:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 204, 0, MsgBin};
split_bin(<<205:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 205, 0, MsgBin};
split_bin(<<206:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 206, 0, MsgBin};
split_bin(<<207:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 207, 0, MsgBin};
split_bin(<<208:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 208, 0, MsgBin};
split_bin(<<209:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 209, 0, MsgBin};
split_bin(<<210:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 210, 0, MsgBin};
split_bin(<<211:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 211, 0, MsgBin};
split_bin(<<212:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 212, 0, MsgBin};
split_bin(<<213:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 213, 0, MsgBin};
split_bin(<<214:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 214, 0, MsgBin};
split_bin(<<215:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 215, 0, MsgBin};
split_bin(<<216:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 216, 0, MsgBin};
split_bin(<<217:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 217, 0, MsgBin};
split_bin(<<218:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 218, 0, MsgBin};
split_bin(<<220:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 220, 0, MsgBin};
split_bin(<<221:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 221, 0, MsgBin};
split_bin(<<222:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 222, 0, MsgBin};
split_bin(<<223:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 223, 0, MsgBin};
split_bin(<<224:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 224, 0, MsgBin};
split_bin(<<225:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 225, 0, MsgBin};
split_bin(<<226:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 226, 0, MsgBin};
split_bin(<<227:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 227, 0, MsgBin};
split_bin(<<228:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 228, 0, MsgBin};
split_bin(<<229:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 229, 0, MsgBin};
split_bin(<<230:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 230, 0, MsgBin};
split_bin(<<231:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 231, 0, MsgBin};
split_bin(<<232:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 232, 0, MsgBin};
split_bin(<<233:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 233, 1, MsgBin};
split_bin(<<234:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 234, 0, MsgBin};
split_bin(<<235:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 235, 0, MsgBin};
split_bin(<<236:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 236, 0, MsgBin};
split_bin(<<237:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 237, 0, MsgBin};
split_bin(<<238:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 238, 0, MsgBin};
split_bin(<<239:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 239, 0, MsgBin};
split_bin(<<240:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 240, 0, MsgBin};
split_bin(<<241:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 241, 0, MsgBin};
split_bin(<<250:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 250, 0, MsgBin};
split_bin(<<251:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 251, 0, MsgBin};
split_bin(<<252:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 252, 0, MsgBin};
split_bin(<<253:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 253, 0, MsgBin};
split_bin(<<254:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 254, 0, MsgBin};
split_bin(<<255:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 255, 0, MsgBin};
split_bin(<<256:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 256, 0, MsgBin};
split_bin(<<257:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 257, 0, MsgBin};
split_bin(<<258:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 258, 0, MsgBin};
split_bin(<<259:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 259, 0, MsgBin};
split_bin(<<260:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 260, 0, MsgBin};
split_bin(<<261:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 261, 0, MsgBin};
split_bin(<<262:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 262, 0, MsgBin};
split_bin(<<263:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 263, 0, MsgBin};
split_bin(<<264:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 264, 0, MsgBin};
split_bin(<<266:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 266, 0, MsgBin};
split_bin(<<267:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 267, 0, MsgBin};
split_bin(<<268:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 268, 0, MsgBin};
split_bin(<<269:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 269, 0, MsgBin};
split_bin(<<270:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 270, 0, MsgBin};
split_bin(<<271:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 271, 0, MsgBin};
split_bin(<<272:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 272, 0, MsgBin};
split_bin(<<273:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 273, 0, MsgBin};
split_bin(<<274:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 274, 0, MsgBin};
split_bin(<<275:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 275, 0, MsgBin};
split_bin(<<276:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 276, 0, MsgBin};
split_bin(<<277:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 277, 0, MsgBin};
split_bin(<<278:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 278, 0, MsgBin};
split_bin(<<280:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 280, 1, MsgBin};
split_bin(<<281:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 281, 0, MsgBin};
split_bin(<<282:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 282, 0, MsgBin};
split_bin(<<283:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 283, 0, MsgBin};
split_bin(<<284:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 284, 0, MsgBin};
split_bin(<<285:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 285, 0, MsgBin};
split_bin(<<286:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 286, 0, MsgBin};
split_bin(<<287:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 287, 0, MsgBin};
split_bin(<<288:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 288, 0, MsgBin};
split_bin(<<289:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 289, 0, MsgBin};
split_bin(<<290:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 290, 0, MsgBin};
split_bin(<<291:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 291, 0, MsgBin};
split_bin(<<292:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 292, 0, MsgBin};
split_bin(<<294:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 294, 0, MsgBin};
split_bin(<<295:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 295, 0, MsgBin};
split_bin(<<296:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 296, 0, MsgBin};
split_bin(<<297:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 297, 0, MsgBin};
split_bin(<<298:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 298, 0, MsgBin};
split_bin(<<299:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 299, 0, MsgBin};
split_bin(<<300:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 300, 0, MsgBin};
split_bin(<<301:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 301, 0, MsgBin};
split_bin(<<303:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 303, 0, MsgBin};
split_bin(<<304:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 304, 0, MsgBin};
split_bin(<<305:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 305, 0, MsgBin};
split_bin(<<310:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 310, 0, MsgBin};
split_bin(<<311:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 311, 0, MsgBin};
split_bin(<<312:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 312, 0, MsgBin};
split_bin(<<313:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 313, 0, MsgBin};
split_bin(<<320:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 320, 0, MsgBin};
split_bin(<<321:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 321, 0, MsgBin};
split_bin(<<322:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 322, 0, MsgBin};
split_bin(<<323:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 323, 0, MsgBin};
split_bin(<<324:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 324, 0, MsgBin};
split_bin(<<325:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 325, 0, MsgBin};
split_bin(<<326:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 326, 0, MsgBin};
split_bin(<<327:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 327, 0, MsgBin};
split_bin(<<328:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 328, 0, MsgBin};
split_bin(<<329:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 329, 0, MsgBin};
split_bin(<<330:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 330, 0, MsgBin};
split_bin(<<331:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 331, 0, MsgBin};
split_bin(<<332:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 332, 0, MsgBin};
split_bin(<<333:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 333, 0, MsgBin};
split_bin(<<334:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 334, 0, MsgBin};
split_bin(<<335:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 335, 0, MsgBin};
split_bin(<<336:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 336, 0, MsgBin};
split_bin(<<337:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 337, 0, MsgBin};
split_bin(<<338:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 338, 0, MsgBin};
split_bin(<<339:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 339, 0, MsgBin};
split_bin(<<340:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 340, 0, MsgBin};
split_bin(<<341:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 341, 0, MsgBin};
split_bin(<<342:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 342, 0, MsgBin};
split_bin(<<343:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 343, 0, MsgBin};
split_bin(<<344:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 344, 0, MsgBin};
split_bin(<<345:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 345, 0, MsgBin};
split_bin(<<346:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 346, 0, MsgBin};
split_bin(<<347:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 347, 0, MsgBin};
split_bin(<<348:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 348, 0, MsgBin};
split_bin(<<349:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 349, 0, MsgBin};
split_bin(<<350:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 350, 0, MsgBin};
split_bin(<<351:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 351, 0, MsgBin};
split_bin(<<352:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 352, 0, MsgBin};
split_bin(<<353:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 353, 0, MsgBin};
split_bin(<<354:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 354, 0, MsgBin};
split_bin(<<355:?INT_PROTO_ID, MsgBin/binary>>) ->
    {ok, 355, 0, MsgBin};
split_bin(_) -> error.
