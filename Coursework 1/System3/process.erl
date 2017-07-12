%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/6]).

% similar to System 2 process.erl except for the fact this also spawn a BEB module
% for further commenting refer to System 2 process.erl
start(Proc_num,Procs,SystemPID,AppPID,Timeout,PLPID)-> 
  receive
    {task2,bind,Bound} -> 
	  start(Proc_num,Bound,SystemPID,0,Timeout,PLPID);
    {task2,start,Max_msg} -> 
      BEB = spawn(beb,start,[]),
	  App = spawn(app,start,[Proc_num,Procs,self(),BEB,Max_msg,SystemPID]),
	  PL = spawn(pl,start,[self()]),
      PL ! {init,BEB},
	  start(Proc_num,Procs,SystemPID,App,Timeout,PL);
	{task2,continue} ->
	  AppPID ! {app,continue,PLPID},
	  timer:send_after(Timeout,{stop}),
	  start(Proc_num,Procs,SystemPID,AppPID,Timeout,PLPID);
	{stop} -> 
		AppPID ! {app,stop}
  end.
