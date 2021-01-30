%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 二月 2017 14:40
%%%-------------------------------------------------------------------
-module(player_winning_record).
-author("Administrator").

-include("role_processor.hrl").
-include("item.hrl").
-include("common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").
-include_lib("network_proto/include/player_pb.hrl").

-define(PLAYER_WINNING_RECORD, player_winning_record). %%玩家胜负记录

%% API
-export([
	init_player_winning_record_info/1,
	save_winning_record_info/3,
	get_player_winning_record_info_by_key/1,
	handle_time/2,
	change_max_money/1,
	cs_query_player_winning_rec_req/1

]).

%%-------玩家胜负数据--------------
update_dic_player_winning_record_info(Info) ->
	put(?PLAYER_WINNING_RECORD, Info).

get_dic_player_winning_record_info() ->
	get(?PLAYER_WINNING_RECORD).

init_player_winning_record_info(PlayerId) ->
	case player_winning_record_info_db:get(PlayerId) of
		{ok, [PlayerWinningRecordInfo]} ->
			NowSec = util:now_seconds(),
			PlayerWinningRecordInfo1 =
				check_time(PlayerWinningRecordInfo, PlayerWinningRecordInfo#player_winning_record_info.last_time, NowSec),
			if
				PlayerWinningRecordInfo1 == PlayerWinningRecordInfo ->
					update_dic_player_winning_record_info(PlayerWinningRecordInfo1);
				true ->
					save_player_winning_record_info(PlayerWinningRecordInfo1)
			end;
		_ ->
			PlayerWinningRecordInfo = create_new_player_winning_record_info(PlayerId),
			save_player_winning_record_info(PlayerWinningRecordInfo)
	end.

save_player_winning_record_info(Info) ->
	DBFun =
		fun() ->
			player_winning_record_info_db:t_write(Info)
		end,
	DBSuccessFun =
		fun() ->
			update_dic_player_winning_record_info(Info)
		end,
	case dal:run_transaction_rpc(DBFun) of
		{atomic, _} ->
			DBSuccessFun(),
			ok;
		{aborted, Reason} ->
			?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
			error
	end.

create_new_player_winning_record_info(PlayerId) ->
	PlayerInfo = player_util:get_dic_player_info(),

	#player_winning_record_info{
		player_id = PlayerId,
		max_money = PlayerInfo#player_info.gold
	}.
%%---------------------------------------------------

check_time(PlayerWinningRecordInfo, OldSec, NewSec) ->
	Flag = util:is_same_week(OldSec, NewSec),
	if
		Flag ->
			PlayerWinningRecordInfo;
		true ->
			PlayerWinningRecordInfo#player_winning_record_info{
				this_week_gains = 0,
				last_time = NewSec
			}
	end.
%%  0点定时器
handle_time(OldSec, NewSec) ->
	PlayerWinningRecordInfo = get_dic_player_winning_record_info(),
	PlayerWinningRecordInfo1 = check_time(PlayerWinningRecordInfo, OldSec, NewSec),
	if
		PlayerWinningRecordInfo1 == PlayerWinningRecordInfo ->
			skip;
		true ->
			save_player_winning_record_info(PlayerWinningRecordInfo1)
	end.


