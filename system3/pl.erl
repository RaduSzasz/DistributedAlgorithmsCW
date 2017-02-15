% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(pl).
-export([start/2]).

start(System, Id) ->
  register(Id, self()),
  System ! {pl_setup, Id},
  receive
    {bind, C} -> next(C)
  end.

next(C) ->
  receive
    {pl_send, Dest, Message} -> Dest ! {hello, self(), Message};
    {hello, From, Message} -> C ! {pl_deliver, From, Message}
  end,
  next(C).
