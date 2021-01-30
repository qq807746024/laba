-module(util_random).

-include_lib("eunit/include/eunit.hrl").

-define(NOTEST, true).

-export([
         get_random_rewards/1,
		random_order_list/1
        ]).

%% 乱序
random_order_list(List) ->
	lists:map(fun({_, E1}) -> E1 end, lists:keysort(1, lists:map(fun(E) ->{random:uniform(), E} end, List))).

%% 按权重获取 
get_random_rewards({random_weight, L_terms, L_weights}) ->
    {Acc, _AccSum} = util:mapfoldl(fun(X, Sum) -> {X+Sum, X+Sum} end, 0, L_weights),
    Pos = util:uniform() * lists:last(Acc),
    [{_, Term} | _] = util:dropwhile(fun({N, _}) -> N < Pos end, lists:zip(Acc, L_terms)),
    [Term];

%% 按权重获取多个,35%随机1个  55%随机2个  10%随机3个
get_random_rewards({random_weight_n, L_terms, L_weights}) ->
	[RandNum] =  get_random_rewards({random_weight, [1,2,3], [35,55,10]}),
	util:foldl(fun(_E, Acc) ->
		get_random_rewards({random_weight, L_terms, L_weights}) ++ Acc
		end,
	[],
	util:seq(1,RandNum));

%% 按概率获取
get_random_rewards({random_simple, L_terms, L_rates}) ->
    get_random_rewards1(L_terms, L_rates, []).

get_random_rewards1([], [], Result) ->
    Result;
get_random_rewards1([Term | T_terms], [Rate | T_rates], Result) ->
    Random = util:uniform(),
    if
        Random < Rate ->
            get_random_rewards1(T_terms, T_rates, [Term | Result]);
        true ->
            get_random_rewards1(T_terms, T_rates, Result)
    end.

%% 测试
get_random_rewards_random_weight_test() ->
    V = util:map(fun(Weights) ->
                get_random_rewards({random_weight, [a, b, c, d], Weights})
        end,
        lists:duplicate(100000, [1,2,3,4])  % tune these
    ),
    %?debugVal(V),
    Result = {
        length(util:filter(fun(X) -> X =:= [a] end, V)),
        length(util:filter(fun(X) -> X =:= [b] end, V)),
        length(util:filter(fun(X) -> X =:= [c] end, V)),
        length(util:filter(fun(X) -> X =:= [d] end, V))
    },
    ?debugVal(Result),
    ok.

get_random_rewards_random_simple_test() ->
    N = 100000,
    R = 0.9,
    Rates = lists:duplicate(N, R),
    Terms = lists:duplicate(N, x),
    Result = get_random_rewards({random_simple, Terms, Rates}),
    Len = length(Result),
    %?debugVal(Len),
    ?assert(abs(Len/N - R) < 0.01),
    ok.


