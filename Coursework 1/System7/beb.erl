%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(beb).
-export([start/0]).

% this is only the receive message part of system 6's beb
start() -> 
	receive
		{proc,beb,init,Rb} -> next(Rb)
	end.

next(Rb) -> 
	receive
		{pl,beb,message, From, Msg} -> 
			Rb ! {beb, rb, message, From, Msg}
	end,
	next(Rb).
