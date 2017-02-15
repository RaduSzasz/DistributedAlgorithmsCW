% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(beb).
-export([start/1]).

start(PL) ->
  receive
    {bind_upper_layer, C} ->
      io:format("Received the initial shit ~n", []),
      wait_neighbours(PL, C)
  end.

wait_neighbours(PL, C) ->
  receive
    {pl_deliver, From, {bind, Neighbours}} -> 
      io:format("Bound everything ~n", []),
      C ! {beb_deliver, From, {bind, Neighbours}},
      next(Neighbours, PL, C)
  end.

next(Neighbours, PL, C) ->
  receive
    {beb_broadcast, Message} ->
      [ PL ! {pl_send, Dest, Message} || Dest <- Neighbours ];
    {pl_deliver, From, Msg} ->
      C ! {beb_deliver, From, Msg}
  end,
  next(Neighbours, PL, C).
