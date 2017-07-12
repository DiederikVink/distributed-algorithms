%%% Diederik Vink (dav114) and Aditya Rajagopal (ar4414)

-module(commander).
-export([start/6]).

start(Leader, Acceptors, Replicas, B, S, C) ->

    [ Acceptor ! {p2a, self(), {B, S, C}} || Acceptor <- Acceptors ],

    Boundary = length(Acceptors)/2,

    next(Leader, Acceptors, Replicas, B, S, C, Boundary).

next(Leader, Acceptors, Replicas, B, S, C, Boundary) ->
    receive
        {p2b, Acceptor, Bdash} ->
            if 
                Bdash == B ->
    				%io:format ("~w p2b received ~w with ~w ~w ~n", [self(), Acceptor, Bdash, B]),
                    AcceptorsNew = lists:delete(Acceptor, Acceptors),
                    AccepSize = length(AcceptorsNew),
					%io:format ("Boundary: ~w, AccepSize: ~w, AcceptorsNew: ~w ~n",[Boundary, AccepSize, AcceptorsNew]),
                    if 
                        (Boundary > AccepSize) ->
                            [Replica ! {decision, S, C} || Replica <- Replicas],
                            %io:format("~w sent ~w ~w ~n", [self(), S, C]),
                            exit(decision);
                        true ->
							next(Leader, AcceptorsNew, Replicas, B, S, C, Boundary)
                        end;

                true ->
                    Leader ! {preempted, Bdash},
                    exit(preempted)
            end
    end.
