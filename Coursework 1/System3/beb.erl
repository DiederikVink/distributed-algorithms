%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(beb).
-export([start/0]).

start() -> 
    % wait for bind command from process
	receive
		{proc,beb,bind,PL,App,Procs} -> next(Procs, PL, App)
	end.

next(Procs, PL, App) -> 
	receive
        % if broadcast tells beb to send a message, tell PL where to send those messages
		{broadcast,beb,send,Msg} -> 
			[PL ! {beb,pl,send,To,Msg} || To <- Procs];
        % if PL receives a message, pass it through to app
		{pl,beb,message,From} -> 
			App ! {beb,app,message,From}
	end,
	next(Procs, PL, App).
