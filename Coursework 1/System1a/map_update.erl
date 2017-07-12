%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(map_update).
-export([start/1]).

% same as map_update.erl in System1, please refer there for comments
start(Count) -> 
    receive
        {update,Rec} -> 
		  start(maps:put(Rec,maps:get(Rec,Count,0)+1,Count));
        {print,Proc} -> Proc ! {task1, report, Count}
    end.
    
