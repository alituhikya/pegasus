%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jul 2016 5:33 PM
%%%-------------------------------------------------------------------
-module(signature_tests).
-author("mb-spare").

-include_lib("eunit/include/eunit.hrl").
-include("../include/pegasus_app_common.hrl").

simple_test() ->
  ?assertNotEqual(undefined,pegasus_signature:get_private_key()).

set_up()->
  mnesia:stop(),
  mnesia:delete_schema([]),
  mnesia:create_schema([]),
  mnesia:start()
.

tear_down(_)->
  mnesia:stop(),
  mnesia:delete_schema([]).

create_tables_test_() ->
  {setup,
    fun set_up/0,
    fun tear_down/1,
    [?_assertEqual({atomic,ok}, pegasus_signature:create_tables()),
      ?_assertEqual(ok, pegasus_signature:ensure_loaded())
    ]}.

with_no_db_test() ->
  TimestampNow = os:system_time(),
  Value = pegasus_signature:get_private_key(),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Value]),
  ?debugFmt("key ~w ~n",[TimestampThen -TimestampNow]),
  ?assertNotEqual(undefined,Value).

with_db_test()->
  set_up(),
  pegasus_signature:initiate(),
  TimestampNow = os:system_time(),
  Value = pegasus_signature:get_private_key(),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Value]),
  ?debugFmt("Time spent with db ~w ~n",[TimestampThen -TimestampNow]),

  TimestampNow2 = os:system_time(),
  Value = pegasus_signature:get_private_key(),
  TimestampThen2 = os:system_time(),
  ?debugFmt("Value ~w ~n",[Value]),
  ?debugFmt("Time spent with db 2 ~w ~n",[TimestampThen2 -TimestampNow2]),

  ?assertNotEqual(undefined,Value),
  tear_down(a)
.
with_no_db_direct_test()->
  set_up(),
  pegasus_signature:initiate(),
  TimestampNow = os:system_time(),
  Value = pegasus_signature:create_private_key(),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Value]),
  ?debugFmt("Time spent with no db  direct ~w ~n",[TimestampThen -TimestampNow]),
  ?assertNotEqual(undefined,Value),
  tear_down(a)
.

with_db2_test()->
  set_up(),
  ok = pegasus_signature:initiate(),
  TimestampNow = os:system_time(),
  Value = pegasus_signature:get_private_key_from_db(1),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Value]),
  ?debugFmt("Time spent with db direct ~w ~n",[TimestampThen -TimestampNow]),
  ?assertNotEqual(undefined,Value),
  tear_down(a)
.

encrypt_test()->
  Settings = pegasus_env_util:get_settings(),
  Amount = <<"2000">>,
  PhoneNumber = <<"256788718757">>,
  TransactionId = <<"an id">>,
  Reason = <<" a reason">>,
  TimestampNow = os:system_time(),
  Authenticationsignature = pegasus_signature:get_signature(binary,Amount,PhoneNumber,Reason,TransactionId,Settings),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Authenticationsignature]),
  ?debugFmt("Time spent binary ~w ~n",[TimestampThen -TimestampNow]).

encrypt_string_test()->
  SettingsOld = pegasus_env_util:get_settings(),
  Amount = "2000",
  PhoneNumber = "256788718757",
  TransactionId = "an id",
  Reason = " a reason",
  Settings = SettingsOld#pegasus_settings{api_password = binary_to_list(SettingsOld#pegasus_settings.api_password),
  api_username =  binary_to_list(SettingsOld#pegasus_settings.api_username),
  notification_url = binary_to_list(SettingsOld#pegasus_settings.notification_url),
  failure_url = binary_to_list(SettingsOld#pegasus_settings.failure_url)
  },
  TimestampNow = os:system_time(),
  Authenticationsignature = pegasus_signature:get_signature(string,Amount,PhoneNumber,Reason,TransactionId,Settings),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~w ~n",[Authenticationsignature]),
  ?debugFmt("Time spent string ~w ~n",[TimestampThen -TimestampNow]).