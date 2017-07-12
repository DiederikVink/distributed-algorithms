%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(pl).
-export([start/1]).

start(RegName) ->
    SL = spawn(sl, start, [self()]),
    % register the SL node as receive address so other SL nodes know where to send
    % registry is removed in System6 for a more realisitic setup that would be used in real life
    register(list_to_atom(pid_to_list(RegName)), SL),
    receive
        {init, AppPID} -> 
            run([], SL, AppPID)
    end.

run(Received, SL, AppPID) ->
    receive
        % if told to send a message, pass on to SL
        {send, Rec, Msg} ->
            SL ! {send, Rec, Msg},
			run(Received,SL,AppPID);
        {delivered, {Sender, Msg}} ->
            % check if message and sender combination sent is unique
            IsElem = lists:member({Sender,Msg}, Received),
            if 
                IsElem ->
                    run(Received, SL, AppPID);
                true -> 
                    % if passed a message from SL, pass it on to the application
                    AppPID ! {message, Sender},
                    % update the list of which senders have send which message to list Received
                    Received_update = lists:append([{Sender,Msg}], Received),
                    run(Received_update, SL, AppPID)
            end
    end.
            
