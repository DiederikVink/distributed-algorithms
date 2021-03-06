%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(pllossy).
-export([start/1]).

% exactly the same as System 4 pllossy.erl, please refer there for any commenting
start(RegName) ->
    SL = spawn(sl, start, [self()]),
    register(list_to_atom(pid_to_list(RegName)), SL),
    receive
        {init, BEBPID, Loss} -> 
            run([], SL, BEBPID, Loss)
    end.

run(Received, SL, BEBPID, Loss) ->
    receive
        {beb,pl,send, Rec, Msg} ->
            Drop = rand:uniform(100),
            if 
                (Drop < Loss) ->
                    SL ! {send, Rec, Msg},
			        run(Received,SL,BEBPID, Loss);
                true -> 
			        run(Received,SL,BEBPID, Loss)
            end;
        {delivered, {Sender, Msg}} ->
            IsElem = lists:member({Sender,Msg}, Received),
            if 
                IsElem ->
                    run(Received, SL, BEBPID, Loss);
                true -> 
                    BEBPID ! {pl,beb,message, Sender},
                    Received_update = lists:append([{Sender,Msg}], Received),
                    run(Received_update, SL, BEBPID, Loss)
            end
    end.
            
