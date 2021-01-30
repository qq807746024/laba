%%%-------------------------------------------------------------------
%%% @author wodong_0013
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 三月 2017 17:07
%%%-------------------------------------------------------------------
-module(ntools).
-author("wodong_0013").
-include("common.hrl").
-include_lib("network_proto/include/laba_pb.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

-compile(export_all).

%		ntools:reimport_tables([announcement]).
reimport_tables(TableList) ->
	lists:foreach(fun(ETableName) ->
		dal:clear_rpc(ETableName)
	end, TableList),

	case file:consult("game.config") of
		{ok, BaseDataList} ->
			util:foldl(fun(E, _Acc) ->
				ETableName = erlang:element(1, E),
				case lists:member(ETableName, TableList) of
					true ->
						mnesia:dirty_write(E);
					false ->
						skip
				end
			end,
				[],
				BaseDataList);
		_ ->
			skip
	end.

clean_all_head() ->
	{ok, List} = dal:read_rpc(player_info),
	lists:foreach(fun(ERec) ->
		NewERec = ERec#player_info{
			icon = ""
		},
		player_info_db:write_player_info(NewERec) end, List).

reward_content_to_reward_list(RewardContent) ->
	try
		ContentList = string:tokens(RewardContent, "+"),
		RewardList =
			util:map(fun(E) ->
				case util:string_to_term("{" ++ E ++ "}") of
					undefined ->
						erlang:error("not_vaild");
					ETerm ->
						ETerm
				end
			end,
			ContentList),
		CheckList =
			lists:foldl(fun({EItemBaseId, ENum}, Acc) ->
				case ets:lookup(?ETS_BASE_ITEM, EItemBaseId) of
					[_EBaseItem] ->
						if
							ENum > 0 ->
								Acc ++ [{EItemBaseId, ENum}];
							true ->
								Acc
						end;
					_ ->
						Acc
				end
			end, [], RewardList),
		if
			length(CheckList) =/= length(RewardList) ->
				{false, "部分奖励错误!"};
			true ->
				{true, CheckList}
		end
	catch
		_Error:_Reason ->
			?ERROR_LOG("reward content to reward list Error! ~p~n", [{erlang:get_stacktrace()}]),
			{false, "奖励内容语法错误!"}
	end.

open_file(PlayerId) ->
	{ok, FileDevice} = file:open(lists:concat(["laba_", PlayerId, ".csv"]), [write]),
	io:fwrite(FileDevice, "~s~n", ["RewardRate,Reroll,BananaNum,Cost,TotalReward"]),
	put(open_file, FileDevice).

write_to_file(Str) ->
	FileDevice = get(open_file),
	io:fwrite(FileDevice, "~s", [Str]).

write_to_file_enter(Str) ->
	FileDevice = get(open_file),
	io:fwrite(FileDevice, "~s~n", [Str]).

close_file() ->
	FileDevice = get(open_file),
	file:close(FileDevice).

get_player_info_by_account(AccountId) ->
	case player_info_db:get_player_info_by_account(AccountId) of
		[] ->
			false;
		[PlayerInfo|_] ->
			PlayerInfo
	end.

