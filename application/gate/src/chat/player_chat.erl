%% @author zouv
%% @doc @todo 聊天系统

-module(player_chat).

-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(CHAT_LIMIT, 15 * 3).    % 30个汉字

-define(LABA_DIAMOND_COST, 20).     % 无喇叭时消耗元宝

-define(CHAT_CD, 2).    % 2scd
-define(CHAT_CD_LAST_TIME_DICT, chat_cd_last_time_dict).    %时间
-define(MAGIC_CHAT_COST_GOLD, 20).    %魔法表情消耗
%% ====================================================================
%% API functions
%% ====================================================================
-export([
	send_msg_notice/2,
	cs_chat/4,
	set_chat_forbid/1
]).

-define(CHAT_ROOM_TYPE_NIU, 1).        % 牛牛
-define(CHAT_ROOM_TYPE_HUNDRED, 2).        % 百人
-define(CHAT_ROOM_TYPE_CAR, 3).        % 豪车


%% ====================================================================
%% Internal functions
%% ====================================================================
%% 聊天
cs_chat(RoomType, ContentType, Content, ObjPlayerId) ->
%%	?INFO_LOG("cs_chat~p~n",[{RoomType,ContentType, Content, ObjPlayerId}]),
	case gm_cmd:cmd(Content) of
		{is_cmd} ->
			skip;
		_ ->
			Content1 = unicode:characters_to_binary(Content),
			NewContent = erlang:binary_to_list(Content1),
			CdCheckFlag = check_chat_cd(),
			PlayerInfo = player_util:get_dic_player_info(),
			%% 暂时不做禁言
			if
				PlayerInfo#player_info.chat_forbid_state == 1 ->
					sys_notice_mod:send_notice("您已被禁言");
				not CdCheckFlag andalso ContentType /= 2->
					if
						(PlayerInfo#player_info.is_robot andalso ContentType == 2) andalso RoomType /= ?CHAT_ROOM_TYPE_CAR ->
							erlang:send_after(2 * 1000, self(), {'robot_send_magic_expression_delay', RoomType, ContentType,Content,ObjPlayerId});
						true ->
							skip
						end,
					sys_notice_mod:send_notice("您的打字速度过快  请稍后再试");
				length(NewContent) > ?CHAT_LIMIT ->
					sys_notice_mod:send_notice("不得超过15字");
				RoomType < ?CHAT_ROOM_TYPE_NIU andalso RoomType > ?CHAT_ROOM_TYPE_CAR ->
					sys_notice_mod:send_notice("房间类型错误");
				true ->
					case check_cost_magic_gold(ContentType,RoomType) of
						true ->
							cs_chat1(RoomType, 30000, ContentType, NewContent, ObjPlayerId);
						_ ->
							sys_notice_mod:send_notice("金币不足")
					end
			end
	end.



cs_chat1(RoomType, _CdTime, ContentType, NewContent, ObjPlayerId) ->

%%	?INFO_LOG("state_2"),
	PlayerRoomInfo =
		case RoomType of
			?CHAT_ROOM_TYPE_NIU ->
				player_niu_room_util:get_player_room_info();
			?CHAT_ROOM_TYPE_HUNDRED ->
				player_hundred_niu_util:get_player_room_info();
			?CHAT_ROOM_TYPE_CAR ->
				player_car_util:get_player_car_room_info();
			_ ->
				[]
		end,
	case player_niu_room_util:get_room_pid(PlayerRoomInfo) of
		{ok, RoomPid} ->
			PlayerInfo = player_util:get_dic_player_info(),
			{ok, PlayerUuid} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
			MsgPre = #sc_player_chat{
				room_type = RoomType,
				content_type = ContentType,
				content = NewContent,
				player_uuid = PlayerUuid,
				player_name = PlayerInfo#player_info.player_name,
				player_icon = PlayerInfo#player_info.icon,
				player_vip = PlayerInfo#player_info.vip_level,
				player_seat_pos = 0,
				send_time = util:now_seconds(),
				des_player_uuid = ObjPlayerId
			},
			if
				PlayerInfo#player_info.is_robot ->
					skip;
				true ->
					case ContentType of
						2 ->
							case RoomType of
								?CHAT_ROOM_TYPE_NIU ->
									gen_fsm:send_all_state_event(RoomPid, {'robot_follow_send_chat_msg',RoomType, ContentType,NewContent, ObjPlayerId});
								_ ->
									skip
							end;
						_ ->
							skip
					end
			end,
			http_static_util:post_talk(PlayerInfo,RoomType,NewContent),
			gen_fsm:send_all_state_event(RoomPid, {'send_chat_msg', MsgPre, PlayerInfo#player_info.id, ObjPlayerId});
		_ ->
			sys_notice_mod:send_notice("房间信息错误")
	end.

%% 发送公告
send_msg_notice(Flag, Content) ->
	ModPid = sys_notice_mod:get_mod_pid(),
	gen_server:cast(ModPid, {'send_msg_notice_to_all', Flag, Content}).

check_chat_cd() ->
	NowSecond = util:now_seconds(),
	case get(?CHAT_CD_LAST_TIME_DICT) of
		undefined ->
			put(?CHAT_CD_LAST_TIME_DICT, NowSecond),
			true;
		LastChatSecond ->
			if
				LastChatSecond + ?CHAT_CD > NowSecond ->
					false;
				true ->
					put(?CHAT_CD_LAST_TIME_DICT, NowSecond),
					true
			end
	end.

check_cost_magic_gold(ContentType,RoomType) ->
	PlayerInfo = player_util:get_dic_player_info(),
	if
		(ContentType == 2 andalso RoomType /= ?CHAT_ROOM_TYPE_CAR) ->
			if
				PlayerInfo#player_info.gold >= ?MAGIC_CHAT_COST_GOLD ->
					item_use:imme_items_reward([{?ITEM_ID_GOLD, -?MAGIC_CHAT_COST_GOLD}], ?REWARD_TYPE_CHAT_MAGIC_COST),
					true;
				true ->
					false
			end;
		true ->
			true
	end.

set_chat_forbid(Flag) ->
	PlayerInfo = player_util:get_dic_player_info(),
	NewPlayerInfo = PlayerInfo#player_info{chat_forbid_state = Flag},
	player_util:save_player_info(NewPlayerInfo).