%% @author zouv
%% @doc socket数据缓存

-module(socket_buffer).

-include_lib("network_proto/include/common_pb.hrl").
-include_lib("network_proto/include/player_pb.hrl").
-include_lib("network_proto/include/login_pb.hrl").

-define(COUNT_BIT,                      32).
%-define(CLIENT_CLEAN_INTERVAL,          10).   % 客户端清理间隔
-define(SERVER_BUFFER_LIMIT,            20).  % 服务端缓存数量限制
-define(SERVER_BUFFER_MAX,              10).   % 服务端缓存数量

%% 进程字典
-define(DIC_CLIENT_PROTO_COUNT,         dic_client_proto_count).
-define(DIC_SERVER_PROTO_COUNT,         dic_server_proto_count).
-define(DIC_PROTO_DATA_BUFFER,          dic_proto_data_buffer).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
         cs_clean/1,
         cs_count/2,
         
         decode/1,
         encode/2,
         
         get_socket_buffer/0,
         update_socket_buffer/2,
         get_next_server_proto_count/1
        ]).

%% ====================================================================
%% Internal functions
%% ====================================================================
%% --------------- 客户端协议计数 ---------------
update_dic_client_proto_count(Count) ->
    put(?DIC_CLIENT_PROTO_COUNT, Count).

get_dic_client_proto_count() ->
    case get(?DIC_CLIENT_PROTO_COUNT) of
        undefined ->
            0;
        ClientProtoCount ->
            ClientProtoCount
    end.

%% --------------- 服务端协议计数 ---------------
update_dic_server_proto_count(Count) ->
    put(?DIC_SERVER_PROTO_COUNT, Count).

get_dic_server_proto_count() ->
    case get(?DIC_SERVER_PROTO_COUNT) of
        undefined ->
            0;
        ClientProtoCount ->
            ClientProtoCount
    end.

%% %% --------------- 协议缓存 ---------------
%% update_dic_proto_data_buffer(List) ->
%%     put(?DIC_PROTO_DATA_BUFFER, List).
%%
%% get_dic_proto_data_buffer() ->
%%     case get(?DIC_PROTO_DATA_BUFFER) of
%%         undefined ->
%%             [];
%%         List ->
%%             List
%%     end.


%% 更新客户端已接收的协议计数
cs_clean(_Msg) ->
	ok.
%%     #cs_common_proto_clean{
%%                            count = Count
%%                           } = Msg,
%%     List = get_dic_proto_data_buffer(),
%%     %io:format("cs_clean___1 ~p~n", [{Count, length(List)}]),
%%     NewList =
%%         util:filter(fun({ECount, _EProtoBin}) ->
%%                          ECount > Count
%%                      end,
%%                      List),
%%     update_dic_proto_data_buffer(NewList).

%% 通知服务端清理协议缓存
cs_count(_ClientSocket, _Msg) ->
	ok.
%%     #cs_common_proto_count{
%%                            count = Count
%%                           } = Msg,
%%     List = get_dic_proto_data_buffer(),
%%     SupplementList =
%%         util:filter(fun({ECount, _EProtoBin}) ->
%%                          ECount > Count
%%                      end,
%%                      List),
%%     util:foreach(fun({ECount, EProtoBin}) ->
%%                       EBinData = <<ECount:?COUNT_BIT, EProtoBin/binary>>,
%%                      tcp_client:send_bin(ClientSocket, EBinData)    % 补发缓存的协议
%%                  end,
%%                  SupplementList).

decode(BinData) ->
    <<Count:?COUNT_BIT, ProtoBinData/binary>> = BinData,
	%%<<MsgType:16, TempBinData/binary>> = ProtoBinData,
	%%io:format("~n socket_buffer decode...... Count : ~p  MsgType: ~p ~n", [Count, MsgType]),

    ClientProtoCount = get_dic_client_proto_count(),
    NewClientProtoCount = ClientProtoCount + 1,
    %io:format("decode___1 ~p~n", [{self(), get(dic_account), Count, ClientProtoCount}]),
%%     if
%%         Count == 0 ->
%%             skip;
%%         Count == NewClientProtoCount andalso Count rem ?CLIENT_CLEAN_INTERVAL == 0 ->
%%             send_common_proto_clean(ClientProtoCount);
%%         true ->
%%             skip
%%     end,
    if
        Count == 0 ->
            {ok, ProtoBinData};
        Count == NewClientProtoCount ->
            update_dic_client_proto_count(NewClientProtoCount),
            {ok, ProtoBinData};
        true ->
            ok%send_common_proto_count(ClientProtoCount)
    end.

encode(Msg, ProtoBinData) ->
    NextServerProtoCount = get_next_server_proto_count(Msg),
    if
        NextServerProtoCount == 0 ->
            skip;
        true ->
            update_dic_server_proto_count(NextServerProtoCount)
            %add_proto_data_buffer(NextServerProtoCount, ProtoBinData)
    end,
    %catch io:format("send_______________ ~ts ~p ~p ~p~n", [get(dic_account), NextServerProtoCount, element(1, Msg), byte_size(ProtoBinData)]),
    <<NextServerProtoCount:?COUNT_BIT, ProtoBinData/binary>>.

%% 通知客户端清理协议缓存
%% send_common_proto_clean(ClientProtoCount) ->
%%     %io:format("send_common_proto_clean___1 ~p~n", [{ClientProtoCount}]),
%%     Msg =
%%         #sc_common_proto_clean{
%%                                count = ClientProtoCount
%%                               },
%%     self() ! {'send_data', Msg}.
%%
%% %% 更新服务端已接收的协议计数
%% send_common_proto_count(ClientProtoCount) ->
%%     %io:format("send_common_proto_count___1 ~p~n", [{ClientProtoCount}]),
%%     Msg =
%%         #sc_common_proto_clean{
%%                                count = ClientProtoCount
%%                               },
%%     self() ! {'send_data', Msg}.

get_next_server_proto_count(Msg) ->
    case Msg of
        #sc_login_reply{} ->
            0;
        #sc_common_heartbeat_reply{} ->
            0;
        #sc_login_reconnection_reply{} ->
            0;
        #sc_player_chat{} ->
            0;
        #sc_player_sys_notice{} ->
            0;
        _ ->
            ServerProtoCount = get_dic_server_proto_count(),
            ServerProtoCount + 1
    end.

get_socket_buffer() ->
    ClientProtoCount = get_dic_client_proto_count(),
    ServerProtoCount = get_dic_server_proto_count(),
    {ClientProtoCount, ServerProtoCount, []}.

update_socket_buffer({ClientProtoCount, ServerProtoCount, _ProtoDataBuffer}, _ClientSocket) ->
    update_dic_client_proto_count(ClientProtoCount),
    update_dic_server_proto_count(ServerProtoCount).
%%     update_dic_proto_data_buffer(ProtoDataBuffer),
%%     List = get_dic_proto_data_buffer(),
%%     util:foreach(fun({ECount, EProtoBin}) ->
%%                       EBinData = <<ECount:?COUNT_BIT, EProtoBin/binary>>,
%%                       tcp_client:send_bin(ClientSocket, EBinData)   % 补发缓存的协议
%%                  end,
%%                  List),
%%     send_common_proto_clean(ClientProtoCount).                      % 通知客户端清理多余的缓存