%%保存胜负记录
save_winning_record_info(KeyList, Money, NiuRoomLevel) ->
	PlayerWinningRecordInfo1 = get_dic_player_winning_record_info(),
	Win = PlayerWinningRecordInfo1#player_winning_record_info.win,
	Lose = PlayerWinningRecordInfo1#player_winning_record_info.lose,
	TotalGains = PlayerWinningRecordInfo1#player_winning_record_info.total_gains,
	ThisWeekGains = PlayerWinningRecordInfo1#player_winning_record_info.this_week_gains,
	NewPlayerWinningRecordInfo1 =
		lists:foldl(fun(Key, PlayerWinningRecordInfo) ->
			case Key of
				'niu_niu' ->
					NiuNiu = PlayerWinningRecordInfo#player_winning_record_info.niu_niu_times,
					PlayerWinningRecordInfo#player_winning_record_info{
						niu_niu_times = NiuNiu + 1
					};
				'wu_hua_niu' ->
					WuHuaNiu = PlayerWinningRecordInfo#player_winning_record_info.wu_hua_niu_times,
					PlayerWinningRecordInfo#player_winning_record_info{
						wu_hua_niu_times = WuHuaNiu + 1
					};
				'si_zha' ->
					SiZha = PlayerWinningRecordInfo#player_winning_record_info.si_zha_times,

					PlayerWinningRecordInfo#player_winning_record_info{
						si_zha_times = SiZha + 1
					};
				'wu_xiao_niu' ->
					WuXiaoNiu = PlayerWinningRecordInfo#player_winning_record_info.wu_xiao_niu_times,

					PlayerWinningRecordInfo#player_winning_record_info{
						wu_xiao_niu_times = WuXiaoNiu + 1
					};
				'san_pai' ->
					SanPai = PlayerWinningRecordInfo#player_winning_record_info.san_pai_times,
					if
						Money > 0 ->
							AddTimes = 1;
						true ->
							AddTimes = 0
					end,

					PlayerWinningRecordInfo#player_winning_record_info{
						san_pai_times = SanPai + AddTimes
					};
				_ ->
					PlayerWinningRecordInfo
			end end, PlayerWinningRecordInfo1, KeyList),

	NowSecond = util:now_seconds(),
	PlayerInfo = player_util:get_dic_player_info(),

	if
		PlayerInfo#player_info.is_robot ->
			EtsFun = fun() -> skip end,
			NewPlayerWinningRecordInfo3 = NewPlayerWinningRecordInfo1;
		true ->
			%?INFO_LOG("NiuRoomLevel ~p Money ~p ~n",[NiuRoomLevel, Money]),
			case NiuRoomLevel of
				0 ->
					EtsFun = fun() -> skip end,
					NewPlayerWinningRecordInfo3 = NewPlayerWinningRecordInfo1;
				10 ->
					EtsFun = fun() -> skip end,
					NewPlayerWinningRecordInfo3 = NewPlayerWinningRecordInfo1#player_winning_record_info{
						hundred_total_win = NewPlayerWinningRecordInfo1#player_winning_record_info.hundred_total_win+Money
					};
				_ ->
					NewPlayerWinningRecordInfo3 = NewPlayerWinningRecordInfo1#player_winning_record_info{
						room_level_gold_list = util:update_keylist_data(NiuRoomLevel, Money,
							NewPlayerWinningRecordInfo1#player_winning_record_info.room_level_gold_list)
					},
					PlayerId = NewPlayerWinningRecordInfo1#player_winning_record_info.player_id,
					NewEtsRec =
						case ets:lookup(?ETS_NIU_BLACKLIST, PlayerId) of
							[] ->
								#niu_blacklist{player_id = PlayerId,flag = 0,rand = 0,
									room_level_gold_list = NewPlayerWinningRecordInfo3#player_winning_record_info.room_level_gold_list};
							[OldEtsRec] ->
								OldEtsRec#niu_blacklist{room_level_gold_list = NewPlayerWinningRecordInfo3#player_winning_record_info.room_level_gold_list}
						end,

					EtsFun = fun() ->
						%?INFO_LOG("NewEtsRec ~p ~n",[NewEtsRec]),
						ets:insert(?ETS_NIU_BLACKLIST, NewEtsRec) end
			end
	end,
	if
		Money > 0 ->
			NewPlayerWinningRecordInfo2 = NewPlayerWinningRecordInfo3#player_winning_record_info{
				win = Win + 1,
				last_time = NowSecond,
				total_gains = TotalGains + Money,
				this_week_gains = ThisWeekGains + Money
			},

			{DBFun, DBSuccessFun} = add_max_money1(NewPlayerWinningRecordInfo2, Money),
			case dal:run_transaction_rpc(DBFun) of
				{atomic, _} ->
					DBSuccessFun(),
					EtsFun(),
					ok;
				{aborted, Reason} ->
					?ERROR_LOG("run transaction error:~p~n", [{Reason, ?STACK_TRACE}]),
					error
			end;
		true ->
			NewPlayerWinningRecordInfo2 = NewPlayerWinningRecordInfo3#player_winning_record_info{
				last_time = NowSecond,
				lose = Lose + 1
			},
			save_player_winning_record_info(NewPlayerWinningRecordInfo2),
			EtsFun()
	end.

%%获取数据
get_player_winning_record_info_by_key(Key) ->
	PlayerWinningRecordInfo = get_dic_player_winning_record_info(),
	case Key of
		'win' ->
			PlayerWinningRecordInfo#player_winning_record_info.win;
		'lose' ->
			PlayerWinningRecordInfo#player_winning_record_info.lose;
		'niu_niu' ->
			PlayerWinningRecordInfo#player_winning_record_info.niu_niu_times;
		'si_zha' ->
			PlayerWinningRecordInfo#player_winning_record_info.si_zha_times;
		'wu_hua_niu' ->
			PlayerWinningRecordInfo#player_winning_record_info.wu_hua_niu_times;
		'wu_xiao_niu' ->
			PlayerWinningRecordInfo#player_winning_record_info.wu_xiao_niu_times;
		'san_pai' ->
			PlayerWinningRecordInfo#player_winning_record_info.san_pai_times;
		'max_money' ->
			PlayerWinningRecordInfo#player_winning_record_info.max_money;
		'total_gains' ->
			PlayerWinningRecordInfo#player_winning_record_info.total_gains;
		'this_week_gains' ->
			PlayerWinningRecordInfo#player_winning_record_info.this_week_gains;
		'rate' ->
			Win = PlayerWinningRecordInfo#player_winning_record_info.win,
			Lose = PlayerWinningRecordInfo#player_winning_record_info.lose,
			if
				Win == 0 ->
					Rate = 0;
				true ->
					Rate = Win / (Lose + Win) * 100
			end,
			Rate;
		_ ->
			?INFO_LOG("get_winning_record_match_key_fail", [Key]),
			0
	end.
