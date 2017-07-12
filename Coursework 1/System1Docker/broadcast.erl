-module(broadcast).
-export([start/4]).

start(Proc, Max_msg, Bound, Counter) -> 
    receive
        {task1, stop} -> Counter ! {print, Proc}
    after
        0 ->
            if
                Max_msg == 0 ->
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    start(Proc, Max_msg, Bound, Counter);
                Max_msg == 1 -> 
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    Counter ! {print, Proc};
                true ->
                    [Counter ! {update,Rec} || Rec <- Bound],
                    [Rec ! {task1, receiver, Proc} || Rec <- Bound],
                    start(Proc, Max_msg - 1, Bound, Counter)
            end
    end.