change_player_icon(AccountId, Icon) ->
	case player_info_db:get_player_info_by_account(AccountId) of
		[PlayerInfo|_] ->
			case role_manager:get_roleprocessor(PlayerInfo#player_info.id) of
				{ok, Pid} ->
					role_processor_mod:cast(Pid, {'handle', player_util, cs_player_change_headicon_req, [Icon,0]});
				_ ->
					false
			end;
		_ ->
			false
	end.


%% 导出输入到文件
%tools_operation:export_to_txt(T).
export_to_txt(T) ->
	S = util:term_to_string(T),
	{ok, FileDevice} = file:open("export_to_txt.txt", [write]),
	io:fwrite(FileDevice, "~ts~n", [unicode:characters_to_binary(S)]),
	file:close(FileDevice).

add_item(AccountId, ItemId, ItemNum) ->
	case player_info_db:get_player_info_by_account(AccountId) of
		[PlayerInfo|_] ->
			case role_manager:get_roleprocessor(PlayerInfo#player_info.id) of
				{ok, Pid} ->
					role_processor_mod:cast(Pid, {'handle', item_use, imme_items_reward, [[{ItemId, ItemNum}], ?REWARD_TYPE_BY_CMD]});
				_ ->
					case lists:member(ItemId, [?ITEM_ID_GOLD, ?ITEM_ID_DIAMOND, ?ITEM_ID_CASH]) of
						true ->
							NewPlayerInfo =
								case ItemId of
									?ITEM_ID_GOLD ->
										PlayerInfo#player_info{gold = PlayerInfo#player_info.gold + ItemNum};
									?ITEM_ID_DIAMOND ->
										PlayerInfo#player_info{diamond = PlayerInfo#player_info.diamond + ItemNum};
									?ITEM_ID_CASH ->
										PlayerInfo#player_info{cash = PlayerInfo#player_info.cash + ItemNum};
									_ ->
										PlayerInfo
								end,
							if
								?ITEM_ID_RED_PACK == ItemId ->
									{_, DBFun1, SuccessFun1, _} = item_use:transc_items_reward([{?ITEM_ID_RED_PACK, ItemNum}], ?REWARD_TYPE_BY_CMD);
								true ->
									DBFun1 = fun() -> skip end,
									SuccessFun1 = fun() -> skip end
							end,
							DBFun = fun() ->
								player_info_db:t_write_player_info(NewPlayerInfo),
								DBFun1()
							end,
							case dal:run_transaction_rpc(DBFun) of
								{atomic, _} ->
									SuccessFun1();
								_ ->
									skip
							end;
						_ ->
							skip
					end
			end;
		_ ->
			error
	end.

autoreim_some_table_data(TableList) ->
	case file:consult("game.config") of
		{ok, BaseDataList} ->
			util:foldl(fun(E, _Acc)	->
				ETableName = erlang:element(1, E),
				case lists:member(ETableName, TableList) of
					true ->
						mnesia:dirty_write(E);
					false ->
						skip
				end
			end,
				[],
				BaseDataList);
		_ ->
			skip
	end.

init_hundred_ai() ->
	ConfigList = hundred_reroll_config_db:get_base(),
	lists:foreach(fun(ERec) ->
		ets:insert(?ETS_HUNDRED_REROLL_CONFIG, ERec) end, ConfigList).

%% leave_room_from(RoomId) ->
%% 	Pattern = #player_niu_room_info{
%% 		room_id = RoomId,
%% 		_ = '_'
%% 	},
%% 	AllList = ets:match_object(?ETS_NIUNIU_PLAYER_IN_GAME, Pattern),
%% 	lists:foreach(fun(E) ->
%% 		case role_manager:get_roleprocessor(E#player_niu_room_info.player_id) of
%% 			{ok, Pid} ->
%% 				role_processor_mod:cast(Pid, {'handle', });
%% 			_ ->
%% 				skip
%% 		end end, AllList),
%% 	ok.
%% robot_manager:logout_robot().
kick_ai_hundred_niu(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, Pid} ->
			role_processor_mod:cast(Pid, {'handle', player_hundred_niu_util, cs_hundred_leave_room_req, []});
		_ ->
			skip
	end,
	ok.

kick_ai_car(PlayerId) ->
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, Pid} ->
			role_processor_mod:cast(Pid, {'handle', player_car_util, cs_car_exit_req, []});
		_ ->
			skip
	end,
	ok.

change_name(PlayerId) ->
	Name = <<229,176,143,229,143,175,231,136,177>>,
	case role_manager:get_roleprocessor(PlayerId) of
		{ok, Pid} ->
			role_processor_mod:cast(Pid, {'handle', player_util, change_name, [Name]});
		_ ->
			case player_info_db:get_base(PlayerId) of
				{ok, [PlayerInfo]} ->
					Name1 = unicode:characters_to_binary(Name),
					NewName = string:strip(lists:flatten(erlang:binary_to_list(Name1))),
					NewPlayerInfo = PlayerInfo#player_info{player_name = NewName},
					Fun = fun() -> player_info_db:t_write_player_info(NewPlayerInfo) end,
					{atomic,_} = dal:run_transaction_rpc(Fun)
			end
	end,
	ok.

%% 踢所有玩家（关服操作前需先踢玩家下线）
%tools_operation:kick_player_all().
kick_player_all() ->
	?INFO_LOG("kick player all___size ~p~n", [ets:info(?ETS_ONLINE, size)]),
	ets:foldl(fun(E, Acc) ->
		EGatePid = E#ets_online.gate_pid,
		if
			is_pid(EGatePid) ->
				tcp_client:login_out(EGatePid);
			true ->
				skip
		end,
		Acc
	end,
		[],
		?ETS_ONLINE).

%% 踢出某玩家
kick_one(PlayerId) ->
	case ets:lookup(?ETS_ONLINE, PlayerId) of
		[ERec] ->
			EGatePid = ERec#ets_online.gate_pid,
			if
				is_pid(EGatePid) ->
					tcp_client:login_out(EGatePid),
					true;
				true ->
					false
			end;
		_ ->
			false
	end.

%% 加百人场奖池
add_to_hundred_pool(RoomId, AddPool) ->
	case ets:lookup(?ETS_HUNDRED_ROOM, RoomId) of
		[RoomInfo] ->
			RoomPid = RoomInfo#hundred_niu_room_info.room_pid,
			gen_fsm:send_all_state_event(RoomPid, {'gm_add_pool', AddPool});
		_ ->
			skip
	end.

clean_hundred_rec() ->
	dal:clear_rpc(hundred_niu_winning_record),
	ok.

%% 同步一次所有正常玩家的userinfo
send_all_player_http_userinfo() ->
	Pattern = #player_items{
		entry = ?ITEM_ID_RED_PACK,
		_ = '_'
	},

	DBFun = fun() -> put(item_datas, mnesia:match_object(Pattern)) end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	%?INFO_LOG("item_datas ~p~n",[get(item_datas)]),
	case player_info_db:get_first() of
		'$end_of_table' ->
			skip;
		Key ->
			do_send_player_http_userinfo(Key)
	end.

