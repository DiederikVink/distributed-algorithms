% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(system6).
-export([start/1]).

start([M,T,L|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  Loss = list_to_integer(atom_to_list(L)),
  % spawn all processes and create list of processes then send bind and start messages to each of them
  Procs = [spawn(process,start,[List_iterator,[],self()]) || List_iterator <- lists:seq(1,5)],
  [P ! {task2,bind,Procs} || P <- Procs],
  [P ! {task2,start,Max_msg,Timeout} || P <- Procs],
  collateSL(0,[],Procs, Loss).

% collate function added as register (shared memory) approach was removed
% this function waits for all processes to send back a message with their respective 
% SL module PIDs, hence each process can now know who to send to 
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

% same as in previous systems
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
