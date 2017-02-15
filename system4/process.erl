% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(process).
-export([start/2]).

start(System, IntId) ->
  Id = list_to_atom(integer_to_list(IntId)),
  PL = spawn(pl, start, [System, Id, 50]),
  BEB = spawn(beb, start, [PL]),
  App = spawn(app, start, [BEB, Id]),
  BEB ! {bind_upper_layer, App},
  PL ! {bind, BEB}.