do_send_player_http_userinfo(Key) ->
	do_send_player_http_userinfo_only(Key),
	case player_info_db:get_next(Key) of
		'$end_of_table' ->
			skip;
		NextKey ->
			do_send_player_http_userinfo(NextKey)
	end.

do_send_player_http_userinfo_only(Key) ->
	?INFO_LOG("do_send_player_http_userinfo ===> ~n~p", [{Key}]),
	{ok, [PlayerInfo]} = player_info_db:get_base(Key),
	if
		PlayerInfo#player_info.is_robot ->
			skip;
		%% PlayerInfo#player_info.login_time > 1498406400->
		%% 	skip;
		true ->
			case role_manager:get_roleprocessor(PlayerInfo#player_info.id) of
				{ok, _Pid} ->
					skip;
				_ ->
					case player_winning_record_info_db:get(PlayerInfo#player_info.id) of
						{ok, [PlayerWinningRec]} ->
							%?INFO_LOG("PlayerWin ~p~n",[PlayerWinningRec#player_winning_record_info.total_gains]),
							PlayerWin = PlayerWinningRec#player_winning_record_info.total_gains;
						_ ->
							PlayerWin = 0
					end,
					case lists:keyfind(PlayerInfo#player_info.id, #player_items.id, get(item_datas)) of
						false ->
							RedBagNum = 0;
						PlayerItems ->
							RedBagNum = PlayerItems#player_items.count
					end,
					%?INFO_LOG("RedBagNum, PlayerWin ~p~n", [{RedBagNum, PlayerWin}]),
					http_static_util:post_user_info(PlayerInfo, RedBagNum, 2, PlayerWin)
			end
	end.

alter_player_hundred_win(PlayerId, Gold) ->
	case player_winning_record_info_db:get(PlayerId) of
		{ok, [PlayerRec]} ->
			NewPlayerRec = PlayerRec#player_winning_record_info{hundred_total_win = Gold},
			player_winning_record_info_db:write(NewPlayerRec);
		_ ->
			skip
	end.

alter_player_niu_win(PlayerId, Level, Gold) ->
	case player_winning_record_info_db:get(PlayerId) of
		{ok, [PlayerRec]} ->
			NewPlayerRec = PlayerRec#player_winning_record_info{
				room_level_gold_list = lists:keystore(Level, 1, PlayerRec#player_winning_record_info.room_level_gold_list, {Level, Gold})},
			player_winning_record_info_db:write(NewPlayerRec);
		_ ->
			skip
	end.

alter_hundred_newbie_taskdata() ->
	{ok, List} = dal:read_rpc(player_game_task_info),
	lists:foreach(fun(E) ->
		case role_manager:get_roleprocessor(E#player_game_task_info.player_id) of
			{ok, Pid} ->
				role_processor_mod:cast(Pid, {'handle', player_game_task_util, change_newbie_mission, []});
			_ ->
				case E#player_game_task_info.hundred_today_all_mission_id_list of
					[] ->
						NewRec = E#player_game_task_info{
							hundred_today_mission_process = 0,  %% 该任务完成进度
							hundred_today_mission_process_over = false,  %% 该任务完成进度
							hundred_today_mission_achieve_num = 0,  %% 今日任务完成数量
							hundred_today_mission_complete_flag = false,  %% 所有任务完成=true

							hundred_today_mission_id = 800001,
							hundred_today_all_mission_id_list = [800001,800002,800003,800004,800005],
							hundred_today_mission_condition = [61,1,1,1000]
						},
						player_game_task_info_db:write(NewRec);
					_ ->
						skip
				end
%%
%% 				MissionId = E#player_game_task_info.hundred_today_mission_id,
%% 				if
%% 					MissionId == 800001 ->
%% 						NewRec = E#player_game_task_info{hundred_today_mission_condition = [61,1,1,1000]},
%% 						player_game_task_info_db:write(NewRec);
%% 					true ->
%% 						skip
%% 				end
		end end, List).

export_all_robot_id() ->
	export_to_txt(ets:foldl(fun(E, Acc) ->[E#ets_robot_data.robot_id|Acc] end, [], ?ETS_ALL_NORMAL_ROBOT)).

%% 清除所有 player_info_db 任务记录
clean_all_player_pack_task()->
	case player_info_db:get_first() of
		'$end_of_table' ->
			skip;
		Key ->
			do_clear_player_pack_task(Key)
	end.

do_clear_player_pack_task(Key)->
	case role_manager:get_roleprocessor(Key) of
		{ok,Pid} ->
			role_processor_mod:cast(Pid,{'handle',player_pack_task,clear_task,[]});
		_->
			player_pack_task_info_db:delete(Key)
	end,
	case player_info_db:get_next(Key) of
		'$end_of_table' ->
			skip;
		NextKey ->
			do_clear_player_pack_task(NextKey)
	end.

clear_player_gold(PlayerId)->
	case player_info_db:get_base(PlayerId) of
		{ok,[PlayerInfo]}->
			NewPlayerInfo = PlayerInfo#player_info{
				gold = 0
			},
			DBFun1 = fun() ->
				player_info_db:t_write_player_info(NewPlayerInfo)
				end,
			SuccessFun1 =fun()->
				ok
				end,
			case dal:run_transaction_rpc(DBFun1) of
				{atomic, _} ->
					SuccessFun1(),
				ok;
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
			end;
		_->
			skip
	end.

check_player_by_name() ->
	Pattern = #player_info{
		player_name = ".提示",
		_ = '_'
	},
	DBFun = fun() -> put(player_name_info_1, mnesia:match_object(Pattern)) end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	A = get(player_name_info_1),
	?INFO_LOG("length~p~n",[A]).

change_player_gold(PlayerId,Count)->
	case player_info_db:get_base(PlayerId) of
		{ok,[Info]} ->
			NewInfo = Info#player_info{
				gold = Count
			},
			player_info_db:write_player_info(NewInfo),
			ok;
		_->
			skip
	end.

redpack_create(Id,SetNum,Time)->
	{ok,[PlayerInfo]} = player_info_db:get_base(Id),
	RedId = roleid_generator:get_auto_red_pack_id(),
	{ok, [Config]}= red_pack_config_db:get(1),
	RedPack = player_redpack_util:get_red_pack_info(SetNum, "恭喜发财，大吉大利", Time, PlayerInfo, RedId, Config),
	red_pack_info_db:write(RedPack).

change_vip_level(PlayerId,Num,Lv)->
	case player_info_db:get_base(PlayerId) of
		{ok,[Info]}->
			NewInfo = Info#player_info{
				recharge_money = Num,
				vip_level = Lv
			},
			player_info_db:write_player_info(NewInfo),
			ok;
		_->
			skip
	end.

change_only_vip_level(PlayerId,Lv)->
	case player_info_db:get_base(PlayerId) of
		{ok,[Info]}->
			NewInfo = Info#player_info{
				vip_level = Lv
			},
			player_info_db:write_player_info(NewInfo),
			ok;
		_->
			skip
	end.



%% 加红包库存在 prize_mod:add_storage/2,
%% 千人红包场 玩家卡着 player_niu_room_util:kick_out_from_room(PlayerId),
%% 豪车进入新一轮 (niu_zs@127.0.0.1)116> gen_server:cast(car_manager:get_mod_pid(),{'enter_state',1,car_state_waiting_2}).
test()->
	{UseCardList1, _} = niu_room_tool:get_rand_nman_card_list(5),
	lists:zip(lists:seq(1, 5), UseCardList1),
	{RateList, CardTypeList} = hundred_niu_timer_mod:get_settle_rate_by_card_list(UseCardList1),
	?INFO_LOG("random_test~p~n",[{RateList, CardTypeList}]).

test_next()->
	lists:map(fun(_E) -> test() end,lists:seq(1,100)).

test_redpack()->
	CardList =
	[{1,1},
		{2,1},
		{3,2},
		{2,2},
		{1,2}],
	?INFO_LOG("test_redpack~p~n",[niu_room_tool:get_card_over_data(CardList)]).

test_rand(Num)->

	Out =
	lists:foldl(fun(_E,Acc)->
		ENum = util:rand(1,100),
	ENum1 =
		if
			ENum =< 20->
				1;
			ENum =< 40->
				2;
			ENum =< 60->
				3;
			ENum =< 80->
				4;
			true ->
				5
		end,


		case lists:keyfind(ENum1,1,Acc) of
			{ENum1,Old} ->
				lists:keystore(ENum1,1,Acc,{ENum1,Old+1});
			_->
				lists:keystore(ENum1,1,Acc,{ENum1,1})
		end end,[],lists:seq(1,Num)),
	?INFO_LOG("test_rand~p~n",[Out]).
%%	if
%%		ENum =< 20->
%%			1;
%%		ENum =< 40->
%%			2;
%%		ENum =< 60->
%%			3;
%%		ENum =< 78->
%%			4;
%%		true ->
%%			5
%%	end.

test_rand_2({random_weight, L_terms, L_weights})->
	{Acc, AccSum} = util:mapfoldl(fun(X, Sum) -> {[Sum,X+Sum],X+Sum} end, 0, L_weights),
	Pos = util:uniform() * AccSum,
	[{_,Out}] = util:filter(fun({[N1,N2], _}) -> N1 < Pos andalso N2 >= Pos end, lists:zip(Acc, L_terms)),
	Out.

get_mail()->
	NowSec = util:now_seconds(),
	{ok,List} = mail_db:get_mail(),
	Out =
	lists:filter(fun(E) -> E#mail.receive_time > NowSec end,List),
	?INFO_LOG("mail_length~p~n",[length(Out)]).
%%test_3()->
%%	[Info] = ets:lookup(?ETS_ONLINE, 1000902),
%%	player_car_util:send_msg(Info#ets_online.gate_pid,Msg ={sc_fudai_pool_update,5
%%	}).

%%test_4()->
%%	String1 = lists:foldl(fun(E,Acc) -> lists:concat([Acc,",",E]) end,"",[123,132,123]),
%%	String2 = lists:foldl(fun(E,Acc) -> lists:concat([Acc,",",E]) end,"",[1,1,1,11]),
%%	String3 = lists:foldl(fun(E,Acc) -> lists:concat([Acc,",",E]) end,"",[12,3,2,312]),
%%	http_static_util:post_bet_log(1,String1,String2,String3,2000).
%%查找最大内存的进程
find_max_memory_process(AttrName,Num) -> %% AttrName = >memory ,reductions ,Num => 个数
	%%进程列表
	ProcessL = processes(),
	%%获取进程信息，
	F = fun(Pid, L) ->
		case process_info(Pid, [AttrName, registered_name, current_function, initial_call]) of
			[Attr, Name, Init, Cur] ->
				Info = {Attr, [{pid, Pid}, Name, Init, Cur]},
				[Info | L];
			undefined ->
				L
		end
			end,
	ProInfoL = lists:foldl(F, [], ProcessL),
	%%排序
	CompF = fun({A, _},{B, _}) ->
		A > B
					end,
	ProInfoSortL = lists:usort(CompF, ProInfoL),
	lists:sublist(ProInfoSortL, Num).

player_prize_reward_record(PlayerId)->
	Pattern = #player_prize_exchange_record{
		player_id = PlayerId,
		_ = '_'
	},
	DBFun = fun() ->	List = mnesia:match_object(Pattern),
		put(prize_record,List)
					end,
	{atomic, _} = dal:run_transaction_rpc(DBFun),
	?INFO_LOG("prize_record~p~n",[get(prize_record)]),
	put(prize_record,undefined).

process_infos() ->
	filelib:ensure_dir("./log/"),
	File = "./log/processes_infos.log",
	{ok, Fd} = file:open(File, [write, raw, binary, append]),
	Fun = fun(Pi,Pid) ->
		Info = io_lib:format("=>~p =>~p \n\n",[Pid,Pi]),
		case  filelib:is_file(File) of
			true   ->   file:write(Fd, Info);
			false  ->
				file:close(Fd),
				{ok, NewFd} = file:open(File, [write, raw, binary, append]),
				file:write(NewFd, Info)
		end,
		timer:sleep(20)
				end,
	[   Fun(erlang:process_info(P),P) ||   P <- erlang:processes()].

change_robot_master_name()->
	Account = robot_manager:get_account_id(1, 1),
%%	{ok,[Data]} = account_to_player_id_db:get_base(Account),
	[PlayerInfo] = player_info_db:get_player_info_by_account(Account),
	player_info_db:write_player_info(PlayerInfo#player_info{player_name = "牛萌萌"}).


log_test()->
	?INFO_LOG("kick player all___size ~p~n", [ets:info(?ETS_ONLINE, size)]).

test_log(Str) ->
	io:format("hahahah ~p~n", [Str]).

ybwl_reset_player_to_lv(PlayerId, Lv, IsOpen) ->
	DbActInfoRet = player_pay_activity_info_db:get(PlayerId),
	case DbActInfoRet of
		{ok, [ActInfo]} ->
			NowInfo = #player_pay_activity_info{
            player_id = ActInfo#player_pay_activity_info.player_id,
            task_id = Lv,  %% 任务id
            process = 0,  %% 进度
            status = [],  %% 完成状态
            open = IsOpen   %% 是否开启
          },
			io:format("ybwl reset convert ~p to ~p ", [ActInfo, NowInfo]),
			DBFun =
				fun() ->
					player_pay_activity_info_db:t_write(NowInfo)
				end,
			DBSuccessFun =
				fun() ->
					io:format("reset success.")
				end,
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					true;
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{?MODULE,?LINE,Reason, ?STACK_TRACE}]),
					false
			end;
		_ ->
			io:format("not found user for reset ybwl lv : ~p ~n", [PlayerId])
	end.

%% 2019.3.24 一本万利更新失误数据修复
fix_ybwl_task_update_error() ->
	ActList = player_pay_activity_info_db:get(),
	lists:foreach(
		fun (Elem) ->
			if 
				length(Elem#player_pay_activity_info.status) > 6 andalso Elem#player_pay_activity_info.task_id == 401 ->
					io:format("Error data ==> : ~p, need repair.~n", [Elem]),
					ybwl_reset_player_to_lv(Elem#player_pay_activity_info.player_id, 401, 1);
			true ->
				skip
			end
		end, ActList).

%%====================================================================================
% 新建一个玩家爆仓数据
create_new_laba_win_history(Type, PlayerId, Rewardnum, TimeInSec) ->
	EtsName = case Type of
		1 -> ?ETS_LAST_WIN_POOL_PLAYER;
		_ -> ?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER
	end,
	{ok,[PlayerInfo]} = player_info_db:get_base(PlayerId),
	{ok, PlayerUuid} = id_transform_util:role_id_to_proto(PlayerInfo#player_info.id),
	NewInfo = #pb_pool_win_player_info{
		player_uuid = PlayerUuid,
		icon_url = PlayerInfo#player_info.icon,
		player_name = PlayerInfo#player_info.player_name,
		vip_level = PlayerInfo#player_info.vip_level,
		win_gold = integer_to_list(Rewardnum),
		c_time = TimeInSec
	},
	laba_win_player_db:write(#laba_win_player{key = {TimeInSec,Type},info = NewInfo}),
	Length = ets:info(EtsName,size),
	if
		Length >= 10 ->
			FirstKey = ets:first(EtsName),
			ets:delete(EtsName,FirstKey),
			ets:insert(EtsName,#ets_data{key = TimeInSec,value = NewInfo}),
			laba_win_player_db:delete({TimeInSec,Type});
		true ->
			ets:insert(EtsName,#ets_data{key = TimeInSec,value = NewInfo})
	end.

change_laba_win_history({Time, Type}, WinGold, type_win_gold)->
	case laba_win_player_db:get({Time, Type}) of
		{ok, [Data]} ->
			EtsName = case Type of
				1 -> ?ETS_LAST_WIN_POOL_PLAYER;
				_ -> ?ETS_LAST_WIN_POOL_SUPER_LABA_PLAYER
			end,
			Info = Data#laba_win_player.info,
			NewInfo = Info#pb_pool_win_player_info {
				win_gold = WinGold
			},
			NewData = Data#laba_win_player {
				info = NewInfo
			},
			laba_win_player_db:write(NewData),
			ets:delete(EtsName, Time),
			ets:insert(EtsName, #ets_data{key = Time,value = NewInfo});
		_ ->
			not_found
	end.

force_rand_change_laba_history_vip_lv()->
	List = laba_win_player_db:get(),
	lists:foreach(fun (Elem)->
		Info = Elem#laba_win_player.info,
		if 
			0 == Info#pb_pool_win_player_info.vip_level ->
				InfoNew = Info#pb_pool_win_player_info {
					vip_level = util:rand(3, 5)
				},
				ELemNew = Elem#laba_win_player {
					info = InfoNew
				},
				laba_win_player_db:write(ELemNew);
			true ->
				skip
		end
	end, List).

%%====================================================================================
%% 强制重置用户资产
dirty_reset_player_means(PlayerId)->
	case player_info_db:get_base(PlayerId) of
		{ok,[PlayerInfo]}->
			if 
				PlayerInfo#player_info.is_robot ->
					skip;
				true ->
					NewPlayerInfo = PlayerInfo#player_info{
						gold = 20000,
						diamond = 30,
						cash = 0,
						recharge_money = 0,
						vip_level = 0
					},
					DBFun1 = fun() ->
						player_info_db:t_write_player_info(NewPlayerInfo)
					end,
					SuccessFun1 =fun()->
						ybwl_reset_player_to_lv(PlayerId, 401, 0),
						player_items_db:delete_player_item_list(PlayerId),
						player_pack_task_info_db:delete(PlayerId)
					end,
					case dal:run_transaction_rpc(DBFun1) of
						{atomic, _} ->
							SuccessFun1(),
						ok;
						{aborted, Reason} ->
							?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}])
					end
			end;
		_->
			skip
	end.

