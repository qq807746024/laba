-ifndef(SC_ITEMS_UPDATE_PB_H).
-define(SC_ITEMS_UPDATE_PB_H, true).
-record(sc_items_update, {
    upd_list = []
}).
-endif.

-ifndef(SC_ITEMS_ADD_PB_H).
-define(SC_ITEMS_ADD_PB_H, true).
-record(sc_items_add, {
    add_list = []
}).
-endif.

-ifndef(SC_ITEMS_DELETE_PB_H).
-define(SC_ITEMS_DELETE_PB_H, true).
-record(sc_items_delete, {
    del_list = []
}).
-endif.

-ifndef(SC_ITEMS_INIT_UPDATE_PB_H).
-define(SC_ITEMS_INIT_UPDATE_PB_H, true).
-record(sc_items_init_update, {
    all_list = []
}).
-endif.

-ifndef(PB_ITEM_INFO_PB_H).
-define(PB_ITEM_INFO_PB_H, true).
-record(pb_item_info, {
    uuid = erlang:error({required, uuid}),
    base_id = erlang:error({required, base_id}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_ITEM_USE_REQ_PB_H).
-define(CS_ITEM_USE_REQ_PB_H, true).
-record(cs_item_use_req, {
    item_uuid = erlang:error({required, item_uuid}),
    num = erlang:error({required, num})
}).
-endif.

-ifndef(SC_ITEM_USE_REPLY_PB_H).
-define(SC_ITEM_USE_REPLY_PB_H, true).
-record(sc_item_use_reply, {
    result = erlang:error({required, result}),
    err_msg = erlang:error({required, err_msg})
}).
-endif.

-ifndef(PB_REWARD_INFO_PB_H).
-define(PB_REWARD_INFO_PB_H, true).
-record(pb_reward_info, {
    base_id = erlang:error({required, base_id}),
    count = erlang:error({required, count})
}).
-endif.

-ifndef(CS_PLAYER_NIU_ROOM_CHEST_DRAW_PB_H).
-define(CS_PLAYER_NIU_ROOM_CHEST_DRAW_PB_H, true).
-record(cs_player_niu_room_chest_draw, {
    type = erlang:error({required, type}),
    game_type = erlang:error({required, game_type})
}).
-endif.

-ifndef(SC_NIU_ROOM_CHEST_DRAW_REPLY_PB_H).
-define(SC_NIU_ROOM_CHEST_DRAW_REPLY_PB_H, true).
-record(sc_niu_room_chest_draw_reply, {
    result = erlang:error({required, result}),
    err,
    rewards = [],
    game_type = erlang:error({required, game_type})
}).
-endif.

-ifndef(SC_NIU_ROOM_CHEST_INFO_UPDATE_PB_H).
-define(SC_NIU_ROOM_CHEST_INFO_UPDATE_PB_H, true).
-record(sc_niu_room_chest_info_update, {
    times = erlang:error({required, times}),
    game_type = erlang:error({required, game_type})
}).
-endif.

-ifndef(SC_NIU_ROOM_CHEST_TIMES_UPDATE_PB_H).
-define(SC_NIU_ROOM_CHEST_TIMES_UPDATE_PB_H, true).
-record(sc_niu_room_chest_times_update, {
    times_niu = erlang:error({required, times_niu}),
    times_hundred = erlang:error({required, times_hundred}),
    times_laba = erlang:error({required, times_laba}),
    update_type = erlang:error({required, update_type})
}).
-endif.

