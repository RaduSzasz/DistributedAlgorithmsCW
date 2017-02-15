% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 1000:
% '3': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '2': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '5': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '4': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '1': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
%
% Output for Max_messages = 0, Timeout = 1000:
% '3': "{90062, 5875} {90062, 15632} {90062, 8230} {90062, 5760} {90062, 5891}"
% '5': "{89729, 8051} {89729, 19861} {89729, 11051} {89729, 15535} {89729, 12917}"
% '2': "{70180, 10792} {70180, 21637} {70180, 12827} {70180, 21141} {70180, 19523}"
% '1': "{100683, 5447} {100683, 11916} {100683, 7694} {100683, 5332} {100683, 5353}"
% '4': "{52668, 14635} {52668, 32011} {52668, 18627} {52668, 38296} {52668, 32460}"
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 0,
  Timeout = 1000,
  [spawn(process, start, [self(), Idx]) || Idx <- lists:seq(1, N)],
  PLs = collect_PLs(0, N, []),
  [PL ! {hello, self(), {task1, start, Max_messages, Timeout}} || PL <- PLs].

collect_PLs(Expected, Expected, PLs) ->
  io:format("~p~n", [PLs]),
  [PL ! {hello, self(), {bind, PLs}} || PL <- PLs],
  PLs;
collect_PLs(Received, Expected, PLs) ->
  receive
    {pl_setup, PL} -> collect_PLs(Received + 1, Expected, PLs ++ [PL])
  end.
