%% @author zouv
%% @doc @todo GM后台接口

-module(gm_oprate).
-include_lib("gate/include/common.hrl").
-include_lib("db/include/mnesia_table_def.hrl").

-include("def.hrl").
%% ====================================================================
%% API functions
%% ====================================================================
-export([
	send_mail/3,
	system_announcement/3,        %% 公告
	bind_player_phone/3,	%% 绑定手机
	set_game_fax/3,		%% 设定税率
	set_forbid_state/3,		%% 禁登(只是将玩家踢下线) 禁言
	set_niu_blacklist/3, 	%% 设置看牌黑名单
	kick_out_player/3,  %% 踢出玩家
	update_hundred_change_cards_config/3, %%
	update_hundred_spe_pool/3,
	add_storage/3,  %% 修改红包库存
	share_mission/3, %% 分享任务
	seven_day_carnival/3, %% 7日任务
	player_exchange_record/3, %% 玩家兑换记录
	add_super_laba_pool/3, %% 超级拉霸水池
	add_hundred_pool/3, %%修改百人牛牛奖池

	change_player_info/3,
	change_redpack_info/3,
	change_rmb_and_vip_lv/3,
	copy_role/3,
	open_block_trade/3, %% 是否开启大额充值
	open_car_win/3,
	add_car_mon_target/3,
	del_car_mon_target/3,
	change_hundred_niu_rate/3,
	add_fruit_special_pool/3,
	add_super_fruit_special_pool/3
]).
-export([
	check_server_ok/3,
	check_server_memory/3,
	check_clean_garbage/3,    %% 检测内存垃圾回收
	get_depot/3,
	is_valid/2
]).

%% 验证请求
%%：Sign = md5(所有参数内容+key) 
is_valid(BinSign, ParaList1) ->
	ParaList2 = lists:map(fun({_, EBin}) ->list_to_binary(EBin) end, lists:keysort(1, ParaList1)),
	ParaList =
		util:map(fun(E) ->
			if
				is_list(E) ->
					E;
				true ->
					""
			end
		end,
			ParaList2),

	StrPara = lists:concat(ParaList),
	CheckSign = erlang:list_to_binary(util:md5(StrPara)),
	io:format("is_valid___1 ~p~n", [{BinSign, CheckSign}]),
	{CheckSign == list_to_binary(BinSign), 0}.


