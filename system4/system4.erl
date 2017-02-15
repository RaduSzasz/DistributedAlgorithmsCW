% Eugenia Kim (ek2213) and Radu-Andrei Szasz (ras114)
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 0:
% '1': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '2': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '3': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '4': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
% '5': "{100, 0} {100, 0} {100, 0} {100, 0} {100, 0}"
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 50:
% '1': "{100, 45} {100, 50} {100, 56} {100, 51} {100, 47}"
% '2': "{100, 56} {100, 49} {100, 51} {100, 47} {100, 52}"
% '4': "{100, 46} {100, 56} {100, 50} {100, 44} {100, 49}"
% '5': "{100, 51} {100, 51} {100, 48} {100, 60} {100, 52}"
% '3': "{100, 50} {100, 49} {100, 45} {100, 55} {100, 49}"
%
% Output for Max_messages = 100, Timeout = 1000, Reliability = 100:
% '5': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '4': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '1': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '2': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
% '3': "{100, 100} {100, 100} {100, 100} {100, 100} {100, 100}"
%
% Output for Max_messages = 0, Timeout = 1000, Reliability = 100:
% '3': "{167022, 1968} {167022, 2878} {167022, 2698} {167022, 2751} {167022, 3165}"
% '2': "{223916, 1755} {223916, 2426} {223916, 2355} {223916, 2438} {223916, 2838}"
% '4': "{389803, 724} {389803, 1102} {389803, 1025} {389803, 1096} {389803, 1309}"
% '1': "{134539, 1837} {134539, 2571} {134539, 2469} {134539, 2501} {134539, 2943}"
% '5': "{387245, 930} {387245, 1284} {387245, 1266} {387245, 1295} {387245, 1592}"
%
% Output for Max_messages = 0, Timeout = 1000, Reliability = 50:
% '1': "{177450, 6832} {177450, 4700} {177450, 4741} {177450, 6684} {177450, 6116}"
% '5': "{165716, 3358} {165716, 1927} {165716, 1780} {165716, 2547} {165716, 2558}"
% '3': "{165935, 4066} {165935, 2477} {165935, 2287} {165935, 3263} {165935, 3383}"
% '2': "{107722, 4894} {107722, 3109} {107722, 2898} {107722, 4188} {107722, 3936}"
% '4': "{182098, 3230} {182098, 1869} {182098, 1633} {182098, 2289} {182098, 2412}"
%
% Output for Max_messages = 0, Timeout = 1000, Reliability = 0:
% '5': "{148228, 0} {148228, 0} {148228, 0} {148228, 0} {148228, 0}"
% '3': "{167560, 0} {167560, 0} {167560, 0} {167560, 0} {167560, 0}"
% '4': "{162781, 0} {162781, 0} {162781, 0} {162781, 0} {162781, 0}"
% '1': "{210054, 0} {210054, 0} {210054, 0} {210054, 0} {210054, 0}"
% '2': "{186575, 0} {186575, 0} {186575, 0} {186575, 0} {186575, 0}"
%
% Firstly, it is important to note that we have a good indication of correctness
% due to the fact that when reliability was 0, no messages were received, but when
% reliability was 100, we had all the messages received in the bounded case and
% a number of messages similar to the one in system3 for the unbounded case.
% In the same fashion, the bounded case for reliability 50 seems to indicate
% that our solution is correct, all the received counts averaging around 50.
%
% Interestingly, the number of messages received when reliability is only 50
% is way higher than the case when reliability is 100. The explanation however
% is fairly straightforward. The main factor limiting the number of message received
% by our applications was the fact that throughout all of the communication layers,
% we chose to prioritize sending. In the case when the reliability is only 50 percent,
% we are less busy sending as we are dropping half of our messages, but there are still
% plenty of received messages for us to process.
-module(system4).
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
