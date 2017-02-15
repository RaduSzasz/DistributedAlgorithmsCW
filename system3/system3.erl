% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 1000:
% '1': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '2': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '4': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '5': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '3': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
%
% Output for Max_messages = 0, Timeout = 1000:
% '4': "{193514, 223} {193514, 404} {193514, 3215} {193514, 313} {193514, 512}"
% '1': "{194540, 4612} {194540, 4151} {194540, 7375} {194540, 2710} {194540, 4428}"
% '3': "{168332, 4229} {168332, 3735} {168332, 6883} {168332, 2542} {168332, 4133}"
% '2': "{179581, 199} {179581, 331} {179581, 3139} {179581, 257} {179581, 421}"
% '5': "{230260, 2524} {230260, 2021} {230260, 4802} {230260, 1637} {230260, 2345}"
-module(system3).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 100,
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
