%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/1]).

% same as in system 6
start(Max_msg) ->
    receive
        {proc, broadcast, init, AppPID, RbBroadcast, Bound, SL} ->
            run(Max_msg, spawn(map_update, start, [#{}]), 0, AppPID, RbBroadcast, Bound, SL)
    end.

run(Max_msg, Counter, Msg, App, RbBroadcast, Bound, SL) -> 
    receive
        {broadcast, stop} -> Counter ! {counter,print, App}
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    RbBroadcast ! {broadcast, rbbroadcast, send, {SL, Msg}},
                    run(Max_msg, Counter, Msg+1, App, RbBroadcast, Bound, SL);
                Max_msg == 1 -> 
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    RbBroadcast ! {broadcast, rbbroadcast, send, {SL, Msg}},
                    Counter ! {counter,print, App};
                true ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    RbBroadcast ! {broadcast, rbbroadcast, send, {SL, Msg}},
                    run(Max_msg - 1, Counter, Msg + 1, App, RbBroadcast, Bound, SL)
            end
    end.
