%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/3]).

% same format as system 6, but more modules to spawn
start(Proc_num, Procs, SystemPID) -> 
	receive
		{task2,bind,Bound} -> 
			start(Proc_num,Bound,SystemPID); 
		{task2,start,Max_msg,Timeout} -> 
			SL = spawn(sl, start, []),
			SystemPID ! {proc, sys, SL},
			Broadcast = spawn(broadcast, start, [Max_msg]),
			PL = spawn(pllossy, start, []), 
			PLBroadcast = spawn(plbroadcast, start, []),
			BEB = spawn(beb, start, []), 
			BebBroadcast = spawn(bebbroadcast, start, []),
			RB = spawn(rb, start, []), 
			RBBroadcast = spawn(rbbroadcast, start, []),
			App = spawn(app, start, [Proc_num, SystemPID]), 
            SLBroadcast = spawn(slbroadcast, start, []),
			init(SL, Broadcast, PL, PLBroadcast, BEB, BebBroadcast, RB, RBBroadcast, App, SLBroadcast, Timeout)
	end.

init(SL, Broadcast, PL, PLBroadcast, BEB, BebBroadcast, RB, RBBroadcast, App, SLBroadcast, Timeout) ->
	receive
		{sys, proc, SlList, Loss} -> 
			SL ! {proc, sl, init, PL}, 
            SLBroadcast ! {proc, slbroadcast, init, SL},
			PL ! {proc, pl, init, BEB},
			PLBroadcast ! {proc, plbroadcast, init, SLBroadcast, Loss},
			BEB ! {proc, beb, init, RB},
			BebBroadcast ! {proc, bebbroadcast, init, PLBroadcast, SlList},
			RB ! {proc, rb, init, App, BebBroadcast},
			RBBroadcast ! {proc, rbbroadcast, init, BebBroadcast},
			App ! {proc, app, init, Broadcast},
			Broadcast ! {proc, broadcast, init, App, RBBroadcast, SlList, SL},
			timer:send_after(Timeout, {stop}),
			init(SL, Broadcast, PL, PLBroadcast, BEB, BebBroadcast, RB, RBBroadcast, App, SLBroadcast, Timeout);
		{stop} -> 
			App ! {app, stop}
	end.

			
			
			
			
