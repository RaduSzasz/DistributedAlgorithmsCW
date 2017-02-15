% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(process).
-export([start/3]).

start(System, IntId, Reliability) ->
  Id = list_to_atom(integer_to_list(IntId)),
  PL = spawn(pl, start, [System, Id, Reliability]), BEB = spawn(beb, start, [PL]),
  RB = spawn(rb, start, [BEB, Id]),
  App = spawn(app, start, [RB, Id]),
  RB ! {bind_upper_layer, App},
  BEB ! {bind_upper_layer, RB},
  PL ! {bind, BEB}.
