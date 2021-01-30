-module(roleid_generator_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
	ServerId = config_app:get_server_id(),
	case ServerId of
		undefined-> 
			Error="can not start line,there is not serverid in configfile\n",
			{error, Error};
		_-> 
			supervisor:start_link({local,  ?MODULE}, ?MODULE, [ServerId])
	end.

init([ServerId]) ->
  RoleIdConfig = {roleid_generator, {roleid_generator,start_link,[ServerId]}, permanent, 2000, worker, [roleid_generator]},
  {ok, {{one_for_one, 10, 10}, [RoleIdConfig]}}.


