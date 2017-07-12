%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/3]).

start(Proc_num,Procs,SystemPID)->
  receive
    % wait for bind message containg PID's of other processes from parent process
    {task1,bind,Bound} -> 
	  start(Proc_num,Bound,SystemPID);
    % receive maximum number of messages, timeout value and spawn the broadcaster
    % set timer for halting send and receive processes. Halt braodcast first.
    {task1,start,Max_msg,Timeout} -> 
	  Count = #{},
	  Broadcast = spawn(broadcast,start,[self(),Max_msg,Procs,spawn(map_update,start,[Count])]),
	  timer:send_after(Timeout,Broadcast,{task1,stop}),
	  timer:send_after(Timeout,self(),{task1,stop}),
	  receiver(Proc_num,Count,SystemPID)
  after
    0 -> ok
  end.
 
receiver(Proc_num,Count,SystemPID)-> 
  receive
    {task1,stop} ->
      % if stop messsage is received, wait for report message from process (needs to wait for all processes to stop)
      receive
        {task1,report,Count_Sent} -> 
          % acknowledge to system that printing has commenced for this process
    	  SystemPID ! {task1,done,self()},
    	  print(Proc_num,Count,Count_Sent,SystemPID)
      end;
    % receive message from other process, increase counter for receive messages
  	{task1,receiver,PIDReceived} -> 
  	  CurVal = maps:get(PIDReceived,Count,0),
  	  if  
  	    (CurVal == 0) ->
  	      Count_1 = maps:put(PIDReceived, 1, Count);
  		true -> 
  		  Count_1 = maps:put(PIDReceived,CurVal+1, Count)
  	  end,
  	  receiver(Proc_num,Count_1,SystemPID)
  after
    0 ->
      receiver(Proc_num,Count,SystemPID)
  end.
 
print(Proc_num,Count_Rec,Count_Sent,SystemPID) -> 
  receive
    {task1, print} ->
  		io:format('~p: ', [Proc_num]),
  		[io:format('{~p,~p} ', [maps:get(Key,Count_Sent),maps:get(Key,Count_Rec)]) || Key <- maps:keys(Count_Sent)],
  		io:format('~n'),
		SystemPID ! {task1,printed}
  end.
