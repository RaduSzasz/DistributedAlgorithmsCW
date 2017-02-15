% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 100:
% '3': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '2': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '1': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '5': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '4': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
%
% Output for Max_messages = 0, Timeout = 1000, Reliability = 100:
% '3': "{1065, 0} {1065, 0} {1065, 0} {1065, 0} {1065, 0}"
% '1': "{381591, 573} {381591, 255} {381591, 93} {381591, 703} {381591, 255}"
% '5': "{197713, 726} {197713, 323} {197713, 110} {197713, 871} {197713, 327}"
% '4': "{171024, 3483} {171024, 2764} {171024, 1426} {171024, 3148} {171024, 2370}"
% '2': "{206369, 2042} {206369, 1273} {206369, 518} {206369, 2289} {206369, 1095}"
-module(system5).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 100,
  Timeout = 1000,
  Short_timeout = 5,
  Early_terminating_process = list_to_atom(integer_to_list(3)),
  [spawn(process, start, [self(), Idx]) || Idx <- lists:seq(1, N)],
  PLs = collect_PLs(0, N, []),
  [PL ! {hello, self(), {task1, start, Max_messages, if PL == Early_terminating_process -> Short_timeout;
                                                        true -> Timeout
                                                     end}} ||
          PL <- PLs].

collect_PLs(Expected, Expected, PLs) ->
  [PL ! {hello, self(), {bind, PLs}} || PL <- PLs],
  PLs;
collect_PLs(Received, Expected, PLs) ->
  receive
    {pl_setup, PL} -> collect_PLs(Received + 1, Expected, PLs ++ [PL])
  end.
