% Eugenia Kim (ek2213) and Radu Szasz (ras114)

-module(rb).
-export([start/2]).

start(BEB, Id) ->
  receive
    {bind_upper_layer, C} -> link(C), next(Id, C, BEB, [])
  end.

next(Id, C, BEB, Delivered) ->
  receive
    {rb_broadcast, M} ->
      BEB ! {beb_broadcast, {rb_data, Id, M}},
      next(Id, C, BEB, Delivered);
    {beb_deliver, _, {rb_data, Sender, M}} ->
      case lists:member(M, Delivered) of
        true -> next(Id, C, BEB, Delivered);
        false ->
          C ! {rb_deliver, Sender, M},
          BEB ! {beb_broadcast, {rb_data, Sender, M}},
          next(Id, C, BEB, Delivered ++ [M])
      end
  end.
