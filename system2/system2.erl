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
%
% For the first case, the output is very similar to the one
% we had in system1.
%
% However, for the set with unbounded message sending we notice that the
% amount of messages sent is much greater than the amount of messages
% received. This is due to the way we implemented the pl process.
% In its receive block we are firstly processing the send requests that
% are coming from the layer above (in this case the App) before we are
% processing the messages that arrived from other processes. Therefore,
% the much bigger difference in between sent and received follows naturally.
%
% This behaviour will be observed throughout all of the next systems.
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
  [PL ! {hello, self(), {bind, PLs}} || PL <- PLs],
  PLs;
collect_PLs(Received, Expected, PLs) ->
  receive
    {pl_setup, PL} -> collect_PLs(Received + 1, Expected, PLs ++ [PL])
  end.
