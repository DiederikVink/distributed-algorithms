%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(system1).
-export([start/1]).

start([M,T|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  % spawn all processes
  Procs = [spawn(process,start,[List_iterator,[],self()]) || List_iterator <- lists:seq(1,5)],
  % provide all other process PID's other than its own to each process
  [P ! {task1,bind,lists:delete(P,Procs)} || P <- Procs],
  [P ! {task1,start,Max_msg,Timeout} || P <- Procs],
  receiving(0).


receiving(Count)->
  if 
    % if all processes have confirmed they are printing, exit system
    Count == 5 -> erlang:halt();
    true -> 
  		receive
  		  {task1, done, P} ->
  		    P ! {task1, print},
  		      receive
  		        {task1, printed} ->
  		          receiving(Count+1)
  		      end
  		end
  end.
