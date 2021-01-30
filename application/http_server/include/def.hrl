-ifndef(DEF_HRL).
-define(DEF_HRL, true).

-define(KEY, "132a0951abf27e9e").        % 验证秘钥 md5(yyfdtllmailkey)
-define(MAIL_FOR_ALL, "cef0eed69108ec93").        % 全服标识 md5(yyfdtllmailforall)

%% 返回值定义 json个格式：
%% {
%%  "result":"true"/"false",
%%  "reason":Msg
%% }
-define(RETURN_FORMAT(Result, FailReason), "{" ++ "\"ret\":\"" ++ Result ++ "\", \"msg\":\"" ++ FailReason ++ "\"}").


-endif.