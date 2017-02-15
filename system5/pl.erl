% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(pl).
-export([start/2, start/3]).

start(System, Id) -> start(System, Id, 100).

start(System, Id, Reliability) ->
  % TODO: Add some checks for 0 <= Reliability <= 100
  register(Id, self()),
  System ! {pl_setup, Id},
  receive
    {bind, C} -> link(C), next(C, Reliability)
  end.

next(C, Reliability) ->
  % This might be slightly inefficient since we are doing it for
  % the case when we have 100% reliability as well, but then again,
  % generating a random number and a comparison should not have any
  % observable effect on the bahaviour
  receive
    {pl_send, Dest, Message} -> 
      Rand = rand:uniform(100),
      case Rand =< Reliability of
        true -> Dest ! {hello, self(), Message};
        false -> ok
      end;
    {hello, From, Message} -> C ! {pl_deliver, From, Message}
  end,
  next(C, Reliability).
