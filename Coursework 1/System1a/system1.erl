%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(system1).
-export([start/1]).

% the same as System 1 system1.erl, please refer there for detailed commenting.
% only differences commented here
start([M,T|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  Procs = [spawn(process,start,[List_iterator,[],self()]) || List_iterator <- lists:seq(1,5)],
  [P ! {task1,bind,lists:delete(P,Procs)} || P <- Procs],
  [P ! {task1,start,Max_msg,Timeout} || P <- Procs],
  receiving(0, Procs).


receiving(Count, Procs)->
  if 
    Count == 5 -> erlang:halt();
    true -> 
  		receive
  		  {task1, done, P} ->
  		    P ! {task1, print},
  		      receive
  		        {task1, printed} ->
  		          receiving(Count+1, Procs)
  		      end
		after
			0 -> 
                % tell P to braodcast to make sure the system doesnt just receive messages
				[P ! {task1, broadcast} || P <- Procs],
				receiving(Count, Procs)
  		end
  end.
