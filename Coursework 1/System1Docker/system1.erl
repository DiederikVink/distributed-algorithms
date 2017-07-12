-module(system1).
-export([start/1]).

start([M,T|_])->
  Max_msg = list_to_integer(atom_to_list(M)),
  Timeout = list_to_integer(atom_to_list(T)),
  Procs = [spawn(string:join(["node@172.19.0",integer_to_list(List_iterator)],"."),process,start,[List_iterator,[],self()]) || List_iterator <- lists:seq(1,5)],
  [P ! {task1,bind,lists:delete(P,Procs)} || P <- Procs],
  [P ! {task1,start,Max_msg,Timeout} || P <- Procs],
  receiving(0).


receiving(Count)->
  if 
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
