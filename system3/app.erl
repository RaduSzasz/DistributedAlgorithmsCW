% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(app).
-export([start/2]).

start(BEB, Id) ->
  receive
    {beb_deliver, _, {bind, Processes}} -> wait_task(BEB, Id, Processes)
  end.

wait_task(BEB, Id, Processes) ->
  receive
    {beb_deliver, _, {task1, start, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeout),
      send_messages(task_1, BEB, Id, Processes, 0, Max_messages, maps:new())
  end.

send_messages(task_1, BEB, Id, Processes, Max_messages, Max_messages, Counts) when Max_messages /= 0 ->
  receive
    timeout ->
      print_counts(Id, Processes, Counts),
      ok;
    {beb_deliver, _, {hello, Pid}} ->
      send_messages(task_1, BEB, Id, Processes, Max_messages, Max_messages, received_message(Pid, Counts))
  end;
send_messages(task_1, BEB, Id, Processes, Messages_sent, Max_messages, Counts) ->
  receive
    timeout ->
      print_counts(Id, Processes, Counts),
      ok;
    {beb_deliver, _, {hello, Pid}} ->
      send_messages(task_1, BEB, Id, Processes, Messages_sent, Max_messages, received_message(Pid, Counts))
  after 0 -> ok
  end,

  BEB ! {beb_broadcast, {hello, Id}},
  NewCounts = lists:foldr(fun(Process, TempCounts) ->
                              sent_message(Process, TempCounts)
                          end, Counts, Processes),

  send_messages(task_1, BEB, Id, Processes, Messages_sent + 1, Max_messages, NewCounts).

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
