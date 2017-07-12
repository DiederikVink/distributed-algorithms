%%% Diederik Vink (dav114) and Aditya Rajagopal (ar4414)

-module(scout).
-export([start/3]).

start(Leader, Acceptors, B) ->
    %io:format("p1a ~w: ~w ~w ~n", [self(), Acceptors, B]),
    [ Acceptor ! {p1a, self(), B} || Acceptor <- Acceptors],

    Pvalues = [],
    Boundary = length(Acceptors)/2,

    next(Leader, B, Acceptors, Pvalues, Boundary).

next(Leader, B, Acceptors, Pvalues, Boundary) ->
    receive
        {p1b, Acceptor, Bdash, R} ->
            %io:format("receive ~w p1b, from ~w: ~w ~w ~n", [self(), Acceptor, Bdash, R]),
            if 
				Bdash == B ->
                	PvaluesSort = lists:sort(Pvalues),
                	PvaluesNew = lists:umerge([R], PvaluesSort),
                	%io:format("Pvals: ~w ~w ~w ~n ", [R, PvaluesSort, PvaluesNew]),
                	AcceptorsNew = lists:delete(Acceptor, Acceptors),
                	AccepSize = length(AcceptorsNew),
                	
                	if 
						AccepSize < Boundary ->
                	    	%io:format("~w sent ~w adopted to ~w ~n", [self(), B, Leader]),
                	    	Leader ! {adopted, B, PvaluesNew},
                	    	exit(adopted);
                		true ->
                		    next(Leader, B, AcceptorsNew, PvaluesNew, Boundary)
                	end;
            	true ->
            	    Leader ! {preempted, Bdash},
            	    exit(preempted)
            	end
    end.
