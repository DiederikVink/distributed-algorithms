%%% Diederik Vink (dav114) and Aditya Rajagopal (ar4414)

-module(leader).
-export([start/1]).

start(EndAfter) ->
    Proposals = [],
    B = {0, self()},
    Active = false,

    receive
        {bind, Acceptors, Replicas} ->
            spawn(scout, start, [self(), Acceptors, B]),
            AcceptorsSort = lists:sort(Acceptors),
            ReplicasSort = lists:sort(Replicas),
            next(Proposals, B, Acceptors, Active, Replicas)
    end.

next(Proposals, {BallotR, BallotLeader}, Acceptors, Active, Replicas) ->
    receive
        {propose, S, C} ->
            %io:format("~w received ~w ~w ~n", [self(), S, C]),
            IsFull = (length(Proposals) /= 0),
            if 
                IsFull ->
                    %io:format("~w ~n" ,[Proposals]),
                    IfElem = membership({S,waste},Proposals);
                true ->
                    IfElem = false,
                    ProposalsSort = lists:sort(Proposals),
                    ProposalsNew = lists:umerge([{S, C}],ProposalsSort),
                    if
                        (Active == true) ->
                            spawn(commander, start, [self(), Acceptors, Replicas, {BallotR, BallotLeader}, S, C]);
                        true ->
                            ok
                    end,
                    next(ProposalsNew, {BallotR, BallotLeader}, Acceptors, Active, Replicas)
            end,
            if
                IfElem ->
                    next(Proposals, {BallotR, BallotLeader}, Acceptors, Active, Replicas);
                true ->
                    ProposalsSort1 = lists:sort(Proposals),
                    Proposals1 = lists:umerge([{S, C}], ProposalsSort1),
                    if
                        (Active == true) ->
                            spawn(commander, start, [self(), Acceptors, Replicas, {BallotR, BallotLeader}, S, C]);
                        true ->
                            ok
                    end,
                    next(Proposals1, {BallotR, BallotLeader}, Acceptors, Active, Replicas)
            end;
        {adopted, B, Pvals} ->
            %io:format("~w received ~w ~w ~n", [self(), B, Pvals]),
            ProposalsSort = lists:sort(Proposals),
            Proposals1 = lists:umerge([lists:max(Pvals)], ProposalsSort),
            Proposals2 = lists:delete([], Proposals1),
            [spawn(commander, start, [self(), Acceptors, Replicas, B, S, C]) || {S, C} <- Proposals2],
            Active1 = true,
            next(Proposals2, {BallotR, BallotLeader}, Acceptors, Active1, Replicas);
        {preempted, {R, Leader}} ->
            if 
                (R > BallotR) ->
                    Active1 = false,
                    BallotR1 = R + 1,
                    spawn(scout, start, [self(), Acceptors, {BallotR1, BallotLeader}]),
                    next(Proposals, {BallotR1, BallotLeader}, Acceptors, Active1, Replicas);
                true ->
                    next(Proposals, {BallotR, BallotLeader}, Acceptors, Active, Replicas)
            end
    end.               

membership({S,_},[]) -> 
  false;
membership({S,_},[{S,_}|T]) ->
  true;
membership({S,_},[{A,_}|T]) ->
  membership({S,waste},T).
