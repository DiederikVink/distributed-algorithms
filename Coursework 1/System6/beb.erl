% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(beb).
-export([start/0]).

start() -> 
	receive
		{proc,beb,init,PL,Rb,Procs} -> next(Procs, PL, Rb)
	end.

next(Procs, PL, Rb) -> 
	receive
		% process message received from rb
		{rb,beb,send,Msg} -> 
			% send message to pl modules 
			[PL ! {beb,pl,send,To,Msg} || To <- Procs];
		% process message received from pl module
		{pl,beb,message, From, Msg} -> 
			% forward message to rb module
			Rb ! {beb, rb, message, From, Msg}
	end,
	next(Procs, PL, Rb).
