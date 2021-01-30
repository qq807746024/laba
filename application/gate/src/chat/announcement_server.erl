%% 公告系统

-module(announcement_server).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([
	gold_recharge/3,
  	mission_accomplished/2,
  	niu_room_chest/3,
  	prize_something/2,
  	pay_for_gold/2,
  	first_recharge/1,
  	monthly_card/1,
  	hundred_niu_win/2,
	laba_win/3,
	super_laba_win/3,
	car_win/2,
	airlaba_win_gold/2,
	airlaba_win_redpack/2,
	airlaba_win_rate/2,
  	vip_level_change/2,
	redpack_notice_all/0,
	redpack_draw_notice/2,
	diamond_fudai_draw/2,
	shop_buy_random_reward/2,
	trigger_add_gm_announcement/4

]).

-export([start_link/0]).
-define(DICT_TIMER_DEF, dict_timer_def).	%% 计时器
-define(DICT_START_SECOND, dict_start_date).		%% 开始时间
-define(DICT_END_SECOND, dict_end_date).		%% 结束时间
-define(DICT_INTERVAL, dict_interval).		%% 间隔时间
-define(DICT_CONTENT, dict_content).	%% 内容

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).
-include_lib("db/include/mnesia_table_def.hrl").  
-include("common.hrl").
%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

gold_recharge(PlayerInfo,GetMoney,GiveMoney)->
  trigger_announcement({gold_recharge},[PlayerInfo,GetMoney,GiveMoney]).

vip_level_change(PlayerName,VipLevel)->
  trigger_announcement({vip_level,VipLevel},[PlayerName]).

redpack_notice_all()->
	trigger_announcement({redpack_notice},[]).

redpack_draw_notice(RedpackNum, PlayerName)->
	trigger_announcement({redpack_notice, RedpackNum},[PlayerName]).

diamond_fudai_draw(PlayerName, Diamond)->
	trigger_announcement({diamond_fudai},[PlayerName, Diamond]).

%%完成任务
mission_accomplished(PlayerName,MissionId)->
  trigger_announcement({mission,MissionId},[PlayerName]).

%%对局宝箱
niu_room_chest(PlayerName,RoomLv,CashNum)->
  trigger_announcement({niu_room_chest,RoomLv},[PlayerName,CashNum]).

%%实物兑换
prize_something(PlayerName,Num) ->
  trigger_announcement({prize_something,Num},[PlayerName]).

%%首冲
first_recharge(PlayerName)->
  trigger_announcement({first_recharge},[PlayerName]).

%%月卡
monthly_card(PlayerName)->
  trigger_announcement({monthly_card},[PlayerName]).

%%兑换金币
pay_for_gold(PlayerName,KeyNum) ->
  trigger_announcement({pay_for_gold,KeyNum},[PlayerName]).

%%百人大战
hundred_niu_win(PlayerName,Gold)->
  trigger_announcement({hundred_niu_win},[PlayerName,Gold]).

%%拉霸
laba_win(PlayerName,Gold,TestType)->
  trigger_announcement({laba_win, TestType},[PlayerName,Gold]).

%% 超级拉霸
super_laba_win(PlayerName,Gold, TestType)->
	trigger_announcement({superlaba_win, TestType},[PlayerName,Gold]).

% 豪车中奖
car_win(PlayerName, Gold) ->
	trigger_announcement({car_win},[PlayerName,Gold]).

% 空战中奖
airlaba_win_gold(PlayerName, Gold) ->
	trigger_announcement({airlaba_win_gold}, [PlayerName, Gold]).
airlaba_win_redpack(PlayerName, RedPack) ->
	trigger_announcement({airlaba_win_redpack}, [PlayerName, RedPack]).
airlaba_win_rate(PlayerName, Rate) ->
	trigger_announcement({airlaba_win_rate}, [PlayerName, Rate]).

% 商城随机金币获奖
shop_buy_random_reward(PlayerName, Gold) ->
	trigger_announcement({shop_buy_random_reward}, [PlayerName,Gold]).

trigger_announcement(Condition, ExtraParams)  ->
	gen_server:cast(?SERVER, {trigger_announcement, Condition, ExtraParams}).

trigger_add_gm_announcement(BeginDateTime, EndDateTime, IntervalSeconds, Content)  ->
	gen_server:cast(?SERVER, {add_gm_announcement, {BeginDateTime, EndDateTime, IntervalSeconds, Content}}).
%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(Args) ->
    {ok, Args}.

handle_call(Request, From, State) ->
	try
		do_call(Request, From, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod call Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Request}, erlang:get_stacktrace()]),
			{reply, ok, State}
	end.

handle_cast(Msg, State)  ->
	try
		do_cast(Msg, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Msg}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

handle_info(Info, State) ->
	try
		do_info(Info, State)
	catch
		Error:Reason ->
			?ERROR_LOG("mod cast Error! info = ~p~n, stack = ~p~n", [{Error, Reason, Info}, erlang:get_stacktrace()]),
			{noreply, State}
	end.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ====================================================================
do_call(_Request, _From, State) ->
	{reply, ok, State}.

%% ====================================================================
do_cast({trigger_announcement, Condition, ExtraParams}, State) ->
    case announcement_db:load_announcement_by_condition(Condition) of
        {ok, AnnouncementList}  ->
            util:map(fun(Announcement) ->
                        case parse_sgte_compile(Announcement) of
                            {ok, ComStr}   ->
                                case pack_announcement(ComStr, Announcement, Condition, ExtraParams) of
                                    {ok, {Type, Content}} ->
                                        player_chat:send_msg_notice(Type, Content);
                                    _ ->  
                                        void
                                end;
                            _   ->  void
                        end 
                      end, 
                      AnnouncementList);
        _   ->  void
    end,
    {noreply, State};

