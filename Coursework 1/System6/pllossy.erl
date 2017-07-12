% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(pllossy).
-export([start/0]).

start() ->
    receive
        {proc, pl, init, SlPID, BebPID, Loss} -> 
            run([], SlPID, BebPID, Loss)
    end.

run(Received, SL, Beb, Loss) ->
    receive
        {beb,pl,send, Rec, Msg} ->
			% selects a random integer uniformly distributed between 
			% 1 : 100 inclusive
            Drop = rand:uniform(100),
            if
				% if the number generated is below the Loss (reliability) value, 
				% then we send, otherwise we drop the message and don't send
                (Drop < Loss) ->
                    SL ! {pl, sl, send, Rec, Msg},
			        run(Received,SL,Beb, Loss);
                true -> 
			        run(Received,SL,Beb, Loss)
            end;
        {sl, pl, delivered, {Sender, Msg}} ->
            IsElem = lists:member({Sender,Msg}, Received),
            if 
                IsElem ->
                    run(Received, SL, Beb, Loss);
                true -> 
                    Beb ! {pl, beb, message, Sender, Msg},
                    Received_update = lists:append([{Sender,Msg}], Received),
                    run(Received_update, SL, Beb, Loss)
            end
    end.
            
