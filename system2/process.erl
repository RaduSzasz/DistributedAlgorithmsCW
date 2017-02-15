% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(process).
-export([start/1]).

start(System) ->
  PL = spawn(pl, start, []),
  PL ! {bind, spawn(app, start, [PL])},
  System ! {pl_setup, PL}.
