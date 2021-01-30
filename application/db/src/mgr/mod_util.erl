-module(mod_util).

-include("../../gate/include/logger.hrl").

-export([get_all_module/1,
		 get_all_module/0,
		load_module_if_not_loaded/1,
		get_module_by_beam/1,
		behaviour_apply/3,
		behaviour_apply/4,
		get_all_behaviour_mod/1,
		get_all_behaviour_mod/2,
		is_mod_is_behaviour/2,
		is_behaviour_attributes/2,
		safe_aplly/3
		]).

get_all_module(Path) ->
	{ok, ALLFiles} = file:list_dir(Path),
	util:foldl(fun(FileName, AccModules)->
					case get_module_by_beam(FileName) of
						[] ->
							AccModules;
						NewModule ->
							[NewModule | AccModules]	
					end
				end,
				[],
				ALLFiles).

get_all_module()->
	get_all_module("./").

load_module_if_not_loaded(NewModule)->
	case erlang:module_loaded(NewModule) of
		false->
			c:l(NewModule);
		_->
			nothing
	end.

get_module_by_beam(FileName)->
	case string:right(FileName,5) of
		".beam"->
			erlang:list_to_atom(string:substr(FileName,1,string:len(FileName) - 5));
		_->
			[]
	end.
	
behaviour_apply(Behaviour, Func, Args)->
	util:foreach(fun(Mod)->
					safe_aplly(Mod, Func, Args)
		end, get_all_behaviour_mod(Behaviour)).

behaviour_apply(Path, Behaviour, Func, Args)->
	util:foreach(fun(Mod)->
					  safe_aplly(Mod, Func, Args)
				  end, 
				  get_all_behaviour_mod(Path, Behaviour)).

get_all_behaviour_mod(Behaviour)->
	util:filter(fun(Mod)-> is_mod_is_behaviour(Mod,Behaviour) end, get_all_module()).

get_all_behaviour_mod(Path, Behaviour)->
	util:filter(fun(Mod)-> is_mod_is_behaviour(Mod,Behaviour) end, get_all_module(Path)).

is_mod_is_behaviour(Mod,Behav)->
	is_behaviour_attributes(Mod:module_info(attributes), Behav).

is_behaviour_attributes([],_)->
	false;
is_behaviour_attributes([{behaviour,Behaviours}|Tail],Behav)->
	case lists:member(Behav,Behaviours) of
		true->
			true;
		_->
			is_behaviour_attributes(Tail,Behav)
	end;
is_behaviour_attributes([_|Tail],Behav)->
	is_behaviour_attributes(Tail,Behav).	

safe_aplly(Mod, Func, Args)->
	try
		erlang:apply(Mod, Func, Args)
	catch 
		E:R->
			?ERROR_LOG("safe_aplly ~p:~p ~p ~p ~p ~n",[Mod, Func, Args,E,R])
	end.


