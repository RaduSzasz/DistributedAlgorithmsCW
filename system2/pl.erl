% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(pl).
-export([start/0]).

start() ->
  receive
    {bind, C} -> next(C)
  end.

next(C) -> 
  receive
    {pl_send, Dest, Message} -> Dest ! {hello, self(), Message};
    {hello, From, Message} -> C ! {pl_deliver, From, Message}
  end.
