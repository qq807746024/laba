-module(util_math).

-compile(export_all).

%% 向上取整
ceiling(X)  ->
    T = erlang:trunc(X),
    case X - T of
        P when P <0 ->  T;
        P when P >0 ->  T + 1;
        _   ->  T
    end.

%% 向下取整
floor(X)    ->
    T = erlang:trunc(X),
    case X - T of
        P when P < 0 -> T - 1;
        P when P > 0 -> T;
        _   ->  T
    end.

%% 保留n位小数
keep_point(Float,N) ->
    ceiling(Float * math:pow(10, N)) / math:pow(10,N).

%% %rsa加密
%% %test:rsa_encrypt_decrypt().
%% rsa_encrypt_decrypt() ->
%%     PubEx  = 65537,
%%     PrivEx = 7531712708607620783801185371644749935066152052780368689827275932079815492940396744378735701395659435842364793962992309884847527234216715366607660219930945,
%%     Mod = 7919488123861148172698919999061127847747888703039837999377650217570191053151807772962118671509138346758471459464133273114654252861270845708312601272799123,
%%     
%%     PrivKey = [PubEx, Mod, PrivEx],
%%     PubKey  = [PubEx, Mod],
%% 
%%     Msg = <<"7896345786348 Asldi">>,
%% 
%%     PKCS1 = rsa_public_encrypt(Msg, PubKey, rsa_pkcs1_padding),
%%     PKCS1Dec = rsa_private_decrypt(PKCS1, PrivKey, rsa_pkcs1_padding),
%%     io:format("Msg ~p~n",[Msg]),
%%     io:format("PKCS1Dec ~p~n",[PKCS1Dec]),
%%     Msg = PKCS1Dec,
%%     ok.
%% 
%% rsa_public_encrypt(Msg, Key, Pad) ->
%%     C1 = crypto:rsa_public_encrypt(Msg, Key, Pad),
%%     C2 = crypto:rsa_public_encrypt(Msg, util:map(fun(E) -> crypto:mpint(E) end, Key), Pad),
%%     {C1,C2}.
%% 
%% rsa_private_decrypt({C1,C2}, Key, Pad) ->
%%     R = crypto:rsa_private_decrypt(C1, Key, Pad),
%%     R = crypto:rsa_private_decrypt(C2, Key, Pad),
%%     R = crypto:rsa_private_decrypt(C1, util:map(fun(E) -> crypto:mpint(E) end, Key), Pad),
%%     R = crypto:rsa_private_decrypt(C2, util:map(fun(E) -> crypto:mpint(E) end, Key), Pad).

