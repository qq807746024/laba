%% @author zouv
%% @doc 登录验证

-module(login_check).
-include("../../gate/include/logger.hrl").
-include_lib("network_proto/include/login_pb.hrl").
-include_lib("gate/include/record.hrl").

-define(PLATFORM_FLAG_DEV, 1000001).   % 开发服
-define(PLATFORM_FLAG_RELEASE, 1000002).   % 外网服
-define(PLATFORM_FLAG_DEV_IOS, 1010001).   % 开发服（苹果）
-define(PLATFORM_FLAG_RELEASE_IOS, 1010002).   % 外网服（苹果）

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	is_validate_login/2,
	is_validate_reconnection/1,
	check_server_full/0,
	cs_login_to_login_data/6,
	authenticate/1
]).

%% ====================================================================
%% Internal functions
%% ====================================================================

authenticate(PszParam) ->
	case PszParam of
		undefined ->
			?INFO_LOG(" Login_authenticate_failed PszParam is undefined"),
			false;
		"" ->
			?INFO_LOG(" Login_authenticate_failed PszParam is """),
			false;
		_ ->
			try
				StrParam = base64:decode_to_string(PszParam),
				ListParam = string:tokens(StrParam, ","),
				if
					erlang:length(ListParam) /= 10 ->
						?INFO_LOG("~p authenticate base64 decode error! ListParam = ~p~n", [?MODULE, ListParam]),
						false;
					true ->
						StrSign = lists:nth(10, ListParam),
						StrAuthKey = ["EHbL5SegMbJy2lrcVUJvkVZ1ne5i0Q"],
						ListClientInfo = lists:sublist(ListParam, 9),
						ListMd5 = [ListClientInfo | StrAuthKey],
						StrMd5 = string:join(ListMd5, ""),
						Md5Hex = lists:flatten([io_lib:format("~2.16.0b", [D]) || D <- binary_to_list(erlang:md5(StrMd5))]),
						?INFO_LOG("~p~n", Md5Hex),
						string:equal(Md5Hex, StrSign)
				end
			catch
				Error:Reason ->
					?ERROR_LOG(" login_check Error! ~n exception = ~p, ~n info = ~p~n",
						[{Error, Reason}, {?MODULE, ?LINE, erlang:get_stacktrace()}]),
					false
			end
	end.

%% 登录验证
is_validate_login(Msg, _ClientIP) ->
	#cs_login{
		sz_param = PszParam
	} = Msg,
	%?INFO_LOG("Login    PszParam ........ ~p~n",[PszParam]),
	Flag = authenticate(PszParam),
	if
		Flag ->
			is_validate_login1(Msg);
		{false, Msg} ->
			{false, Msg};
		true ->
			{false, "账号验证失败！"}
	end.
	%is_validate_login1(Msg).

is_validate_login1(Msg) ->
	#cs_login{
		platform_flag = _PlatformId,
		sz_param = Sz_Param,
		uid = _Account,


		password = Password
	} = Msg,
	PlatFormList = config_app:get_platform_list(),
	StrParam = base64:decode_to_string(Sz_Param),
	ListParam = string:tokens(StrParam, ","),
	Account = lists:nth(1, ListParam),
	%% 用手机号登录的就传1，否则为0
	IsPhoneLogin1 = list_to_integer(lists:nth(3, ListParam)),
	%?INFO_LOG("lists:nth(3, ListParam) ~p~n",[lists:nth(3, ListParam)]),
	Sex1 = lists:nth(5,ListParam),
	Sex = list_to_integer(Sex1),
	Name = lists:nth(6,ListParam),

	Icon = lists:nth(7,ListParam),
	Chnid = list_to_integer(lists:nth(8,ListParam)),
	ShareId = list_to_integer(lists:nth(9,ListParam)),
