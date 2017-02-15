% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 3000, Reliability = 100, Short_timeout = 5:
%'3': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'1': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'2': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'5': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'4': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 50, Short_timeout = 5:
%'3': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'1': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'2': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'4': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%'5': "{100, 1} {100, 1} {100, 1} {100, 1} {100, 1}"
%
% Output for Max_messages = 0, Timeout = 1000, Reliability = 75, Short_timeout = 10000:
% '4': "{144239, 1} {144239, 1} {144239, 1} {144239, 1} {144239, 1}"
% '1': "{46991, 1} {46991, 1} {46991, 1} {46991, 1} {46991, 1}"
% '2': "{60792, 1} {60792, 1} {60792, 1} {60792, 1} {60792, 1}"
% '5': "{106447, 1} {106447, 1} {106447, 1} {106447, 1} {106447, 1}"
% '3': "{527410, 1} {527410, 1} {527410, 1} {527410, 1} {527410, 1}"
%
% It is interesting to observe that for all the processes the number of responses received
% was 1. This is due to the filtering that the Reliable Broadcast imposed on our messages.
% We could have went past this limitation by adding some payload to the messages in order to
% identify that they are different. However, we considered that it would better illustrate the
% point and it would bring not much extra doing otherwise.
-module(system6).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 0,
  Timeout = 1000,
  Short_timeout = 10000,
  Reliability = 75,
  Early_terminating_process = list_to_atom(integer_to_list(3)),
  [spawn(process, start, [self(), Idx, Reliability]) || Idx <- lists:seq(1, N)],
  PLs = collect_PLs(0, N, []),
  [PL ! {hello, self(), {rb_data, self(), {task1, start, Max_messages, if PL == Early_terminating_process -> Short_timeout;
                                                        true -> Timeout
                                                     end}}} || PL <- PLs].

collect_PLs(Expected, Expected, PLs) ->
  [PL ! {hello, self(), {rb_data, self(), {bind, PLs}}} || PL <- PLs],
  PLs;
collect_PLs(Received, Expected, PLs) ->
  receive
    {pl_setup, PL} -> collect_PLs(Received + 1, Expected, PLs ++ [PL])
  end.
