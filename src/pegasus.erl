%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Jul 2016 5:11 PM
%%%-------------------------------------------------------------------
-module(pegasus).
-author("mb-spare").

-include("../include/pegasus_app_common.hrl").
-include("../../core/include/core_app_common.hrl").
-include("../include/response_not_shared.hrl").
%% API
-export([
  deposit/1,
  deposit_test/1,
  authenticate/1,
  withdraw/1,
  send_money/2,
  check_transaction_status/1,
  check_transaction_status_withdraw/1,
  confirmation_poll/1,
  large_interval_poll/1

]).

-spec(deposit(#payment{})->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
deposit(Payment = #payment{amount =Amount, phone_number = PhoneNumber,network = Network,reason = Reason,transaction_id = TransactionId}) ->

Settings =  pegasus_env_util:get_settings(),
%%  Settings = case Network of
%%               mtn -> pegasus_env_util:get_settings_withdraw();
%%               airtel -> pegasus_env_util:get_settings()
%%             end,


  Authenticationsignature = pegasus_signature:get_signature(binary,Amount,PhoneNumber,Reason,TransactionId,Settings),
  AutoCreateRecord = #'AutoCreate/Request'{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "acdepositfunds",
    'NonBlocking' = "TRUE", %% inquiry
    'Amount' = Amount,
    'Account' = PhoneNumber,
    'AccountProviderCode' = pegasus_util:get_network_code(Network),
    'Narrative' = Reason,
    'ExternalReference' = TransactionId,
    'ProviderReferenceText' = Reason,
    'InstantNotificationUrl' =Settings#pegasus_settings.notification_url,
    'FailureNotificationUrl' = Settings#pegasus_settings.failure_url,
    'AuthenticationSignatureBase64' = Authenticationsignature
  },
  Method = post,
  URL = Settings#pegasus_settings.payment_url,
  Headers = [{<<"Content-Type">>, <<"text/xml">>}, {<<"Content-transfer-encoding">>, <<"text">>}],
  Options = [],
  RE = xml_request:get_request(manual,AutoCreateRecord),
  Value = ibrowse:send_req(URL,Headers,Method,binary_to_list(RE),Options,60000),
  case Value of
    {ok,"200",_,ReturnedBody}  ->
      BodyDecoded= xml_response:get_response(fast_xml,list_to_binary(ReturnedBody)),
      io:format("BodyDecoded ~w ~n",[BodyDecoded]),

      case BodyDecoded#'Response'.'Status' of
        <<"OK">> ->
          ResultPollStart = confirmation_poll(Payment),
          case ResultPollStart of
            {ok,_}->{ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded};
            {error,Error3}-> {error,<<"failed to initialize ">>,Error3}
          end;
        <<"ERROR">> ->
          case BodyDecoded#'Response'.'TransactionStatus'  of
            <<"FAILED">> ->
              {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
            <<"INDETERMINATE">> ->
              {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
          end
      end;
    {ok,S1,_,E1} ->
      io:format("E1 ~w ~n",[E1]),
      io:format("S1 ~w ~n",[S1]),
      {error, <<"transaction initiation failed">>,E1};
    {error, Error}->
      io:format("Error ~w ~n",[Error]),
      {error,<<"service provider unavailable, please try again">>,Error};
    Error2 ->
      io:format("Error ~w ~n",[Error2]),
      {error,<<"fatal error in making contact with service provider, please try again">>,Error2}

  end.


-spec(deposit_test(#payment{})->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
deposit_test(Payment = #payment{amount =Amount, phone_number = PhoneNumber,network = Network,reason = Reason,transaction_id = TransactionId}) ->
  Settings = case Network of
               mtn -> pegasus_env_util:get_settings_withdraw();
               airtel -> pegasus_env_util:get_settings()
             end,

  Authenticationsignature = pegasus_signature:get_signature(binary,Amount,PhoneNumber,Reason,TransactionId,Settings),
  AutoCreateRecord = #'AutoCreate/Request'{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "acdepositfunds",
    'NonBlocking' = "TRUE", %% inquiry
    'Amount' = Amount,
    'Account' = PhoneNumber,
    'AccountProviderCode' = pegasus_util:get_network_code(Network),
    'Narrative' = Reason,
    'ExternalReference' = TransactionId,
    'ProviderReferenceText' = Reason,
    'InstantNotificationUrl' =Settings#pegasus_settings.notification_url,
    'FailureNotificationUrl' = Settings#pegasus_settings.failure_url,
    'AuthenticationSignatureBase64' = Authenticationsignature
  },
  error_logger:error_msg("deposit_test AutoCreateRecord ~w ~n",[AutoCreateRecord]),
  BodyDecoded =#'Response'{'TransactionStatus' = <<"SUCCESS">>,
    'TransactionReference' = TransactionId,
    'Status' = <<"OK">>,
    'StatusMessage' = <<"SUCCESS">>
  },
  case BodyDecoded#'Response'.'Status' of
    <<"OK">> ->
      ResultPollStart = confirmation_poll(Payment),
      case ResultPollStart of
        {ok,_}->{ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded};
        {error,Error3}-> {error,<<"failed to initialize ">>,Error3}
      end;
    <<"ERROR">> ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
        <<"INDETERMINATE">> ->
          {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
      end
  end.
-spec(withdraw(#payment{})->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
withdraw(#payment{amount =Amount, phone_number = PhoneNumber,network = Network,reason = Reason,transaction_id = TransactionId}) ->
  Settings = pegasus_env_util:get_settings_withdraw(),
  Authenticationsignature = pegasus_signature:get_signature(binary,Amount,PhoneNumber,Reason,TransactionId,Settings),
  AutoCreateRecord = #'AutoCreate/Request'{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "acwithdrawfunds",
    'NonBlocking' = "TRUE", %% inquiry
    'Amount' = Amount,
    'Account' = PhoneNumber,
    'AccountProviderCode' = pegasus_util:get_network_code(Network),
    'Narrative' = Reason,
    'ExternalReference' = TransactionId,
    'ProviderReferenceText' = Reason,
    'InstantNotificationUrl' =Settings#pegasus_settings.notification_url,
    'FailureNotificationUrl' = Settings#pegasus_settings.failure_url,
    'AuthenticationSignatureBase64' = Authenticationsignature
  },
  Method = post,
  URL = Settings#pegasus_settings.payment_url,
  Headers = [{<<"Content-Type">>, <<"text/xml">>}, {<<"Content-transfer-encoding">>, <<"text">>}],
  Options = [{timeout, 30000}],
  RE = xml_request:get_request(manual,AutoCreateRecord),
  Value = ibrowse:send_req(URL,Headers,Method,binary_to_list(RE),Options,60000),
  case Value of
    {ok,"200",_,ReturnedBody}  ->
      BodyDecoded= xml_response:get_response(fast_xml,list_to_binary(ReturnedBody)),
      io:format("BodyDecoded ~w ~n",[BodyDecoded]),

      case BodyDecoded#'Response'.'Status' of
        <<"OK">> ->
          {ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded}
        ;
        <<"ERROR">> ->
          case BodyDecoded#'Response'.'TransactionStatus'  of
            <<"FAILED">> ->
              {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
            <<"INDETERMINATE">> ->
              {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
          end
      end;
    {ok,S1,_,E1} ->
      io:format("E1 ~w ~n",[E1]),
      io:format("S1 ~w ~n",[S1]),
      {error, <<"transaction initiation failed">>,E1};
    {error, Error}->
      io:format("Error ~w ~n",[Error]),
      {error,<<"service provider unavailable, please try again">>,Error};
    Error2 ->
      io:format("Error ~w ~n",[Error2]),
      {error,<<"fatal error in making contact with service provider, please try again">>,Error2}
  end.

-spec(check_transaction_status(ExternalReference :: binary())->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_status(ExternalReference) ->
  Settings = pegasus_env_util:get_settings(),
  AutoCreateRecord = #check_transaction_status{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "actransactioncheckstatus",
    'PrivateTransactionReference' = ExternalReference
  },
  Method = post,
  URL = Settings#pegasus_settings.payment_url,
  Headers = [{<<"Content-Type">>, <<"text/xml">>}, {<<"Content-transfer-encoding">>, <<"text">>}],
  Options = [{timeout, 30000}],
  RE = xml_request:get_check_status_request(AutoCreateRecord),
  Value = ibrowse:send_req(URL,Headers,Method,binary_to_list(RE),Options,60000),
  case Value of
    {ok,"200",_,ReturnedBody}  ->
      BodyDecoded= xml_response:get_response(fast_xml,list_to_binary(ReturnedBody)),
      io:format("BodyDecoded ~w ~n",[BodyDecoded]),

      case BodyDecoded#'Response'.'Status' of
        <<"OK">> ->
          {ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded};
        <<"ERROR">> ->
          case BodyDecoded#'Response'.'TransactionStatus'  of
            <<"FAILED">> ->
              {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
            <<"INDETERMINATE">> ->
              {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
          end
      end;
    {ok,S1,_,E1} ->
      io:format("E1 ~w ~n",[E1]),
      io:format("S1 ~w ~n",[S1]),
      {error, <<"transaction initiation failed">>,E1};
    {error, Error}->
      io:format("Error ~w ~n",[Error]),
      {error,<<"service provider unavailable, please try again">>,Error};
    Error2 ->
      io:format("Error ~w ~n",[Error2]),
      {error,<<"fatal error in making contact with service provider, please try again">>,Error2}

  end.


-spec(check_transaction_status_withdraw(ExternalReference :: binary())->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_status_withdraw(ExternalReference) ->
  Settings = pegasus_env_util:get_settings_withdraw(),
  AutoCreateRecord = #check_transaction_status{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "actransactioncheckstatus",
    'PrivateTransactionReference' = ExternalReference
  },
  Method = post,
  URL = Settings#pegasus_settings.payment_url,
  Headers = [{<<"Content-Type">>, <<"text/xml">>}, {<<"Content-transfer-encoding">>, <<"text">>}],
  Options = [{timeout, 30000}],
  RE = xml_request:get_check_status_request(AutoCreateRecord),
  Value = ibrowse:send_req(URL,Headers,Method,binary_to_list(RE),Options,60000),
  case Value of
    {ok,"200",_,ReturnedBody}  ->
      BodyDecoded= xml_response:get_response(fast_xml,list_to_binary(ReturnedBody)),
      io:format("BodyDecoded ~w ~n",[BodyDecoded]),

      case BodyDecoded#'Response'.'Status' of
        <<"OK">> ->
          {ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded};
        <<"ERROR">> ->
          case BodyDecoded#'Response'.'TransactionStatus'  of
            <<"FAILED">> ->
              {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
            <<"INDETERMINATE">> ->
              {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
          end
      end;
    {ok,S1,_,E1} ->
      io:format("E1 ~w ~n",[E1]),
      io:format("S1 ~w ~n",[S1]),
      {error, <<"transaction initiation failed">>,E1};
    {error, Error}->
      io:format("Error ~w ~n",[Error]),
      {error,<<"service provider unavailable, please try again">>,Error};
    Error2 ->
      io:format("Error ~w ~n",[Error2]),
      {error,<<"fatal error in making contact with service provider, please try again">>,Error2}

  end.

-spec(check_transaction_test(ExternalReference :: binary())->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_test(ExternalReference) ->
  Settings = pegasus_env_util:get_settings(),
  AutoCreateRecord = #check_transaction_status{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "actransactioncheckstatus",
    'PrivateTransactionReference' = ExternalReference
  },
  error_logger:error_msg("check_transaction_test AutoCreateRecord ~w ~n",[AutoCreateRecord]),
  BodyDecoded =#'Response'{'TransactionStatus' = <<"SUCCEEDED">>,
    'TransactionReference' = ExternalReference,
    'Status' = <<"OK">>,
    'StatusMessage' = <<"SUCCESS">>
  },
  case BodyDecoded#'Response'.'Status' of
    <<"OK">> ->
      {ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded}
    ;
    <<"ERROR">> ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
        <<"INDETERMINATE">> ->
          {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
      end
  end.

-spec(check_transaction_test_unknown(ExternalReference :: binary())->
  {ok, Message :: binary(),Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_test_unknown(ExternalReference) ->
  Settings = pegasus_env_util:get_settings(),
  AutoCreateRecord = #check_transaction_status{
    'APIPassword' = Settings#pegasus_settings.api_password,
    'APIUsername' = Settings#pegasus_settings.api_username,
    'Method' = "actransactioncheckstatus",
    'PrivateTransactionReference' = ExternalReference
  },
  error_logger:error_msg("check_transaction_test_unknown AutoCreateRecord ~w ~n",[AutoCreateRecord]),
  BodyDecoded =#'Response'{'TransactionStatus' = <<"INDETERMINATE">>,
    'TransactionReference' = ExternalReference,
    'Status' = <<"ERROR">>,
    'StatusMessage' = <<"INDETERMINATE">>
  },
  case BodyDecoded#'Response'.'Status' of
    <<"OK">> ->
      {ok,{BodyDecoded#'Response'.'TransactionStatus',BodyDecoded#'Response'.'TransactionReference'},BodyDecoded}
    ;
    <<"ERROR">> ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          {error, BodyDecoded#'Response'.'StatusMessage',BodyDecoded};
        <<"INDETERMINATE">> ->
          {unknown, BodyDecoded#'Response'.'StatusMessage',BodyDecoded}
      end
  end.


%% @doc this is called to authenticate the signature of pegasus
-spec(authenticate(#core_request{})-> ok | {error, Error :: term()}).
authenticate(Request) ->
  case application:get_env(test) of
    {ok, false}->authenticate(production,Request);
    {ok,true}->authenticate(test,Request);
    _->authenticate(test,Request)
  end.

authenticate(test,_Request)->
  ok;
authenticate(production,#core_request{args_list = ArgsList})->
  try
    Signature = lists:keyfind(<<"signature">>, 1, ArgsList),
    Decrypted =pegasus_signature:decrypt(Signature),
    {ok,DateTime} = lists:keyfind(<<"date_time">>, 1, ArgsList),
    {ok,Amount} = lists:keyfind(<<"amount">>, 1, ArgsList),
    {ok,Narrative} = lists:keyfind(<<"narrative">>, 1, ArgsList),
    {ok,NetworkRef} = lists:keyfind(<<"network_ref">>, 1, ArgsList),
    {ok,ExternalRef} = lists:keyfind(<<"external_ref">>, 1, ArgsList),

    Decrypted =:= erlang:iolist_to_binary([DateTime,Amount,Narrative,NetworkRef,ExternalRef])
  of
    true -> ok;
    false -> {error,<<"signature authentiacation failed">>}
  catch
    _X:_Y ->
      {error,<<"signature authentiacation failed">>}
  end.

send_money(PhoneNumber,Amount)->
  pegasus:withdraw(#payment{amount =Amount, phone_number = PhoneNumber,
    network = number_manipulator:get_network(PhoneNumber),reason = "chapchap",transaction_id = "anId"}).

confirmation_poll(Payment = #payment{phone_number = _PhoneNumber,archive = Archive,long_poll_fun = Type,start_after = StartAfter,poll_interval = Interval,max = Max})->
  StartPoll = periodic_sup:start_periodic(
    #periodic_state{
      task = fun poll/1,
      data = Payment,
      type = Type,
      start_after =StartAfter,
      interval = Interval,
      max =Max
    }
  ),

  %% attempt to start the asynchronous process
  case StartPoll of
    {ok, Pid,Name} ->
      %% attempt to run the asynchronous process
      Archive(<<"async process polling started">>, {Pid,Name}),
      {ok,Pid};
    Error1 ->
      Archive(<<"async process polling failed to start">>, Error1),
      {error,Error1}
  end.

poll(PeriodicState = #periodic_state{type = test})->
  poll_internal(fun check_transaction_test/1,PeriodicState);
poll(PeriodicState = #periodic_state{type = test_unknown,number_of_calls = N})->
  if
    N < 3 -> poll_internal(fun check_transaction_test_unknown/1,PeriodicState);
    true ->  poll_internal(fun check_transaction_test/1,PeriodicState)
  end;

poll(PeriodicState)->
  poll_internal(fun check_transaction_status/1,PeriodicState).
poll_internal(CheckStatusFunction,PeriodicState = #periodic_state{data = Payment,number_of_calls = N})->
  Archive = Payment#payment.archive,
  ConfirmCallback =Payment#payment.on_confirm_callback,
  IndeterminatCallback = Payment#payment.on_indeterminate_callback,
  case CheckStatusFunction(Payment#payment.transaction_id) of
    {ok,_,BodyDecoded} ->
      case BodyDecoded#'Response'.'TransactionStatus' of
        <<"SUCCEEDED">> ->
          Archive(<<"transaction SUCCEEDED">>,BodyDecoded),
          ConfirmCallback(),
          PeriodicState#periodic_state{stop = true};
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          IndeterminatCallback(),
          PeriodicState#periodic_state{stop = true};
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {unknown, _,BodyDecoded} when is_record(BodyDecoded,'Response') ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          IndeterminatCallback(),
          PeriodicState#periodic_state{stop = true};
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {error, _,BodyDecoded} when is_record(BodyDecoded,'Response') ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          IndeterminatCallback(),
          PeriodicState#periodic_state{stop = true};
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {error,ErrorMessage,Error}->
      Archive(erlang:iolist_to_binary([<<"failed to confirm transaction tries: ">>,integer_to_binary(N)]),[Error,ErrorMessage]),
      PeriodicState
  end.


large_interval_poll(Payment = #payment{phone_number = _PhoneNumber,archive = Archive,
  poll_interval = Interval, start_after = StartAfter,max = Max,long_poll_fun = Type
})->
  LagePollFun = case Type of
                  deposit ->fun large_poll_deposit/1;
                  withdraw -> fun large_poll_withdraw/1;
                  test -> fun large_poll_test/1;
                  test_unknown -> fun large_poll_test_unknown/1
                end,

  StartPoll = periodic_sup:start_periodic(
    #periodic_state{
      task = LagePollFun,
      data = Payment,
      type = custom,
      start_after = StartAfter,
      interval = Interval,
      max = Max%% for approximately 6 minutes

    }
  ),

  %% attempt to start the asynchronous process
  case StartPoll of
    {ok, Pid,Name} ->
      %% attempt to run the asynchronous process
      Archive(<<"async process polling started">>, {Pid,Name}),
      {ok,Pid};
    Error1 ->
      Archive(<<"async process polling failed to start">>, Error1),
      {error,Error1}
  end.

large_poll_withdraw(PeriodicState)->
  large_poll(fun check_transaction_status_withdraw/1,PeriodicState).
large_poll_deposit(PeriodicState)->
  large_poll(fun check_transaction_status/1,PeriodicState).
large_poll_test(PeriodicState = #periodic_state{number_of_calls = N})->
  if
    N < 3 -> large_poll(fun check_transaction_test_unknown/1,PeriodicState);
    true ->  large_poll(fun check_transaction_test/1,PeriodicState)
  end.
large_poll_test_unknown(PeriodicState)->
  large_poll(fun check_transaction_test_unknown/1,PeriodicState).

large_poll(Function,PeriodicState = #periodic_state{data = Payment,number_of_calls = N})->
  Archive = Payment#payment.archive,
  ConfirmCallback =Payment#payment.on_confirm_callback,
  case Function(Payment#payment.transaction_id) of
    {ok,_,BodyDecoded} ->
      case BodyDecoded#'Response'.'TransactionStatus' of
        <<"SUCCEEDED">> ->
          Archive(<<"transaction SUCCEEDED">>,BodyDecoded),
          ConfirmCallback(),
          PeriodicState#periodic_state{stop = true};
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          PeriodicState;
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {unknown, _,BodyDecoded} when is_record(BodyDecoded,'Response') ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          PeriodicState;
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {error, _,BodyDecoded} when is_record(BodyDecoded,'Response') ->
      case BodyDecoded#'Response'.'TransactionStatus'  of
        <<"FAILED">> ->
          Archive(<<"transaction FAILED">>,BodyDecoded),
          PeriodicState#periodic_state{stop = true};
        <<"INDETERMINATE">> ->
          Archive(<<"transaction INDETERMINATE">>,BodyDecoded),
          PeriodicState;
        _ ->  Archive(<<"checking status">>,BodyDecoded),
          PeriodicState
      end;
    {error,ErrorMessage,Error}->
      Archive(erlang:iolist_to_binary([<<"failed to confirm transaction tries: ">>,integer_to_binary(N)]),[Error,ErrorMessage]),
      PeriodicState
  end.
