-module(dal).
-include("../../gate/include/logger.hrl").
%% 非DB节点使用
-export([
		 read_rpc/1, 
		 read_rpc/2, 
		 read_index_rpc/3, 
		 read_select_rpc/4,
		 write_rpc/1, 
		 delete_rpc/2,
		 clear_rpc/1,
		 first_rpc/1,
         last_rpc/1,
         next_rpc/2,
		 prev_rpc/2,
		 run_transaction_rpc/1,
		 
		 t_write/1,
		 t_delete/2,
		 t_abort/1
		]).

-include_lib("stdlib/include/qlc.hrl").

%% ---------------
read_rpc(Table) ->
	read(Table).

read_rpc(Table,Key) ->
	read(Table, Key).

read_index_rpc(Table,SecondaryKey,Pos) ->
	read_index(Table, SecondaryKey, Pos).

read_select_rpc(Table, MatchHead, MatchGuard, MatchResult) ->
	read_select(Table, MatchHead, MatchGuard, MatchResult).

write_rpc(Object) ->
	write(Object).

delete_rpc(Table, Key) ->
	delete(Table, Key).

clear_rpc(Table) ->
	clear(Table).

first_rpc(Table) ->
	first(Table).

last_rpc(Table) ->
    last(Table).

next_rpc(Table, Key) ->
    next(Table, Key).

prev_rpc(Table, Key) ->
	prev(Table, Key).

run_transaction_rpc(Transaction) ->
	run_transaction(Transaction).

%% ---------------
%% 事务写
t_write(Object)	->
	mnesia:write(Object).

%% 事务删除
t_delete(Table, Key) ->
	mnesia:delete({Table, Key}).

t_abort(Reason)	->
	mnesia:abort(Reason).

%% ---------------------------------------------
read(Table)->
	ReadFun = fun()-> qlc:e(qlc:q([X || X <- mnesia:table(Table)])) end,
	case mnesia:transaction(ReadFun) of
		{aborted,Reason} -> ?ERROR_LOG("read error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		{atomic, []} -> {ok,[]};
		{atomic, Result}-> {ok, Result}
	end.

read(Table, Key)->
	case catch  mnesia:dirty_read({Table,Key}) of
		{'EXIT',Reason} -> ?ERROR_LOG("read error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		Result when is_list(Result) -> {ok,Result};
		Result->
			?ERROR_LOG("read error ~p ~n",[Result]),{failed,Result}
	end.
	
read_index(Table, SecondaryKey, Pos)->
	case catch  mnesia:dirty_index_read(Table, SecondaryKey, Pos) of
		{'EXIT',Reason} -> ?ERROR_LOG("read_index error ~p Table ~p ~n",[Reason,Table]),{failed,Reason};
		Result when is_list(Result)-> {ok,Result};
		Result-> ?ERROR_LOG("read_index error ~p ~n",[Result]),{failed,Result}
	end.

read_select(Table, MatchHead, MatchGuard, MatchResult) ->
	Fun = 
		fun() ->
			mnesia:select(Table, [{MatchHead, MatchGuard, MatchResult}])
		end,
	case mnesia:transaction(Fun) of
		{atomic, List} -> 
			{ok, List};
		{aborted, Reason} -> 
			?ERROR_LOG("read error ~p Table ~p ~n", [Reason, Table]), {failed, Reason}
	end.

first(Table) ->
	case catch mnesia:dirty_first(Table) of
        {'EXIT', Reason} ->  
            ?ERROR_LOG("get first key ~p Table ~p ~n",[Reason,Table]),
            {failed, Reason};
        Result ->  
            {ok, Result}
    end.

last(Table) ->
    case catch mnesia:dirty_last(Table) of
        {'EXIT', Reason} ->  
            ?ERROR_LOG("get last key ~p Table ~p ~n",[Reason, Table]),
            {failed, Reason};
        Result ->  
            {ok, Result}
    end.

next(Table, Key)    ->
    case catch mnesia:dirty_next(Table, Key) of
        {'EXIT', Reason} ->  
            ?ERROR_LOG("get next key ~p Table ~p ~n",[Reason,Table]),
            {failed, Reason};
        Result ->  
            {ok, Result}
    end.

prev(Table, Key)    ->
    case catch mnesia:dirty_prev(Table, Key) of
        {'EXIT', Reason}    ->  
            ?ERROR_LOG("get prev key ~p Table ~p ~n",[Reason,Table]),
            {failed, Reason};
        Result ->  
            {ok, Result}
    end.

write(Object)->
	case catch mnesia:dirty_write(Object) of
		{'EXIT', Reason} -> 
			?ERROR_LOG("write error ~p~n Object ~p ~n", [Reason, Object]), {failed, Reason};
		ok -> 
			{ok}
	end.

delete(Table, Key)->
	case catch mnesia:dirty_delete({Table,Key}) of
		{'EXIT',Reason} -> {failed, Reason};
		ok -> {ok}
	end.

clear(Table) ->
	case mnesia:clear_table(Table) of
		{atomic, ok} ->
			ok;
		{aborted, R} ->
			?ERROR_LOG("clear error ~p~n Object ~p ~n", [R, Table]),
			{failed, R}
	end.

run_transaction(Transaction)->
	mnesia:sync_transaction(Transaction).


