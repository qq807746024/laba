-module(roleid_generator).

-behaviour(gen_server).

-define(ID_INDEX, 2000000).
-define(ID_TYPE_PLAYER, 'id_type_player').
-define(ID_TYPE_ACCOUNT, 'id_type_account').
-define(ID_TYPE_ITEM, 'id_type_item').

-define(ID_MAIL, 'id_mail').
-define(ID_TYPE_PAY_LOG, 'id_type_pay_log').
-define(ID_ALREADY_RECEIVE_PAY_INFO, 'id_already_receive_pay_info').
-define(ID_BUG_RECORD, 'id_bug_record').
-define(ID_PRIZE_RECORD, 'id_prize_record').
-define(ID_RED_PACK, 'id_red_pack').
-define(ID_RED_PACK_NOTICE, 'id_red_pack_notice').

-record(state,
{
	server_id,
	index_player_id = 0,
	index_account_id = 0,
	index_item_id = 0,

	index_mail_id = 0,
	index_pay_log_id = 0,

	index_already_receive_pay_info_id = 0,
	index_bug_record_id = 0,
	index_prize_record_id = 0,
	index_red_pack_id = 0,
	index_red_pack_notice_id = 0
}).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
	start_link/1,

	is_player_id_fit/1,
	get_auto_player_id/0,
	get_auto_account_id/0,
	get_auto_item_id/0,

	get_auto_mail_id/0,
	get_auto_pay_log_id/0,
	get_already_receive_pay_info_id/0,
	get_auto_bug_record_id/0,
	get_auto_prize_record_id/0,
	get_auto_red_pack_id/0,
	get_auto_red_pack_notice_id/0
]).

start_link(ServerId) ->
	gen_server:start({local, ?MODULE}, ?MODULE, [ServerId], []).

init([ServerId]) ->
	PlayerIdMax = id_max_db:get_id_max({ServerId, ?ID_TYPE_PLAYER}, 0),
	AccountMax = id_max_db:get_id_max({ServerId, ?ID_TYPE_ACCOUNT}, 0),
	ItemIdMax = id_max_db:get_id_max({ServerId, ?ID_TYPE_ITEM}, 0),
	MailIdMax = id_max_db:get_id_max({ServerId, ?ID_MAIL}, 0),
	ShopPayIdMax = id_max_db:get_id_max({ServerId, ?ID_TYPE_PAY_LOG}, 0),
	AlReadyReceivePayInfoIdMax = id_max_db:get_id_max({ServerId, ?ID_ALREADY_RECEIVE_PAY_INFO}, 0),
	BugRecordInfoIdMax = id_max_db:get_id_max({ServerId, ?ID_BUG_RECORD}, 0),
	PrizeRecordIdMax = id_max_db:get_id_max({ServerId, ?ID_PRIZE_RECORD}, 0),
	RedPackInfoIdMax = id_max_db:get_id_max({ServerId, ?ID_RED_PACK}, 0),
	RedPackNoticeIdMax = id_max_db:get_id_max({ServerId, ?ID_RED_PACK_NOTICE}, 0),
	State =
		#state{
			server_id = ServerId,
			index_player_id = PlayerIdMax,
			index_account_id = AccountMax,
			index_item_id = ItemIdMax,
			index_mail_id = MailIdMax,
			index_pay_log_id = ShopPayIdMax,
			index_already_receive_pay_info_id = AlReadyReceivePayInfoIdMax,
			index_bug_record_id = BugRecordInfoIdMax,
			index_prize_record_id = PrizeRecordIdMax,
			index_red_pack_id = RedPackInfoIdMax,
			index_red_pack_notice_id = RedPackNoticeIdMax
		},
	{ok, State}.

%% 获取玩家自增Id
handle_call({'get_auto_id', ?ID_TYPE_PLAYER = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_player_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_player_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取玩家自增Id
handle_call({'get_auto_id', ?ID_TYPE_ACCOUNT = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_account_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_account_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取物品自增Id
handle_call({'get_auto_id', ?ID_TYPE_ITEM = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_item_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_item_id = NewCurIndx},
	{reply, Id, NewState};


%% 获取邮件自增Id
handle_call({'get_auto_id', ?ID_MAIL = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_mail_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_mail_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取充值日志自增Id
handle_call({'get_auto_id', ?ID_TYPE_PAY_LOG = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_pay_log_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_pay_log_id = NewCurIndx},
	{reply, Id, NewState};


%% 获取交易ID
handle_call({'get_auto_id', ?ID_ALREADY_RECEIVE_PAY_INFO = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_already_receive_pay_info_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_already_receive_pay_info_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取bug反馈ID
handle_call({'get_auto_id', ?ID_BUG_RECORD = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_bug_record_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_bug_record_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取bug反馈ID
handle_call({'get_auto_id', ?ID_PRIZE_RECORD = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_prize_record_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_prize_record_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取红包提示id
handle_call({'get_auto_id', ?ID_RED_PACK_NOTICE = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_red_pack_notice_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_red_pack_notice_id = NewCurIndx},
	{reply, Id, NewState};

%% 获取红包id
handle_call({'get_auto_id', ?ID_RED_PACK = IdFlag}, _From, State) ->
	ServerId = State#state.server_id,
	CurrentIndex = State#state.index_red_pack_id,
	{Id, NewCurIndx} = generate_id(ServerId, CurrentIndex, IdFlag),
	NewState = State#state{index_red_pack_id = NewCurIndx},
	{reply, Id, NewState};

handle_call(_Request, _From, State) ->
	{reply, reply_ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ===
generate_id(ServerId, CurrentIndex, IdFlag) ->
	NewCurIndx = CurrentIndex + 1,
	id_max_db:update_id_max({ServerId, IdFlag}, NewCurIndx),
	Id = ServerId * ?ID_INDEX + CurrentIndex,
	{Id, NewCurIndx}.

%% 是否是合法的玩家Id
is_player_id_fit(Id) ->
	Id >= ?ID_INDEX.

%% 获取玩家自增Id
get_auto_player_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_TYPE_PLAYER}).

%% 获取玩家自增Id
get_auto_account_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_TYPE_ACCOUNT}).

%% 获取物品自增Id
get_auto_item_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_TYPE_ITEM}).


%% 获取邮件自增Id
get_auto_mail_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_MAIL}).

%% 获取充值记录自增Id
get_auto_pay_log_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_TYPE_PAY_LOG}).


%% 获取交易自增Id
get_already_receive_pay_info_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_ALREADY_RECEIVE_PAY_INFO}).

%% 获取bug反馈记录自增Id
get_auto_bug_record_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_BUG_RECORD}).

%% 获取bug反馈记录自增Id
get_auto_prize_record_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_PRIZE_RECORD}).

%% 获取红包自增Id
get_auto_red_pack_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_RED_PACK}).

%% 获取红包提示自增Id
get_auto_red_pack_notice_id() ->
	gen_server:call(?MODULE, {'get_auto_id', ?ID_RED_PACK_NOTICE}).