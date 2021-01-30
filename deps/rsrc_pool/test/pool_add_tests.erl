%%
%% Copyright (C) 2010-2013 by krasnop@bellsouth.net (Alexei Krasnopolski)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License. 
%%

%% @hidden
%% @since 2012-12-01
%% @copyright 2010-2013 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://crasnopolski.com/]
%% @version {@version}
%% @doc This module is running unit tests for helper_common module.

-module(pool_add_tests).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").
-include("test.hrl").

%%
%% Import modules
%%
-import(resource_pool, []).
-import(resource_factory, []).
-import(resource_pool_tests, [f/0, f2/0]).

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%

resource_pool_test_() ->
	[ 
    {foreachx, 
      fun do_setup/1, 
      fun resource_pool_tests:do_cleanup/2, 
      [
        {add, fun add/2},
        {add_max_idle, fun add_max_idle/2}
      ]
    }
	]
.

do_setup(X) ->
  ?debug_Fmt("setup: ~p", [X]), 
  Options = set(X),   
  {ok, Pid} = resource_pool:new(test_pool, factory, 0, Options),
  Pid
.

set(add) -> [];
set(add_max_idle) -> [{max_active, 2},{max_idle, 2}];
set(_) -> [].

add(_X, Pool) -> fun() ->
%  ?debug_Fmt("    : pool add test: ~p",[X]),
  resource_pool:borrow(Pool),
  resource_pool:add(Pool),
  ?assertEqual(2, f()),
  ?assertEqual({1,1}, f2()),

  resource_pool:borrow(Pool),
  ?assertEqual({2,0}, f2()),
  ?PASSED
end.

add_max_idle(_X, Pool) -> fun() ->
%  ?debug_Fmt("    : pool add test: ~p",[X]),
  R1 = resource_pool:borrow(Pool),
  R2 = resource_pool:borrow(Pool),
  resource_pool:return(Pool, R1),
  resource_pool:return(Pool, R2),
  ?assertEqual(2, f()),
  ?assertEqual({0,2}, f2()),
  resource_pool:add(Pool),
  ?assertEqual(2, f()),
  ?assertEqual({0,2}, f2()),
  ?PASSED
end.
%%
%% Local Functions
%%

