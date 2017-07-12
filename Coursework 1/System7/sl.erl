%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(sl).
-export([start/0]).

start() ->
    receive
        {proc, sl, init, PL} ->
            run([], PL)
    end.

% only recieve part of system 6 sl module
run(Sent,PL) -> 
    receive
        {task2, message, MsgTup} ->
            PL ! {sl, pl, delivered, MsgTup},
			run(Sent,PL)
    end.
