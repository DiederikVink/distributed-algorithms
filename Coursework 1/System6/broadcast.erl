% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/1]).

start(Max_msg) ->
    receive
        {proc, broadcast, init, AppPID, RbPID, Bound, SL} ->
            run(Max_msg, spawn(map_update, start, [#{}]), 0, AppPID, RbPID, Bound, SL)
    end.

run(Max_msg, Counter, Msg, App, Rb, Bound, SL) -> 
    receive
		% request map_update module to send to app module the current Count of messages on Timeout
        {broadcast, stop} -> Counter ! {counter,print, App}
	% similar to previous systems
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    Rb ! {broadcast, rb, send, {SL, Msg}},
                    run(Max_msg, Counter, Msg+1, App, Rb, Bound, SL);
                Max_msg == 1 -> 
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    Rb ! {broadcast, rb, send, {SL, Msg}},
                    Counter ! {counter,print, App};
                true ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    Rb ! {broadcast, rb, send, {SL, Msg}},
                    run(Max_msg - 1, Counter, Msg + 1, App, Rb, Bound, SL)
            end
    end.
