%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(system7).
-export([start/1]).

% same as system6's system module
start([M,T,L|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  Loss = list_to_integer(atom_to_list(L)),
  Procs = [spawn(process,start,[List_iterator,[],self()]) || List_iterator <- lists:seq(1,5)],
  [P ! {task2,bind,Procs} || P <- Procs],
  [P ! {task2,start,Max_msg,Timeout} || P <- Procs],
  collateSL(0,[],Procs, Loss).

collateSL(Count, SlList, Procs, Loss) -> 
	if
		Count == 5 -> 
			[P ! {sys, proc, SlList, Loss} || P <- Procs],
			print(0);
		true -> 
			receive 
				{proc, sys, SL} -> 
					collateSL(Count+1, [SL|SlList], Procs, Loss)
			end
	end.

print(Count)->
  if 
    Count == 5 -> erlang:halt();
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
