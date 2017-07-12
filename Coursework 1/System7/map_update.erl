%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(map_update).
-export([start/1]).

% same as in previous systems
start(Count) -> 
    receive
        {counter,update,Rec} -> 
		  start(maps:put(Rec,maps:get(Rec,Count,0)+1,Count));
        {counter,print,App} -> 
            App ! {app,report, Count}
    end.
    
