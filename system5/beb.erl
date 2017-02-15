% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(beb).
-export([start/1]).

start(PL) ->
  receive
    {bind_upper_layer, C} ->
      link(C),
      wait_neighbours(PL, C)
  end.

wait_neighbours(PL, C) ->
  receive
    {pl_deliver, From, {bind, Processes}} -> 
      C ! {beb_deliver, From, {bind, Processes}},
      next(Processes, PL, C)
  end.

next(Processes, PL, C) ->
  receive
    {beb_broadcast, Message} ->
      [ PL ! {pl_send, Dest, Message} || Dest <- Processes ];
    {pl_deliver, From, Msg} ->
      C ! {beb_deliver, From, Msg}
  end,
  next(Processes, PL, C).