dirty_reset_all_player_means()->
	case player_info_db:get_first() of
		'$end_of_table' ->
			skip;
		Key ->
			a_dirty_reset_all_player_means_step(Key)
	end.

a_dirty_reset_all_player_means_step(Key)->
	dirty_reset_player_means(Key),
	case player_info_db:get_next(Key) of
		'$end_of_table' ->
			skip;
		NextKey ->
			a_dirty_reset_all_player_means_step(NextKey)
	end.

%%====================================================================================
reset_player_stickiness_redpack_by_qid(Id, Qid) ->
	case player_stickiness_redpack_level_info_db:get_base(Id) of
		{ok, [X]} ->
			?INFO_LOG("reset_player_stickiness_redpack_by_qid convert X ~p~n", [X]),
			ProjList = X#player_stickiness_redpack_level_info.proj_list,
			NewProjList = lists:filter(fun (Elem) ->
				{_, TestType, _} = Elem#player_stickiness_redpack_level_info_proj_elem.key,
				TestType =/= Qid
			end, ProjList),
			NewX = X#player_stickiness_redpack_level_info{
				proj_list = NewProjList
			},
			player_stickiness_redpack_level_info_db:write(NewX);
		_ ->
			skip
	end.
priv_reset_player_stickiness_redpack_by_qid_next(Current, Qid) ->
	case mnesia:dirty_next(player_stickiness_redpack_level_info, Current) of
        '$end_of_table' ->
            skip;
        Next ->
            [X] = mnesia:dirty_read({player_stickiness_redpack_level_info, Next}),
            case X#player_stickiness_redpack_level_info.proj_list of
				[] -> skip;
				[Elem | _] ->
					reset_player_stickiness_redpack_by_qid(X#player_stickiness_redpack_level_info.key, Qid);
				_ ->
					skip
			end,
			priv_reset_player_stickiness_redpack_by_qid_next(Next, Qid);
		_ ->
			skip
    end.
priv_reset_player_stickiness_redpack_by_qid_first(Qid) ->
	case mnesia:dirty_first(player_stickiness_redpack_level_info) of
        '$end_of_table' ->
            skip;
        First ->
            [X] = mnesia:dirty_read({player_stickiness_redpack_level_info, First}),
            case X#player_stickiness_redpack_level_info.proj_list of
				[] -> skip;
				[Elem | _] ->
					reset_player_stickiness_redpack_by_qid(X#player_stickiness_redpack_level_info.key, Qid);
				_ ->
					skip
			end,
			priv_reset_player_stickiness_redpack_by_qid_next(First, Qid);
		_ ->
			skip
    end.
reset_all_player_stickiness_redpack_by_qid(Qid) ->
	priv_reset_player_stickiness_redpack_by_qid_first(Qid).

%%====================================================================================
priv_write_player_statistics(X) ->
	NewPDB = case X#player_statistics.et_prev_daily_bet of
		{A1, B1, C1, D1} ->
			{A1, B1, C1, D1, 0};
		_ ->
			X#player_statistics.et_prev_daily_bet
	end,
	NewLDB = case X#player_statistics.et_last_daily_bet of
		{A2, B2, C2, D2} ->
			{A2, B2, C2, D2, 0};
		_ ->
			X#player_statistics.et_last_daily_bet
	end,
	NewPDE = case X#player_statistics.et_prev_daily_earn of
		{A3, B3, C3, D3} ->
			{A3, B3, C3, D3, 0};
		_ ->
			X#player_statistics.et_prev_daily_earn
	end,
	NewLDE = case X#player_statistics.et_last_daily_earn of
		{A4, B4, C4, D4} ->
			{A4, B4, C4, D4, 0};
		_ ->
			X#player_statistics.et_last_daily_earn
	end,
	player_statistics_db:write_player_statistics(X#player_statistics{
		et_prev_daily_bet = NewPDB,
		et_last_daily_bet = NewLDB,
		et_prev_daily_earn = NewPDE,
		et_last_daily_earn = NewLDE
	}).
upgrade_player_statistics_next(Prev) ->
	case mnesia:dirty_next(player_statistics, Prev) of
        '$end_of_table' ->
            skip;
        Next ->
			[X] = mnesia:dirty_read({player_statistics, Next}),
            priv_write_player_statistics(X),
			upgrade_player_statistics_next(Next);
		_ ->
			skip
	end.
upgrade_player_statistics() ->
	case mnesia:dirty_first(player_statistics) of
        '$end_of_table' ->
            skip;
        First ->
            [X] = mnesia:dirty_read({player_statistics, First}),
            priv_write_player_statistics(X),
			upgrade_player_statistics_next(First);
		_ ->
			skip
    end.