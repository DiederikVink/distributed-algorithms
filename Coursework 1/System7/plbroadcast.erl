%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(plbroadcast).
-export([start/0]).

start() ->
    receive
        {proc, plbroadcast, init, SlBroadcastPID, Loss} -> 
            run([], SlBroadcastPID, Loss)
    end.

% only the broadcasting part of the pllossy from system6
run(Received, SLBroadcast, Loss) ->
    receive
        {bebbroadcast,plbroadcast,send, Rec, Msg} ->
            Drop = rand:uniform(100),
            if 
                (Drop < Loss) ->
                    SLBroadcast ! {plbroadcast, slbroadcast, send, Rec, Msg},
			        run(Received, SLBroadcast, Loss);
                true -> 
			        run(Received, SLBroadcast, Loss)
            end
    end.

