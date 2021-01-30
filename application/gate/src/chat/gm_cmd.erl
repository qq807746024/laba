%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 二月 2017 16:57
%%%-------------------------------------------------------------------
-module(gm_cmd).
-author("wodong_0013").
-include("log.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
%% API
-compile(export_all).


cmd(TempContent) ->
	case config_app:get_gm_cmd_on() of
		1 ->
			cmd1(TempContent);
		_ ->
			skip
	end.

cmd1(TempContent) ->
	TempContent1 = unicode:characters_to_binary(TempContent),
	Content = erlang:binary_to_list(TempContent1),
	%?INFO_LOG("Content ~p~n",[Content]),
	case string:tokens(Content, " ") of
	%% add_player_exp加玩家经验
		["ai", StrBaseId, StrNum] ->
			BaseId = erlang:list_to_integer(StrBaseId),
			Num = erlang:list_to_integer(StrNum),
			case item_base_db:get_base(BaseId) of
				{ok, [_BaseItem]} ->
					Rewards = [{BaseId, Num}],
					item_use:imme_items_reward(Rewards, ?REWARD_TYPE_BY_CMD);
					%sys_notice_mod:send_notice(io_lib:format("已添加物品id: ~p", [BaseId]));
				_ ->
					sys_notice_mod:send_notice("无效的Id")
			end,
			{is_cmd};
		["bug",_Content1]->
			player_bug_feedback:cs_bug_feedback(TempContent),
			{is_cmd};
		["cname"]->
			player_util:cs_player_change_name_req("ABC"),
			{is_cmd};
		["win",Type1,Key1,Money1]->
			Type = erlang:list_to_integer(Type1),
			Money = erlang:list_to_integer(Money1),
			if
				is_list(Key1)->
					Key = erlang:list_to_atom(Key1);
				true->
					Key = Key1
			end,
			if
				Type == 1->
					player_winning_record:save_winning_record_info(Key,Money, 0);
				Type == 2->
					player_winning_record:get_player_winning_record_info_by_key(Key);
				Type == 3->
					?INFO_LOG(11),
					player_winning_record:change_max_money(Money);
				Type == 4 ->
					player_winning_record:cs_query_player_winning_rec_req(undefined);
				true->
					skip
			end,
			{is_cmd};
		["zmd"]->
			PlayerInfo = player_util:get_dic_player_info(),
			announcement_server:vip_level_change(PlayerInfo#player_info.player_name, PlayerInfo#player_info.vip_level),
			{is_cmd};
		["shop_test",Type1]->
			Type = erlang:list_to_integer(Type1),
			if
				Type == 1 ->
					PlayerInfo = player_util:get_dic_player_info(),
					NewP = PlayerInfo#player_info{
						diamond =  120
					},
					DBFun = fun() ->
						player_info_db:t_write_player_info(NewP)
									end,
					DBSuccessFun = fun() ->
						?INFO_LOG("111")
												 end,
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBSuccessFun();
						{aborted, _Reason} ->
							%?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							err
					end;
				Type == 2 ->
					player_shop:cs_buy(10000, 'client');
				true ->
					skip
			end,
			{is_cmd};
		["checkin",Type,Day]->
			Type1 = erlang:list_to_integer(Type),
			Day1 = erlang:list_to_integer(Day),
			player_checkin:gm_test(Type1,Day1),
			{is_cmd};
		["mission",Type,Id]->
			Type1 = erlang:list_to_integer(Type),
			Id1 = erlang:list_to_integer(Id),
			player_mission:gm_test(Type1,Id1),
			{is_cmd};
		["logout"]->
			GateId = player_util:get_dic_gate_pid(),
			tcp_client:login_out(GateId),
			{is_cmd};
		["cz",Flag] ->
			Type = list_to_integer(Flag),
			rechage_test(Type),
			{is_cmd};
		["mail",Type,Key]->
			Type1 = erlang:list_to_integer(Type),
			Key1 = erlang:list_to_integer(Key),
			player_mail:gm_test(Type1,Key1),
			{is_cmd};
		["niu_chest",Type,Key]->
			Type1 = erlang:list_to_integer(Type),
			Key1 = erlang:list_to_integer(Key),
			player_niu_room_chest:gm_test(Type1,Key1),
			{is_cmd};
		["sub",Type]->
			Type1 = erlang:list_to_integer(Type),
			player_subsidy_util:cs_niu_subsidy_req(Type1),
			{is_cmd};
		["pc"]->
			player_prize_util:test_change_rechage_record(),
			{is_cmd};
		["vip_test",Type,Key]->
			Type1 = erlang:list_to_integer(Type),
			Key1 = erlang:list_to_integer(Key),
			player_vip_util:gm_test(Type1,Key1),
			{is_cmd};
		["redpack",Type,Key]->
			Type1 = erlang:list_to_integer(Type),
			Key1 = erlang:list_to_integer(Key),
			player_redpack_util:gm_test(Type1,Key1),
			{is_cmd};
		["li"]->
			PlayerInfo = player_util:get_dic_player_info(),
			player_laba_util:init(PlayerInfo#player_info.id),
			{is_cmd};
		["mc"]->
			player_shop:cs_buy(60001, 'back'),
			{is_cmd};
		["buy", Id]->
			player_shop:cs_buy(erlang:list_to_integer(Id), 'back'),
			{is_cmd};
		["bc"]->
			PlayerInfo = player_util:get_dic_player_info(),
			player_buy_info_db:delete(PlayerInfo#player_info.id),
			{is_cmd};
		["gt"]->
			PlayerInfo = player_util:get_dic_player_info(),
			dal:delete_rpc(player_game_task_info, PlayerInfo#player_info.id),
			{is_cmd};
		["gd", Id]->
			player_game_task_util:cs_game_task_draw_req(1, list_to_integer(Id)),
			{is_cmd};
		["rt"]->
			PlayerInfo = player_util:get_dic_player_info(),
			dal:delete_rpc(player_pack_task_info, PlayerInfo#player_info.id),
			{is_cmd};
		["aq", Flag]->
			player_activity_util:cs_activity_info_query_req(erlang:list_to_integer(Flag)),
			{is_cmd};
		["ad", Flag1, Flag2]->
			player_activity_util:cs_activity_draw_req(erlang:list_to_integer(Flag1), erlang:list_to_integer(Flag2)),
			{is_cmd};
		["id"]->
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerId = PlayerInfo#player_info.id,
			?INFO_LOG("PM_CZ PlayerId ======== ~p~n",[PlayerId]),
			{is_cmd};
		["hb"]->
			player_redpack_room_util:send_sc_redpack_room_draw_reply(0, "",
				item_use:get_pb_reward_info([{?ITEM_ID_RED_PACK, 4}]), util:now_seconds() + 300),
			{is_cmd};
		["qk", OrderId] ->
			player_prize_util:cs_prize_query_phonecard_key_req(OrderId),
			{is_cmd};
		["ds", Id, Opt] ->
			{ok, StrId} = id_transform_util:item_id_to_proto(list_to_integer(Id)),
			player_redpack_util:cs_red_pack_do_select_req(StrId, list_to_integer(Opt)),
			{is_cmd};
		["ps"] ->
			player_shop:test(),
			{is_cmd};
		["share",Type1,Code1,Type22] ->
			Type = erlang:list_to_integer(Type1),
			Code = erlang:list_to_integer(Code1),
			Type2 = erlang:list_to_integer(Type22),
			player_share_util:gm_test(Type,Code,Type2),
			{is_cmd};
		["car",Type1,Code1,Type22] ->
			Type = erlang:list_to_integer(Type1),
			Code = erlang:list_to_integer(Code1),
			Type2 = erlang:list_to_integer(Type22),
			player_car_util:gm_test(Type,Code,Type2),
			{is_cmd};
		["laba",Type1,Code1,Type22] ->
			Type = erlang:list_to_integer(Type1),
			Code = erlang:list_to_integer(Code1),
			Type2 = erlang:list_to_integer(Type22),
			player_laba_util:gm_test(Type,Code,Type2),
			{is_cmd};
		["prize",Type1] ->
			Type = erlang:list_to_integer(Type1),
			player_prize_util:gm_test(Type),
			{is_cmd};
		["s_w",Type1] ->
			Type = erlang:list_to_integer(Type1),
			player_share_lucky_wheel_util:gm_test(Type),
			player_niu_room_chest:change_process(1),
			{is_cmd};
		_ ->
			skip
	end.

rechage_test(Flag) ->
	PlayerInfo = player_util:get_dic_player_info(),
	PlayerId = PlayerInfo#player_info.id,
	?INFO_LOG("PM_CZ PlayerId ======== ~p~n",[PlayerId]),
	ID          = roleid_generator:get_already_receive_pay_info_id(),
	OrderID = util:now_seconds(),
	AlreadyReceivePayInfo =
		#already_receive_pay_info{
			id = ID,
			order_id    = integer_to_list(OrderID),
			money       = "50",
			server_id   = "1",
			role_id     = integer_to_list(PlayerId),
			call_back   = lists:concat([Flag, ",xxx"]),
			openid      = "xxxxxxx",
			order_status= "1",
			pay_type    = [],
			pay_time    = [],
			chn_id      = [],
			sub_chn_id  = [],
			remark      = []
		},

	case ets:lookup(?ETS_SHOP_ITEM, Flag) of
		[_PayItemInfo]   ->
			case player_info_db:get_player_info_role_id(PlayerId) of
				[_PlayerInfo]    ->
					Fun =   fun() ->
						already_receive_pay_info_db:t_write_already_receive_pay_info(AlreadyReceivePayInfo)
					end,
					case dal:run_transaction_rpc(Fun) of
						{atomic, _} ->
							case role_manager:get_roleprocessor(PlayerId) of
								{ok, PlayerPID} ->
									role_processor_mod:cast(PlayerPID, {'pay_receive_handle', ID});
								_ ->
									io:format("~ts~n",[list_to_binary("玩家不在线")])
							end;
						_ ->
							io:format("~ts~n",[list_to_binary("数据库失败")])
					end;
				_ ->
					io:format("~ts~n",[list_to_binary("玩家查找失败")])
			end;
		_ ->
			io:format("~ts~n",[list_to_binary("无对应充值数据")])
	end.
