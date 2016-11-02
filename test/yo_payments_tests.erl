%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jul 2016 5:04 PM
%%%-------------------------------------------------------------------
-module(pegasus_tests).
-author("mb-spare").

-include_lib("eunit/include/eunit.hrl").
-include("../deps/core/include/core_app_common.hrl").
deposit_test() ->
  hackney:start(),
  application:ensure_all_started(fast_xml),
 Value = pegasus:deposit(#payment{amount ="2000", phone_number = "256774661330",network = mtn,reason = "chapchap",transaction_id = "anId"}),
 ?debugFmt("Value ~w ~n",[Value])
.

withdraw_test() ->
  hackney:start(),
  application:ensure_all_started(fast_xml),
  Value = pegasus:withdraw(#payment{amount ="2000", phone_number = "256774661330",network = mtn,reason = "chapchap",transaction_id = "anId"}),
  ?debugFmt("Value ~w ~n",[Value])
.


