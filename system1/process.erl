% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(process).
-export([start/0]).

start() ->
  receive
    {bind, Processes} -> wait_task(Neighbours)
  end.

wait_task(Processes) ->
  receive
    {task1, start, Max_messages, Timeout} ->
      timer:send_after(Timeout, timeout),
      send_messages(task_1, Processes, 0, Max_messages, maps:new())
  end.

send_messages(task_1, Processes, Max_messages, Max_messages, Counts) when Max_messages /= 0 ->
  receive
    timeout ->
      print_counts(Processes, Counts),
      wait_task(Processes);
    {hello, Pid} ->
      send_messages(task_1, Processes, Max_messages, Max_messages, received_message(Pid, Counts))
  end;
send_messages(task_1, Processes, Messages_sent, Max_messages, Counts) ->
  receive
    timeout ->
      print_counts(Processes, Counts),
      wait_task(Processes);
    {hello, Pid} ->
      send_messages(task_1, Processes, Messages_sent, Max_messages, received_message(Pid, Counts))
  after 0 -> ok
  end,

  NewCounts = lists:foldr(fun(Process, TempCounts) ->
                              Process ! {hello, self()},
                              sent_message(Process, TempCounts)
                          end, Counts, Processes),

  send_messages(task_1, Processes, Messages_sent + 1, Max_messages, NewCounts).

received_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent, Received + 1}, Counts).

sent_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent + 1, Received}, Counts).

print_counts(Processes, Counts) ->
  SentReceived = [maps:get(Pid, Counts, {0, 0}) || Pid <- Processes],
  SentReceivedStr = ["{" ++ integer_to_list(Sent) ++ ", " ++ integer_to_list(Received) ++ "}" ||
                      {Sent, Received} <- SentReceived],
  io:format("~p: ~p~n", [self(), string:join(SentReceivedStr, " ")]).
