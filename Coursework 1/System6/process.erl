% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/3]).

% recieves bind from system6
start(Proc_num, Procs, SystemPID) -> 
	receive
		{task2,bind,Bound} -> 
			start(Proc_num,Bound,SystemPID); 
		% spawn all the required modules
		{task2,start,Max_msg,Timeout} -> 
			SL = spawn(sl, start, []),
			SystemPID ! {proc, sys, SL},
			Broadcast = spawn(broadcast, start, [Max_msg]),
			PL = spawn(pllossy, start, []), 
			BEB = spawn(beb, start, []), 
			RB = spawn(rb, start, []), 
			App = spawn(app, start, [Proc_num, SystemPID]), 
			init(SL, Broadcast, PL, BEB, RB, App, Timeout)
	end.

% waits for the list of SL PID to be recieved 
% initialises each of the spawned modules with the required values
init(SL, Broadcast, PL, BEB, RB, App, Timeout) ->
	receive
		{sys, proc, SlList, Loss} -> 
			SL ! {proc, sl, init, PL}, 
			Broadcast ! {proc, broadcast, init, App, RB, SlList, SL},
			PL ! {proc, pl, init, SL, BEB, Loss},
			BEB ! {proc, beb, init, PL, RB, SlList},
			RB ! {proc, rb, init, App, BEB},
			App ! {proc, app, init, Broadcast},
			% send this message to terminate the process
			timer:send_after(Timeout, {stop}),
			init(SL, Broadcast, PL, BEB, RB, App, Timeout);
		{stop} -> 
			App ! {app, stop}
	end.

			
			
			
			
