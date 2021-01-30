-module(id_transform_util).

-export([
		 role_id_to_internal/1,
		 role_id_to_proto/1,
		 
		 item_id_to_internal/1,
		 item_id_to_proto/1,

         mail_id_to_proto/1,
         mail_id_to_internal/1
		]).

-ifdef(TEST).
-compile(export_all).
-endif.


%% 转为协议uuid
role_id_to_proto(RoleID)	->
	ID	=	erlang:binary_to_list(base64:encode(erlang:term_to_binary(RoleID))),
	{ok, ID}.

role_id_to_internal(RoleID)	->
	try	
		ID = (erlang:binary_to_term(base64:decode( erlang:list_to_binary(RoleID)) )),
		{ok, ID}
	catch	
		_:R ->
			{error, R}
	end.

%% 转为协议uuid
item_id_to_proto(ItemID)	->
	ID	= erlang:binary_to_list(base64:encode(erlang:term_to_binary(ItemID))),
	{ok, ID}.

item_id_to_internal(ItemID)	->
	try	
		ID = (erlang:binary_to_term(base64:decode( erlang:list_to_binary(ItemID)) )),
		{ok, ID}
	catch	
		_:R ->
			{error, R}
	end.

mail_id_to_proto(MailId) ->
	ID	=	erlang:binary_to_list(base64:encode(erlang:term_to_binary(MailId))),
    {ok, ID}.
mail_id_to_internal(ProtoMailId) ->
    try
		MailId = (erlang:binary_to_term(base64:decode( erlang:list_to_binary(ProtoMailId)) )),
		{ok, MailId}
	catch	
		_:R ->
			{error, R}
	end.

    
	

