%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(app).
-export([start/6]).

start(Proc_num,Procs,ProcessPID,PlPID,Max_msg,SystemPID)-> 
	receive 
	  {app,continue} -> 
		% get from registry all the SL modules you can send to 
		SlList = [whereis(list_to_atom(pid_to_list(Proc))) || Proc <- Procs],
		Broadcast = spawn(broadcast,start,[self(),Max_msg,SlList,PlPID,spawn(map_update,start,[#{}]),0]),
		receiver(Proc_num,#{},SystemPID,Broadcast)
	end.
 
receiver(Proc_num,Count_Rec,SystemPID,Broadcast)-> 
  receive
    % when told to stop due to timeout, stop braodcast and start printing
    {app,stop} ->
	  Broadcast ! {broadcast,stop},  
      receive
        {app,report,Count_Sent} -> 
    	  SystemPID ! {task2,done,self()},
    	  print(Proc_num,Count_Rec,Count_Sent,SystemPID)
      end;
    % when a message is received, increment map containing messages received per process
  	{message,PIDReceived} -> 
  	  CurVal = maps:get(PIDReceived,Count_Rec,0),
  	  if  
  	    (CurVal == 0) ->
  	      Count_1 = maps:put(PIDReceived, 1, Count_Rec);
  		true -> 
  		  Count_1 = maps:put(PIDReceived,CurVal+1, Count_Rec)
  	  end,
  	  receiver(Proc_num,Count_1,SystemPID,Broadcast)
  after
    0 ->
      receiver(Proc_num,Count_Rec,SystemPID,Broadcast)
  end.
 
print(Proc_num,Count_Rec,Count_Sent,SystemPID) -> 
  receive
    {task2, print} ->
  		io:format('~p: ', [Proc_num]),
  		[io:format('{~p,~p} ', [maps:get(Key,Count_Sent),maps:get(Key,Count_Rec)]) || Key <- maps:keys(Count_Sent)],
  		io:format('~n'),
		SystemPID ! {task2,printed}
  end.
