-module(slogger).

-compile(export_all).

%% 测试打印
msg(Format, Data) ->
	error_logger:info_msg(Format, Data),
	ok.

msg(Format) ->
	error_logger:info_msg(Format),
	ok.

%% 警告
warning_msg(Format, Data) ->
	error_logger:warning_msg(Format, Data),
	ok.

warning_msg(Format) ->
	error_logger:warning_msg(Format),
	ok.

msg_filter(Id,Format,Data) ->
	if Id== 2030096->
		   msg(Format,Data);
	   true->
		   ok
	end.


