% Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(rb).
-export([start/0]).

start() ->
    receive
        {proc, rb, init, App, Beb} ->
            run(App, Beb, [])
    end.

run(App, Beb, Received) ->
    receive
        {broadcast, rb, send, Msg} -> 
			% passes message received from broadcast to beb for broadcast
            Beb ! {rb, beb, send, Msg},
            run(App, Beb, Received);
		% message that is recieved passed to this module from beb
        {beb, rb, message, Sender, {Creator, Msg}} ->
			% send message to app that a message has passed the beb filter
			% this count is displayed in the 3rd column of the output
            App ! {rb, app, sender, Sender},
			% checks if the creater +  message tuple is new
            IsElem = lists:member({Creator, Msg}, Received),
            if
                IsElem ->
                    run(App, Beb, Received);
                true ->
					% this message to app creates the count displayed in the 
					% second column of the output
                    App ! {rb, app, message, Creator},
					% this message is sent in order to re-broadcst received messages
                    Beb ! {rb, beb, send,{Creator, Msg}},
                    run(App, Beb, [{Creator, Msg}| Received])
            end
    end.