%% 内容加入到dict 覆盖之前数据 and 取消计时器 重新开始计时器
do_cast({add_gm_announcement, {StartTime, EndTime, Interval, Content}}, State) ->
	NowDate = calendar:local_time(),
	if
		NowDate >= EndTime ->
			skip;
		true ->
			put(?DICT_CONTENT, Content),
			put(?DICT_START_SECOND, util:datetime_to_seconds(StartTime)),
			put(?DICT_END_SECOND, util:datetime_to_seconds(EndTime)),
			put(?DICT_INTERVAL, Interval),
			update_timer_def(undefined),
			do_add_gm_announcement()
	end,

	{noreply, State};

do_cast(_Msg, State) ->
    {noreply, State}.

%% ====================================================================
do_info('refresh_send', State) ->
	%?INFO_LOG("refresh_send ~p~n",[get(?DICT_CONTENT)]),
	player_chat:send_msg_notice(1, get(?DICT_CONTENT)),
	do_add_gm_announcement(),
	%% 群发content

	{noreply, State};

do_info(_Info, State) ->
	{noreply, State}.

%% ====================================================================

parse_sgte_compile(Announcement)    ->
    case Announcement#announcement.content of
        {ok, ComStr}    ->  
            {ok, ComStr};
        Value           ->
            {ok, ComStr} = sgte:compile(Value), 
            NewAnnouncement = Announcement#announcement{content = {ok, ComStr}},
            announcement_db:write_announcement(NewAnnouncement),
            {ok, ComStr}
    end.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

%%
pack_announcement(ComStr, _Announcement, {gold_recharge}, [PlayerInfo,GetMoney,GiveMoney|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerInfo#player_info.player_name},{get_money,GetMoney},{give_money,GiveMoney}])}};

pack_announcement(ComStr, _Announcement, {mission,_}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {niu_room_chest,_}, [PlayerName,CashNum|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,CashNum}])}};

pack_announcement(ComStr, _Announcement, {prize_something,_}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {pay_for_gold,_}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {first_recharge}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {monthly_card}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {hundred_niu_win}, [PlayerName,Gold|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};

pack_announcement(ComStr, _Announcement, {laba_win, ?TEST_TYPE_TRY_PLAY}, [PlayerName,Gold|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};
pack_announcement(ComStr, _Announcement, {laba_win, ?TEST_TYPE_ENTERTAINMENT}, [PlayerName,Gold|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};

pack_announcement(ComStr, _Announcement, {superlaba_win, ?TEST_TYPE_TRY_PLAY}, [PlayerName,Gold|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};
pack_announcement(ComStr, _Announcement, {superlaba_win, ?TEST_TYPE_ENTERTAINMENT}, [PlayerName,Gold|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};

pack_announcement(ComStr, _Announcement, {car_win}, [PlayerName,Gold|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};

pack_announcement(ComStr, _Announcement, {airlaba_win_gold}, [PlayerName,Gold|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};
pack_announcement(ComStr, _Announcement, {airlaba_win_redpack}, [PlayerName,RedPack|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,RedPack}])}};
pack_announcement(ComStr, _Announcement, {airlaba_win_rate}, [PlayerName,Rate|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Rate}])}};

pack_announcement(ComStr, _Announcement, {shop_buy_random_reward}, [PlayerName,Gold|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName},{num,Gold}])}};

pack_announcement(ComStr, _Announcement, {vip_level,_}, [PlayerName|_]) ->
  {ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {redpack_notice,_}, [PlayerName|_]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName}])}};

pack_announcement(ComStr, _Announcement, {redpack_notice}, []) ->
	{ok,{1,sgte:render_str(ComStr,[])}};

pack_announcement(ComStr, _Announcement, {diamond_fudai}, [PlayerName, Diamond]) ->
	{ok,{1,sgte:render_str(ComStr,[{name,PlayerName}, {diamond, Diamond}])}};

pack_announcement(ComStr, _Announcement, {tribute_failure}, [AtkRoleName, BoatName, HonorReduce, SilverReduce|_]) ->
	{ok, {9, sgte:render_str(ComStr, [ {name, AtkRoleName}, {boat, BoatName}, {prestige_num, HonorReduce}, {silver_num, SilverReduce}])}};

pack_announcement(ComStr, _Announcement, _Condition, [PlayerInfo|_])  ->
    {ok, {1, sgte:render_str(ComStr, [{name, PlayerInfo#player_info.player_name}])}}.


update_timer_def(TimerDef) ->
	OldTimerRel = get(?DICT_TIMER_DEF),
	case is_reference(OldTimerRel) of
		true ->
			erlang:cancel_timer(OldTimerRel);
		_ ->
			skip
	end,
	put(?DICT_TIMER_DEF, TimerDef).

do_add_gm_announcement() ->
	%?INFO_LOG("do_add_gm_announcement"),
	NowSecond = util:now_seconds(),
	StartSecond = max(get(?DICT_START_SECOND), NowSecond),
	case calc_next_announcement_second(StartSecond, NowSecond) of
		0 ->
			update_timer_def(undefined);
		TimerSecond ->
			TimerRef = erlang:send_after(TimerSecond*1000, self(), 'refresh_send'),
			update_timer_def(TimerRef)
	end.

calc_next_announcement_second(StartSecond, NowSecond) ->
	Interval = get(?DICT_INTERVAL),
	EndSecond = get(?DICT_END_SECOND),
	if
		StartSecond + Interval > EndSecond ->
			0;
		true ->
			max(0, StartSecond + Interval - NowSecond)
	end.