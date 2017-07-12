%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(app).
-export([start/6]).

% similar to app.erl in Systme 4, please refer there for commenting
% only differences are commented here
start(Proc_num,Procs,ProcessPID,BEBPID,Max_msg,SystemPID)-> 
	receive 
	  {app,continue,PLPID} -> 
		% get from registry all the SL modules you can send to 
		SlList = [whereis(list_to_atom(pid_to_list(Proc))) || Proc <- Procs],
        BEBPID ! {proc,beb,bind,PLPID,self(),SlList},
		Broadcast = spawn(broadcast,start,[self(),Max_msg,SlList,BEBPID,spawn(map_update,start,[#{}]),0]),
		receiver(Proc_num,#{},SystemPID,Broadcast)
	end.
 
receiver(Proc_num,Count_Rec,SystemPID,Broadcast)-> 
  receive
    {app,stop} ->
	  Broadcast ! {broadcast,stop},  
      receive
        {app,report,Count_Sent} -> 
    	  SystemPID ! {task2,done,self()},
    	  print(Proc_num,Count_Rec,Count_Sent,SystemPID)
      end;
  	{beb,app,message,PIDReceived} -> 
  	  CurVal = maps:get(PIDReceived,Count_Rec,0),
  	  if  
  	    (CurVal == 0) ->
  	      Count_1 = maps:put(PIDReceived, 1, Count_Rec);
  		true -> 
  		  Count_1 = maps:put(PIDReceived,CurVal+1, Count_Rec)
  	  end,
  	  receiver(Proc_num,Count_1,SystemPID,Broadcast);
    % if terminate function has been received, terminate with message of "Faulty Process"
    {terminate} ->
      Broadcast ! {terminate},
      exit("Faulty Process")
  after
    0 ->
      receiver(Proc_num,Count_Rec,SystemPID,Broadcast)
  end.
 
print(Proc_num,Count_Rec,Count_Sent,SystemPID) -> 
  receive
    {task2, print} ->
  		io:format('~p: ', [Proc_num]),
  		[io:format('{~p,~p} ', [maps:get(Key,Count_Sent,0),maps:get(Key,Count_Rec,0)]) || Key <- maps:keys(Count_Sent)],
  		io:format('~n'),
		SystemPID ! {task2,printed}
  end.
