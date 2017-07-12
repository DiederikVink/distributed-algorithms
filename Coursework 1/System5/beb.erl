%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(beb).
-export([start/0]).

% exactly the same as System 3 beb.erl, please refer there for commenting
start() -> 
	receive
		{proc,beb,bind,PL,App,Procs} -> next(Procs, PL, App)
	end.

next(Procs, PL, App) -> 
	receive
		{broadcast,beb,send,Msg} -> 
			[PL ! {beb,pl,send,To,Msg} || To <- Procs];
		{pl,beb,message,From} -> 
			App ! {beb,app,message,From}
	end,
	next(Procs, PL, App).
