%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(sl).
-export([start/1]).

% the same as System2 sl.erl, so please refer theere for commenting
start(PL) ->
    % essentially our init message
    timer:send_after(250,{retransmit}),
    run([], PL).

run(Sent,PL) -> 
    receive
        {task2, message, MsgTup} ->
            PL ! {delivered, MsgTup},
			run(Sent,PL);
        {retransmit} -> 
            [element(1, Receip) ! {task2, message, element(2, Receip)} || Receip <- Sent],
            timer:send_after(250,{retransmit}),
            run(Sent, PL);
        {send, Rec, Msg} ->
            Rec ! {task2, message, {self(), Msg}},
            Sent_update = lists:append([{Rec,Msg}],Sent),
            run(Sent_update,PL)
    end.
