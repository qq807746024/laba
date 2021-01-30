%% @author zouv
%% @doc @todo 加密

-module(util_crypto).

-compile(export_all).

-define(DEFAULT_CRYPTO_MOD, 		aes_cfb128).
-define(BYTE_SIZE_UNIT, 			16).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).



%% ====================================================================
%% Internal functions
%% ====================================================================

test_encrypt_data(TempData) ->
	%% 加密
	%Key = crypto:hmac(md5, <<21>>, <<100>>),
    Ivec = crypto:rand_bytes(16),
	Key = Ivec,
io:format("encrypt_data___1 ~p~n", [{TempData, byte_size(Key), byte_size(Ivec), Key, Ivec}]),
	CipherText = crypto:aes_cfb_128_encrypt(Key, Ivec, TempData),
	%CipherText = crypto:block_encrypt(?DEFAULT_CRYPTO_MOD, Key, Ivec, TempData),
	%CipherText1 = crypto:block_encrypt(aes_cbc128, Key, Ivec, TempData),
	%CipherText2 = crypto:block_encrypt(aes_cbc256, Key, Ivec, TempData),
io:format("encrypt_data___2 ~p~n", [CipherText]),
	%% 解密
	_Key1 = crypto:hmac(md5, <<22>>, <<100>>),
	_Ivec1 = crypto:rand_bytes(16),
	%PlainText = crypto:block_decrypt(?DEFAULT_CRYPTO_MOD, Key, Ivec, CipherText),
	PlainText = crypto:aes_cfb_128_decrypt(Key, Ivec, CipherText),
io:format("encrypt_data___3 ~p~n", [{PlainText}]),
	ok.

%% %% AES加密算法的CFB模式进行加密
%% %%：Data 为加密的数据
%% %%：Key 为16位密钥
%% %%：Ivec 为初始化向量
%% encrypt_data_aes_cfb128(PlainText, Key) ->
%% 	%Ivec = crypto:rand_bytes(16),
%% 	crypto:block_encrypt(?DEFAULT_CRYPTO_MOD, Key, Key, PlainText).
%% 
%% decrypt_data_aes_cfb128(CipherText, Key) ->
%% 	%Ivec = crypto:rand_bytes(16),
%% 	crypto:block_decrypt(?DEFAULT_CRYPTO_MOD, Key, Key, CipherText).

%% 版本问题，这里先使用15B的低版本接口
encrypt_data_aes_cfb128(PlainText, Key) ->
	Size = erlang:byte_size(PlainText),
	ZeroCount = (?BYTE_SIZE_UNIT - (Size rem ?BYTE_SIZE_UNIT)) rem ?BYTE_SIZE_UNIT,
	ZeroBin = binary:copy(<<0:8/unsigned-big-integer>>, ZeroCount),
	PlainText2 = <<PlainText/binary, ZeroBin/binary>>,
	ResultBin = crypto:aes_cfb_128_encrypt(Key, Key, PlainText2),
    <<ResultBin2:Size/binary, _/binary>> = ResultBin,
    ResultBin2.

decrypt_data_aes_cfb128(CipherText, Key) ->
    Size        = erlang:byte_size(CipherText),
    ZeroCount   = (?BYTE_SIZE_UNIT - (Size rem ?BYTE_SIZE_UNIT)) rem ?BYTE_SIZE_UNIT,
    ZeroBin     = binary:copy(<<0:8/unsigned-big-integer>>, ZeroCount),
    CipherText2 = <<CipherText/binary, ZeroBin/binary>>,
	ResultBin = crypto:aes_cfb_128_decrypt(Key, Key, CipherText2),
    <<ResultBin2:Size/binary, _/binary>> = ResultBin,
    ResultBin2.

%% RSA 公钥解密
%% CipherText, Key
decrypt_data_rsa(_CipherText, RSAPublicKey) ->
	CipherText = <<"测试">>,
	io:format("Format ~p ~n", [CipherText]),
	Index = 1,
	Acc = [],
	decrypt_data_rsa(CipherText, RSAPublicKey, Index, Acc).

decrypt_data_rsa(CipherText, RSAPublicKey, Index, Acc) ->
	%% 按128位分段解密
    Len = erlang:length(CipherText) - Index,
	if
		Index =< Len ->
			if
				Len >= 128 ->
					Len1 = 128;
				true ->
					Len1 = Len
			end,
			SubCipherText = string:substr(CipherText, Index, Len1),
			DecryptBin = public_key:decrypt_public(erlang:list_to_binary(SubCipherText), RSAPublicKey),
			DecryptStr = erlang:binary_to_list(DecryptBin),
			NewAcc = Acc ++ DecryptStr,
			NewIndex = Index + Len1,
			decrypt_data_rsa(CipherText, RSAPublicKey, NewIndex, NewAcc);
		true ->
			Acc
	end.

%% AES cbc 加密 add by sen
%% PlaniText, Key 均为二进制数据
encrypt_data_aes_cbc128(PlainText, Key) ->
   Size = erlang:byte_size(PlainText),
   Padding = ?BYTE_SIZE_UNIT - (Size rem ?BYTE_SIZE_UNIT),
   PaddingBin = binary:copy(<<Padding:8/unit:1>>, Padding),
   PlainText2 = <<PlainText/binary, PaddingBin/binary>>,
   %crypto:aes_cfb_128_encrypt(Key, Key, PlainText2).        % 版本问题，使用旧接口
   crypto:block_encrypt(aes_cbc128, Key, Key, PlainText2).

%% AES cbc 解密 add by sen
%% CipherText, Key 均为二进制数据
decrypt_data_aes_cbc128(CipherText, Key) ->
    %ResultBin = crypto:aes_cfb_128_decrypt(Key, Key, CipherText),
	ResultBin = crypto:block_decrypt(aes_cbc128, Key, Key, CipherText),
    ResultLen = erlang:byte_size(ResultBin),
	R2 = (ResultLen-1) * 8,
	<<_RCount:R2, Count:8>> = ResultBin,
	Size = ResultLen - Count,
	<<ResultBin2:Size/binary, _/binary>> = ResultBin,
    ResultBin2.

%% 异或加密
bxor_binary(Binary, CryptoNum) ->
    list_to_binary(dualmap(fun(E1, E2) ->
                               E1 bxor E2
                           end, 
                           binary_to_list(Binary), 
                           CryptoNum)).

dualmap(_F, [], _) ->
    [];
dualmap(F, [E1 | L1], E2) ->
    [F(E1, E2) | dualmap(F, L1, E2)].    


