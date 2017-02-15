% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(pl).
-export([start/2]).

start(System, Id) ->
  AtomId = list_to_atom(integer_to_list(Id)),
  register(AtomId, self()),
  System ! {pl_setup, AtomId},
  receive
    {bind, C} -> next(C)
  end.

next(C) -> 
  receive
    {pl_send, Dest, Message} -> Dest ! {hello, self(), Message};
    {hello, From, Message} -> C ! {pl_deliver, From, Message}
  end,
  next(C).
