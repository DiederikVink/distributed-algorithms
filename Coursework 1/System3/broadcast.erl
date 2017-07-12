%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/6]).

% very similar to System2 broadcast.erl, for commenting please see that file
% only differences are commented here
start(App, Max_msg, Bound, BEB, Counter, Msg) -> 
    receive
        {broadcast, stop} -> Counter ! {counter,print, App}
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to BEB instead of PL, and let BEB decided recipients
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    start(App, Max_msg, Bound, BEB, Counter, Msg+1);
                Max_msg == 1 -> 
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to BEB instead of PL, and let BEB decided recipients
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    Counter ! {counter,print, App};
                true ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to BEB instead of PL, and let BEB decided recipients
                    BEB ! {broadcast, beb, send, {App, Msg}},
                    start(App, Max_msg - 1, Bound, BEB, Counter, Msg+1)
            end
    end.
