%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 三月 2017 21:39
%%%-------------------------------------------------------------------
-module(player_redpack_util).
-author("wodong_0013").


-include("role_processor.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/red_pack_pb.hrl").

-define(RED_PACK_NOTICE_LAST_TIME, 3600 * 24 * 7). %%打开或取消的消息保留时间：7天
-define(RED_PACK_NOTICE_TYPE_UNOPENED, 1).  %%红包未开启
-define(RED_PACK_NOTICE_TYPE_OPEN, 2).    %%红包开启
-define(RED_PACK_NOTICE_TYPE_CANCEL, 3).  %%红包取消

-define(NOTICE_TYPE_STATE, 1).  %%状态信息类型
-define(NOTICE_TYPE_REQ, 2).    %%请求信息类型

%% API
-export([
	%init_player_red_pack_log/1,
	cs_red_pack_query_list_req/2,
	cs_red_pack_create_req/2,

	cs_red_pack_open_req/2,
	cs_red_pack_cancel_req/1,
	cs_red_pack_do_select_req/2,
	cs_red_pack_search_req/1,

	send_red_pack_notice_update/2,
	packet_pb_notice/1,
	send_player_login_red_pack_notice/0,
	send_init_msg/0,
	gm_test/2,
	do_cancel_redpack/1,
	prev_do_cancel_redpack_all/0,
	get_red_pack_info/6
]).
lookup_ets_red_pack_info(Id) ->
	case ets:lookup(?ETS_RED_PACK, Id) of
		[] ->
			{false, "红包已被猜中"};
		[Info] ->
			Info
	end.
lookup_ets_red_pack_key(Id) ->
	case ets:lookup(?ETS_PLAYER_RED_PACK_SEARCH_KEY, Id) of
		[] ->
			#ets_player_red_pack_search_key{
				player_id = Id,
				key = 0
			};
		[Info] ->
			Info
	end.

insert_ets_red_pack(Info) ->
	ets:insert(?ETS_RED_PACK, Info).

insert_ets_red_pack_key(Info) ->
	ets:insert(?ETS_PLAYER_RED_PACK_SEARCH_KEY, Info).

