%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(process).
-export([start/3]).

% very similar to process.erl in System 1 so please refer there for commenting
% only differences have been commented here
start(Proc_num,Procs,SystemPID)->
  receive
    {task1,bind,Bound} -> 
	  start(Proc_num,Bound,SystemPID);
    {task1,start,Max_msg,Timeout} -> 
	  timer:send_after(Timeout,self(),{task1,stop}),
	  receiver(Proc_num,#{},SystemPID, Max_msg, Procs, spawn(map_update, start, [#{}]))
  after
    0 -> ok
  end.
 
receiver(Proc_num,Count,SystemPID, Max_msg, Bound, Counter)-> 
  receive
    {task1,stop} ->
	  Counter ! {print, self()},
      receive
        {task1,report,Count_Sent} -> 
    	  SystemPID ! {task1,done,self()},
    	  print(Proc_num,Count,Count_Sent,SystemPID)
      end;

  	{task1,receiver,PIDReceived} -> 
  	  CurVal = maps:get(PIDReceived,Count,0),
  	  if  
  	    (CurVal == 0) ->
  	      Count_1 = maps:put(PIDReceived, 1, Count);
  		true -> 
  		  Count_1 = maps:put(PIDReceived,CurVal+1, Count)
  	  end,
  	  receiver(Proc_num,Count_1,SystemPID, Max_msg, Bound, Counter);
	
    % added in braodcast function from System 1 braodcast.erl, please refer there for detailed commenting
	{task1, broadcast} -> 
      if
          Max_msg == 0 ->
              [Counter ! {update,Rec} || Rec <- Bound],
              [Rec ! {task1, receiver, self()} || Rec <- Bound],
           	  receiver(Proc_num, Count, SystemPID, Max_msg, Bound, Counter);
          Max_msg == 1 -> 
              [Counter ! {update,Rec} || Rec <- Bound],
              [Rec ! {task1, receiver, self()} || Rec <- Bound],
              receiver(Proc_num, Count, SystemPID, -2, Bound, Counter);
              %Counter ! {print, self()};
          Max_msg > 0 ->
              [Counter ! {update,Rec} || Rec <- Bound],
              [Rec ! {task1, receiver, self()} || Rec <- Bound],
              receiver(Proc_num, Count, SystemPID, Max_msg - 1, Bound, Counter);
	      true -> receiver(Proc_num,Count,SystemPID, Max_msg, Bound, Counter)
      end
  after
    0 ->
      receiver(Proc_num,Count,SystemPID, Max_msg, Bound, Counter)
  end.
 
print(Proc_num,Count_Rec,Count_Sent,SystemPID) -> 
  receive
    {task1, print} ->
  		io:format('~p: ', [Proc_num]),
  		[io:format('{~p,~p} ', [maps:get(Key,Count_Sent),maps:get(Key,Count_Rec)]) || Key <- maps:keys(Count_Sent)],
  		io:format('~n'),
		SystemPID ! {task1,printed}
  end.
