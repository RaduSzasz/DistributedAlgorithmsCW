% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 0:
% '1': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '2': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '3': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '4': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '5': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 50:
% '1': "{100, 45} {100, 50} {100, 56} {100, 51} {100, 47}"
% '2': "{100, 56} {100, 49} {100, 51} {100, 47} {100, 52}"
% '4': "{100, 46} {100, 56} {100, 50} {100, 44} {100, 49}"
% '5': "{100, 51} {100, 51} {100, 48} {100, 60} {100, 52}"
% '3': "{100, 50} {100, 49} {100, 45} {100, 55} {100, 49}"
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 100:
% '5': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '4': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '1': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '2': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '3': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
-module(system4).
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
