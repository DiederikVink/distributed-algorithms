%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/5]).

% now far more governing than in System1
start(Proc_num,Procs,SystemPID,AppPID,Timeout)-> 
  receive
    % receive all other process PIDs
    {task2,bind,Bound} -> 
	  start(Proc_num,Bound,SystemPID,0,Timeout);
    % spawn and initialize all App and PL
    {task2,start,Max_msg} -> 
	  PL = spawn(pl,start,[self()]),
	  App = spawn(app,start,[Proc_num,Procs,self(),PL,Max_msg,SystemPID]),
      PL ! {init,App},
	  start(Proc_num,Procs,SystemPID,App,Timeout);
    % after all process have initallized and are read, start all braodcasting
	{task2,continue} ->
	  AppPID ! {app,continue},
	  timer:send_after(Timeout,{stop}),
	  start(Proc_num,Procs,SystemPID,AppPID,Timeout);
    % stop when instructed to do so by system
	{stop} -> 
		AppPID ! {app,stop}
  end.
