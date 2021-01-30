-module(data_gen).
-include("../../gate/include/logger.hrl").
-export([
		 import_config/1
		]).

import_config(File)->
	case file:consult(File) of
		{ok, BaseDataList} ->
%%			?INFO_LOG(" now clear table : ~p =========================", [File]),
			util:foldl(fun(E, Acc)	->
							 ETableName = erlang:element(1, E),
		                     case lists:member(ETableName, Acc) of
								true ->
									Acc;
								false ->
									mnesia:clear_table(ETableName),
									[ETableName | Acc]
							 end
						end, 
						[], 
						BaseDataList),
%%            ?INFO_LOG(" now import config : ~p =======================", [File]),
            util:foldl(fun(E, Acc) ->
                            mnesia:dirty_write(E),
                            ETableName = erlang:element(1, E),
                            case lists:member(ETableName, Acc) of
                                true ->
                                    Acc;
                                false ->
%%									?ERROR_LOG("--- write : ~p~n", [erlang:element(1, E)]),
                                    [ETableName | Acc]
                             end
                        end, 
                        [], 
                        BaseDataList);
            %util:foreach(fun mnesia:dirty_write/1, BaseDataList);
		{error, Reason} ->
			?ERROR_LOG("import config error! info = ~p~n", [Reason])
	end.
