%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(system5).
-export([start/1]).

% exactly the same as system4. please refer there for commenting
start([M,T,L|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  Loss = list_to_integer(atom_to_list(L)),
  Procs = [spawn(process,start,[List_iterator,[],self(), 0,Timeout,0,Loss]) || List_iterator <- lists:seq(1,5)],
  [P ! {task2,bind,Procs} || P <- Procs],
  [P ! {task2,start,Max_msg} || P <- Procs],
  timer:sleep(10),
  [P ! {task2,continue} || P <- Procs],
  print(0).

print(Count)->
  if 
    Count == 4 -> erlang:halt();
    true -> 
  		receive
  		  {task2, done, P} ->
  		    P ! {task2, print},
  		      receive
  		        {task2, printed} ->
  		          print(Count+1)
  		      end
  		end
  end.
