%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(slbroadcast).
-export([start/0]).

start() ->
    timer:send_after(250,{retransmit}),
    receive
        {proc, slbroadcast, init,  SL} ->
            run([],  SL)
    end.

% only broadcast half of system6 sl
run(Sent,  SL) ->
   receive
        {retransmit} -> 
            [element(1, Receip) ! {task2, message, element(2, Receip)} || Receip <- Sent],
            timer:send_after(250,{retransmit}),
            run(Sent,  SL);
        {plbroadcast, slbroadcast, send, Rec, Msg} ->
            Rec ! {task2, message, {SL, Msg}},
            Sent_update = lists:append([{Rec,Msg}],Sent),
            run(Sent_update,  SL)
   end.
