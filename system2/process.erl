% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)

-module(process).
-export([start/2]).

start(System, Id) ->
  PL = spawn(pl, start, [System, Id]),
  PL ! {bind, spawn(app, start, [PL, Id])}.