send_init_msg() ->
	PlayerInfo = player_util:get_dic_player_info(),
	AllRedPackNum = red_pack_mod:get_red_pack_all_num(),
	{ok, List} = red_pack_info_db:get_by_player_id(PlayerInfo#player_info.id),
	PbList = pack_pb_red_pack_info(List),
	send_self_red_pack_info(AllRedPackNum, PbList).

send_self_red_pack_info(AllRedPackNum, PbList) ->
	Msg = #sc_self_red_pack_info{
		all_red_pack_num = AllRedPackNum,
		red_pack_list = PbList
	},
	%?INFO_LOG("sc_self_red_pack_info~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


%%查询红包列表
cs_red_pack_query_list_req(StartId, EndId) ->
	PlayerInfo = player_util:get_dic_player_info(),
	KeyInfo = lookup_ets_red_pack_key(PlayerInfo#player_info.id),
	%?INFO_LOG("id~p~n",[StartId, EndId]),
	{InfoList, Length, NewKey, NewStartId} =
		if
			StartId == 1 orelse KeyInfo#ets_player_red_pack_search_key.key == 0 ->
				case ets:last(?ETS_RED_PACK) of
					'$end_of_table' ->
						{[], 0, 0, 1};
					LastKey ->
						get_red_pack_info_list_by_key(LastKey, EndId - StartId + 1, [], 0, StartId)
				end;
			true ->
				get_red_pack_info_list_by_key(KeyInfo#ets_player_red_pack_search_key.key, EndId - StartId + 1, [], 0, StartId)
		end,
	%?INFO_LOG("InfoList ~p~n",[InfoList]),
	PbInfoList = pack_pb_red_pack_info(InfoList),
	MaxNum = red_pack_mod:get_red_pack_all_num(),
	%?INFO_LOG("newkey~p~n",[NewKey]),
	send_red_pack_query_list_back(NewStartId, max(NewStartId, (NewStartId + Length - 1)), MaxNum, PbInfoList),
	insert_ets_red_pack_key(KeyInfo#ets_player_red_pack_search_key{key = NewKey}).

send_red_pack_query_list_back(StartId, EndId, MaxNum, PbInfoList) ->
	Msg = #sc_red_pack_query_list_reply{
		begin_id = StartId,
		end_id = EndId,
		max_num = MaxNum,
		list = PbInfoList
	},
	%?INFO_LOG("sc_red_pack_query_list_reply~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

pack_pb_red_pack_info(InfoList) ->
	NewList =
		lists:map(fun(E) ->
			{ok, PleyerUid} = id_transform_util:role_id_to_proto(E#red_pack_info.player_id),
			Uid = integer_to_list(E#red_pack_info.id),
			#pb_red_pack_info{
				uid = Uid,
				player_name = E#red_pack_info.player_name,
				player_icon = E#red_pack_info.player_icon,
				player_id = PleyerUid,
				min_num = E#red_pack_info.min_num,
				max_num = E#red_pack_info.max_num,
				over_time = E#red_pack_info.create_time,
				des = E#red_pack_info.des,
				account = E#red_pack_info.account,
				sex = E#red_pack_info.sex
			} end, InfoList),
	NewList.

get_red_pack_info_list_by_key(Key, 0, Acc, Num, StartId) ->
	{Acc, Num, Key, StartId};
get_red_pack_info_list_by_key(Key, Length, Acc, Num, StartId) ->
	case ets:lookup(?ETS_RED_PACK, Key) of
		[] ->
			get_red_pack_info_list_from_top();
		[Info] ->
			Acc1 = [Info | Acc],
			case ets:prev(?ETS_RED_PACK, Key) of
				'$end_of_table' ->
					{Acc1, Num + 1, Key, StartId};
				PrevKey ->
					get_red_pack_info_list_by_key(PrevKey, Length - 1, Acc1, Num + 1, StartId)
			end
	end.

get_red_pack_info_list_from_top() ->
	case ets:last(?ETS_RED_PACK) of
		'$end_of_table' ->
			{[], 0, 0};
		Lastkey ->
			get_red_pack_info_list_from_top1(Lastkey, 20, [], 0)
	end.

get_red_pack_info_list_from_top1(Key, 0, Acc, Num) ->
	{Acc, Num, Key, 0};

get_red_pack_info_list_from_top1(Key, Length, Acc, Num) ->
	case ets:lookup(?ETS_RED_PACK, Key) of
		[] ->
			{Acc, Num, Key, 0};
		[Info] ->
			Acc1 = [Info | Acc],
			case ets:prev(?ETS_RED_PACK, Key) of
				'$end_of_table' ->
					{Acc1, Num + 1, Key, 0};
				PrevKey ->
					get_red_pack_info_list_from_top1(PrevKey, Length - 1, Acc1, Num + 1)
			end
	end.


% 发红包
cs_red_pack_create_req(SetNum, Des) ->
	PlayerInfo = player_util:get_dic_player_info(),
	NowSec = util:now_seconds(),
	case check_red_pack_create(PlayerInfo, SetNum) of
		{false, Err} ->
			send_red_pack_create_back(1, Err);
		{Config, CostGold, TaxFee} ->
			Id = roleid_generator:get_auto_red_pack_id(),
			%EtsRedInfo = pack_ets_red_pack_info(SetNum, Des, NowSec, PlayerInfo, Id, Config),
			RedInfo = get_red_pack_info(SetNum, Des, NowSec, PlayerInfo, Id, Config),
			RedPackNotice = pack_red_pack_notice_create(RedInfo, PlayerInfo, ?NOTICE_TYPE_STATE),
			PBRedPckNotice = packet_pb_notice(RedPackNotice),
			PbRedpackInfo = pack_pb_red_pack_info([RedInfo]),
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward([{?ITEM_ID_GOLD, -CostGold}], ?REWARD_TYPE_RED_PACK),

			AllNum = red_pack_mod:get_red_pack_all_num(),

			DBFun = fun() ->
				DBFun1(),
				red_pack_info_db:t_write(RedInfo),
				red_pack_notice_db:t_write(RedPackNotice)
			end,
			DBSuccessFun = fun() ->
				SuccessFun1(),
				insert_ets_red_pack(RedInfo),
				send_red_pack_notice_update([PBRedPckNotice], []),
				send_self_red_pack_info(AllNum + 1, PbRedpackInfo),
				send_red_pack_create_back(0, ""),
				depot_manager_mod:add_to_depot(TaxFee),
				http_static_util:post_set_red_pack(PlayerInfo, RedInfo#red_pack_info.id, SetNum, NowSec)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_red_pack_create_back(1, "数据库错误")
			end
	end.

send_red_pack_create_back(Result, Err) ->
	Msg = #sc_red_pack_create_reply{
		result = Result,
		err = Err
	},
	%?INFO_LOG("sc_red_pack_create_reply~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).


check_red_pack_create(PlayerInfo, SetNum) ->
	%?INFO_LOG("setnum~p~n",[SetNum]),
	HaveGold = PlayerInfo#player_info.gold,
	Flag1 = player_vip_util:is_can_create_red_pack(),
	case red_pack_config_db:get(1) of
		{ok, [Config]} ->
			[MinGlod, MaxGold] = Config#red_pack_config.gold_interval,
			IsInRoom = is_in_room(),
			Fee = Config#red_pack_config.fee,
			PropertyMin = Config#red_pack_config.property_min,
			TaxFee = trunc(SetNum * Fee / 100),
			CostGold = SetNum + TaxFee,
			if
				IsInRoom ->
					{false, "牌局未结束，无法发红包"};
				not Flag1 ->
					{false, "发红包需要VIP3以上"};
				HaveGold < (PropertyMin + CostGold) ->
					{false, "金币不足"};
				SetNum < MinGlod orelse SetNum > MaxGold ->
					{false, "红包金额需介于1000-3000万"};
				true ->
					{ok, List} = red_pack_info_db:get_by_player_id(PlayerInfo#player_info.id),
					Length = length(List),
					if
						Length >= 3 ->
							{false, "同时最多发3个红包"};
						true ->
							{Config, CostGold, TaxFee}
					end
			end;
		_ ->
			{false, "查询红包基础表错误"}
	end.


get_red_pack_info(SetNum, NewDes, NowSec, PlayerInfo, Id, Config) ->
	%?INFO_LOG("PlayerInfo~p~n",[PlayerInfo]),
	[Min, Max] = Config#red_pack_config.gold_interval,
	#red_pack_info{
		id = Id,
		player_name = PlayerInfo#player_info.player_name,
		player_icon = PlayerInfo#player_info.icon,
		player_id = PlayerInfo#player_info.id,
		min_num = Min,
		max_num = Max,
		create_time = NowSec,
		des = NewDes,
		set_num = SetNum,
		account = PlayerInfo#player_info.account,
		sex = PlayerInfo#player_info.sex
	}.


%% 检测玩家是否已猜过该红包
check_already_open_req(RedInfo, OpenPlayerId) ->
	Pattern = #red_pack_notice{
		redpack_id = RedInfo#red_pack_info.id,
		open_player_id = OpenPlayerId,
		_ = '_'
	},
	DBFun = fun() ->
		case mnesia:match_object(Pattern) of
			[] ->
				put(redpack_temp, false);
			_ ->
				put(redpack_temp, true)
		end
	end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	get(redpack_temp).



%猜红包
cs_red_pack_open_req(Uid, CheckNum) ->
	%{ok, Id} = id_transform_util:item_id_to_internal(Uid),
	Id = list_to_integer(Uid),
	Check =
		case lookup_ets_red_pack_info(Id) of
			{false, Err} ->
				{false, Err};
			Info ->
				SetNum = Info#red_pack_info.set_num,
				PlayerInfo = player_util:get_dic_player_info(),
				Flag1 = player_vip_util:is_can_open_red_pack(),
				Flag2 = PlayerInfo#player_info.id == Info#red_pack_info.player_id,
				Flag3 = check_cd_time(),
				put(red_pack_cd_time, util:now_seconds()),
				Flag4 = check_already_open_req(Info, PlayerInfo#player_info.id),
				if
					not Flag3 ->
						{false, "每隔10S才可猜一次红包"};
					not Flag1 ->
						{false, "VIP用户才可猜红包"};
					Flag2 ->
						{false, "不能猜自己的红包"};
					Flag4 ->
						{false, "你已猜过该红包了"};
					SetNum /= CheckNum ->
						{false, "猜错了，再试试看 !"};
					true ->
						Info
				end
		end,
	case Check of
		{false, Err1} ->
			send_red_pack_open_back(1, Err1, 0, Uid);
		RedInfo ->
			PlayerInfo1 = player_util:get_dic_player_info(),
			%% 写入记录 通知发红包者记录更新
			RedPackNotice = pack_red_pack_notice_create(RedInfo, PlayerInfo1, ?NOTICE_TYPE_REQ),
			DBFun = fun() ->
				red_pack_notice_db:t_write(RedPackNotice)
			end,
			NoticeFun =
				case role_manager:get_roleprocessor(RedInfo#red_pack_info.player_id) of
					{ok, Pid} ->
						fun() ->
							role_processor_mod:cast(Pid, {'player_red_pack_notice_update', RedPackNotice#red_pack_notice.id})
						end;
					_ ->
						fun() -> skip end
				end,
			DBSuccessFun = fun() ->
				NoticeFun(),
				send_red_pack_open_back(0, "", RedInfo#red_pack_info.set_num, Uid)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_red_pack_open_back(1, "数据库错误", 0, Uid)
			end
	end.

%% get_obj_player_info(ObjPlayerId) ->
%% 	case player_info_db:get_base(ObjPlayerId) of
%% 		{ok, [PlayerInfo]} ->
%% 			{PlayerInfo#player_info.account, PlayerInfo#player_info.id, PlayerInfo#player_info.player_name};
%% 		_ ->
%% 			{"0", 0, ""}
%% 	end.

send_red_pack_open_back(Result, Err, SetNum, Uid) ->
	Msg = #sc_red_pack_open_reply{
		result = Result,
		err = Err,
		reward_num = SetNum,
		uid = Uid
	},
	%?INFO_LOG("sc_red_pack_open_reply~p~n", [Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

check_cd_time() ->
	CdTime =
		case red_pack_config_db:get(1) of
			{ok, [Info]} ->
				Info#red_pack_config.guess_time;
			_ ->
				10
		end,
	case get(red_pack_cd_time) of
		undefined ->
			true;
		OldTime ->
			NowSec = util:now_seconds(),
			(NowSec - OldTime) > CdTime
	end.

match_and_change_red_pack_search_key(Id, NextKey) ->
	Pid = red_pack_mod:get_mod_pid(),
	gen_server:cast(Pid, {'match_and_change_red_pack_search_key', Id, NextKey}).

delete_ets_red_pack_info(Id) ->
	ets:delete(?ETS_RED_PACK, Id).

confirm_red_pack_notice_open(AccDict, NoticeUuId, Opt) ->
	PlayerInfo = player_util:get_dic_player_info(),
	StateNoticeInfo = dict:fetch(state_notice, AccDict),
	RewardNoticeInfo = dict:fetch(reward_notice, AccDict),
	AllReqNoticeList = dict:fetch(req_notice_id_list, AccDict),
	RedPackInfo = dict:fetch(red_pack_info, AccDict),
	{DBFunConfirm, DBSuccessFunConfirm} = confirm_red_pack_notice_open2(StateNoticeInfo, AllReqNoticeList, RewardNoticeInfo#red_pack_notice.open_player_name),
	DBFun = fun() ->
		red_pack_info_db:t_delete(RedPackInfo#red_pack_info.id),
		delete_ets_red_pack_info(RedPackInfo#red_pack_info.id),
		DBFunConfirm()
	end,
	%{ok, RedPackUuid} = id_transform_util:item_id_to_proto(RedPackInfo#red_pack_info.id),
	RedPackUuid = integer_to_list(RedPackInfo#red_pack_info.id),
	PrevKey1 = get_prev_key(RedPackInfo#red_pack_info.id),
	DBFunSuccess = fun() ->
		match_and_change_red_pack_search_key(RedPackInfo#red_pack_info.id, PrevKey1),
		http_static_util:post_redpack_trade(PlayerInfo#player_info.id, RewardNoticeInfo#red_pack_notice.open_player_account,
			RewardNoticeInfo#red_pack_notice.open_player_id, RedPackInfo#red_pack_info.id, util:now_seconds()),
		DBSuccessFunConfirm(),
		%% 发送奖励邮件
		send_notice_mail(RewardNoticeInfo#red_pack_notice.open_player_id, RewardNoticeInfo#red_pack_notice.open_player_name,
			RewardNoticeInfo#red_pack_notice.open_player_account, RewardNoticeInfo#red_pack_notice.create_player_id,
			PlayerInfo#player_info.player_name, PlayerInfo#player_info.account, RedPackInfo#red_pack_info.set_num,
			RedPackInfo#red_pack_info.des, RedPackInfo#red_pack_info.create_time),
		%% 发送取消邮件
		send_last_req_peopel_cancel_mail(lists:delete(RewardNoticeInfo#red_pack_notice.id, AllReqNoticeList),
			PlayerInfo#player_info.account, PlayerInfo#player_info.player_name, RedPackInfo#red_pack_info.set_num
		),
		send_red_pack_do_select_reply(0, "", RedPackUuid, NoticeUuId, Opt)
	end,
	{DBFun, DBFunSuccess}.


confirm_red_pack_notice_open2(Notice, ReqNoticeList, OpenName) ->
	NewNotice = Notice#red_pack_notice{
		type = ?RED_PACK_NOTICE_TYPE_OPEN,
		open_player_name = OpenName
	},
	DBFun = fun() ->
		lists:foreach(fun(E) -> red_pack_notice_db:t_delete(E) end, ReqNoticeList),
		red_pack_notice_db:t_write(NewNotice)
	end,
	NoticeProtoIdList = lists:map(fun(E) -> {ok, EProtoId} = id_transform_util:item_id_to_proto(E),EProtoId end, ReqNoticeList),
	DBSuccessFun = fun() ->
		send_red_pack_notice_update([packet_pb_notice(NewNotice)], NoticeProtoIdList)
	end,
	{DBFun, DBSuccessFun}.

cancel_red_pack_notice_open(NoticeId) ->
	DBFun = fun() ->
		red_pack_notice_db:t_delete(NoticeId)
	end,
	{ok, EProtoId} = id_transform_util:item_id_to_proto(NoticeId),
	DBSuccessFun = fun() ->
		player_redpack_util:send_red_pack_notice_update([], [EProtoId])
	end,
	{DBFun, DBSuccessFun}.
%send_red_pack_notice_update(Id)->
%  PlayerInfo = player_util:get_dic_player_info(),
%  ok.

send_player_login_red_pack_notice() ->
	case player_util:get_dic_gate_pid() of
		GateProc when GateProc =/= undefined ->
			PlayerInfo = player_util:get_dic_player_info(),
			{ok, RedPackNotices} = red_pack_notice_db:get_by_player_id(PlayerInfo#player_info.id),
			RedPackNotices2 = util:foldl(fun(RedPackNotice, NoticesAcc) ->
				case is_notice_expire(RedPackNotice) of
					false ->
						[RedPackNotice | NoticesAcc];
					true ->
						%?INFO_LOG("delete notice  ~p~n",[RedPackNotice]),
						delete_exist_notice(RedPackNotice),
						NoticesAcc
				end
			end, [], RedPackNotices),
			SystemMails =
				util:map(fun(RedPackNotice) ->
					packet_pb_notice(RedPackNotice)
				end,

					RedPackNotices2),
			send_red_pack_notice_update(SystemMails, []),
			send_init_msg();
		_ ->
			void
	end.

send_red_pack_notice_update(List, DeleteList) ->
	Msg = #sc_red_pack_notice_update{
		list = List,
		delete_notice_list = DeleteList
	},
	%io:format("sc_red_pack_notice_update ----------- ~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

is_notice_expire(Notice) ->
	if
		Notice#red_pack_notice.type /= 0 ->
			NowSec = util:now_seconds(),
			if
				NowSec > Notice#red_pack_notice.create_time + ?RED_PACK_NOTICE_LAST_TIME ->
					true;
				true ->
					false
			end;
		true ->
			false
	end.

delete_exist_notice(Notice) ->
	Transaction =
		fun() ->
			red_pack_notice_db:t_delete(Notice#red_pack_notice.id)
		end,
	{atomic, _} = dal:run_transaction_rpc(Transaction).

packet_pb_notice(Notice) ->
	{ok, NoticeUid} = id_transform_util:item_id_to_proto(Notice#red_pack_notice.id),
	RedPackUid = integer_to_list(Notice#red_pack_notice.redpack_id),
	%{ok, RedPackUid} = id_transform_util:item_id_to_proto(Notice#red_pack_notice.redpack_id),
	#pb_red_pack_notice{
		notice_id = NoticeUid,

		notice_type = Notice#red_pack_notice.notice_type,
		get_sec_time = Notice#red_pack_notice.create_time,
		content = Notice#red_pack_notice.contect,
		gold_num = Notice#red_pack_notice.gold_num,
		type = Notice#red_pack_notice.type,
		open_player_name = Notice#red_pack_notice.open_player_name,
		open_player_account = Notice#red_pack_notice.open_player_account,
		uid = RedPackUid
	}.


pack_red_pack_notice_create(RedInfo, _PlayerInfo, ?NOTICE_TYPE_STATE) ->
	#red_pack_notice{
		id = roleid_generator:get_auto_red_pack_notice_id(),

		notice_type = ?NOTICE_TYPE_STATE,    %% 1 状态类通知 2 请求类通知
		redpack_id = RedInfo#red_pack_info.id,        %%  红包id

		create_player_id = RedInfo#red_pack_info.player_id,
		create_time = RedInfo#red_pack_info.create_time,
		gold_num = RedInfo#red_pack_info.set_num,
		contect = RedInfo#red_pack_info.des,
		type = ?RED_PACK_NOTICE_TYPE_UNOPENED,
		open_player_id = 0,
		open_player_name = "",
		open_player_account = ""        %%开启红包的玩家的玩家号
	};
pack_red_pack_notice_create(RedInfo, OpenerPlayerInfo, ?NOTICE_TYPE_REQ) ->
	#red_pack_notice{
		id = roleid_generator:get_auto_red_pack_notice_id(),

		notice_type = ?NOTICE_TYPE_REQ,    %% 1 状态类通知 2 请求类通知
		redpack_id = RedInfo#red_pack_info.id,        %%  红包id

		create_player_id = RedInfo#red_pack_info.player_id,
		create_time = RedInfo#red_pack_info.create_time,
		gold_num = RedInfo#red_pack_info.set_num,
		contect = RedInfo#red_pack_info.des,
		type = 0,
		open_player_id = OpenerPlayerInfo#player_info.id,
		open_player_name = OpenerPlayerInfo#player_info.player_name,
		open_player_account = OpenerPlayerInfo#player_info.account        %%开启红包的玩家的玩家号
	}.

%% make_open_pack_req_str(PlayerInfo, Des, GoldNum) ->
%% 	io_lib:format("~p金币红包“~s”被[[ff69ef]~s[-]]（ID:~s），猜中啦！是否把奖励给他",
%% 		[GoldNum, Des, PlayerInfo#player_info.player_name, PlayerInfo#player_info.account]).

%% 取消 清除所有请求开红包记录 并通知玩家邮件 Uid = 通知id
cs_red_pack_cancel_req(Uid) ->
	{ok, Id} = id_transform_util:item_id_to_internal(Uid),
	%?INFO_LOG("cancel_id~p~n",[Id]),
	case pre_red_pack_cancel_req(Id) of
		{ok, RedPackInfo, NoticeInfo} ->
			SetNum1 = RedPackInfo#red_pack_info.set_num,
			Reward = [{?ITEM_ID_GOLD, SetNum1}],
			{_NewPlayerInfo, DBFun1, SuccessFun1, _} =
				item_use:transc_items_reward(Reward, ?REWARD_TYPE_RED_PACK),
			PrevKey1 = get_prev_key(RedPackInfo#red_pack_info.id),

			NewNoticeInfo = NoticeInfo#red_pack_notice{
				type = ?RED_PACK_NOTICE_TYPE_CANCEL
			},
			DBFun = fun() ->
				DBFun1(),
				red_pack_notice_db:t_write(NewNoticeInfo),
				red_pack_info_db:t_delete(RedPackInfo#red_pack_info.id),
				delete_ets_red_pack_info(RedPackInfo#red_pack_info.id)
			end,
			DBSuccessFun = fun() ->
				SuccessFun1(),
				match_and_change_red_pack_search_key(RedPackInfo#red_pack_info.id, PrevKey1),
				do_clean_other_relate_notice(NewNoticeInfo, RedPackInfo),
				send_red_pack_cancel_back(0, "", RedPackInfo#red_pack_info.id)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					send_red_pack_cancel_back(1, "数据库错误", RedPackInfo#red_pack_info.id)
			end;
		{false, Err} ->
			send_red_pack_cancel_back(1, Err, 0)
	end,
	ok.

%% 清除关联记录 发取消邮件
do_clean_other_relate_notice(NewNoticeInfo, RedPackInfo) ->
	CreatePlayerId = RedPackInfo#red_pack_info.player_id,
	{CreatePlayerName, AccountId} =
		case player_info_db:get_base(CreatePlayerId) of
			{ok, [CreatePlayerInfo]} ->
				{CreatePlayerInfo#player_info.player_name, CreatePlayerInfo#player_info.account};
			_ ->
				{"", 0}
		end,
	RedPackId = RedPackInfo#red_pack_info.id,
	Pattern = #red_pack_notice{
		notice_type = ?NOTICE_TYPE_REQ,
		redpack_id = RedPackId,        %%  红包id
		_ = '_'
	},
	DBFun = fun() ->
		put(redpack_temp, mnesia:match_object(Pattern))
	end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	NoticeList = get(redpack_temp),
	DeleteList =
		lists:foldl(fun(ERec, Acc) ->
			ObjPlayerId = ERec#red_pack_notice.open_player_id,
			red_pack_notice_db:delete(ERec#red_pack_notice.id),
			send_cancel_redpack_red_mail(ObjPlayerId, AccountId, CreatePlayerName, RedPackInfo#red_pack_info.set_num),
			{ok, Uuid} = id_transform_util:item_id_to_proto(ERec#red_pack_notice.id),
			[Uuid|Acc]
		end, [], NoticeList),
	send_red_pack_notice_update([packet_pb_notice(NewNoticeInfo)], DeleteList),

	ok.



send_cancel_redpack_red_mail(ObjPlayerId, ObjAccount, CreatePlayerName, Set_num) ->
	%{ok, ObjAccount} = id_transform_util:role_id_to_proto(ObjPlayerId),
	Content = io_lib:format("[[5bf6de]~s[-]]（ID:~p）所发的[[5bf6de]~p[-]]金币红包已被取消，您的猜中结果无效。", [CreatePlayerName, ObjAccount, Set_num]),
	player_mail:send_system_mail(ObjPlayerId, 1, ?MAIL_TYPE_CANCEL_REDPACK_MAIL, "红包取消通知", Content, []),
	ok.

pre_red_pack_cancel_req(Id) ->
	%?INFO_LOG("cancel_id",[Id]),
	case red_pack_notice_db:get(Id) of
		{ok, [NoticeInfo]} ->
			PlayerInfo = player_util:get_dic_player_info(),
			PlayerId = PlayerInfo#player_info.id,
			if
				NoticeInfo#red_pack_notice.type =/= ?NOTICE_TYPE_STATE ->
					{false, "通知类型错误"};
				NoticeInfo#red_pack_notice.create_player_id =/= PlayerId ->
					{false, "非法操作2"};
				true ->
					case red_pack_info_db:get(NoticeInfo#red_pack_notice.redpack_id) of
						{ok, [RedPackInfo]} ->
							PlayerInfo = player_util:get_dic_player_info(),
							PlayerId = PlayerInfo#player_info.id,
							if
								RedPackInfo#red_pack_info.player_id == PlayerId ->
									{ok, RedPackInfo, NoticeInfo};
								true ->
									{false, "id错误"}
							end;
						_ ->
							{false, "红包已被猜中"}
					end
			end;
		_ ->
			{false, "通知id错误"}
	end.


send_red_pack_cancel_back(Result, Err, Uid) ->
	%{ok, PackUuid} = id_transform_util:mail_id_to_proto(Uid),
	PackUuid = integer_to_list(Uid),
	Msg = #sc_red_pack_cancel_reply{
		result = Result,
		err = Err,
		uid = PackUuid
	},
	%?INFO_LOG("sc_red_pack_cancel_reply~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

get_prev_key(Id) ->
	case ets:prev(?ETS_RED_PACK, Id) of
		'$end_of_table' ->
			case ets:next(?ETS_RED_PACK, Id) of
				'$end_of_table' ->
					0;
				NextKey ->
					%?INFO_LOG("pre_key~p~n", [PreKey]),
					NextKey
			end;
		PreKey ->
			%?INFO_LOG("next_key~p~n", [NextKey]),
			PreKey
	end.

%% change_red_pack_notice_type(Id) ->
%% 	case red_pack_notice_db:get(Id) of
%% 		{ok, [Notice]} ->
%% 			NewNotice = Notice#red_pack_notice{
%% 				type = ?RED_PACK_NOTICE_TYPE_CANCEL
%% 			},
%% 			DBFun = fun() ->
%% 				red_pack_notice_db:t_write(NewNotice)
%% 			end,
%% 			DBSuccessFun = fun() ->
%% 				void end,
%% 			case dal:run_transaction_rpc(DBFun) of
%% 				{atomic, _} ->
%% 					DBSuccessFun();
%% 				{aborted, Reason} ->
%% 					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
%% 					error
%% 			end;
%% 		_ ->
%% 			skip
%% 	end.

send_notice_mail(PlayerId, PlayerName, PlayerAccount, ObjPlayerId, ObjName, ObjAccount, SetNum, RedpackTitle, RedpackCreateSec) ->
	Title1 = "猜中红包通知",
	%{ok, ObjAccount} = id_transform_util:role_id_to_proto(ObjPlayerId),
	Content1 = io_lib:format("您猜中了[[5bf6de]~s[-]]（ID：~s）所发的[[5bf6de]~p[-]]金币红包，猜中金币已经发送到您的游戏账号中。", [ObjName,
		ObjAccount, SetNum]),
	player_mail:send_system_mail(PlayerId, 1, ?MAIL_TYPE_RED_PACK_DRAW_NOTICE, Title1, Content1, [{?ITEM_ID_GOLD, SetNum}]),

	Title2 = "红包被猜中通知",
	{{Y, M, D}, {H, Min, _}} = util:seconds_to_datetime(RedpackCreateSec),
	MinS =
		if
			Min >= 10 ->
				integer_to_list(Min);
			true ->
				lists:concat(["0", Min])
		end,
	RedpackCreate = lists:concat([Y, "-", M, "-", D, " ", H, ":", MinS]),
	%{ok, PlayerAccount} = id_transform_util:role_id_to_proto(PlayerId),
	Content2 = io_lib:format("您所发的[[5bf6de]~p[-]]金币红包（~s，~s）已被[[5bf6de]~s[-]]（ID：~s）猜中！", [SetNum, RedpackTitle, RedpackCreate,
		PlayerName, PlayerAccount]),
	player_mail:send_system_mail(ObjPlayerId, 1, ?MAIL_TYPE_RED_PACK_DRAW_NOTICE, Title2, Content2, []),
	ok.

%% 红包确认
cs_red_pack_do_select_req(NoticeUuId, Opt) ->
	%% 判断通知id的红包id是否自己的 判断是否已选择
	%% 确认后发奖励邮件 取消其他通知 发送取消邮件
	%% 取消后只取消当前通知
	{ok, NoticeId} = id_transform_util:item_id_to_internal(NoticeUuId),
	%io:format("NoticeId ~p",[ {NoticeId, NoticeUuId}]),
	case pre_check_select(NoticeId, Opt) of
		{true, AccDict} ->
			case Opt of
				0 ->
					%% 同意
					{DBFun, DBFunSuccess} = confirm_red_pack_notice_open(AccDict, NoticeUuId, Opt),
					case dal:run_transaction_rpc(DBFun) of
						{atomic, _} ->
							DBFunSuccess();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
					end;
				_ ->
					%% 取消
					%% 取消当个玩家
					RewardNoticeInfo = dict:fetch(reward_notice, AccDict),
					RedPackInfo = dict:fetch(red_pack_info, AccDict),
					PlayerInfo = player_util:get_dic_player_info(),
					{DBFunConfirm, DBSuccessFunConfirm} = cancel_red_pack_notice_open(RewardNoticeInfo#red_pack_notice.id),
					%{ok, RedPackUuid} = id_transform_util:item_id_to_proto(RedPackInfo#red_pack_info.id),
					RedPackUuid = integer_to_list(RedPackInfo#red_pack_info.id),
					DBFunSuccess = fun() ->
						DBSuccessFunConfirm(),
						send_last_req_peopel_cancel_mail([RewardNoticeInfo#red_pack_notice.id],
							PlayerInfo#player_info.account, PlayerInfo#player_info.player_name, RedPackInfo#red_pack_info.set_num
						),
						send_red_pack_do_select_reply(0, "", RedPackUuid, NoticeUuId, Opt)
					end,
					case dal:run_transaction_rpc(DBFunConfirm) of
						{atomic, _} ->
							DBFunSuccess();
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
							send_red_pack_do_select_reply(1, "数据库错误", "", NoticeUuId, Opt)
					end
			end;
		{false, Err} ->
			send_red_pack_do_select_reply(1, Err, "", NoticeUuId, Opt)
	end.

pre_check_select(NoticeId, Opt) ->
	Requires = [
		check_opt,
		check_redpack_id,
		check_notice_list
	],
	check_select_require(NoticeId, Opt, dict:new(), Requires).

check_select_require(_NoticeId, _Opt, AccDict, []) ->

	{true, AccDict};

check_select_require(NoticeId, Opt, AccDict, [check_opt | T]) ->
	if
		Opt >= 0 andalso Opt =< 1 ->
			check_select_require(NoticeId, Opt, AccDict, T);
		true ->
			{false, "opt错误"}
	end;


check_select_require(NoticeId, Opt, AccDict, [check_redpack_id | T]) ->

	case red_pack_notice_db:get(NoticeId) of
		{ok, [NoticeInfo]} ->
			PlayerInfo = player_util:get_dic_player_info(),
			if
				NoticeInfo#red_pack_notice.notice_type == ?NOTICE_TYPE_STATE ->
					{false, "类型错误"};
				NoticeInfo#red_pack_notice.create_player_id =/= PlayerInfo#player_info.id ->
					{false, "非法操作1"};
				true ->
					%% 检测红包是否还在
					%?INFO_LOG("NoticeInfo#red_pack_notice.redpack_id ~p~n", [NoticeInfo#red_pack_notice.redpack_id]),
					case lookup_ets_red_pack_info(NoticeInfo#red_pack_notice.redpack_id) of
						{false, _} ->
							{false, "红包不存在！"};
						RedInfo ->
							AccDict2 = dict:store(red_pack_info, RedInfo, AccDict),
							AccDict3 = dict:store(reward_notice, NoticeInfo, AccDict2),
							Pattern = #red_pack_notice{
								redpack_id = NoticeInfo#red_pack_notice.redpack_id,
								notice_type = ?NOTICE_TYPE_STATE,
								_ = '_'
							},
							DBFun = fun() ->
								put(redpack_temp, mnesia:match_object(Pattern))
							end,
							{atomic, _} = dal:run_transaction_rpc(DBFun),
							case get(redpack_temp) of
								[StateNotice] ->
									AccDict4 = dict:store(state_notice, StateNotice, AccDict3),
									check_select_require(NoticeId, Opt, AccDict4, T);
								_ ->
									{false, "状态通知错误"}
							end
					end
			end;
		_ ->
			{false, "通知不存在"}
	end;

check_select_require(NoticeId, Opt, AccDict, [check_notice_list | T]) ->
	case Opt of
		0 ->
			RedPackInfo = dict:fetch(red_pack_info, AccDict),
			Pattern = #red_pack_notice{
				redpack_id = RedPackInfo#red_pack_info.id,
				notice_type = ?NOTICE_TYPE_REQ,
				_ = '_'
			},
			DBFun = fun() ->
				put(redpack_temp, lists:map(fun(E) -> E#red_pack_notice.id end, mnesia:match_object(Pattern)))
			end,
			{atomic, _} = dal:run_transaction_rpc(DBFun),
			AccDict2 = dict:store(req_notice_id_list, get(redpack_temp), AccDict),
			check_select_require(NoticeId, Opt, AccDict2, T);
		_ ->
			check_select_require(NoticeId, Opt, AccDict, T)
	end;

check_select_require(NoticeId, Opt, AccDict, [_ | T]) ->
	check_select_require(NoticeId, Opt, AccDict, T).


send_last_req_peopel_cancel_mail(List, AccountId, CreatePlayerName, Set_num) ->
	lists:foreach(fun(EId) ->
		send_cancel_redpack_red_mail(EId, AccountId, CreatePlayerName, Set_num)
	end, List).

send_red_pack_do_select_reply(Result, Err, RedPackId, NoticeUuid, Opt) ->
	Msg = #sc_red_pack_do_select_reply{
		result = Result,
		err_msg = Err,
		redpack_id = RedPackId,
		opt = Opt,
		notice_id = NoticeUuid
	},
	%io:format("~ts ~n", [list_to_binary(Err)]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

cs_red_pack_search_req(RedPackId) ->
	RedPackList = ets:lookup(?ETS_RED_PACK, RedPackId),
	Msg = #sc_red_pack_search_reply{
		list = pack_pb_red_pack_info(RedPackList)
	},
	%?INFO_LOG("sc_red_pack_search_reply ~p~n",[Msg]),
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).

do_cancel_redpack(RedPackInfo) ->
	SetNum1 = RedPackInfo#red_pack_info.set_num,
	Reward = [{?ITEM_ID_GOLD, SetNum1}],

	{ok, NoticeList} = red_pack_notice_db:get_by_player_id(RedPackInfo#red_pack_info.player_id),
	%?INFO_LOG("NoticeList ~p~n",[NoticeList]),
	case lists:filter(fun(E) ->
		E#red_pack_notice.notice_type == ?NOTICE_TYPE_STATE andalso E#red_pack_notice.redpack_id == RedPackInfo#red_pack_info.id
		end, NoticeList) of
		[NoticeInfo] ->
			NewNoticeInfo = NoticeInfo#red_pack_notice{
				type = ?RED_PACK_NOTICE_TYPE_CANCEL
			},

			PrevKey1 = get_prev_key(RedPackInfo#red_pack_info.id),
			Title2 = "红包退回通知",
			Content2 = io_lib:format("您所发的[[5bf6de]~p[-]]金币红包（~s，~s）在12小时内没有被玩家猜中，红包内金币随本邮件退回！", [
				SetNum1, RedPackInfo#red_pack_info.des, util:format_datetime_to_string(util:seconds_to_datetime(RedPackInfo#red_pack_info.create_time))]),
			DBFun = fun() ->
				red_pack_notice_db:t_write(NewNoticeInfo),
				red_pack_info_db:t_delete(RedPackInfo#red_pack_info.id),
				delete_ets_red_pack_info(RedPackInfo#red_pack_info.id)
			end,
			DBSuccessFun = fun() ->
				player_mail:send_system_mail(RedPackInfo#red_pack_info.player_id, 1, ?MAIL_TYPE_REDPACK_TIMEOUT_MAIL, Title2, Content2, Reward),
				match_and_change_red_pack_search_key(RedPackInfo#red_pack_info.id, PrevKey1),
				do_clean_other_relate_notice_check(NewNoticeInfo, RedPackInfo)
			end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				_ ->
					?INFO_LOG("Error ~p~n",[?MODULE, ?LINE])
			end;
		OtherData ->
			?INFO_LOG("Error ~p~n", [{?MODULE, ?LINE, OtherData}]),

			PrevKey1 = get_prev_key(RedPackInfo#red_pack_info.id),
			Title2 = "红包退回通知",
			Content2 = io_lib:format("您所发的[[5bf6de]~p[-]]金币红包（~s，~s）在12小时内没有被玩家猜中，红包内金币随本邮件退回！", [
				SetNum1, RedPackInfo#red_pack_info.des, util:format_datetime_to_string(util:seconds_to_datetime(RedPackInfo#red_pack_info.create_time))]),
			DBFun = fun() ->
				red_pack_info_db:t_delete(RedPackInfo#red_pack_info.id),
				delete_ets_red_pack_info(RedPackInfo#red_pack_info.id)
							end,
			DBSuccessFun = fun() ->
				player_mail:send_system_mail(RedPackInfo#red_pack_info.player_id, 1, ?MAIL_TYPE_REDPACK_TIMEOUT_MAIL, Title2, Content2, Reward),
				match_and_change_red_pack_search_key(RedPackInfo#red_pack_info.id, PrevKey1)
										 end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun();
				_ ->
					?INFO_LOG("Error ~p~n",[?MODULE, ?LINE])
			end
	end.


%% 清除关联记录 发取消邮件
do_clean_other_relate_notice_check(NewNoticeInfo, RedPackInfo) ->
	CreatePlayerId = RedPackInfo#red_pack_info.player_id,
	{CreatePlayerName, AccountId} =
		case player_info_db:get_base(CreatePlayerId) of
			{ok, [CreatePlayerInfo]} ->
				{CreatePlayerInfo#player_info.player_name, CreatePlayerInfo#player_info.account};
			_ ->
				{"", 0}
		end,
	RedPackId = RedPackInfo#red_pack_info.id,
	Pattern = #red_pack_notice{
		notice_type = ?NOTICE_TYPE_REQ,
		redpack_id = RedPackId,        %%  红包id
		_ = '_'
	},
	DBFun = fun() ->
		put(redpack_temp, mnesia:match_object(Pattern))
	end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	NoticeList = get(redpack_temp),
	DeleteList =
		lists:foldl(fun(ERec, Acc) ->
			ObjPlayerId = ERec#red_pack_notice.open_player_id,
			red_pack_notice_db:delete(ERec#red_pack_notice.id),
			send_cancel_redpack_red_mail(ObjPlayerId, AccountId, CreatePlayerName, RedPackInfo#red_pack_info.set_num),
			{ok, Uuid} = id_transform_util:item_id_to_proto(ERec#red_pack_notice.id),
			[Uuid|Acc]
		end, [], NoticeList),
	case role_manager:get_roleprocessor(CreatePlayerId) of
		{ok, Pid} ->
			role_processor_mod:cast(Pid, {'handle', player_redpack_util, send_red_pack_notice_update, [[packet_pb_notice(NewNoticeInfo)], DeleteList]});
		_ ->
			skip
	end,
	ok.


gm_test(Type, Key) ->
	if
		Type == 1 ->
			cs_red_pack_create_req(10000, "恭喜发财，大吉大利");
		Type == 2 ->
			PlayerInfo = player_util:get_dic_player_info(),
			?INFO_LOG("player_di~p~n", [PlayerInfo#player_info.id]);
		Type == 3 ->  %未使用
			%{ok, Id} = id_transform_util:item_id_to_proto(Key),
			Id = integer_to_list(Key),
			?INFO_LOG("11"),
			cs_red_pack_open_req(Id, 100001),
			?INFO_LOG("22"),
			cs_red_pack_open_req(Id, 10000);
		Type == 4 ->
			cs_red_pack_query_list_req(1, 5);
		Type == 5 ->
			{ok, Key1} = id_transform_util:item_id_to_proto(Key),
			cs_red_pack_cancel_req(Key1);
		Type == 6 ->
			ok;
			%gen_server:cast(red_pack_mod:get_mod_pid(), {'red_pack_num_change', 0});
		Type == 7 ->  %未测
			red_pack_info_db:clean(),
			red_pack_notice_db:clean(),
			red_pack_total_info_db:clean(),
			red_pack_mod:init_ets();
		Type == 8 ->
			ok;
		true ->
			skip
	end.

prev_do_cancel_redpack_all() ->
	ets:foldl(fun(E, _Acc) -> prev_do_cancel_redpack(E) end, [], ?ETS_RED_PACK).

%% 取消前版本红包
prev_do_cancel_redpack(RedPackInfo) ->
	SetNum1 = RedPackInfo#red_pack_info.set_num,
	Reward = [{?ITEM_ID_GOLD, SetNum1}],

	PrevKey1 = get_prev_key(RedPackInfo#red_pack_info.id),
	Title2 = "红包退回通知",
	Content2 = io_lib:format("您所发的[[5bf6de]~p[-]]金币红包（~s，~s）在12小时内没有被玩家猜中，红包内金币随本邮件退回！", [
		SetNum1, RedPackInfo#red_pack_info.des, util:format_datetime_to_string(util:seconds_to_datetime(RedPackInfo#red_pack_info.create_time))]),
	DBFun = fun() ->
		red_pack_info_db:t_delete(RedPackInfo#red_pack_info.id),
		delete_ets_red_pack_info(RedPackInfo#red_pack_info.id)
	end,
	DBSuccessFun = fun() ->
		player_mail:send_system_mail(RedPackInfo#red_pack_info.player_id, 1, ?MAIL_TYPE_REDPACK_TIMEOUT_MAIL, Title2, Content2, Reward),
		match_and_change_red_pack_search_key(RedPackInfo#red_pack_info.id, PrevKey1)
	end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun();
		_ ->
			?INFO_LOG("Error ~p~n",[?MODULE, ?LINE])
	end.


is_in_room()->
	false.
	% PlayerRoomInfo = player_niu_room_util:get_player_room_info(),
	% PlayerHundredRoom =  player_hundred_niu_util:get_player_room_info(),
	% if
	% 	PlayerRoomInfo#player_niu_room_info.room_id > 0 ->
	% 		true;
	% 	true ->
	% 		HundredRoomId = PlayerHundredRoom#player_niu_room_info.room_id,
	% 		if
	% 			HundredRoomId > 0 ->
	% 				EtsName = hundred_niu_processor:get_hundred_player_ets_name(HundredRoomId),
	% 				case ets:lookup(EtsName, PlayerHundredRoom#player_niu_room_info.player_id) of
	% 					[EtsData] ->
	% 						if
	% 							EtsData#ets_hundred_niu_player_info.seat_pos == 0 ->
	% 								true;
	% 							true ->
	% 								#ets_hundred_niu_player_info{
	% 									set_1_flag = Set_1,
	% 									set_2_flag = Set_2,
	% 									set_3_flag = Set_3,
	% 									set_4_flag = Set_4
	% 								} = EtsData,
	% 								CheckList = lists:filter(fun(E) -> E == false end, [Set_1, Set_2, Set_3, Set_4]),
	% 								if
	% 									length(CheckList) == 4->
	% 										false;
	% 									true ->
	% 										true
	% 								end
	% 						end;
	% 					_->
	% 						false
	% 				end;
	% 			true ->
	% 				false
	% 		end
	% end.