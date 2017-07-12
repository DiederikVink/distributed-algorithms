%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(map_update).
-export([start/1]).

start(Count) -> 
    receive
        % increment value of of messages sent to specific recipeient
        {update,Rec} -> 
		  start(maps:put(Rec,maps:get(Rec,Count,0)+1,Count));
        % output current count map to process
        {print,Proc} -> Proc ! {task1, report, Count}
    end.
    
