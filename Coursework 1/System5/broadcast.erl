%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/6]).

% the same as System 3 broadcast.erl, please refer there for commenting
start(App, Max_msg, Bound, BEB, Counter, Msg) -> 
    receive
        {broadcast, stop} -> Counter ! {counter,print, App};
        {terminate} -> exit("Faulty Process")
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    start(App, Max_msg, Bound, BEB, Counter, Msg+1);
                Max_msg == 1 -> 
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    Counter ! {counter,print, App};
                true ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    start(App, Max_msg - 1, Bound, BEB, Counter, Msg+1)
            end
    end.
