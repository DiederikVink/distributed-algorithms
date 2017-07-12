%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(pl).
-export([start/1]).

% similar to System 2 pl.erl, please refer there to any commenting
% only differences to System2 pl.erl are commented
start(RegName) ->
    SL = spawn(sl, start, [self()]),
    register(list_to_atom(pid_to_list(RegName)), SL),
    receive
        % connect to BEB instead of App
        {init, BEBPID} -> 
            run([], SL, BEBPID)
    end.

run(Received, SL, BEBPID) ->
    receive
        {beb,pl,send, Rec, Msg} ->
            SL ! {send, Rec, Msg},
			run(Received,SL,BEBPID);
        {delivered, {Sender, Msg}} ->
            IsElem = lists:member({Sender,Msg}, Received),
            if 
                IsElem ->
                    run(Received, SL, BEBPID);
                true -> 
                    % send to beb instead of App
                    BEBPID ! {pl,beb,message, Sender},
                    Received_update = lists:append([{Sender,Msg}], Received),
                    run(Received_update, SL, BEBPID)
            end
    end.
            
