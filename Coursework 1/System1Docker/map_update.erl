-module(map_update).
-export([start/1]).

start(Count) -> 
    receive
        {update,Rec} -> 
		  start(maps:put(Rec,maps:get(Rec,Count,0)+1,Count));
        {print,Proc} -> Proc ! {task1, report, Count}
    end.
    
