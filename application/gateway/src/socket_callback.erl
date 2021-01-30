-module(socket_callback).
-include("../../gate/include/logger.hrl").
-export([
		 get_client_mod/0,
		 on_socket_receive/6, 
		 on_socket_close/5
		]).

get_client_mod()->
	[
	 {?MODULE, on_socket_receive, []},
	 {?MODULE, on_socket_close, []}
	].

%% 接收客户端的数据包
on_socket_receive(GatePid, BinData, ClientSocket, ClientIp, PlayerPid, ProtoKey)->
    try
        case socket_buffer:decode(BinData) of
            {ok, ProtoBinData} ->
                Msg = decode(ProtoBinData, ProtoKey),
                package_dispatcher:dispatch(Msg, GatePid, ClientSocket, PlayerPid);
            _ ->
                skip
        end
    catch
        E:R->
            ?ERROR_LOG("socket receive error! E=~p~n R=~p~n info = ~p~n ",
                                [{?MODULE, ClientIp, BinData, erlang:get_stacktrace()}, E, R]),
            {null}
    end.

%% 关闭网关
on_socket_close(_Reason, _ClientSocket, _PlayerPid, _PlayerId, _Account) ->
	%?INFO_LOG("~p close gate! info = ~w ~s~n\n", [?MODULE, {Reason, ClientSocket, PlayerId}, Account]),
	ok.

%% 数据包解密
decode(Binary, ProtoKey) ->
	{ok, ProtoId, IsCrypto, MsgBin} = message_code:split_bin(Binary),
%% 	%% *************打印接收的消息*************
%% 	io:format("~n ------------------    decode Msg,  ProtoId = ~p    ------------------------ ~n", [ProtoId]),
%% 	%% ***********************************

	if
		%% 已加密
		IsCrypto == 1 ->
			MsgBin1 = util_crypto:decrypt_data_aes_cfb128(MsgBin, ProtoKey);
		true ->
			MsgBin1 = MsgBin
	end,
    {ok, Msg} = message_code:decode_msg_bin(ProtoId, MsgBin1),
	%{ok, Msg} = message_code:decode_msg_bin(ProtoId, MsgBin),

	Msg.


