% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output when Max_messages = 0, Timeout = 3000
% <0.56.0>: "{309137, 294736} {309137, 277484} {309137, 309137} {309137, 246105} {309137, 285180}"
% <0.57.0>: "{246106, 294736} {246106, 277484} {246106, 309137} {246106, 246105} {246106, 285181}"
% <0.58.0>: "{285182, 294736} {285182, 277484} {285182, 309137} {285182, 246106} {285182, 285182}"
% <0.55.0>: "{277484, 294735} {277484, 277484} {277484, 309137} {277484, 246104} {277484, 285180}"
% <0.54.0>: "{294736, 294735} {294736, 277483} {294736, 309136} {294736, 246104} {294736, 285179}"
%
% Output when Max_messages = 1000, Timeout = 3000
% <0.57.0>: "{1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000}"
% <0.54.0>: "{1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000}"
% <0.55.0>: "{1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000}"
% <0.58.0>: "{1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000}"
% <0.56.0>: "{1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000} {1000, 1000}"
%
% The second output is easy to explain; in the 3 seconds allowed for the process
% to run, each process had the time to finish execution and reach the allowed
% limit of sending messages.
%
% To explain the output of the unbounded case, it is important to notice that
% as long as there are messages in the queue, we will aim to process them. This
% leads to non determinism as we have no guarantee on what is in the queue and
% when.
% The difference in numbers is caused by the processes not being scheduled for
% an equal time. Therefore some of them managed to get more time to send messages
% than others did. The small variations in the number of received messages from
% a certain other process is easy to explain by the order in which the messages
% arrived in the queue.
% It's important to note that the number of sent messages is greater than the
% number of received messages. This is due to the fact that there are still
% messages in the queue when we are timing out the processes and those messages
% will be lost.
%
% As it can be easily seen, timeout has precedence over the other kinds of messages.
%
-module(system1).
-export([start/0]).

start() ->
  N = 5,
  Max_messages = 1000,
  Timeout = 3000,
  Processes = [spawn(process, start, []) || _ <- lists:seq(1, N)],
  [Process ! {bind, Processes} || Process <- Processes],
  [Process ! {task1, start, Max_messages, Timeout} || Process <- Processes].
