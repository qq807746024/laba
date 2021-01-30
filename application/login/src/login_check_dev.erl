%% @author zouv
%% @doc @todo “开发服”登录验证

-module(login_check_dev).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
         check/1
        ]).



%% ====================================================================
%% Internal functions
%% ====================================================================
check([Uid, Password]) ->
    case Password of
        [BinPassword] ->
            ok;
        _ ->
            BinPassword = <<>>
    end,
    StrPassword = erlang:binary_to_list(BinPassword),
    case config_app:is_server_type_dev() of
        true ->
            IsAccountValid = true;
        _ ->
            IsAccountValid = account_db:check_account(Uid, StrPassword)
    end,
    if
        IsAccountValid ->
            {true, Uid};
        true ->
            {false, "帐号或密码错误！"}
    end.


