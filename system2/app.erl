% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(app).
-export([start/1]).

start(PL) ->
  receive
    {pl_deliver, _, {bind, Neighbours}} -> wait_task(PL, Neighbours)
  end.

wait_task(PL, Neighbours) ->
  receive
    {pl_deliver, _, {task1, start, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeout),
      send_messages(task_1, PL, Neighbours, 0, Max_messages, maps:new())
  end.

send_messages(task_1, PL, Neighbours, Max_messages, Max_messages, Counts) when Max_messages /= 0 ->
  receive
    timeout ->
      print_counts(Neighbours, Counts),
      wait_task(PL, Neighbours);
    {pl_deliver, _PL, {hello, Pid}} ->
      send_messages(task_1, PL, Neighbours, Max_messages, Max_messages, received_message(Pid, Counts))
  end;
send_messages(task_1, PL, Neighbours, Messages_sent, Max_messages, Counts) ->
  receive
    timeout ->
      print_counts(Neighbours, Counts),
      wait_task(PL, Neighbours);
    {hello, Pid} ->
      send_messages(task_1, PL, Neighbours, Messages_sent, Max_messages, received_message(Pid, Counts))
  after 0 -> ok
  end,

  NewCounts = lists:foldr(fun(Process, TempCounts) ->
                              PL ! {pl_send, Process, {hello, self()}},
                              sent_message(Process, TempCounts)
                          end, Counts, Neighbours),

  send_messages(task_1, PL, Neighbours, Messages_sent + 1, Max_messages, NewCounts).

received_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent, Received + 1}, Counts).

sent_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent + 1, Received}, Counts).

print_counts(Neighbours, Counts) ->
  SentReceived = [maps:get(Pid, Counts, {0, 0}) || Pid <- Neighbours],
  SentReceivedStr = ["{" ++ integer_to_list(Sent) ++ ", " ++ integer_to_list(Received) ++ "}" ||
                      {Sent, Received} <- SentReceived],
  io:format("~p: ~p~n", [self(), string:join(SentReceivedStr, " ")]).
