%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/7]).

% exactly the same as System 3 process.erl. Please refer there for any commenting
start(Proc_num,Procs,SystemPID,AppPID,Timeout,PLPID,Loss) -> 
  receive
    {task2,bind,Bound} -> 
	  start(Proc_num,Bound,SystemPID,0,Timeout,PLPID,Loss);
    {task2,start,Max_msg} -> 
      BEB = spawn(beb,start,[]),
	  App = spawn(app,start,[Proc_num,Procs,self(),BEB,Max_msg,SystemPID]),
	  PL = spawn(pllossy,start,[self()]),
      PL ! {init,BEB,Loss},
	  start(Proc_num,Procs,SystemPID,App,Timeout,PL,Loss);
	{task2,continue} ->
	  AppPID ! {app,continue,PLPID},
	  timer:send_after(Timeout,{stop}),
	  start(Proc_num,Procs,SystemPID,AppPID,Timeout,PLPID,Loss);
	{stop} -> 
		AppPID ! {app,stop}
  end.