%%最大财富变动
change_max_money(Money) ->
	PlayerWinningRecordInfo = get_dic_player_winning_record_info(),
	add_max_money1(PlayerWinningRecordInfo, Money).

add_max_money1(PlayerWinningRecordInfo, NowMoney) ->
	OldMaxMoney = PlayerWinningRecordInfo#player_winning_record_info.max_money,
	NewPlayerWinningRecordInfo =
		if
			NowMoney > OldMaxMoney ->
				PlayerWinningRecordInfo#player_winning_record_info{
					max_money = NowMoney
				};
			true ->
				PlayerWinningRecordInfo
		end,
	DBFun =
		fun() ->
			player_winning_record_info_db:t_write(NewPlayerWinningRecordInfo)
		end,
	DBSuccessFun =
		fun() ->
			update_dic_player_winning_record_info(NewPlayerWinningRecordInfo)
		end,
	{DBFun, DBSuccessFun}.
	%save_player_winning_record_info(NewPlayerWinningRecordInfo).


cs_query_player_winning_rec_req(ObjPlayerUuid) ->
	PlayerInfo = player_util:get_dic_player_info(),
	case ObjPlayerUuid of
		undefined ->
			PlayerWinRec = get_dic_player_winning_record_info(),
			do_send_win_record_msg(PlayerWinRec, ObjPlayerUuid,PlayerInfo);
		"" ->
			PlayerWinRec = get_dic_player_winning_record_info(),
			do_send_win_record_msg(PlayerWinRec, ObjPlayerUuid,PlayerInfo);
		_ ->
			{ok, PlayerId} = id_transform_util:role_id_to_internal(ObjPlayerUuid),
			case player_winning_record_info_db:get(PlayerId) of
				{ok, [PlayerWinRec]} ->
					ObjPlayerInfo = player_info_db:get_player_info(PlayerId),  %%检测？？？
					do_send_win_record_msg(PlayerWinRec, ObjPlayerUuid,ObjPlayerInfo);
				_ ->
					?INFO_LOG("cs_query_player_winning_rec_req Get Error ~p~n", [{?MODULE, ?LINE}])
			end
	end,
	ok.



do_send_win_record_msg(PlayerWinRec, ObjPlayerUuid,ObjPlayerInfo) ->
	if
		PlayerWinRec#player_winning_record_info.win == 0 ->
			WinRate = 0;
		true ->
			Win = PlayerWinRec#player_winning_record_info.win,

			if
				Win == 0 ->
					WinRate = 0;
				true ->
					WinRate = trunc(PlayerWinRec#player_winning_record_info.win*100 /
						(Win + PlayerWinRec#player_winning_record_info.lose))
			end

	end,

	Msg = #sc_query_player_winning_rec_reply{
		win_rate = WinRate,
		win_count = PlayerWinRec#player_winning_record_info.win,
		defeated_count = PlayerWinRec#player_winning_record_info.lose,
		max_property = PlayerWinRec#player_winning_record_info.max_money,
		total_profit = PlayerWinRec#player_winning_record_info.total_gains,
		week_profit = PlayerWinRec#player_winning_record_info.this_week_gains,
		niu_10 = PlayerWinRec#player_winning_record_info.niu_niu_times,
		niu_11 = PlayerWinRec#player_winning_record_info.si_zha_times,
		niu_12 = PlayerWinRec#player_winning_record_info.wu_hua_niu_times,
		niu_13 = PlayerWinRec#player_winning_record_info.wu_xiao_niu_times,
		niu_0_win = PlayerWinRec#player_winning_record_info.san_pai_times,
		obj_player_uuid = ObjPlayerUuid,
		obj_name = ObjPlayerInfo#player_info.player_name,
		sex = ObjPlayerInfo#player_info.sex,
		gold = ObjPlayerInfo#player_info.gold,
		icon = ObjPlayerInfo#player_info.icon,
		level = ObjPlayerInfo#player_info.level,
		vip_level = ObjPlayerInfo#player_info.vip_level,
		account = ObjPlayerInfo#player_info.account
	},
	tcp_client:send_data(player_util:get_dic_gate_pid(), Msg).