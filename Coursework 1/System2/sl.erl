%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(sl).
-export([start/1]).

start(PL) ->
    % essentially our init message
    timer:send_after(250,{retransmit}),
    run([], PL).

run(Sent,PL) -> 
    receive
        % if message received from other process, pass it on to PL
        {task2, message, MsgTup} ->
            PL ! {delivered, MsgTup},
			run(Sent,PL);
        % after set interval, retransmit all previously sent messages
        {retransmit} -> 
            [element(1, Receip) ! {task2, message, element(2, Receip)} || Receip <- Sent],
            timer:send_after(250,{retransmit}),
            run(Sent, PL);
        % when told by PL, send to instructed recipient (Rec)
        {send, Rec, Msg} ->
            Rec ! {task2, message, {self(), Msg}},
            % record all messages that have been sent and to whom they were sent
            Sent_update = lists:append([{Rec,Msg}],Sent),
            run(Sent_update,PL)
    end.
