%% @author zouv
%% @doc @todo 分享相关协议


-module(ge_share).
-author("Administrator").

-include_lib("network_proto/include/share_pb.hrl").
-include("logger.hrl").
%% API
-export([handle/2]).


%% 分享新手礼包领取
handle(#cs_share_new_bee_reward_req{} = Msg,StateName)->
  player_share_util:cs_share_new_bee_reward_req(
    Msg#cs_share_new_bee_reward_req.code
  ),
  StateName;

%% 分享任务奖励领取
handle(#cs_share_mission_reward_req{} = Msg,StateName)->
  player_share_util:cs_share_mission_reward_req(
    Msg#cs_share_mission_reward_req.friend_id,
    Msg#cs_share_mission_reward_req.type
  ),
  StateName;

%% 分享抽奖
handle(#cs_share_draw_request{} = Msg,StateName)->
  player_share_lucky_wheel_util:draw(
    Msg#cs_share_draw_request.flag
  ),
  StateName;

%% 分享好友进度
handle(#cs_share_friend_request{} = Msg,StateName)->
  player_share_lucky_wheel_util:cs_share_friend_request(
    Msg#cs_share_friend_request.page,
    Msg#cs_share_friend_request.user_id
  ),
  StateName;

%% 分享好友榜单
handle(#cs_share_rank_request{} = Msg,StateName)->
  player_share_lucky_wheel_util:cs_share_rank_request(
    Msg#cs_share_rank_request.page
  ),
  StateName;

%% 7日狂欢领奖
handle(#cs_task_seven_award_request{} = _Msg,StateName)->
  player_7_day_carnival_util:draw(),
  StateName;

%% 分享朋友圈
handle(#cs_share_with_friends_req{} = _Msg,StateName)->
  player_share_util:cs_share_with_friends_req(),
  StateName;

handle(Msg, StateName) ->
  ?ERROR_LOG("not match! ~p~n", [{?MODULE, ?LINE, Msg, StateName}]),
  StateName.