%% 发奖励邮件:
%% http://127.0.0.1:9891/cgi-bin/gm_oprate:send_mail?
%% 参数：
%% sign:验证串=md5(下面参数字符串连接(按usort排列下面key))
%% time: 时间(默认当前时间)
%% title: 标题
%% content: 内容
%% roleid: 角色id
%% type: 类型 0发单人 1发所有人
%% reward: 奖励内容(空表示没奖励) 格式=101,99+102,99(表示加金币99和钻石99)
send_mail(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					sign,
					time,
					title,
					content,
					roleid,
					type,
					reward
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Title  = proplists:get_value("title", Parameters),
					Content  = proplists:get_value("content", Parameters),
					RoleId  = proplists:get_value("roleid", Parameters),
					Type  = proplists:get_value("type", Parameters),
					Reward  = proplists:get_value("reward", Parameters),
					gm_mod:do_send_mail(Title, Content, RoleId, list_to_integer(Type), Reward);
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason ->
				?ERROR_LOG("send mail Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
				log_util:add_gm_oprate(?MLOG_ETS_GM_error, error_mail, []),
				{1, "参数错误!"}
		end,

	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 全服公告
%%http://127.0.0.1:9891/cgi-bin/gm_oprate:system_announcement?
%%参数：sign=Sign&beginTime=Time&endTime=Time&intervalSeconds=Seconds&content=Content
%%起始时间：beginDataTime
%%：{{2014,10,01},{8,0,0}}
%%结束时间：endDataTime
%%：{{2014,10,10},{20,0,0}}
%%公告间隔：intervalSeconds
%%：3600
%%公告内容：content
system_announcement(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					sign,
					beginTime,
					endTime,
					intervalSeconds,
					content
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			%BinSign  = proplists:get_value("sign", Parameters),
			BeginTime  = proplists:get_value("beginTime", Parameters),
			EndTime  = proplists:get_value("endTime", Parameters),
			IntervalSeconds  = proplists:get_value("intervalSeconds", Parameters),
			Content  = proplists:get_value("content", Parameters),
%% 			List = [
%% 				{"beginTime", BeginTime},
%% 				{"endTime", EndTime},
%% 				{"intervalSeconds", IntervalSeconds},
%% 				{"content", Content}
%% 			],
			%?INFO_LOG("List ~p~n",[List]),
			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					case gm_mod:add_announcement(BeginTime, EndTime, IntervalSeconds, Content) of
						true ->
							log_util:add_gm_oprate(?MLOG_ETS_GM_success, system_announcement, [BeginTime, EndTime, IntervalSeconds, Content]),
							{0, "发送成功"};
						{false, R} ->
							log_util:add_gm_oprate(?MLOG_ETS_GM_error, system_announcement, [BeginTime, EndTime, IntervalSeconds, Content]),
							{1, R}
					end;
				 _ ->
					 {1, "参数错误"}
			end
		catch
			Error:Reason ->
				?ERROR_LOG("system announcement Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
				log_util:add_gm_oprate(?MLOG_ETS_GM_error, system_announcement, []),
				{1, "参数错误!"}
		end,

	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


%% 检测服务器状态
check_server_ok(SessionID, _Env, _Input) ->
	{OnlineCount, TotalMemory} = get_server_status(),
	mod_esi:deliver(SessionID, lists:concat(["Content-Type: text/html; charset=UTF-8\r\n\r\n", "OK-", OnlineCount, "-", TotalMemory])).

get_server_status() ->
	OnlineCount = gm_mod:get_online_count(),
	TotalMemory = erlang:memory(total),
	{OnlineCount, TotalMemory}.


%% 打印服务器内存数据
check_server_memory(SessionID, _Env, _Input) ->
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n"] ++ get_server_now_memory_status()).

get_server_now_memory_status() ->
	%% 打开../etop_info_export.txt 发送页面
	case file:open("etop_info_export.txt", [read]) of
		{ok, Rd} ->
			Result = get_html_data(Rd, []),
			file:close(Rd),
			%% 端口
			Port = config_app:get_tcp_port(),
			%% 当前内存
			Memory = erlang:memory(total),
			lists:concat(["<p>", Port, ":", Memory, Result, "</p>"]);
		{error, Err} ->
			Err
	end.

get_html_data(Rd, OutList) ->
	Result = io:get_line(Rd, ""),
	if
		Result == eof ->
			OutList;
		true ->
			get_html_data(Rd, OutList ++ [lists:concat([Result, "<br>"])])
	end.

check_clean_garbage(SessionID, _Env, Input) ->
	InputList = util_url:parse_paremeter(Input),
	MaxMemory = proplists:get_value("mm", InputList),
	NowTotalMem = erlang:memory(total),
	if
		MaxMemory < NowTotalMem ->
			[erlang:garbage_collect(Pid) || Pid <- processes()],
			mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n"] ++ ["Do_Clean"]);
		true ->
			mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n"] ++ ["Skip"])
	end.

get_depot(SessionID, _Env, _Input) ->
	%% ETS_GOLD_DEPOT_INFO
	[DepotInfo] = ets:lookup(?ETS_GOLD_DEPOT_INFO, 1),
	mod_esi:deliver(SessionID, lists:concat(["Content-Type: text/html; charset=UTF-8\r\n\r\n", "OK-", DepotInfo#gold_depot_info.total_depot, "-",
		DepotInfo#gold_depot_info.today_depot])).

%% 绑定手机号
%http://127.0.0.1:9891/cgi-bin/gm_oprate:bind_player_phone?
%参数：sign=Sign&role_id=role_id&phone_num = 1
% role_id 账号id string
% phone_num 固定为1 string
%验证标识sign:
%：Sign = md5(所有参数内容)     例：Sign = md5(role_id+phone_num)
bind_player_phone(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					role_id,
					phone_num,
					sign
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Account  = proplists:get_value("role_id", Parameters),
					PhoneNum  = proplists:get_value("phone_num", Parameters),

					case add_player_phone(Account, PhoneNum) of
						{false, Reason} ->
							{1, Reason};
						_ ->
							{0, "绑定成功"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


%% add_player_phone(Account, PhoneNum, 1) ->
%% 	{ObjPlayerId, _} = string:to_integer(string:strip(Account)),
%% 	case player_info_db:get_player_info_role_id(ObjPlayerId) of
%% 		[PlayerInfo] ->
%% 			{PhoneNum, _} = string:to_integer(string:strip(PhoneNum)),
%% 			add_player_phone(PlayerInfo, PhoneNum);
%% 		_ ->
%% 			{false, "无该玩家记录"}
%% 	end.
%%
%% add_player_phone(_PlayerInfo, PhoneNum) ->
%% 	player_util:cs_player_bind_phone_num(PhoneNum).
add_player_phone(Account, _PhoneNum) ->
	player_util:cs_player_bind_phone_num(Account).

%% 设置游戏税率
%http://127.0.0.1:9991/cgi-bin/gm_oprate:set_game_fax?
%参数：sign=Sign&type=Type&rate=Rate&fax=Fax
% type = 1
% rate = 倍率
% fax = 税率
%验证标识sign:
%：Sign = md5(所有参数内容)     例：Sign = md5(role_id+phone_num)
set_game_fax(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					type,
					rate,
					fax
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Type  = proplists:get_value("type", Parameters),
					Rate  = proplists:get_value("rate", Parameters),
					Fax  = proplists:get_value("fax", Parameters),

					case gm_mod:set_game_fax(Type, Rate, Fax) of
						{false, Reason} ->
							{1, Reason};
						_ ->
							{0, "修改成功"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 禁登、禁言
%%http://127.0.0.1:9001/cgi-bin/gm_oprate:set_forbid_state?
%%参数：sign=Sign&roleid=RoleId&type=Type&flag=Flag
%%玩家角色id：roleid
%%类型：type
%%：1登录
%%：2聊天
%%操作标识：flag
%%：1禁止
%%：0解禁
set_forbid_state(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					roleid,
					type,
					flag
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					RoleId  = proplists:get_value("roleid", Parameters),
					Type  = proplists:get_value("type", Parameters),
					Flag  = proplists:get_value("flag", Parameters),

					case gm_mod:set_forbid_state(list_to_integer(RoleId), list_to_integer(Type), list_to_integer(Flag)) of
						{false, Reason} ->
							{1, Reason};
						_ ->
							{0, "修改成功"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


%% 添加&删除黑名单
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:set_niu_blacklist?
%%参数：sign=Sign&roleid=RoleId&type=Type&flag=Flag&rand=Rand
%%玩家角色id：roleid
%%类型：type
%%：0=看牌
%%操作标识：flag
%%：1=加入 or 修改概率
%%：0删除
%% 概率 : rand 0-100
set_niu_blacklist(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					roleid,
					type,
					flag,
					rand
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					RoleId  = proplists:get_value("roleid", Parameters),
					Type  = proplists:get_value("type", Parameters),
					Flag  = proplists:get_value("flag", Parameters),
					Rand  = proplists:get_value("rand", Parameters),

					case gm_mod:set_niu_blacklist(list_to_integer(RoleId), list_to_integer(Type), list_to_integer(Flag), list_to_integer(Rand)) of
						{false, Reason} ->
							{1, Reason};
						_ ->
							?INFO_LOG(" ~p~n",[{list_to_integer(RoleId), list_to_integer(Type), list_to_integer(Flag), list_to_integer(Rand)}]),
							{0, "修改成功"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 从房间踢出玩家（牛牛和红包场）
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:kick_out_player?
%%参数：sign=Sign&roleid=RoleId
%%玩家角色id：roleid
kick_out_player(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					roleid
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					RoleId  = proplists:get_value("roleid", Parameters),

					case player_info_db:get_player_info_by_account(RoleId) of
						[PlayerInfo|_] ->
							case player_niu_room_util:kick_out_from_room(PlayerInfo#player_info.id) of
								skip ->
									{1,"玩家不在房间里"};
								ok ->
									{0,"成功"}
							end;
						_->
							{1, "玩家不存在"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 修改百人牛牛控制概率
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:update_hundred_change_cards_config?
%%参数：sign=Sign&keyid=KeyId&num1=Num1&num2=Num2&num3=Num3&num4=Num4&num5=Num5
%%keyid: 1 - 玩家庄， 2 - 系统庄
%% num1 -- num2 : 牌型从最小到最大的概率
update_hundred_change_cards_config(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					keyid,
					num1,
					num2,
					num3,
					num4,
					num5
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					KeyId  = list_to_integer(proplists:get_value("keyid", Parameters)),
					Num1  = list_to_integer(proplists:get_value("num1", Parameters)),
					Num2  = list_to_integer(proplists:get_value("num2", Parameters)),
					Num3  = list_to_integer(proplists:get_value("num3", Parameters)),
					Num4  = list_to_integer(proplists:get_value("num4", Parameters)),
					Num5  = list_to_integer(proplists:get_value("num5", Parameters)),
					case ets:lookup(?ETS_HUNDRED_CHANGE_CARDS_CONFIG,KeyId) of
						[_PlayerInfo|_] ->
							NewData = #hundred_change_cards_config{ key = KeyId,weight_list = {random_weight,[1,2,3,4,5],[Num1,Num2,Num3,Num4,Num5]}},
							ets:insert(?ETS_HUNDRED_CHANGE_CARDS_CONFIG,NewData),
							Content = lists:concat(["成功 =》",KeyId,",",Num1,",",Num2,",",Num3,",",Num4,",",Num5]),
							{0,Content};
						_->
							{1, "keyid错误"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 修改百人牛牛特殊水池
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:update_hundred_spe_pool?
%%参数：sign=Sign&goldnum=GoldNum
%%goldnum: 水池数值
update_hundred_spe_pool(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					goldnum
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					GoldNum = list_to_integer(proplists:get_value("goldnum", Parameters)),
					depot_manager_mod:add_to_depot({GoldNum,0},'hundred_special_pool'),
					{0, "请查看后台数据，确保水池值覆盖成功"};
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 修改百人牛牛奖池
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:add_hundred_pool?
%%参数：sign=&goldnum=GoldNum&roomid=RoomId
%%goldnum: 添加奖池数值
%%roomid: 房间id
add_hundred_pool(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					goldnum,
					roomid
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					GoldNum = list_to_integer(proplists:get_value("goldnum", Parameters)),
					RoomId = list_to_integer(proplists:get_value("roomid", Parameters)),
					case ntools:add_to_hundred_pool(RoomId, GoldNum) of
						ok->
							{0, "成功"};
						skip ->
							{1,"房间id错误"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 修改红包库存
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:add_storage?
%%参数：sign=Sign&id=Id&num=Num
%%id:红包id
%% num：数量
add_storage(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
				?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id,
					num
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end, FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					Num = list_to_integer(proplists:get_value("num", Parameters)),
					case prize_mod:add_storage([Id],Num) of
						ok ->
							{0, "请登入游戏查看，确保库存修改成功"};
						E->
							?INFO_LOG("Err ~p~n",[{?MODULE,?LINE,E}]),
							{1, "错误"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 分享任务
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:share_mission?
%%参数：sign=Sign&id=Id
%%id:账号id
share_mission(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
%%			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Account = proplists:get_value("id", Parameters),
					case player_info_db:get_player_info_by_account(Account) of
						[Info]->
							case role_manager:get_roleprocessor(Info#player_info.id) of
								{ok,Pid} ->
									role_processor_mod:cast(Pid,{'do_share_mission','type_prize',10});
								_->
									player_share_util:do_share_mission_offline({Info#player_info.id,4})
							end,
							{0,"成功"};
						_->
							{1, "玩家信息错误"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 七天狂欢渠道
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:seven_day_carnival?
%%参数：sign=Sign&str=Str&id=Id
%% id =>1,7日狂欢；2，一本万利
seven_day_carnival(SessionID, _Env, Input)->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			%% ?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					str,
					id
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					Str = proplists:get_value("str", Parameters),
					?INFO_LOG("str~p~n",[{Str}]),
					StrList = string:tokens(Str, ";"),
					ChnidList =
					lists:map(fun(EStr) ->
						[EStr1,EStr2] = string:tokens(EStr, ","),
						{list_to_integer(EStr1),list_to_integer(EStr2)} end,StrList),

					if
						Id == 1->
							NowChnidConfig = #activity_chnid_config{
								key = 1,
								chnid_list = ChnidList,
								time = util:now_seconds()
							},
							activity_chnid_config_db:write(NowChnidConfig),
							gate_app:init_ets_activity_chnid_config(?ETS_ACTIVITY_CHNID_CONFIG,NowChnidConfig#activity_chnid_config.chnid_list,NowChnidConfig#activity_chnid_config.time),
							{0, "成功"};
						Id == 2 ->
							NowChnidConfig = #activity_gold_chnid_config{
								key = 1,
								chnid_list = ChnidList,
								time = util:now_seconds()
							},
							activity_gold_chnid_config_db:write(NowChnidConfig),
							gate_app:init_ets_activity_chnid_config(?ETS_ACTIVITY_GOLD_CHNID_CONFIG,NowChnidConfig#activity_gold_chnid_config.chnid_list,NowChnidConfig#activity_gold_chnid_config.time),
							{0, "成功"};
						true ->
							{1, "id错误"}
					end;
				_ ->
					{1, "参数错误123"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 玩家兑换记录
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:player_exchange_record?
%%参数：sign=Sign&id=Id&time=Time
%% id 玩家角色id
player_exchange_record(SessionID, _Env, Input)->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
%%			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id,
					time
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					Time = list_to_integer(proplists:get_value("time", Parameters)),
					case player_info_db:get_base(Id) of
						{ok,[PlayerInfo]}->
							case player_prize_exchange_record_db:get_by_player_id(PlayerInfo#player_info.id) of
								List when is_list(List)->
									StrList =
									lists:foldl(fun(E,Acc)->
										case util:is_same_date(E#player_prize_exchange_record.second_time,Time) of
											true ->
												EStr=lists:concat([E#player_prize_exchange_record.id,",",E#player_prize_exchange_record.record_type,",",E#player_prize_exchange_record.obj_id,",",
													E#player_prize_exchange_record.need_item_id,",",E#player_prize_exchange_record.need_item_num,",",E#player_prize_exchange_record.second_time,";"]),
												lists:concat([EStr,Acc]);
											false ->
												Acc
										end
										 end,"",List),
%%									?INFO_LOG("StrList~p~n",[StrList]),
									{0,StrList};
								_->
									{1, "查询数据库错误"}
							end;
						_->
							{1, "玩家不存在"}
					end;
				_ ->
					{1, "参数错误123"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 超级拉霸水池增加（兼容水果）
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:add_super_laba_pool?
%%参数：sign=Sign&num=Num&is_super=IsSuper
%% Num 增加多少金币
add_super_laba_pool(SessionID, _Env, Input)->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			%% ?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					num_pool,
					num_rank,
					is_super
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end, FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					NumPool = list_to_integer(proplists:get_value("num_pool", Parameters)),
					NumRank = list_to_integer(proplists:get_value("num_rank", Parameters)),
					IsSuper = list_to_integer(proplists:get_value("is_super", Parameters)),
					if
						0 =:= IsSuper ->
							gen_server:cast(laba_mod:get_mod_pid(), {'cast_add_pool_num', {NumPool, 0}});
						true ->
							gen_server:cast(laba_mod:get_mod_pid(), {'cast_add_pool_num_super_laba', {NumPool, NumRank}})
					end,
					{0, "成功"};
				_ ->
					{1, "参数错误1"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 修改
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:change_player_info?
%%参数：sign=Sign&id=Id&goldnum=GoldNum&dia=Dia&acount=Account&name=Name&rmb=Rmb&betnum=BetNum&vip=Vip&level=Level&ticket=Ticket&playerwin=Playerwin&redpack=Redpack
%%	id:玩家id
%% goldnum：金币数量
%% dia : 钻石,
%% acount:
change_player_info(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
%%			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id,
					goldnum,
					dia,
					acount,
					rmb,
					betnum,
					vip,
					level,
					ticket,
					playerwin,
					redpack
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end, FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					Num = list_to_integer(proplists:get_value("goldnum", Parameters)),
					Dia = list_to_integer(proplists:get_value("dia", Parameters)),
					Account = proplists:get_value("acount", Parameters),
					Name = proplists:get_value("name", Parameters),
					Rmb = list_to_integer(proplists:get_value("rmb", Parameters)),
					BetNum = list_to_integer(proplists:get_value("betnum", Parameters)),
					Vip = list_to_integer(proplists:get_value("vip", Parameters)),
					Level = list_to_integer(proplists:get_value("level", Parameters)),
					Ticket = list_to_integer(proplists:get_value("ticket", Parameters)),
					Playerwin = list_to_integer(proplists:get_value("playerwin", Parameters)),
					RedPack = list_to_integer(proplists:get_value("redpack", Parameters)),
					case player_info_db:get_base(Id) of
						{ok,[Info]}->
							NewInfo = Info#player_info{
								gold = Num,
								diamond = Dia
							},
							player_info_db:write_player_info(NewInfo);
						_->
							PlayerInfo =
								#player_info{
									id = Id,
									account = Account,
									player_name = Name,
									gold = Num,
									diamond = Dia,
									exp = 0,
									level = Level,
									vip_level = Vip,
									recharge_money = Rmb,
									create_time = util:now_seconds(),
									sex =0,
									cash = Ticket,
									is_robot = false	,	%% 是否机器人
									robot_cls = 0,		%% 0=普通 1=百人庄家
									guide_step_id = 0,	%% 新手引导id
									login_forbid_state = 0,	%% 禁登=1
									chat_forbid_state = 0	%% 禁言=1
								},
							AccInfo = #account_to_player_id{
								account = Account,
								player_id = Id
							},
							account_to_player_id_db:write(AccInfo),
							player_info_db:write_player_info(PlayerInfo)
					end,
					case hundred_niu_cost_db:get(Id) of
						{ok,[Info1]} ->
							NewInfo1 = Info1#hundred_niu_cost{
								num = BetNum
							},
							hundred_niu_cost_db:write(NewInfo1);
						_->
							NewInfo1 = #hundred_niu_cost{
								player_id = Id,
								num = BetNum
							},
							hundred_niu_cost_db:write(NewInfo1)
					end,
					case player_winning_record_info_db:get(Id) of
						{ok,[PWIn]}->
							NewPwin = PWIn#player_winning_record_info{
								total_gains = Playerwin
							},
							player_winning_record_info_db:write(NewPwin);
						_->
							NewPwin = #player_winning_record_info{
								player_id = Id,
								total_gains = Playerwin
							},
							player_winning_record_info_db:write(NewPwin)
					end,
					case player_items_db:get_player_item_list(Id) of
						List when is_list(List)->
							case lists:keyfind(109,#player_items.entry,List) of
								false ->
									New = item_util:create_item_info(Id, 109, RedPack),
									player_items_db:write_player_items(New);
								Old ->
									New = Old#player_items{
										count = RedPack
									},
									player_items_db:write_player_items(New)
							end;
						_->
							skip
					end,
					{0,"成功"};
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 红包广场
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:change_redpack_info?
%%参数：sign=Sign&id=Id&num=Num&time=Time
%%	id:玩家id
%% num：数量
change_redpack_info(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id,
					num,
					time
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end, FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					SetNum = list_to_integer(proplists:get_value("num", Parameters)),
					Time = list_to_integer(proplists:get_value("time", Parameters)),
					{ok,[PlayerInfo]} = player_info_db:get_base(Id),
					RedId = roleid_generator:get_auto_red_pack_id(),
					{ok, [Config]}= red_pack_config_db:get(1),
					RedPack = player_redpack_util:get_red_pack_info(SetNum, "恭喜发财，大吉大利", Time, PlayerInfo, RedId, Config),
					red_pack_info_db:t_write(RedPack),
					{ok,"成功"};
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


%% 修改充值和vip等级
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:change_rmb_and_vip_lv?
%%参数：sign=Sign&id=Id&num=Num&lv=Lv
%%	id:角色id
%% num：人民币
%% lv:vip等级
change_rmb_and_vip_lv(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					id,
					num,
					lv
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Id = list_to_integer(proplists:get_value("id", Parameters)),
					SetNum = list_to_integer(proplists:get_value("num", Parameters)),
					Lv = list_to_integer(proplists:get_value("lv", Parameters)),
					case ntools:change_vip_level(Id,SetNum,Lv) of
						ok->
							{0,"成功"};
						skip->
							{1,"玩家不存在"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%%
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:copy_role?
%%参数：sign=Sign&account1=Account1&account2=Account2
%%	id:角色id
copy_role(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			?INFO_LOG("Parameters~p~n",[Parameters]),
			FieldNameAtoms =
				[
					account1
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
								 end,
					FieldNameAtoms),

			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Account1 = proplists:get_value("account1", Parameters),
					Account2 = proplists:get_value("account2", Parameters),
					case account_to_player_id_db:get_base(Account1) of
						{ok,[AInfo1]} ->
							case account_to_player_id_db:get_base(Account2) of
								{ok,[AInfo2]} ->
									if
										AInfo1#account_to_player_id.player_id == AInfo2#account_to_player_id.player_id ->
											case player_info_db:get_player_info_by_account(Account1) of
												[PInfo1]->
													if
														PInfo1#player_info.account == Account1 ->
															NewPId = roleid_generator:get_auto_player_id(),
															PInfo2 = PInfo1#player_info{
																id = NewPId,
																account = Account2
															},
															case player_items_db:get_player_item_list(PInfo1#player_info.id) of
																List when is_list(List)->
																	case lists:keyfind(109,#player_items.entry,List) of
																		false ->
																			skip;
																		Old ->
																			New = item_util:create_item_info(NewPId, 109, Old#player_items.count),
																			?INFO_LOG("Newitem~p~n",[New]),
																			player_items_db:write_player_items(New)
																	end;
																_->
																	skip
															end,
															player_info_db:write_player_info(PInfo2),
															account_to_player_id_db:write(AInfo2#account_to_player_id{player_id = NewPId}),
															?INFO_LOG("NewPId~p~n",[NewPId]),
															{0,"成功"};
														PInfo1#player_info.account == Account2 ->
															NewPId = roleid_generator:get_auto_player_id(),
															PInfo2 = PInfo1#player_info{
																id = NewPId,
																account = Account1
															},
															case player_items_db:get_player_item_list(PInfo1#player_info.id) of
																List when is_list(List)->
																	case lists:keyfind(109,#player_items.entry,List) of
																		false ->
																			skip;
																		Old ->
																			New = item_util:create_item_info(NewPId, 109, Old#player_items.count),
																			?INFO_LOG("Newitem~p~n",[New]),
																			player_items_db:write_player_items(New)
																	end;
																_->
																	skip
															end,
															player_info_db:write_player_info(PInfo2),
															account_to_player_id_db:write(AInfo1#account_to_player_id{player_id = NewPId}),
															?INFO_LOG("NewPId~p~n",[NewPId]),
															{0,"成功"};
														true ->
															{0,"账号不匹配"}
													end;
												_->
													{1,"玩家数据不存在"}
											end;
										true ->
											{1,"玩家id不同"}
									end;
								_->
									{1,"账号2错误"}
							end;
						_->
							{1,"账号1错误"}
					end;
%%
%%					case account_to_player_id_db:get_base(Acount1) of
%%						{ok,[AInfo1]} ->
%%							?INFO_LOG("Ainfo~p~n",[AInfo]),
%%							case player_info_db:get_base(AInfo#account_to_player_id.player_id) of
%%								{ok,[PInfo]}->
%%									Acount2 = PInfo#player_info.account,
%%									if
%%										Acount == Acount2->
%%											{0,"账号相同"};
%%										true ->
%%											NewPlayerId = roleid_generator:get_auto_player_id(),
%%											NewPInfo = PInfo#player_info{
%%												id = NewPlayerId,
%%												account = Acount2
%%												},
%%											case account_to_player_id_db:get_base(Acount2) of
%%												{ok,[_AInfo2]}->
%%													NewAinfo2 = AInfo#account_to_player_id{
%%														player_id = NewPlayerId
%%													},
%%													account_to_player_id_db:write(NewAinfo2),
%%													player_info_db:write_player_info(NewPInfo),
%%													case player_items_db:get_player_item_list(PInfo#player_info.id) of
%%														List when is_list(List)->
%%															case lists:keyfind(109,#player_items.entry,List) of
%%																false ->
%%																	skip;
%%																Old ->
%%																	New = item_util:create_item_info(NewPlayerId, 109, Old#player_items.count),
%%																	?INFO_LOG("Newitem~p~n",[New]),
%%																	player_items_db:write_player_items(New)
%%															end;
%%														_->
%%															skip
%%													end,
%%													?INFO_LOG("NewPlayerId~p~n",[{Acount,Acount2,NewPlayerId}]),
%%													{0,"成功"};
%%												_->
%%													{1,"账号2不存在"}
%%											end
%%									end;
%%								_->
%%									{1,"玩家不存在"}
%%							end;
%%						_->
%%							{1,"账号不存在"}
%%					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate bind_player_phone Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


%%
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:open_block_trade?
%%  参数 open=true/false
open_block_trade(SessionID, _Env, Input) ->
	InputList = util_url:parse_paremeter(Input),
	{ErrCode, IsOpen} = case proplists:get_value("open", InputList) of
		"true" ->
			{ok, true};
		"false" ->
			{ok, false};
		_ ->
			{error, false}
	end,
	{ErrCode2, Desc} = try 
		if 
			ErrCode =/= ok ->
				{1, "参数错误"};
			true ->
				case base_shop_item_db:get(10009) of
					{ok, [Data]} ->
						if
							%196000000 =/= Data#base_shop_item.item_num ->
							%	{1, "大额充值配置已经更改，保险起见重新修改这个代码以确认"};
							true ->
								if 
									IsOpen ->
										NewData = Data#base_shop_item {
											discount = 100
										};
									true ->
										NewData = Data#base_shop_item {
											discount = 110
										}
								end,
								base_shop_item_db:write(NewData),
								gate_app:refresh_ets_data(),
								{0, "成功"}
						end;
					_ ->
						{2, "没有找到大额充值的商城物品"}
				end
		end
	catch
		Error:Reason1 ->
			?ERROR_LOG("gm_operate open_block_trade Error! ~n exception = ~p, ~n info = ~p~n",
				[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
			{2, "参数错误!"}
	end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(ErrCode2), Desc),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).


% /cgi-bin/gm_oprate:open_car_win?RoomId=1&WinPos=1
open_car_win(SessionID, _Env, Input)->
	InputList = util_url:parse_paremeter(Input),
	RoomId = list_to_integer(proplists:get_value("RoomId", InputList)),
	WinPos = list_to_integer(proplists:get_value("WinPos", InputList)),
	CheckedRoomPid = case ets:lookup(?ETS_CAR_ROOM, RoomId) of
		[RoomInfo] ->
			RoomPid = RoomInfo#car_room_info.room_pid,
			case erlang:is_pid(RoomPid) of
				true ->
					case erlang:is_process_alive(RoomPid) of
						true ->
							RoomPid;
						_ ->
							undefined
					end;
				_ ->
					undefined
			end;
		_ ->
			undefined
	end,
	{ErrCode, Desc} = case CheckedRoomPid of
		undefined ->
			{-1, "房间未找到"};
		_ ->
			gen_fsm:send_all_state_event(CheckedRoomPid, {'superadm_win_ctrl', WinPos}),
			{0, "成功"}
	end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(ErrCode), Desc),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

pri_add_or_del_car_mon_target(SessionID, InputList, IsAdd) ->
	RoomId = list_to_integer(proplists:get_value("RoomId", InputList)),
	MonId = list_to_integer(proplists:get_value("monId", InputList)),
	CheckedRoomPid = case ets:lookup(?ETS_CAR_ROOM, RoomId) of
		[RoomInfo] ->
			RoomPid = RoomInfo#car_room_info.room_pid,
			case erlang:is_pid(RoomPid) of
				true ->
					case erlang:is_process_alive(RoomPid) of
						true ->
							RoomPid;
						_ ->
							undefined
					end;
				_ ->
					undefined
			end;
		_ ->
			undefined
	end,
	{ErrCode, Desc} = case CheckedRoomPid of
		undefined ->
			{-1, "房间未找到"};
		_ ->
			if
				IsAdd ->
					gen_fsm:send_all_state_event(CheckedRoomPid, {'superadm_add_mon_target', MonId});
				true ->
					gen_fsm:send_all_state_event(CheckedRoomPid, {'superadm_del_mon_target', MonId})
			end,
			{0, "成功"}
	end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(ErrCode), Desc),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

% /cgi-bin/gm_oprate:add_car_mon_target?RoomId=1&monId=1
add_car_mon_target(SessionID, _Env, Input)->
	InputList = util_url:parse_paremeter(Input),
	pri_add_or_del_car_mon_target(SessionID, InputList, true).

% /cgi-bin/gm_oprate:del_car_mon_target?RoomId=1&monId=1
del_car_mon_target(SessionID, _Env, Input)->
	InputList = util_url:parse_paremeter(Input),
	pri_add_or_del_car_mon_target(SessionID, InputList, false).


%% 
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:change_hundred_niu_rate?
%%参数：sign=Sign&set=set&key=key
%%
change_hundred_niu_rate(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					key, set
				],
			FieldNames =
				util:map(fun(EFieldNameAtom) ->
					erlang:atom_to_list(EFieldNameAtom)
				end, FieldNameAtoms),
			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					Key = proplists:get_value("key", Parameters),
					SetData = proplists:get_value("set", Parameters),
					SetData1 = mochijson2:decode(SetData),
					?INFO_LOG("change_hundred_niu_rate~p",[{Key,SetData1}]),
					Flag = player_hundred_niu_util:gm_opt(Key, SetData1),
					if
						Flag =:= false ->
							{3, "类型错误"};
						true ->
							{0, "成功"}
					end;
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate change_hundred_niu_rate Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 增减水果水池
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:add_fruit_special_pool?
%%参数：sign=Sign&addNum=1000&addIndex=1&testType=1
%%
add_fruit_special_pool(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					addNum,
					addIndex,
					testType
				],
			FieldNames = util:map(fun(EFieldNameAtom) ->
				erlang:atom_to_list(EFieldNameAtom)
			end, FieldNameAtoms),
			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					AddNum = list_to_integer(proplists:get_value("addNum", Parameters)),
					AddIndex = list_to_integer(proplists:get_value("addIndex", Parameters)),
					TestType = list_to_integer(proplists:get_value("testType", Parameters)),
					depot_manager_mod:is_fruit_pool_enough_then_update(AddIndex, AddNum, 0, 0, 0, TestType, true),
					{0, "成功"};
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate add_fruit_special_pool Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).

%% 增减超级水果水池
%%http://127.0.0.1:9991/cgi-bin/gm_oprate:add_super_fruit_special_pool?
%%参数：sign=Sign&addNum=1000&addIndex=1&testType=1
%%
add_super_fruit_special_pool(SessionID, _Env, Input) ->
	{Result, FailReason} =
		try
			{ok, Parameters}  = pay_handle:parse_paremeter(Input),
			FieldNameAtoms =
				[
					addNum,
					addIndex,
					testType
				],
			FieldNames = util:map(fun(EFieldNameAtom) ->
				erlang:atom_to_list(EFieldNameAtom)
			end, FieldNameAtoms),
			case pay_handle:all_paremeters_is_exist(Parameters, FieldNames) of
				{true, _} ->
					AddNum = list_to_integer(proplists:get_value("addNum", Parameters)),
					AddIndex = list_to_integer(proplists:get_value("addIndex", Parameters)),
					TestType = list_to_integer(proplists:get_value("testType", Parameters)),
					depot_manager_mod:is_super_fruit_pool_enough_then_update(AddIndex, AddNum, 0, 0, 0, TestType, true),
					{0, "成功"};
				_ ->
					{1, "参数错误"}
			end
		catch
			Error:Reason1 ->
				?ERROR_LOG("gm_operate add_super_fruit_special_pool Error! ~n exception = ~p, ~n info = ~p~n",
					[{Error, Reason1}, {?MODULE, ?LINE, erlang:get_stacktrace(), Input}]),
				{2, "参数错误!"}
		end,
	ResultStr = ?RETURN_FORMAT(integer_to_list(Result), FailReason),
	mod_esi:deliver(SessionID, ["Content-Type: text/html; charset=UTF-8\r\n\r\n", ResultStr]).
