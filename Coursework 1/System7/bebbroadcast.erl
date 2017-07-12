%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(bebbroadcast).
-export([start/0]).

% this is only the broadcasting part of system6's beb
start() -> 
	receive
		{proc, bebbroadcast, init, PLBroadcast, Procs} -> next(Procs, PLBroadcast)
	end. 

next(Procs, PLBroadcast) -> 
	receive
		{rbbroadcast,bebbroadcast,send,Msg} -> 
			[PLBroadcast ! {bebbroadcast,plbroadcast,send,To,Msg} || To <- Procs]
	end,
	next(Procs, PLBroadcast).
	
