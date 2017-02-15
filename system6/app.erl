% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
-module(app).
-export([start/2]).

start(RB, Id) ->
  receive
    {rb_deliver, _, {bind, Neighbours}} -> wait_task(RB, Id, Neighbours)
  end.

wait_task(RB, Id, Neighbours) ->
  receive
    {rb_deliver, _, {task1, start, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeout),
      send_messages(task_1, RB, Id, Neighbours, 0, Max_messages, maps:new())
  end.

send_messages(task_1, RB, Id, Neighbours, Max_messages, Max_messages, Counts) when Max_messages /= 0 ->
  receive
    timeout ->
      print_counts(Id, Neighbours, Counts),
      ok;
    {rb_deliver, _, {hello, Pid}} ->
      send_messages(task_1, RB, Id, Neighbours, Max_messages, Max_messages, received_message(Pid, Counts))
  end;
send_messages(task_1, RB, Id, Neighbours, Messages_sent, Max_messages, Counts) ->
  receive
    timeout ->
      print_counts(Id, Neighbours, Counts),
      ok;
    {rb_deliver, _, {hello, Pid}} ->
      send_messages(task_1, RB, Id, Neighbours, Messages_sent, Max_messages, received_message(Pid, Counts))
  after 0 -> ok
  end,

  RB ! {rb_broadcast, {hello, Id}},
  NewCounts = lists:foldr(fun(Process, TempCounts) ->
                              sent_message(Process, TempCounts)
                          end, Counts, Neighbours),

  send_messages(task_1, RB, Id, Neighbours, Messages_sent + 1, Max_messages, NewCounts).

received_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent, Received + 1}, Counts).

sent_message(Pid, Counts) ->
  {Sent, Received} = maps:get(Pid, Counts, {0, 0}),
  maps:put(Pid, {Sent + 1, Received}, Counts).

print_counts(Id, Neighbours, Counts) ->
  SentReceived = [maps:get(Pid, Counts, {0, 0}) || Pid <- Neighbours],
  SentReceivedStr = ["{" ++ integer_to_list(Sent) ++ ", " ++ integer_to_list(Received) ++ "}" ||
                      {Sent, Received} <- SentReceived],
  io:format("~p: ~p~n", [Id, string:join(SentReceivedStr, " ")]).
