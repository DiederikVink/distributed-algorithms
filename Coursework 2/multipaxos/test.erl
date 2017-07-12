-module(test).
-export([start/0]).

start() ->
    SetTest = sets:new(),
    Tmp1 = sets:add_element({2,5}, SetTest),
    Tmp2 = sets:add_element({1, 8}, Tmp1),
    Res1 = membership({1, waste}, sets:to_list(Tmp2)),
    Res2 = extract2({waste,8}, sets:to_list(Tmp2)),
    io:format("1 ~w ~n2 ~w ~n", [Res1, Res2]),

    List = [1, 2, 3, 4, 5, 6],
    Set = to_set(List, SetTest),
    io:format("1 ~w ~n", [Set]).
    
to_set([], Set) ->
    Set;
to_set([Val|T], Set) ->
    Set1 = sets:add_element(Val, Set),
    to_set(T, Set1).

membership({S,_},[]) -> 
  false;
membership({S,_},[{S,_}|T]) ->
  true;
membership({S,_},[{A,_}|T]) ->
  membership({S,waste},T).

extract({S,_},[]) -> 
  false;
extract({S,_},[{S,C}|T]) ->
  C;
extract({S,_},[{A,_}|T]) ->
  extract({S,waste},T).

extract2({_,S},[]) -> 
  false;
extract2({_,S},[{C,S}|T]) ->
  C;
extract2({_,S},[{_,A}|T]) ->
  extract2({waste,S},T).
