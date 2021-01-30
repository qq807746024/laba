-ifndef(__PREDEF).
-define(__PREDEF, true).

-define(__COMPILE_SUPERFRUIT, true).

-ifdef(__COMPILE_SUPERFRUIT).
-define(SUPERFRUIT, 1).
-else.
-define(SUPERFRUIT, 0).
-endif.

-define(IS_MUTISRV_RANK, true). % 多服务器排行

-endif.
