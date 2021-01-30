%% @author zouv
%% @doc @todo 玩家相关协议

-module(ge_player).
-include("logger.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/mission_pb.hrl").
-include_lib("network_proto/include/mail_pb.hrl").
-include_lib("network_proto/include/chest_pb.hrl").

-export([handle/2]).

%% 改名
handle(#cs_player_change_name_req{} = Msg, StateName) ->
	NewName = Msg#cs_player_change_name_req.name,
	player_util:cs_player_change_name_req(NewName),
	StateName;

%% 改头像
handle(#cs_player_change_headicon_req{} = Msg, StateName) ->
	NewIcon = Msg#cs_player_change_headicon_req.icon,
	Sex = Msg#cs_player_change_headicon_req.sex,
	player_util:cs_player_change_headicon_req(NewIcon, Sex),
	StateName;

%% 聊天
handle(#cs_player_chat{} = Msg, StateName) ->
	#cs_player_chat{
		room_type = RoomType,
		content_type = ContentType,
		content = Content,
		obj_player_uuid = ObjPlayerUuid
	} = Msg,
%% 	case id_transform_util:role_id_to_internal(ObjPlayerUuid) of
%% 		{ok, ObjPlayerId} ->
%% 			ok;
%% 		_ ->
%% 			ObjPlayerId = 0
%% 	end,
	player_chat:cs_chat(RoomType, ContentType, Content, ObjPlayerUuid),
	StateName;

%% 查询记录
handle(#cs_query_player_winning_rec_req{} = Msg, StateName) ->
	player_winning_record:cs_query_player_winning_rec_req(Msg#cs_query_player_winning_rec_req.obj_player_uuid),
	StateName;


%% bug反馈
handle(#cs_common_bug_feedback{} = Msg, StateName)->
	#cs_common_bug_feedback{
		content = Content
	} = Msg,
	player_bug_feedback:cs_bug_feedback(Content),
	StateName;

%% 查询人数
handle(#cs_niu_query_in_game_player_num_req{} = Msg, StateName) ->
	player_niu_room_util:cs_niu_query_in_game_player_num_req(Msg#cs_niu_query_in_game_player_num_req.game_type),
	StateName;

%% 破产补助
handle(#cs_niu_subsidy_req{} = Msg, StateName)->
	player_subsidy_util:cs_niu_subsidy_req(Msg#cs_niu_subsidy_req.type),
	StateName;

%% 领取任务奖励
handle(#cs_draw_mission_request{} = Msg,StateName)->
	#cs_draw_mission_request{
		id = Id
	} = Msg,
	player_mission:draw(Id),
	StateName;

%% 查询排行榜
handle(#cs_rank_query_req{} = Msg,StateName)->
	player_rank_util:cs_rank_query_req(Msg#cs_rank_query_req.rank_type),
	StateName;

%% 读
handle(#cs_read_mail{} = Msg,StateName)->
	{ok, MailId} = id_transform_util:mail_id_to_internal(Msg#cs_read_mail.mail_id),
	player_mail:read(MailId),
	StateName;

%% 领邮件
handle(#cs_mail_draw_request{} = Msg,StateName)->
	player_mail:draw_rewards(Msg#cs_mail_draw_request.mail_ids, Msg#cs_mail_draw_request.request_mark),
	StateName;
%% 删邮件
handle(#cs_mail_delete_request{} = Msg,StateName)->
	player_mail:draw_rewards(Msg#cs_mail_delete_request.mail_id,Msg#cs_mail_draw_request.request_mark),
	StateName;
%% 签到
handle(#cs_daily_checkin_req{} = Msg,StateName)->
	player_checkin:cs_daily_checkin(Msg#cs_daily_checkin_req.flag),
	StateName;
%% 补签
handle(#cs_make_up_for_checkin_req{} = Msg,StateName)->
	player_checkin:cs_make_up_for_checkin(Msg#cs_make_up_for_checkin_req.flag),
	StateName;
%% vip每日登录礼包
handle(#cs_vip_daily_reward{} = _Msg,StateName)->
	player_vip_util:cs_vip_daily_reward(),
	StateName;
%% 对局宝箱
handle(#cs_player_niu_room_chest_draw{} = Msg,StateName)->
	player_niu_room_chest:draw(Msg#cs_player_niu_room_chest_draw.type,Msg#cs_player_niu_room_chest_draw.game_type),
	StateName;
%% 绑定手机号领奖
handle(#cs_player_bind_phone_num_draw{} = _Msg,StateName)->
	player_util:cs_player_bind_phone_num_draw(),
	StateName;
%% 引导领奖
handle(#cs_guide_next_step_req{} = Msg,StateName)->
	player_guide_util:cs_guide_next_step_req(Msg#cs_guide_next_step_req.next_step_id),
	StateName;

%% 游戏任务领奖
handle(#cs_game_task_draw_req{} = Msg,StateName)->
  player_game_task_util:cs_game_task_draw_req(Msg#cs_game_task_draw_req.game_type,
    Msg#cs_game_task_draw_req.task_id),
  StateName;

%% 游戏任务领宝箱
handle(#cs_game_task_box_draw_req{} = Msg,StateName)->
  player_game_task_util:cs_game_task_box_draw_req(Msg#cs_game_task_box_draw_req.game_type,
    Msg#cs_game_task_box_draw_req.box
  ),
  StateName;

%% 查询上周百人排行
handle(#cs_hundred_last_week_rank_query_req{} = _Msg,StateName)->
	player_rank_util:cs_hundred_last_week_rank_query_req(),
	StateName;

%% 实名认证
handle(#cs_real_name_update{} = Msg,StateName)->
	player_util:real_name_authentication(Msg#cs_real_name_update.name,Msg#cs_real_name_update.id_card_num),
	StateName;

%% 实名认证查询
handle(#cs_real_name_req{} = _Msg,StateName)->
	player_util:cs_real_name_req(),
	StateName;
%% 超级拉霸上周排行
handle(#cs_super_laba_last_week_rank_query_req{} = _Msg,StateName)->
	player_rank_util:cs_super_laba_last_week_rank_query_req(),
	StateName;

%% 查询最近的每日榜单发奖情况 
handle(#cs_query_last_daily_rank_reward_req{} = _Msg, StateName) ->
	player_rank_util:cs_query_last_daily_rank_reward_req(_Msg#cs_query_last_daily_rank_reward_req.type),
	StateName;

%% 粘性红包领取
handle(#cs_stickiness_redpack_draw_req{} = _Msg, StateName) ->
	player_stickiness_redpack:cs_stickiness_redpack_draw_req(_Msg#cs_stickiness_redpack_draw_req.room_type, _Msg#cs_stickiness_redpack_draw_req.testtype),
	StateName;
handle(#cs_player_stickiness_redpack_info_notify_req{} = Msg, StateName) ->
	player_stickiness_redpack:cs_player_stickiness_redpack_info_notify_req(Msg#cs_player_stickiness_redpack_info_notify_req.room_type,
		Msg#cs_player_stickiness_redpack_info_notify_req.testtype),
	StateName;
handle(#cs_player_bet_stickiness_redpack_draw_req{} = Msg, StateName) ->
	player_bet_stickiness_redpack:cs_player_bet_stickiness_redpack_draw_req(Msg#cs_player_bet_stickiness_redpack_draw_req.room_type,
		Msg#cs_player_bet_stickiness_redpack_draw_req.testtype, Msg#cs_player_bet_stickiness_redpack_draw_req.level),
	StateName;
handle(#cs_bet_lock_config_req{} = Msg, StateName) ->
	player_bet_lock:cs_bet_lock_config_req(Msg#cs_bet_lock_config_req.room_type,
		Msg#cs_bet_lock_config_req.testtype),
	StateName;
handle(#cs_player_salary_query_req{} = _Msg, StateName) ->
	player_daily_salary:cs_player_salary_query_req(),
	StateName;
handle(#cs_lottery_draw_req{} = Msg, StateName) ->
	player_lottery_util:cs_lottery_draw_req(Msg#cs_lottery_draw_req.prize_cls),
	StateName;

handle(Msg, StateName) ->
	?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
	StateName.
