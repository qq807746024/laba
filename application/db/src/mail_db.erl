-module(mail_db).

-behaviour(db_operater_mod).

-include("mnesia_table_def.hrl").

-export([load_mail_by_player_id/1,
         get_mail/1,
		 get_mail/0,
         t_write_mail/1,
		 delete_mail/1,
		get_first/0,
		get_next/1,
         t_delete_mail/1,
		write_mail/1]).

-export([start/0, create_mnesia_table/1, tables_info/0]).

-define(DB_NAME, mail).

start() ->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(?DB_NAME, record_info(fields, ?DB_NAME), #?DB_NAME{}, ?MODULE, [to_id], set).

tables_info() ->
	[{?DB_NAME, disc}].

load_mail_by_player_id(PlayerID)    ->
    dal:read_index_rpc(?DB_NAME, PlayerID, to_id).
    
get_mail(MailID)    ->
    dal:read_rpc(?DB_NAME, MailID).

get_mail()    ->
	dal:read_rpc(?DB_NAME).

t_write_mail(Mail)  ->
    dal:t_write(Mail).
    
t_delete_mail(MailID) ->
    dal:t_delete(?DB_NAME, MailID).

delete_mail(MailID) ->
	case catch mnesia:dirty_delete({?DB_NAME,MailID}) of
		{'EXIT',Reason} -> {failed, Reason};
		ok -> {ok}
	end.

write_mail(Mail) ->
	case catch mnesia:dirty_write(Mail) of
		{'EXIT', Reason} ->
			?ERROR_LOG("write error ~p~n Object ~p ~n", [Reason, Mail]), {failed, Reason};
		ok ->
			{ok}
	end.

get_first() ->
	{ok, FirstKey} = dal:first_rpc(?DB_NAME),
	FirstKey.

get_next(Key) ->
	{ok, NextKey} = dal:next_rpc(?DB_NAME, Key),
	NextKey.
