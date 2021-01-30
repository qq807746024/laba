%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 二月 2017 15:38
%%%-------------------------------------------------------------------
-module(niu_room_tool).
-author("wodong_0013").

%% API 分离一些代码 美观一些
-compile(export_all).

-include("common.hrl").
-include("niu_room.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/niu_game_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(ALL_COMBINATION_LIST, [{1,2,3},{1,2,4},{1,2,5},{1,3,4},{1,3,5},{1,4,5},{2,3,4},{2,3,5},{2,4,5},{3,4,5}]).

%% 关闭房间
do_event('close_room') ->
	niu_room_manager:close_room();

%% 聊天
do_event({'send_chat_msg', MsgPre, SendPlayerId, ObjPlayerId}) ->
	do_send_chat_msg(MsgPre, SendPlayerId, ObjPlayerId);

do_event({'robot_follow_send_chat_msg', RoomType, ContentType,NewContent,ObjPlayerId})->
	do_send_robot_chat_msg(RoomType, ContentType,NewContent,ObjPlayerId);

%% 同步在玩 每次开局都置true
do_event({'syn_player_game', PlayerId}) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	PlayerList = RoomDict#niu_room_info.player_list,
	case lists:keyfind(PlayerId, #niu_room_player_rec.player_id, PlayerList) of
		false ->
			skip;
		PlayerRec ->
			NewPlayerRec = PlayerRec#niu_room_player_rec{leave_flag = false},
			NewRoomDict = RoomDict#niu_room_info{
				player_list = lists:keystore(PlayerId, #niu_room_player_rec.player_id, PlayerList, NewPlayerRec)
			},
			niu_room_processor:update_room_info_dict(NewRoomDict)
	end;

%% 同步在玩 每次开局都置true
do_event({'syn_player_gold_num', PlayerId, GoldNum,_Dia}) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	PlayerList = RoomDict#niu_room_info.player_list,
	case lists:keyfind(PlayerId, #niu_room_player_rec.player_id, PlayerList) of
		false ->
			skip;
		PlayerRec ->
			NewPlayerRec = PlayerRec#niu_room_player_rec{now_gold_num = GoldNum},
			NewRoomDict = RoomDict#niu_room_info{
				player_list = lists:keystore(PlayerId, #niu_room_player_rec.player_id, PlayerList, NewPlayerRec)
			},
			niu_room_processor:update_room_info_dict(NewRoomDict),
			%% 同步给其他人
			AllMemberList = niu_room_processor:get_player_id_list_by_playerlist(NewRoomDict#niu_room_info.player_list),
			niu_room_processor:send_to_others_player_info_update(AllMemberList, NewPlayerRec, 'normal')
	end;

%% 同步在玩 每次开局都置true 返回back
do_event({'check_back_to_room', PlayerId, PlayerGateId}) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	PlayerList = RoomDict#niu_room_info.player_list,
	case lists:keyfind(PlayerId, #niu_room_player_rec.player_id, PlayerList) of
		false ->
			%% send_back
			player_niu_room_util:send_niu_enter_room_reply(PlayerGateId, 1, 0);
		PlayerRec ->
			%% 在列表里面则还没进入结算
			NewPlayerRec = PlayerRec#niu_room_player_rec{leave_flag = false},
			NewRoomDict = RoomDict#niu_room_info{
				player_list = lists:keystore(PlayerId, #niu_room_player_rec.player_id, PlayerList, NewPlayerRec)
			},
			niu_room_processor:update_room_info_dict(NewRoomDict),
			player_niu_room_util:send_niu_enter_room_reply(PlayerGateId, 0, 1),
			send_niu_room_reconnetc_msg_info(RoomDict, PlayerId, PlayerGateId),
			niu_room_processor:update_player_room_data(PlayerId,
				NewRoomDict#niu_room_info.room_id, self(), 'enter_room_back', RoomDict#niu_room_info.room_level, 0)
%% 			case role_manager:get_roleprocessor(PlayerId) of
%% 				{ok, Pid} ->
%% 					role_processor_mod:cast(Pid, {'handle', player_niu_room_chest, send_enter_room_msg, [RoomDict#niu_room_info.room_level]});
%% 				_ ->
%% 					skip
%% 			end
	end;

%% 聊天
do_event({'player_base_info_change', PlayerId, ChangeList}) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	PlayerList = RoomDict#niu_room_info.player_list,
	case lists:keyfind(PlayerId, #niu_room_player_rec.player_id, PlayerList) of
		false ->
			%% send_back
			skip;
		PlayerRec ->
			NewPlayerRec=
				lists:foldl(fun({Key, Val}, Acc) ->
					case Key of
						'icon' ->
							Acc#niu_room_player_rec{icon_str = Val};
						'name' ->
							Acc#niu_room_player_rec{player_name = Val};
						'vip_level' ->
							Acc#niu_room_player_rec{vip_level = Val};
						_ ->
							Acc
					end end, PlayerRec, ChangeList),
			NewRoomDict = RoomDict#niu_room_info{
				player_list = lists:keystore(PlayerId, #niu_room_player_rec.player_id, PlayerList, NewPlayerRec)
			},
			niu_room_processor:update_room_info_dict(NewRoomDict),
			AllMemberList = niu_room_processor:get_player_id_list_by_playerlist(NewRoomDict#niu_room_info.player_list),
			niu_room_processor:send_to_others_player_info_update(AllMemberList, NewPlayerRec, 'normal')
	end;

%% do_event('check_add_last_robot') ->
%% 	RoomDict = hundred_niu_processor:get_room_info_dict(),
%% 	#niu_room_info{
%% 		room_level = Level,
%% 		player_list = PlayerList
%% 	} = RoomDict,
%% 	NowMemberNum = length(PlayerList),
%% 	if
%% 		NowMemberNum == 5 ->
%% 			skip;
%% 		true ->
%% 			gen_server:cast(robot_manager:get_mod_pid(), {'need_some_robot_enter', 'five', self(), Level, 1})
%% 	end;

%% 强制踢出玩家
do_event({'kick_ou_player', ObjPlayerId}) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	?INFO_LOG("kick_ou_player~p~n",[RoomDict]),
	?INFO_LOG("niu_room_processor_info~p~n",[erlang:process_info(RoomDict#niu_room_info.room_pid)]),
	PlayerList = RoomDict#niu_room_info.player_list,
	NewList = lists:keydelete(ObjPlayerId, #niu_room_player_rec.player_id, PlayerList),
	NewRoomDict = RoomDict#niu_room_info{
		player_list = NewList
	},
	niu_room_processor:update_room_info_dict(NewRoomDict),
	ok;

do_event(Event) ->
	?ERROR_LOG(" NIU_room_Procesor handle event Error! ~p", [Event]),
	ok.


%% 获得n人卡
get_rand_nman_card_list(NeedNum) ->
	{UseCardList, _} = get_one_man_card_by_num(NeedNum*5),
	InitList = lists:map(fun(_) -> [] end, lists:seq(1, NeedNum)),
	lists:foldl(fun(_E, {UseAcc, LastAcc}) ->
		{ThisUse, Left} = lists:split(NeedNum, LastAcc),
		{lists:map(fun(E) ->
			lists:nth(E, UseAcc) ++ [lists:nth(E, ThisUse)] end, lists:seq(1, NeedNum)), Left}
		end, {InitList, UseCardList}, lists:seq(1, 5)).

get_one_man_card_by_num(NeedCardNum) ->
	lists:foldl(fun(_E, {AccUse, AccLast}) ->
		Num1 = length(AccLast),
		Num = util:rand(1, Num1),
		{Idx, CardInfo} = lists:nth(Num, AccLast),
		NewAcc = lists:keydelete(Idx, 1, AccLast),
		{[CardInfo|AccUse], NewAcc}
	end, {[], ?CARD_TYPE_LIST}, lists:seq(1, NeedCardNum)).

get_one_man_card(LastCardAcc) ->
	lists:foldl(fun(_E, {AccUse, AccLast}) ->
		Num1 = length(AccLast),
		Num = util:rand(1, Num1),
		{Idx, CardInfo} = lists:nth(Num, AccLast),
		NewAcc = lists:keydelete(Idx, 1, AccLast),
		{[CardInfo|AccUse], NewAcc}
	end, {[], LastCardAcc}, lists:seq(1, 5)).

%% 获取牌结算信息
get_card_over_data(CardList) ->
	CardType = calc_card_list_type(CardList),
	[BiggestCardInfo|_] = lists:reverse(lists:sort(CardList)),
	{CardType, BiggestCardInfo}.


calc_card_list_type(CardList) ->
	CardList1 = lists:map(fun({CardNum, C}) ->
		if
			CardNum >= 10 ->
				{10, C};
			true ->
				{CardNum, C}
		end end, CardList),

	{AllCount, TenNum} =
		lists:foldl(fun({NumBer, _Color}, {CountAcc, TenNumAcc}) ->
			if
				NumBer == 10 ->
					{CountAcc+NumBer, TenNumAcc+1};
				true ->
					{CountAcc+NumBer, TenNumAcc}
			end
		end, {0, 0}, CardList1),
	if
		AllCount =< 10 ->
			13;
		true ->
			CheckBigNiu =
				lists:filter(fun({NumBer, _Color}) ->
					NumBer > 10  
				end, CardList),
			Check2 = length(CheckBigNiu),
			if
				Check2 == 5 ->
					12;
				true ->
					NumberList = lists:foldl(fun({NumBer, _Color}, Acc) ->
						case lists:keyfind(NumBer, 1, Acc) of
							false ->
								[{NumBer, 1}|Acc];
							{_, OldNum} ->
								lists:keystore(NumBer, 1, Acc, {NumBer, OldNum+1})
						end
					end, [], CardList),
					[{_, Times1}, {_, Times2} |_] = NumberList,
					if
						Times1 == 4 orelse Times2 == 4 ->
							11;
						true ->
							%% 检测牛牛
							CheckType = AllCount rem 10,
							if
								TenNum >= 3 ->
									%% 有牛
									if
										CheckType == 0 ->
											10;
										true ->
											AllCount rem 10
									end;
								true ->
									case check_list_niuniu(CardList1) of
										true ->
											if
												CheckType == 0 ->
													10;
												true ->
													AllCount rem 10
											end;
										_ ->
											0
									end
							end
					end
			end
	end.

check_member_num_state() ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	#niu_room_info{
		player_list = PlayerList
	} = RoomDict,
	NowMemberNum = length(PlayerList),
	case NowMemberNum of
		0 ->
			?NIU_ROOM_STATE_IDEL_0;
		1 ->
			?NIU_ROOM_STATE_WAITING_PLAYER_ENTER_10;
		_ ->
			?NIU_ROOM_STATE_WAITING_START_11
	end.

state_name_to_id(State) ->
	case State of
		?NIU_ROOM_STATE_IDEL_0 ->
			0;
		?NIU_ROOM_STATE_WAITING_PLAYER_ENTER_10 ->
			10;
		?NIU_ROOM_STATE_WAITING_START_11 ->
			11;
		?NIU_ROOM_STATE_CHOOSE_MASTER_SEND_CARD_20 ->
			20;
		?NIU_ROOM_STATE_CHOOSE_MASTER_SET_MASTER_21 ->
			21;
		?NIU_ROOM_STATE_FREE_USER_SET_RATE_30 ->
			30;
		?NIU_ROOM_STATE_COMPARE_CARD_40 ->
			40;
		?NIU_ROOM_STATE_SETTLEMENT_50 ->
			50;
		_ ->
			999
	end.

%% 检测无10列表中 取n个数可组成10的倍数
check_list_niuniu(CardList1) ->
	check_list_niuniu1(CardList1, ?ALL_COMBINATION_LIST).


check_list_niuniu1(_CardList, []) ->
	false;

check_list_niuniu1(CardList, [{P1, P2, P3}|T]) ->
	CheckNum =
		lists:foldl(fun(EPos, Acc) ->
			{Num, _} = lists:nth(EPos, CardList),
			Num + Acc end, 0, [P1, P2, P3]),
	CheckNum1 = CheckNum rem 10,
	if
		CheckNum1 == 0 ->
			true;
		true ->
			check_list_niuniu1(CardList, T)
	end.

%% 获取玩家离线时获得的奖励 (百人 五人 红包场)
get_player_offline_reward(PlayerId) ->
	case niu_room_offline_reward_db:get_base(PlayerId) of
		{ok, [PlayerOffline]} ->
			PlayerOffline;
		_ ->
			#niu_room_offline_reward{
				player_id = PlayerId,
				total_offline_reward_gold = 0,
				total_offline_reward_diamond = 0
			}
	end.

%% 离线加金币
add_niu_room_offline_gold_reward(PlayerId, Num) ->
	case niu_room_offline_reward_db:get_base(PlayerId) of
		{ok, [PlayerOffline]} ->
			NewPlayerOffline = PlayerOffline#niu_room_offline_reward{
				total_offline_reward_gold = PlayerOffline#niu_room_offline_reward.total_offline_reward_gold + Num
			};
		_ ->
			NewPlayerOffline = #niu_room_offline_reward{
				player_id = PlayerId,
				total_offline_reward_gold = Num
			}
	end,
	niu_room_offline_reward_db:write(NewPlayerOffline).

%% 离线加钻石
add_niu_room_offline_diamond_reward(PlayerId, Num) ->
	case niu_room_offline_reward_db:get_base(PlayerId) of
		{ok, [PlayerOffline]} ->
			NewPlayerOffline = PlayerOffline#niu_room_offline_reward{
				total_offline_reward_diamond = PlayerOffline#niu_room_offline_reward.total_offline_reward_diamond + Num
			};
		_ ->
			NewPlayerOffline = #niu_room_offline_reward{
				player_id = PlayerId,
				total_offline_reward_diamond = Num
			}
	end,
	niu_room_offline_reward_db:write(NewPlayerOffline).

%% 组合返回房间消息
send_niu_room_reconnetc_msg_info(RoomDict, ObjPlayerId, PlayerGateId) ->
	State = RoomDict#niu_room_info.state,
	PlayerList = RoomDict#niu_room_info.player_list,
	MyRec = lists:keyfind(ObjPlayerId, #niu_room_player_rec.player_id, PlayerList),

	Msg1 = #sc_niu_player_back_to_room_info_update{
		state_id = state_name_to_id(State),
		end_sec_time = RoomDict#niu_room_info.end_sec_time,
		player_list = [],
		master_pos = 0,
		my_pos = MyRec#niu_room_player_rec.pos
	},
	case State of
		?NIU_ROOM_STATE_CHOOSE_MASTER_SEND_CARD_20 ->
			%% 你的牌
			PbPlayerList =
				lists:foldl(fun(EPlayerRec, Acc) ->
					case EPlayerRec#niu_room_player_rec.player_id == ObjPlayerId of
						true ->
							CardList = EPlayerRec#niu_room_player_rec.card_list,
							CardPbInfo = niu_room_timer_mod:pack_card_info(lists:sublist(CardList, 4));
						_ ->
							CardPbInfo = []
					end,
					if
						EPlayerRec#niu_room_player_rec.rate_master_set_flag ->
							MasterRate = EPlayerRec#niu_room_player_rec.rate_master;
						true ->
							MasterRate = undefined
					end,
					PbPlayerInfo = packe_player_reconnect_info(RoomDict#niu_room_info.room_level,
						CardPbInfo, EPlayerRec, MasterRate, undefined, undefined),
					[PbPlayerInfo|Acc]
				end, [], PlayerList),
			Msg = Msg1#sc_niu_player_back_to_room_info_update{
				player_list = PbPlayerList,
				master_pos = 0
			};
		?NIU_ROOM_STATE_CHOOSE_MASTER_SET_MASTER_21 ->
			PbPlayerList =
				lists:foldl(fun(EPlayerRec, Acc) ->
					case EPlayerRec#niu_room_player_rec.player_id == ObjPlayerId of
						true ->
							CardList = EPlayerRec#niu_room_player_rec.card_list,
							CardPbInfo = niu_room_timer_mod:pack_card_info(lists:sublist(CardList, 4));
						_ ->
							CardPbInfo = []
					end,
					MasterRate = EPlayerRec#niu_room_player_rec.rate_master,
					PbPlayerInfo = packe_player_reconnect_info(RoomDict#niu_room_info.room_level,
						CardPbInfo, EPlayerRec, MasterRate, undefined, undefined),
					[PbPlayerInfo|Acc]
				end, [], PlayerList),
			case lists:keyfind(RoomDict#niu_room_info.master_id, #niu_room_player_rec.player_id, PlayerList) of
				false ->
					MasterPos = 0;
				MasterRec ->
					MasterPos = MasterRec#niu_room_player_rec.pos
			end,
			Msg = Msg1#sc_niu_player_back_to_room_info_update{
				player_list = PbPlayerList,
				master_pos = MasterPos
			};
		?NIU_ROOM_STATE_FREE_USER_SET_RATE_30 ->
			PbPlayerList =
				lists:foldl(fun(EPlayerRec, Acc) ->
					case EPlayerRec#niu_room_player_rec.player_id == ObjPlayerId of
						true ->
							CardList = EPlayerRec#niu_room_player_rec.card_list,
							CardPbInfo = niu_room_timer_mod:pack_card_info(lists:sublist(CardList, 4));
						_ ->
							CardPbInfo = []
					end,
					MasterRate = EPlayerRec#niu_room_player_rec.rate_master,
					if
						EPlayerRec#niu_room_player_rec.rate_master_set_flag ->
							FreeRate = EPlayerRec#niu_room_player_rec.rate_free;
						true ->
							FreeRate = undefined
					end,
					PbPlayerInfo = packe_player_reconnect_info(RoomDict#niu_room_info.room_level,
						CardPbInfo, EPlayerRec, MasterRate, FreeRate, undefined),
					[PbPlayerInfo|Acc]
				end, [], PlayerList),
			case lists:keyfind(RoomDict#niu_room_info.master_id, #niu_room_player_rec.player_id, PlayerList) of
				false ->
					MasterPos = 0;
				MasterRec ->
					MasterPos = MasterRec#niu_room_player_rec.pos
			end,
			Msg = Msg1#sc_niu_player_back_to_room_info_update{
				player_list = PbPlayerList,
				master_pos = MasterPos
			};

		?NIU_ROOM_STATE_COMPARE_CARD_40 ->
			%% 5牌下发
			PbPlayerList =
				lists:foldl(fun(EPlayerRec, Acc) ->
					case EPlayerRec#niu_room_player_rec.show_card_flag of
						true ->
							CardType = EPlayerRec#niu_room_player_rec.card_type,
							CardList = EPlayerRec#niu_room_player_rec.card_list,
							CardPbInfo = niu_room_timer_mod:pack_card_info(CardList);
						_ ->
							if
								EPlayerRec#niu_room_player_rec.player_id == ObjPlayerId ->
									CardType = EPlayerRec#niu_room_player_rec.card_type,
									CardList = EPlayerRec#niu_room_player_rec.card_list,
									CardPbInfo = niu_room_timer_mod:pack_card_info(CardList);
								true ->
									CardType = 0,
									CardPbInfo = []
							end
					end,
					MasterRate = EPlayerRec#niu_room_player_rec.rate_master,
					FreeRate = EPlayerRec#niu_room_player_rec.rate_free,
					PbPlayerInfo = packe_player_reconnect_info(RoomDict#niu_room_info.room_level,
						CardPbInfo, EPlayerRec, MasterRate, FreeRate, CardType),
					[PbPlayerInfo|Acc]
				end, [], PlayerList),
			case lists:keyfind(RoomDict#niu_room_info.master_id, #niu_room_player_rec.player_id, PlayerList) of
				false ->
					MasterPos = 0;
				MasterRec ->
					MasterPos = MasterRec#niu_room_player_rec.pos
			end,

			Msg = Msg1#sc_niu_player_back_to_room_info_update{
				player_list = PbPlayerList,
				master_pos = MasterPos
			};
		_ ->
			Msg = Msg1
	end,
	tcp_client:send_data(PlayerGateId, Msg),
	ok.


packe_player_reconnect_info(RoomLevel, CardPbInfo, ERec, MasterRate, FreeRate, CardType) ->
	{ok, PlayerUuid} = id_transform_util:role_id_to_proto(ERec#niu_room_player_rec.player_id),
	ShowNum =
		case RoomLevel of
			?REDPACK_ROOM_LEVEL ->
				ERec#niu_room_player_rec.now_diamond_num;
			_ ->
				ERec#niu_room_player_rec.now_gold_num
		end,
%%	{ok,[Info ]} = player_info_db:get_base(ERec#niu_room_player_rec.player_id),
%%	?INFO_LOG("packe_player_reconnect_info~p~n",[{ERec#niu_room_player_rec.player_id,ERec#niu_room_player_rec.vip_level,Info#player_info.vip_level}]),
	#pb_niu_player_info{
		pos = ERec#niu_room_player_rec.pos,
		player_uuid = PlayerUuid,
		gold_num = ShowNum,
		icon_type = 1,
		icon_url = ERec#niu_room_player_rec.icon_str,
		player_name = ERec#niu_room_player_rec.player_name,
		master_rate = MasterRate,
		free_rate = FreeRate,
		open_card_list = CardPbInfo,
		card_type = CardType,
		vip_level = ERec#niu_room_player_rec.vip_level,
		sex = ERec#niu_room_player_rec.sex
	}.


%% 获取谁获胜卡
get_hundred_5_card_list('master_win') ->
	get_hundred_5_card_list(0);

get_hundred_5_card_list('rand_win') ->
	RandPos = util:rand(0, 4),
	get_hundred_5_card_list(RandPos);

get_hundred_5_card_list(Pos) when Pos >= 0 andalso Pos =< 4 ->
	{FiveCardList, _} = get_rand_nman_card_list(5),
	FiveCardList1 =
		lists:map(fun(ECardList) ->
			{CardType, {Num, Clr}} = get_card_over_data(ECardList),
			{{CardType, Num, Clr}, ECardList} end, FiveCardList),
	FiveCardList2 = lists:keysort(1, FiveCardList1),
	{MaxKey, MaxCardInfo} = lists:last(FiveCardList2),
	FiveCardList3 = lists:keydelete(MaxKey, 1, FiveCardList1),
	FiveCardList4 = lists:map(fun({_, CardList}) -> CardList end, FiveCardList3),
	{List1, List2} = lists:split(Pos, FiveCardList4),
	FiveCardList5 = List1 ++ [MaxCardInfo] ++ List2,
	FiveCardList5;

get_hundred_5_card_list(_) ->
	[].

%% 获取4炸
get_card_info_of_4zha() ->
	RandNum = util:rand(1, 13),
	DeleteList1 = [{RandNum,1}, {RandNum,2}, {RandNum,3}, {RandNum,4}],
	AnotherOneCard = lists:nth(util:rand(1, 12), lists:delete(RandNum, lists:seq(1, 13))),
	{Pre1, End1} = lists:split(util:rand(0, 4), DeleteList1),
	DeleteList = Pre1++[{AnotherOneCard, 1}]++End1,
	LastCard = lists:foldl(fun(E, Acc) ->
		lists:delete(E, Acc) end, ?CARD_TYPE_LIST, DeleteList),
	{UseList, _} =
		lists:foldl(fun(_E, {UseAcc, LastAcc}) ->
			{Use1, Last1} = get_one_man_card(LastAcc),
			{ [Use1 | UseAcc],  Last1}
		end, {[], LastCard}, lists:seq(1, 4)),
	{Pre, End} = lists:split(util:rand(1,4), UseList),
	Pre ++ [DeleteList] ++ End.
	%[DeleteList] ++ UseList.

%% 获取牛牛
get_card_info_of_niuniu() ->
	List1 = [{1,1}, {2, 2}, {3,3}, {3, 4}, {1,4}],
	List2 = [{1,1}, {2, 2}, {3,3}, {3, 4}, {1,4}],
	List3 = [{1,1}, {2, 2}, {3,3}, {3, 4}, {1,4}],
	List4 = [{1,1}, {2, 2}, {3,3}, {3, 4}, {1,4}],
	List5 = [{1,1}, {2, 2}, {3,3}, {3, 4}, {1,4}],
	[List1, List2, List3, List4, List5].


%% 获取5花
get_card_info_of_5big(_LastCard) ->


	ok.

%% 获取5小
get_card_info_of_5small(_LastCard) ->


	ok.


do_send_chat_msg(MsgPre, SendPlayerId, _ObjPlayerId) ->
	RoomDict = niu_room_processor:get_room_info_dict(),
	SeatPos = get_player_seat_pos(RoomDict#niu_room_info.player_list, SendPlayerId),
	Msg = MsgPre#sc_player_chat{
		player_seat_pos = SeatPos
	},
	AllMemberList = niu_room_processor:get_player_id_list_by_playerlist(RoomDict#niu_room_info.player_list),
	niu_room_processor:send_to_members_msg(Msg, AllMemberList).

get_player_seat_pos(PlayerList, SendPlayerId) ->
	case lists:keyfind(SendPlayerId, #niu_room_player_rec.player_id, PlayerList) of
		false ->
			0;
		PlayerRec ->
			PlayerRec#niu_room_player_rec.pos
	end.

do_send_robot_chat_msg(RoomType, ContentType,NewContent,ObjPlayerUid)->
	{ok,ObjPlayerId} = id_transform_util:role_id_to_internal(ObjPlayerUid),
	RoomDict = niu_room_processor:get_room_info_dict(),
	PlayerList = RoomDict#niu_room_info.player_list,
	RobotPlayerList =
	lists:filter(fun(E)->
		E#niu_room_player_rec.player_id /= ObjPlayerId andalso (E#niu_room_player_rec.is_robot) end,PlayerList),
	lists:map(fun(ERec)->
		case role_manager:get_roleprocessor(ERec#niu_room_player_rec.player_id) of
			{ok, RobotPid} ->
				case robot_magic_expression_config_db:get_base(4) of
					{ok,[Config]}->
						Rate = Config#robot_magic_expression_config.probability,
						Flag = niu_room_timer_mod:is_send_robot_msg(Rate),
						if
							Flag ->
								{MinTime,MaxTime} = Config#robot_magic_expression_config.time_rand,
								Time = util:rand(MinTime,MaxTime),
								ComboTimesList = Config#robot_magic_expression_config.combo_times_list,
								ComboWeight =  Config#robot_magic_expression_config.combo_times_weight,
								ComBoTimes = niu_room_robot:get_random_key({ComboTimesList,ComboWeight}),
								lists:map(fun(_E)->
									role_processor_mod:cast(RobotPid, {'robot_send_magic_expression',{Time,RoomType, ContentType,NewContent,ObjPlayerId}})
													end,lists:seq(1,ComBoTimes));
							true ->
								skip
						end;
					_->
						skip
				end;
			_ ->
				skip
		end end,RobotPlayerList).


