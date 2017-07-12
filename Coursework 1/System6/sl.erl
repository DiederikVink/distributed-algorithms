% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(sl).
-export([start/0]).

% same as in previous systems 
start() ->
    timer:send_after(250,{retransmit}),
    receive
        {proc, sl, init, PL} ->
            run([], PL)
    end.

run(Sent,PL) -> 
    receive
        {task2, message, MsgTup} ->
            PL ! {sl, pl, delivered, MsgTup},
			run(Sent,PL);
        {retransmit} -> 
            [element(1, Receip) ! {task2, message, element(2, Receip)} || Receip <- Sent],
            timer:send_after(250,{retransmit}),
            run(Sent, PL);
        {pl, sl, send, Rec, Msg} ->
            Rec ! {task2, message, {self(), Msg}},
            Sent_update = lists:append([{Rec,Msg}],Sent),
            run(Sent_update,PL)
    end.
