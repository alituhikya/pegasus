%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Jul 2016 11:24 AM
%%%-------------------------------------------------------------------
-module(xml_request_tests).
-author("mb-spare").
-include("../include/pegasus_app_common.hrl").
-include_lib("eunit/include/eunit.hrl").

manual()->
Settings = pegasus_env_util:get_settings(),
  TimestampNow = os:system_time(),
  Amount = <<"2000">>,
  PhoneNumber = <<"256788718757">>,
  TransactionId = <<"an id">>,
  Reason = <<" a reason">>,
  Authenticationsignature = pegasus_signature:get_signature(binary,Amount,PhoneNumber,Reason,TransactionId,Settings),
  AutoCreateRecord = #'AutoCreate/Request'{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = <<"acdepositfunds">>,
    'NonBlocking' = <<"TRUE">>, %% inquiry
    'Amount' = Amount,
    'Account' = PhoneNumber,
    'AccountProviderCode' = <<"mtn">>,
    'Narrative' = Reason,
    'ExternalReference' = TransactionId,
    'ProviderReferenceText' = <<"a reason">>,
    'InstantNotificationUrl' = Settings#pegasus_settings.notification_url,
    'FailureNotificationUrl' = Settings#pegasus_settings.failure_url,
    'AuthenticationSignatureBase64' = Authenticationsignature
  },


  Value = xml_request:get_request(manual,AutoCreateRecord),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~p ~n",[Value]),
  ?debugFmt("Time spent with manual ~w ~n",[TimestampThen -TimestampNow]),
  Value.



erlsom()->
  SettingsOld = pegasus_env_util:get_settings(),
  TimestampNow = os:system_time(),
  Amount = "2000",
  PhoneNumber = "256788718757",
  TransactionId = "an id",
  Reason = " a reason",
  Settings = SettingsOld#pegasus_settings{api_password =binary_to_list(SettingsOld#pegasus_settings.api_password),
  api_username =  binary_to_list(SettingsOld#pegasus_settings.api_username),
  notification_url = binary_to_list(SettingsOld#pegasus_settings.notification_url),
  failure_url = binary_to_list(SettingsOld#pegasus_settings.failure_url)
  },
  Authenticationsignature = pegasus_signature:get_signature(string,Amount,PhoneNumber,Reason,TransactionId,Settings),
  AutoCreateRecord = #'AutoCreate/Request'{
    'APIPassword' = (Settings#pegasus_settings.api_password),
    'APIUsername' = (Settings#pegasus_settings.api_username),
    'Method' = "acdepositfunds",
    'NonBlocking' = "TRUE", %% inquiry
    'Amount' = Amount,
    'Account' = PhoneNumber,
    'AccountProviderCode' = "mtn",
    'Narrative' = Reason,
    'ExternalReference' =TransactionId,
    'ProviderReferenceText' = Reason,
    'InstantNotificationUrl' = (Settings#pegasus_settings.notification_url),
    'FailureNotificationUrl' = (Settings#pegasus_settings.failure_url),
    'AuthenticationSignatureBase64' = Authenticationsignature
  },
  Value = xml_request:get_request(erlsom,AutoCreateRecord),
  TimestampThen = os:system_time(),
  ?debugFmt("Value ~p ~n",[Value]),
  ?debugFmt("Time spent with erlsom ~w ~n",[TimestampThen -TimestampNow]),
  Value.
erlsom_test() ->
erlsom()
.
manual_test() ->
  manual()
.

erlsom2_test() ->
  erlsom()
.
manual2_test() ->
  manual()
.

equality_test()->
 Value = manual(),
  ValueString = binary_to_list(Value),

  {ok, ModelOut} = erlsom:compile_xsd_file(pegasus_util:get_file("deposit.xsd"), []),
  ?debugFmt("xml : ~w",[ ValueString]),
  {ok,BodyDecoded,_} = erlsom:scan(ValueString,ModelOut),
  ?assert(is_record(BodyDecoded,'AutoCreate')),
  Request = BodyDecoded#'AutoCreate'.'Request',
  ?debugFmt("equlity ~w ~n",[Request]).
