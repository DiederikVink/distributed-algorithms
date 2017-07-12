%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(pllossy).
-export([start/0]).

start() ->
    receive
        {proc, pl, init, BebPID} -> 
            run([], BebPID)
    end.

% only the receive part from system6 pllossy
run(Received, Beb) ->
    receive
        {sl, pl, delivered, {Sender, Msg}} ->
            IsElem = lists:member({Sender,Msg}, Received),
            if 
                IsElem ->
                    run(Received, Beb);
                true -> 
                    Beb ! {pl, beb, message, Sender, Msg},
                    Received_update = lists:append([{Sender,Msg}], Received),
                    run(Received_update, Beb)
            end
    end.
            
