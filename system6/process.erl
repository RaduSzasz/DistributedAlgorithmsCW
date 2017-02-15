% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(process).
-export([start/2]).

start(System, IntId) ->
  Id = list_to_atom(integer_to_list(IntId)),
  PL = spawn(pl, start, [System, Id, 100]),
  BEB = spawn(beb, start, [PL]),
  RB = spawn(rb, start, [BEB, Id]),
  App = spawn(app, start, [RB, Id]),
  RB ! {bind_upper_layer, App},
  BEB ! {bind_upper_layer, RB},
  PL ! {bind, BEB}.
