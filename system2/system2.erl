% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 100,
  Timeout = 1000,
  [spawn(process, start, [self()]) || _ <- lists:seq(1, N)],
  PLs = collect_PLs(0, N, []),
  [PL ! {hello, self(), {task1, start, Max_messages, Timeout}} || PL <- PLs]

collect_PLs(Expected, Expected, PLs) ->
  [PL ! {hello, self(), {bind, PLs}} || PL <- PLs],
  PLs;
collect_PLs(Received, Expected, PLs) ->
  receive
    {pl_setup, PL} -> collect_PLs(Received + 1, Expected, PLs ++ [PL])
  end.