%%	?INFO_LOG("ShareId~p~n",[ShareId]),
	if
		IsPhoneLogin1 > 1 orelse IsPhoneLogin1 < 0 ->
			?INFO_LOG("Error ~p~n",[{?MODULE, ?LINE, IsPhoneLogin1}]),
			IsPhoneLogin = 0;
		true ->
			IsPhoneLogin = IsPhoneLogin1
	end,
	%?INFO_LOG("StrParam ==== ~p~n",[StrParam]),
	if
		PlatFormList /= [] ->
			case config_app:is_server_type_dev() of
			%% 开发服
				true ->
					RLoginData = cs_login_to_login_data(Msg, Account, IsPhoneLogin,Icon,Name,{Sex,Chnid,ShareId}),
					{ok, Account, Account, RLoginData};
			%% SDK登录
				_ ->
					%%暂时使用 外网测试服 检测方式,下面注释是原来的检测方式
					case login_check_dev:check([Account, Password]) of
						{true, Account} ->
							RLoginData = cs_login_to_login_data(Msg, Account, IsPhoneLogin,Icon,Name,{Sex,Chnid,ShareId}),
							{ok, Account, Account, RLoginData};
						{false, _Reason} = FailedReturn ->
							FailedReturn
					end
			end;
		true ->
			{false, "服务器维护中..."}
	end.

%% 重连验证
is_validate_reconnection(Msg) ->
	#cs_login_reconnection{
		platform_flag = _PlatformId,
		user = Uid,
		reconnect_key = ClientReconnectKey
	} = Msg,
	%?INFO_LOG("ReConnect Msg------- ~p~n",[Msg]),
	case id_transform_util:role_id_to_internal(Uid) of
		{ok, PlayerId} ->
			case player_info_db:get_player_info_role_id(PlayerId) of
				[_PlayerData] ->
					case role_manager:get_roleprocessor(PlayerId) of
						{ok, PlayerPid} ->
							case role_processor_mod:call(PlayerPid, {'check_reconnection_key', ClientReconnectKey}) of
								{true, Account} ->
									{ok, PlayerId, PlayerPid, Account};
								_ ->
									{false, "验证失效，请重新登录!"}
							end;
						_ ->
							{false, "已退出游戏，请重新登陆!"}
					end;
				_ ->
					{false, "请先创建帐号!"}
			end;
		_ ->
			{false, "Uid错误!"}
	end.


check_server_full() ->
	OnlineCount = 0, %tools_operation:get_online_count(),
	case config_app:get_online_limit() of
		CountLimit when OnlineCount >= CountLimit ->
			true;
		_ ->
			false
	end.


cs_login_to_login_data(CsLogin, Uid, IsPhoneLogin,"0",_Name,{_Sex,Chnid,ShareId}) ->
	#cs_login{
		platform_flag = PlatformId,
		uid = Account,
		password = _Password,
		version = Version,
		network_type = NetworkType,
		sys_type = SysType,
%%		chnid = Chnid,
%%		sub_chnid = SubChnid,
		ios_idfa = IosIdFa,
		ios_idfv = IosIdFv,
		mac_address = MacAddress,
		device_type = DeviceType
	} = CsLogin,
	#r_login_data{
		platform_flag = PlatformId,
		openid = Account,
		uid = Uid,
		version = Version,
		network_type = NetworkType,
		sys_type = SysType,
		chnid = Chnid,
		sub_chnid = ShareId,
		ios_idfa = IosIdFa,
		ios_idfv = IosIdFv,
		mac_address = MacAddress,
		device_type = DeviceType,
		is_phone_login = IsPhoneLogin
	};

cs_login_to_login_data(CsLogin, Uid, IsPhoneLogin,Icon,Name,{Sex,Chnid,ShareId}) ->
	#cs_login{
		platform_flag = PlatformId,
		uid = Account,
		password = _Password,
		version = Version,
		network_type = NetworkType,
		sys_type = SysType,
%%		chnid = Chnid,
%%		sub_chnid = SubChnid,
		ios_idfa = IosIdFa,
		ios_idfv = IosIdFv,
		mac_address = MacAddress,
		device_type = DeviceType
	} = CsLogin,
	#r_login_data{
		platform_flag = PlatformId,
		openid = Account,
		uid = Uid,
		version = Version,
		network_type = NetworkType,
		sys_type = SysType,
		chnid = Chnid,
		sub_chnid = ShareId,
		ios_idfa = IosIdFa,
		ios_idfv = IosIdFv,
		mac_address = MacAddress,
		device_type = DeviceType,
		is_phone_login = IsPhoneLogin,
		player_icon = Icon,
		player_name = Name,
		sex = Sex
	}.




