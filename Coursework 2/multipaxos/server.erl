
%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex

-module(server).
-export([start/3]).

start(System, N_accounts, End_after) ->

  Database = spawn(database, start, [N_accounts, End_after]),

  Replica = spawn(replica, start, [Database]),
 
  Acceptor = spawn(acceptor, start, []),

  Leader = spawn(leader, start, [End_after]),

  System ! {config, Replica, Acceptor, Leader},

  exit(done).
