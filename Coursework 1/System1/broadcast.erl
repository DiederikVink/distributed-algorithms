%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(broadcast).
-export([start/4]).

start(Proc, Max_msg, Bound, Counter) -> 
    receive
        %if stop command if received, inform counter to export count of sent messages
        {task1, stop} -> Counter ! {print, Proc}
    after
        0 ->
            if
                % if max messages is set to zero, do not stop sending until stop message is received
                Max_msg == 0 ->
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    start(Proc, Max_msg, Bound, Counter);
                % if max messages was not zero, this is the last message that will be send
                Max_msg == 1 -> 
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    Counter ! {print, Proc};
                % keep decrementing max messages until it reaches 1 and the last message gets sent
                true ->
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    start(Proc, Max_msg - 1, Bound, Counter)
            end
    end.
