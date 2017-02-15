% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(app).
-export([start/2]).

start(PL, Id) ->
  receive
    {pl_deliver, _, {bind, Processes}} -> wait_task(PL, Id, Processes)
  end.

wait_task(PL, Id, Processes) ->
  receive
    {pl_deliver, _, {task1, start, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeout),
      send_messages(task_1, PL, Id, Processes, 0, Max_messages, maps:new())
  end.

send_messages(task_1, PL, Id, Processes, Max_messages, Max_messages, Counts) when Max_messages /= 0 ->
  receive
    timeout ->
      print_counts(Id, Processes, Counts),
      wait_task(PL, Id, Processes);
    {pl_deliver, _, {hello, Pid}} ->
      send_messages(task_1, PL, Id, Processes, Max_messages, Max_messages, received_message(Pid, Counts))
  end;
send_messages(task_1, PL, Id, Processes, Messages_sent, Max_messages, Counts) ->
  receive
    timeout ->
      print_counts(Id, Processes, Counts),
      wait_task(PL, Id, Processes);
    {pl_deliver, _, {hello, Pid}} ->
      send_messages(task_1, PL, Id, Processes, Messages_sent, Max_messages, received_message(Pid, Counts))
  after 0 -> ok
  end,

  NewCounts = lists:foldr(fun(Process, TempCounts) ->
                              PL ! {pl_send, Process, {hello, Id}},
                              sent_message(Process, TempCounts)
                          end, Counts, Processes),

  send_messages(task_1, PL, Id, Processes, Messages_sent + 1, Max_messages, NewCounts).

received_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent, Received + 1}, Counts).

sent_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent + 1, Received}, Counts).

print_counts(Id, Processes, Counts) ->
  SentReceived = [maps:get(Pid, Counts, {0, 0}) || Pid <- Processes],
  SentReceivedStr = ["{" ++ integer_to_list(Sent) ++ ", " ++ integer_to_list(Received) ++ "}" ||
                      {Sent, Received} <- SentReceived],
  io:format("~p: ~p~n", [Id, string:join(SentReceivedStr, " ")]).
