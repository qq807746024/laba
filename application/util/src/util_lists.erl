-module(util_lists).

-compile(export_all).

nonDuplicate(List) ->
    Set = sets:from_list(List), sets:to_list(Set).

%% setnth(Index, List, NewElement) -> List.
setnth(1, [_|Rest], New) -> [New|Rest];
setnth(I, [E|Rest], New) -> [E|setnth(I-1, Rest, New)].

%% Can add following caluse if you want to be kind and allow invalid indexes.
%% I wouldn't!
%% setnth(_, [], New) -> New.