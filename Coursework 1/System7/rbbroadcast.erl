%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(rbbroadcast).
-export([start/0]).

start() ->
    receive
        {proc, rbbroadcast, init, BebBroadcast} ->
            run(BebBroadcast)
    end.

% only receive part of system 6 rb
run(BebBroadcast) ->
    receive
        {broadcast, rbbroadcast, send, Msg} -> 
            BebBroadcast ! {rbbroadcast, bebbroadcast, send, Msg},
            run(BebBroadcast)
    end.
