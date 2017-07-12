%%% Aditya Rajagopal (ar4414) and Diederik Vink (dav114)

-module(replica).
-export([start/1]).

start(Database) ->
  Slot_in = 1,
  Slot_out = 1, 
  Requests = [],
  Proposals = [],
  Descisions = [],

  receive
    {bind, Leaders} -> 
       LeadersSort = lists:sort(Leaders),
       next(Requests, Descisions, Slot_out, Proposals, Database, Slot_in, LeadersSort)
  end.

next(Requests, Descisions, Slot_out, Proposals, Database, Slot_in, Leaders) ->
  %io:format("Req0: ~w ~w ~n", [self(), Requests]),
  receive
    {request, C} ->      % request from client
      RequestsSort = lists:sort(Requests),
      Requests1 = lists:umerge([C], RequestsSort), 
	  %io:format("Req: ~w ~w ~n", [self(), Requests1]),
      propose(Slot_in, Slot_out, Requests1, Proposals, Descisions, Leaders),
      receive
          {prop_res, Slot_inNew, Slot_outNew, RequestsNew, ProposalsNew, DescisionsNew, LeadersNew} ->
	  		%io:format("Req1: ~w ~w ~w  ~n", [Slot_inNew, self(), RequestsNew]),
            next(RequestsNew, DescisionsNew, Slot_outNew, ProposalsNew, Database, Slot_inNew, LeadersNew)
      end;
    
	{decision, S, C} ->  % decision from commander
      %io:format("~w received ~w ~w ~n", [self(), S, C]),
      DescisionsSort = lists:sort(Descisions),
	  Descisions1 = lists:umerge([{S,C}], DescisionsSort),
      IsElem = membership({Slot_out,waste}, Descisions1),
	  if 
	     IsElem ->
          C1 = extract({Slot_out,waste}, Descisions1),
		  decide(Slot_out, Descisions1, Proposals, Requests, C1, Database),
          receive
              {decide, ProposalsNew, RequestsNew, Slot_outNew} ->
                  Proposals1 = ProposalsNew,
                  Requests1 = RequestsNew,
				  Slot_out1 = Slot_outNew
          end;
		true ->
          Proposals1 = Proposals,
          Requests1 = Requests,
		  Slot_out1 = Slot_out
	  end,
  	  propose(Slot_in, Slot_out1, Requests1, Proposals1, Descisions1, Leaders),
      receive
          {prop_res, Slot_inNew1, Slot_outNew1, RequestsNew1, ProposalsNew1, DescisionsNew1, LeadersNew1} ->
		  	%io:format("Proposals: ~w, Requests: ~w, Descisions: ~w ~n", [ProposalsNew1, RequestsNew1, DescisionsNew1]),
            next(RequestsNew1, DescisionsNew1, Slot_outNew1, ProposalsNew1, Database, Slot_inNew1, LeadersNew1)
      end
  end.

propose(Slot_in, Slot_out, Requests, Proposals, Descisions, Leaders) ->
  WINDOW = 5,
  %ReqList = sets:to_list(Requests),
  IsElem = (length(Requests) /= 0),
  Claus = (Slot_in < Slot_out + WINDOW) and (IsElem),
  if 
	Claus -> 
      C = lists:nth(1, Requests),
	  %io:format("C: ~w ~n",[C]),
      IsElem1 = membership({Slot_in,waste}, Descisions),
	  if
	    IsElem1 -> 
	      Requests1 = Requests, 
	      Proposals1 = Proposals;
	    true ->
	      Requests1 = lists:delete(C, Requests),
          ProposalsSort = lists:sort(Proposals),
	      Proposals1 = lists:umerge([{Slot_in, C}], ProposalsSort),
	      [Leader ! {propose, Slot_in, C} || Leader <- Leaders]
	  end,
	  Slot_in1 = Slot_in + 1,
	  %io:format("Req_Prop: ~w, ~w ~n",[Slot_in1, Requests1]),
	  propose(Slot_in1, Slot_out, Requests1, Proposals1, Descisions, Leaders);
    true ->
  		%io:format("Req_Out: ~w, ~w ~n",[Slot_in, Requests]),
  		self() ! {prop_res, Slot_in, Slot_out, Requests, Proposals, Descisions, Leaders}
  end.
  
   
perform({Client, Cid, Op}, Slot_out, Descisions, Database) ->
  S = extract2({waste,{Client,Cid,Op}}, Descisions),
  IsElem = (S /= false),
  if 
  	 IsElem -> 
	  if 
	    S < Slot_out ->
		  Slot_out1 = Slot_out + 1;
		true -> 
      	  Database ! {execute, Op},
	  	  Slot_out1 = Slot_out + 1,
      	  Client ! {response, Cid}
	  end;
	true ->
      Database ! {execute, Op},
	  Slot_out1 = Slot_out + 1,
      Client ! {response, Cid}
  end,
  self() ! {perf_res, Slot_out1}.

decide(Slot_out, Descisions, Proposals, Requests, C, Database) ->
  C1 = extract({Slot_out,waste}, Proposals),
  IsElem = (C1 /= false),
  if 
     IsElem -> 
	  Proposals1 = lists:delete({Slot_out,C1}, Proposals),
	  if 
	    C /= C1 -> 
          RequestsSort = lists:sort(Requests),
		  Requests1 = lists:umerge([C1], RequestsSort);
		true -> 
		  Requests1 = Requests
	  end;
	true -> 
	  Proposals1 = Proposals,
      Requests1 = Requests
  end,
  
  perform(C, Slot_out, Descisions, Database),
  receive 
      {perf_res, Slot_outNew} ->
          Slot_out1 = Slot_outNew
  end,
  
  C2 = extract({Slot_out1,waste}, Descisions),
  IsElem1 = (C2 /= false),
  
  if 
    IsElem1 ->
      decide(Slot_out1, Descisions, Proposals1, Requests1, C2, Database);
	true ->
  		self() ! {decide, Proposals1, Requests1, Slot_out1}
  end.
    
membership({S,_},[]) -> 
  false;
membership({S,_},[{S,_}|T]) ->
  true;
membership({S,_},[{A,_}|T]) ->
  membership({S,waste},T).

extract({S,_},[]) -> 
  false;
extract({S,_},[{S,C}|T]) ->
  C;
extract({S,_},[{A,_}|T]) ->
  extract({S,waste},T).

extract2({_,S},[]) -> 
  false;
extract2({_,S},[{C,S}|T]) ->
  C;
extract2({_,S},[{_,A}|T]) ->
  extract2({waste,S},T).
