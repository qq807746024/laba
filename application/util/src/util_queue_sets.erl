-module(util_queue_sets).

-export([
    new/1,
    reset/1,
    add/3,
    has/3
]).

-record(u_queue_sets, {
    maxSize,
    size,
    queue,
    sets
}).

-record(u_queue_sets_elem, {
    key, val
}).

new(MaxSize) ->
    Rec = #u_queue_sets{
        maxSize = MaxSize
    },
    reset(Rec).

reset(Instance) ->
    Instance#u_queue_sets {
        size = 0,
        queue = queue:new(),
        sets = sets:new()
    }.

add(Item, Key, Instance) ->
    Chk = #u_queue_sets_elem {
        key = Key,
        val = Item
    },
    case sets:is_element(Chk, Instance#u_queue_sets.sets) of
        true ->
            Instance;
        _ ->
            NewSize = Instance#u_queue_sets.size + 1,
            OptInstance = if
                NewSize > Instance#u_queue_sets.maxSize ->
                    {{_, Out}, OutedQueue} = queue:out(Instance#u_queue_sets.queue),
                    OutedSets = sets:del_element(Out, Instance#u_queue_sets.sets),
                    Instance#u_queue_sets{
                        sets = OutedSets,
                        queue = OutedQueue
                    };
                true ->
                    Instance#u_queue_sets{
                        size = NewSize
                    }
            end,
            NewQueue = queue:in(Key, OptInstance#u_queue_sets.queue),
            NewSets = sets:add_element(Chk, OptInstance#u_queue_sets.sets),
            OptInstance#u_queue_sets{
                sets = NewSets,
                queue = NewQueue
            }
    end.

has(Item, Key, Instance) ->
    Chk = #u_queue_sets_elem {
        key = Key,
        val = Item
    },
    sets:is_element(Chk, Instance#u_queue_sets.sets).