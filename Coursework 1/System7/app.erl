%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(app).
-export([start/2]).

% same as in system 6
start(Proc_num,SystemPID)-> 
	receive 
      {proc, app, init, BroadcastPID} ->
		receiver(Proc_num,#{},#{},SystemPID,BroadcastPID)
	end.
 
receiver(Proc_num,Count_Rec,Count_Sender,SystemPID,Broadcast)-> 
  receive
    {app,stop} ->
	  Broadcast ! {broadcast,stop},  
      receive
        {app,report,Count_Sent} -> 
    	  SystemPID ! {task2,done,self()},
    	  print(Proc_num,Count_Rec,Count_Sender,Count_Sent,SystemPID)
      end;
  	{rb,app,message,PIDReceived} -> 
  	  CurVal = maps:get(PIDReceived,Count_Rec,0),
  	  if  
  	    (CurVal == 0) ->
  	      Count_1 = maps:put(PIDReceived, 1, Count_Rec);
  		true -> 
  		  Count_1 = maps:put(PIDReceived,CurVal+1, Count_Rec)
  	  end,
  	  receiver(Proc_num,Count_1,Count_Sender,SystemPID,Broadcast);
    {rb,app,sender,PIDSender} ->
  	  SendVal = maps:get(PIDSender,Count_Sender,0),
  	  if  
  	    (SendVal == 0) ->
  	      Count_2 = maps:put(PIDSender, 1, Count_Sender);
  	    true -> 
  	      Count_2 = maps:put(PIDSender, SendVal+1, Count_Sender)
  	  end,
      
  	  receiver(Proc_num,Count_Rec,Count_2,SystemPID,Broadcast)
  after
    0 ->
      receiver(Proc_num,Count_Rec,Count_Sender,SystemPID,Broadcast)
  end.
 
print(Proc_num,Count_Rec,Count_Sender,Count_Sent,SystemPID) -> 
  receive
    {task2, print} ->
        Size = maps:size(Count_Rec),
  		io:format('~p: ', [Proc_num]),
  		[io:format('{~p,~p,~p} ', [maps:get(Key,Count_Sent,0),maps:get(Key,Count_Rec,0),maps:get(Key,Count_Sender,0)]) || Key <- maps:keys(Count_Sent)],
  		io:format('~n'),
		SystemPID ! {task2,printed}
  end.

%print(Proc_num,#{},Count_Sent,SystemPID) -> 
%  receive
%    {task2, print} ->
%  		io:format('~p: ', [Proc_num]),
%  		[io:format('{~p,~p} ', [maps:get(Key,Count_Sent),0]) || Key <- maps:keys(Count_Sent)],
%  		io:format('here ~n'),
%		SystemPID ! {task2,printed}
%  end.

