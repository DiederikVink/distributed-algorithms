%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/6]).

% very similar to System1 braodcast.erl, for commenting, please see that file.
% only differences are commented
start(App, Max_msg, Bound, PL, Counter, Msg) -> 
    receive
        {broadcast, stop} -> Counter ! {counter,print, App}
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to PL rather than directly to node, PL will pass on the message
                    [PL ! {send, Rec, {App, Msg}} || Rec <- Bound],
                    start(App, Max_msg, Bound, PL, Counter, Msg+1);
                Max_msg == 1 -> 
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to PL rather than directly to node, PL will pass on the message
                    [PL ! {send, Rec, {App, Msg}} || Rec <- Bound],
                    Counter ! {counter,print, App};
                true ->
                    [Counter ! {counter,update,Rec} || Rec <- Bound],
                    % send to PL rather than directly to node, PL will pass on the message
                    [PL ! {send, Rec, {App, Msg}} || Rec <- Bound],
                    start(App, Max_msg - 1, Bound, PL, Counter, Msg+1)
            end
    end.
