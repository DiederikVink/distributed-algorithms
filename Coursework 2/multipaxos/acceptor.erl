%%% Aditya Rajagopal (ar4414) and Diederik Vink (dav114)

-module(acceptor).
-export([start/0]).

start() ->
	Ballot_num = -1,
	Accepted = [],
	next(Ballot_num, Accepted). 

next(Ballot_num, Accepted) ->
	receive
		{p1a, Scout, B} ->
            %io:format("p1a ~w: ~w ~w ~n", [self(), Scout, B]),
			if
				B > Ballot_num -> 
					Ballot_num1 = B;
				true -> 
					Ballot_num1 = Ballot_num
			end,
            %io:format("send ~w p1b, to ~w: ~w ~w ~n", [self(), Scout, Ballot_num1, Accepted]),
			Scout ! {p1b, self(), Ballot_num1, Accepted},
			next(Ballot_num1, Accepted);
		
		{p2a, Commander, {B,S,C}} -> 
			if 
				B == Ballot_num -> 
                    AcceptedSort = lists:sort(Accepted),
					Accepted1 = lists:umerge([{B,S,C}], AcceptedSort);
				true ->
					Accepted1 = Accepted
			end, 
			Commander ! {p2b, self(), Ballot_num},
			next(Ballot_num, Accepted1)
	end.
