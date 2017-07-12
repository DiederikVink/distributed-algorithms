%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/7]).

% very similar to System 4 process.erl. Please refer there for any commenting
% only differences have been commented here
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
      % if the current process is process 3, terminate after 35 ms
	  if 
	  	Proc_num == 3 -> 
            timer:send_after(35, AppPID, {terminate}),
			timer:kill_after(35);
		true -> ok
	  end,
	  start(Proc_num,Procs,SystemPID,AppPID,Timeout,PLPID,Loss);
	{stop} -> 
		AppPID ! {app,stop}
  end.
