%Diederik Vink (dav114) Aditya Rajagopal (ar4414)

-module(rb).
-export([start/0]).

start() ->
    receive
        {proc, rb, init, App, BebBroadcast} ->
            run(App, [], BebBroadcast)
    end.

run(App, Received, BebBroadcast) ->
    receive
        {beb, rb, message, Sender, {Creator, Msg}} ->
            App ! {rb, app, sender, Sender},
            IsElem = lists:member({Creator, Msg}, Received),
            if
                IsElem ->
                    run(App, Received, BebBroadcast);
                true ->
                    App ! {rb, app, message, Creator},
					% cutting into broadcast chain so we emulate a broadcaster here
					% this is done as the rb module needs to rebroadcast receieved messages
                    BebBroadcast ! {rbbroadcast, bebbroadcast, send,{Creator, Msg}},
                    run(App, [{Creator, Msg}| Received], BebBroadcast)
            end
    end.

