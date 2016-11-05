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
-include("../include/response.hrl").
-include("../include/PegPay.hrl").
%% API
-export([
  get_details/1,
  pay_bill/1,
  authenticate/1,
  check_transaction_status/1,
  confirmation_poll/1
]).

-spec(get_details(#payment{}) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
get_details(#payment{customer_id = CustomerId, type = BillID, transaction_id = TransactionId}) ->

  Settings = pegasus_env_util:get_settings(),
  {Bill, Param} = pegasus_util:get_type_and_param(BillID),
  Value = 'PegPay_client':'QueryCustomerDetails'(
    #'QueryCustomerDetails'{
      % Optional:
      query =
      #'QueryRequest'{
        % Optional:
        'QueryField1' = binary_to_list(CustomerId), %% CustomerRef/Id
        % Optional:
        'QueryField2' = Param,%%Kampala
        % Optional:
        'QueryField4' = Bill, %NWSC
        % Optional:
        'QueryField5' = Settings#pegasus_settings.api_username,
        % Optional:
        'QueryField6' = Settings#pegasus_settings.api_password
      }},
    _Soap_headers = [],
    _Soap_options = [{url, Settings#pegasus_settings.url}]),
  case Value of
    {ok, 200, _, _, _, _, ReturnedBody} ->
      BodyDecoded = xml_response:get_details_response(ReturnedBody),
      io:format("BodyDecoded ~w ~n", [BodyDecoded]),

      case BodyDecoded#query_details_response.status_code of
        <<"0">> ->
          Body = [
            {<<"TransactionRef">>, TransactionId},
            {<<"CustomerId">>, BodyDecoded#query_details_response.customer_ref},
            {<<"Biller">>, list_to_binary(Bill)},
            {<<"CustomerName">>, BodyDecoded#query_details_response.customer_name},
            {<<"PaymentItem">>,erlang:iolist_to_binary([ list_to_binary(Bill),<<" ">>, list_to_binary(Param)])},
            {<<"Balance">>, BodyDecoded#query_details_response.outstanding_balance},
            {<<"Area/BouquetCode">>, BodyDecoded#query_details_response.'Area/BouquetCode'},
            {<<"CustomerType">>, BodyDecoded#query_details_response.customer_type}
          ],
          {ok, {BodyDecoded#query_details_response.status_description, BodyDecoded#query_details_response.customer_name}, Body};

        StatusCode ->
          {error, pegasus_util:get_message(StatusCode, TransactionId), StatusCode}
      end;
    {ok, S1, _, E1} ->
      io:format("E1 ~w ~n", [E1]),
      io:format("S1 ~w ~n", [S1]),
      {error, <<"transaction initiation failed">>, E1};
    {error, Error} ->
      io:format("Error ~w ~n", [Error]),
      {error, <<"service provider unavailable, please try again">>, Error};
    Error2 ->
      io:format("Error ~w ~n", [Error2]),
      {error, <<"fatal error in making contact with service provider, please try again">>, Error2}

  end.
%% @doc
%%PostField1 CustomerRef(Utility CustomerID)
%%PostField2 Customer Name
%%PostField21 Customer Type e.g. PREPAID or POSTPAID etc.
%%PostField3 Area
%%PostField4 UtilityCode
%%PostField5 PaymentDate in dd/MM/yyyy e.g. 28/12/2015
%%PostField7 TransactionAmount
%%PostField8 TransactionType e.g. CASH,EFT etc.
%%PostField9 VendorCode
%%PostField10 Password
%%PostField11 CustomerTel
%%PostField12 Reversal (is 0 for Prepaid Vendors)
%%PostField13 TranIdToReverse(is left blank)
%%PostField14 Teller e.g. can be customerTel or customer Name
%%PostField15 Offline (is 0)
%%PostField16 DigitalSignature
%%PostField17 ChequeNumber(is left Empty)
%%PostField18 Narration
%%PostField19 Email(can be Empty)
%%PostField20 Vendor Transaction ID
%% @end
-spec(pay_bill(#payment{}) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
%% this is to test failure case
pay_bill(Payment = #payment{email = EmailRaw, amount = AmountRaw, customer_id = CustomerId, type = test_failed, transaction_id = TransactionIdRaw, phone_number = PhoneNumberRaw}) ->
  Settings = pegasus_env_util:get_settings(),
  {Bill, Param} = pegasus_util:get_type_and_param(<<"nswc_kampala">>),
  Amount = integer_to_list(AmountRaw),
  PaymentDate = pegasus_util:get_payment_date(),
  Narration = "Paying for " ++ Bill ++ " " ++ Param ++ " of " ++ Amount ++ " via chapchap",
  TransactionType = pegasus_util:get_transacion_type(Bill),
  PhoneNumber = binary_to_list(PhoneNumberRaw),
  TransactionId = binary_to_list(TransactionIdRaw),
  Email = binary_to_list(EmailRaw),

  Authenticationsignature = pegasus_signature:get_signature(
    CustomerId,
    PhoneNumber,
    TransactionId,
    Settings,
    PaymentDate,
    Amount,
    Narration,
    TransactionType
  ),
  error_logger:error_msg("Email ~w ~n",[Email]),
  error_logger:error_msg("Authenticationsignature ~w ~n",[Authenticationsignature]),
  Value = test_values:get_test_failed_value(),
    case Value of
    {ok, 200, _, _, _, _, ReturnedBody} ->
      BodyDecoded = xml_response:get_post_transaction_response(ReturnedBody),
      io:format("BodyDecoded ~w ~n", [BodyDecoded]),

      case BodyDecoded#post_transaction_response.status_code of
        <<"1000">> ->
          ResultPollStart = confirmation_poll(Payment),
          case ResultPollStart of
            {ok, _} ->
              Body = [
                {receipt_id, BodyDecoded#post_transaction_response.peg_pay_id},
                {status_code, BodyDecoded#post_transaction_response.status_code},
                {status_description, BodyDecoded#post_transaction_response.status_description}
              ],
              {ok, {BodyDecoded#post_transaction_response.status_description, BodyDecoded#post_transaction_response.peg_pay_id}, Body};
            {error, Error3} -> {error, <<"failed to initialize ">>, Error3}
          end;
        StatusCode ->
          {error, pegasus_util:get_message(StatusCode, TransactionId), StatusCode}
      end
  end;
%% this is to test success case
pay_bill(Payment = #payment{email = EmailRaw, amount = AmountRaw, customer_id = CustomerId, type = Type, transaction_id = TransactionIdRaw, phone_number = PhoneNumberRaw})
  when Type =:= test orelse Type =:= test_failed_poll ->
  Settings = pegasus_env_util:get_settings(),
  {Bill, Param} = pegasus_util:get_type_and_param(<<"nswc_kampala">>),
  Amount = integer_to_list(AmountRaw),
  PaymentDate = pegasus_util:get_payment_date(),
  Narration = "Paying for " ++ Bill ++ " " ++ Param ++ " of " ++ Amount ++ " via chapchap",
  TransactionType = pegasus_util:get_transacion_type(Bill),
  PhoneNumber = binary_to_list(PhoneNumberRaw),
  TransactionId = binary_to_list(TransactionIdRaw),
  Email = binary_to_list(EmailRaw),
  Authenticationsignature = pegasus_signature:get_signature(
    CustomerId,
    PhoneNumber,
    TransactionId,
    Settings,
    PaymentDate,
    Amount,
    Narration,
    TransactionType
  ),
  error_logger:error_msg("Email ~w ~n",[Email]),
  error_logger:error_msg("Authenticationsignature ~w ~n",[Authenticationsignature]),
  Value = test_values:get_test_success_value(),
  case Value of
    {ok, 200, _, _, _, _, ReturnedBody} ->
      BodyDecoded = xml_response:get_post_transaction_response(ReturnedBody),
      io:format("BodyDecoded ~w ~n", [BodyDecoded]),
      case BodyDecoded#post_transaction_response.status_code of
        <<"1000">> ->
          ResultPollStart = confirmation_poll(Payment),
          case ResultPollStart of
            {ok, _} ->
              Body = [
                {receipt_id, BodyDecoded#post_transaction_response.peg_pay_id},
                {status_code, BodyDecoded#post_transaction_response.status_code},
                {status_description, BodyDecoded#post_transaction_response.status_description}
              ],
              {ok, {BodyDecoded#post_transaction_response.status_description, BodyDecoded#post_transaction_response.peg_pay_id}, Body};
            {error, Error3} -> {error, <<"failed to initialize ">>, Error3}
          end;
        StatusCode ->
          {error, pegasus_util:get_message(StatusCode, TransactionId), StatusCode}
      end
  end;
pay_bill(Payment = #payment{email = EmailRaw, amount = AmountRaw, customer_id = CustomerId, type = BillID, transaction_id = TransactionIdRaw, phone_number = PhoneNumberRaw}) ->
  Settings = pegasus_env_util:get_settings(),
  {Bill, Param} = pegasus_util:get_type_and_param(BillID),
  Amount = integer_to_list(AmountRaw),
  PaymentDate = pegasus_util:get_payment_date(),
  Narration = "Paying for " ++ Bill ++ " " ++ Param ++ " of " ++ Amount ++ " via chapchap",
  TransactionType = pegasus_util:get_transacion_type(Bill),
  PhoneNumber = binary_to_list(PhoneNumberRaw),
  TransactionId = binary_to_list(TransactionIdRaw),
  Email = binary_to_list(EmailRaw),

%%  dataToSign (CustRef + CustName + CustomerTel +
%%    VendorTransactionID + VendorCode + Password + PaymentDate + Teller +
%%    TransactionAmount + Narration + TransactionType;) OR literally
%%(PostField1 + PostField2 + PostField11 + PostField20 + PostField9 + PostField10 +
%%PostField5 + PostField14 + PostField7 + PostField18 + PostField8)

  Authenticationsignature = pegasus_signature:get_signature(
    CustomerId,
    PhoneNumber,
    TransactionId,
    Settings,
    PaymentDate,
    Amount,
    Narration,
    TransactionType
  ),
  Value = 'PegPay_client':'PrepaidVendorPostTransaction'(
    #'PrepaidVendorPostTransaction'{
      % Optional:
      trans =
      #'TransactionRequest'{
        % Optional:
        'PostField1' = CustomerId#query_details_response.customer_ref,
        % Optional:
        'PostField2' = CustomerId#query_details_response.customer_name,
        % Optional:
        'PostField3' = Param,
        % Optional:
        'PostField4' = Bill, %% UtilityCode
        % Optional:
        'PostField5' = PaymentDate, %% payment date, dd/MM/yyyy
        % Optional:
        'PostField6' = "",
        % Optional:
        'PostField7' = Amount, %% amount
        % Optional:
        'PostField8' = TransactionType,%%PostField8 TransactionType e.g. CASH,EFT etc.
        % Optional:
        'PostField9' = Settings#pegasus_settings.api_username,
        % Optional:
        'PostField10' = Settings#pegasus_settings.api_password,
        % Optional:
        'PostField11' = PhoneNumber, %% CustomerTel
        % Optional:
        'PostField12' = "0",%%Reversal (is 0 for Prepaid Vendors)
        % Optional:
        'PostField13' = "",
        % Optional:
        'PostField14' = PhoneNumber, %%Teller e.g. can be customerTel or customer Name
        % Optional:
        'PostField15' = "0",%%Offline (is 0)
        % Optional:
        'PostField16' = Authenticationsignature, %DigitalSignature
        % Optional:
        'PostField17' = "",%ChequeNumber(is left Empty
        % Optional:
        'PostField18' = Narration,
        'PostField19' = Email,
        % Optional:
        'PostField20' = TransactionId,
        % Optional:
        'PostField21' = Param %%Customer Type e.g. PREPAID or POSTPAID etc.
      }},
    _Soap_headers = [],
    _Soap_options = [{url, Settings#pegasus_settings.url}]),
  case Value of
    {ok, 200, _, _, _, _, ReturnedBody} ->
      BodyDecoded = xml_response:get_post_transaction_response(ReturnedBody),
      io:format("BodyDecoded ~w ~n", [BodyDecoded]),

      case BodyDecoded#post_transaction_response.status_code of
        <<"1000">> ->
          ResultPollStart = confirmation_poll(Payment),
          case ResultPollStart of
            {ok, _} ->
              Body = [
                {receipt_id, BodyDecoded#post_transaction_response.peg_pay_id},
                {status_code, BodyDecoded#post_transaction_response.status_code},
                {status_description, BodyDecoded#post_transaction_response.status_description}
              ],
              {ok, {BodyDecoded#post_transaction_response.status_description, BodyDecoded#post_transaction_response.peg_pay_id}, Body};
            {error, Error3} -> {error, <<"failed to initialize ">>, Error3}
          end;
        StatusCode ->
          {error, pegasus_util:get_message(StatusCode, TransactionId), StatusCode}
      end;
    {ok, S1, _, E1} ->
      io:format("E1 ~w ~n", [E1]),
      io:format("S1 ~w ~n", [S1]),
      {error, <<"transaction initiation failed">>, E1};
    {error, Error} ->
      io:format("Error ~w ~n", [Error]),
      {error, <<"service provider unavailable, please try again">>, Error};
    Error2 ->
      io:format("Error ~w ~n", [Error2]),
      {error, <<"fatal error in making contact with service provider, please try again">>, Error2}
  end.

-spec(check_transaction_status(ExternalReference :: binary()) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_status(TransactionId) ->
  Settings = pegasus_env_util:get_settings(),
  Value = 'PegPay_client':'GetTransactionDetails'(
    #'GetTransactionDetails'{
      % Optional:
      query =
      #'QueryRequest'{
        'QueryField5' = Settings#pegasus_settings.api_username,
        % Optional:
        'QueryField6' = Settings#pegasus_settings.api_password,
        'QueryField10' = binary_to_list(TransactionId)}},
    _Soap_headers = [],
    _Soap_options = [{url, Settings#pegasus_settings.url}]),
  case Value of
    {ok, 200, _, _, _, _, ReturnedBody} ->
      BodyDecoded = xml_response:get_status_response(ReturnedBody),
      io:format("BodyDecoded ~w ~n", [BodyDecoded]),

      case BodyDecoded#get_status_response.status_code of
        <<"0">> ->
          Body = [
            {status_code, BodyDecoded#get_status_response.status_code},
            {status_description, BodyDecoded#get_status_response.status_description},
            {receipt, BodyDecoded#get_status_response.receipt}
          ],
          {ok, {BodyDecoded#get_status_response.status_description, BodyDecoded#get_status_response.receipt}, Body};
        <<"1000">> ->
          {pending, pegasus_util:get_message(<<"1000">>, TransactionId), BodyDecoded};
        StatusCode ->
          {error, pegasus_util:get_message(StatusCode, TransactionId), StatusCode}
      end;
    {ok, S1, _, E1} ->
      io:format("E1 ~w ~n", [E1]),
      io:format("S1 ~w ~n", [S1]),
      {error, <<"transaction initiation failed">>, E1};
    {error, Error} ->
      io:format("Error ~w ~n", [Error]),
      {error, <<"service provider unavailable, please try again">>, Error};
    Error2 ->
      io:format("Error ~w ~n", [Error2]),
      {error, <<"fatal error in making contact with service provider, please try again">>, Error2}

  end.

-spec(check_transaction_test(ExternalReference :: binary()) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_test(_) ->

  Body = [
    {status_code, "0"},
    {status_description, "SUCCESS"},
    {receipt, "qo8u02u0s903"}
  ],
  {ok, {"SUCCESS", "qo8u02u0s903"}, Body}.

-spec(check_transaction_test_pending(ExternalReference :: binary()) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_test_pending(ExternalReference) ->

  {error, pegasus_util:get_message("1000", ExternalReference), "1000"}.

-spec(check_transaction_test_failed(ExternalReference :: binary()) ->
  {ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}).
check_transaction_test_failed(ExternalReference) ->

  {error, pegasus_util:get_message("100", ExternalReference), "100"}.


%% @doc this is called to authenticate the signature of pegasus
-spec(authenticate(#core_request{}) -> ok | {error, Error :: term()}).
authenticate(Request) ->
  case application:get_env(test) of
    {ok, false} -> authenticate(production, Request);
    {ok, true} -> authenticate(test, Request);
    _ -> authenticate(test, Request)
  end.

authenticate(test, _Request) ->
  ok;
authenticate(production, #core_request{args_list = ArgsList}) ->
  try
    Signature = lists:keyfind(<<"signature">>, 1, ArgsList),
    Decrypted = pegasus_signature:decrypt(Signature),
    {ok, DateTime} = lists:keyfind(<<"date_time">>, 1, ArgsList),
    {ok, Amount} = lists:keyfind(<<"amount">>, 1, ArgsList),
    {ok, Narrative} = lists:keyfind(<<"narrative">>, 1, ArgsList),
    {ok, NetworkRef} = lists:keyfind(<<"network_ref">>, 1, ArgsList),
    {ok, ExternalRef} = lists:keyfind(<<"external_ref">>, 1, ArgsList),

    Decrypted =:= erlang:iolist_to_binary([DateTime, Amount, Narrative, NetworkRef, ExternalRef])
  of
    true -> ok;
    false -> {error, <<"signature authentiacation failed">>}
  catch
    _X:_Y ->
      {error, <<"signature authentiacation failed">>}
  end.

confirmation_poll(Payment = #payment{phone_number = _PhoneNumber, archive = Archive, long_poll_fun = Type, start_after = StartAfter, poll_interval = Interval, max = Max}) ->
  StartPoll = periodic_sup:start_periodic(
    #periodic_state{
      task = fun poll/1,
      data = Payment,
      type = Type,
      start_after = StartAfter,
      interval = Interval,
      max = Max
    }
  ),

  %% attempt to start the asynchronous process
  case StartPoll of
    {ok, Pid, Name} ->
      %% attempt to run the asynchronous process
      Archive(<<"async process polling started">>, {Pid, Name}),
      {ok, Pid};
    Error1 ->
      Archive(<<"async process polling failed to start">>, Error1),
      {error, Error1}
  end.

poll(PeriodicState = #periodic_state{type = test, number_of_calls = N}) ->
  if
    N < 3 -> poll_internal(fun check_transaction_test_pending/1, PeriodicState);
    true -> poll_internal(fun check_transaction_test/1, PeriodicState)
  end;
poll(PeriodicState = #periodic_state{type = test_failed_poll}) ->
  poll_internal(fun check_transaction_test_failed/1, PeriodicState);
poll(PeriodicState) ->
  poll_internal(fun check_transaction_status/1, PeriodicState).
poll_internal(CheckStatusFunction, PeriodicState = #periodic_state{data = Payment}) ->
  Archive = Payment#payment.archive,
  ConfirmCallback = Payment#payment.on_confirm_callback,
  OnFailureCallback = Payment#payment.on_indeterminate_callback,
  case CheckStatusFunction(Payment#payment.transaction_id) of
    {ok, {_Description, Receipt}, BodyDecoded} ->
      Archive(<<"transaction SUCCEEDED">>, BodyDecoded),
      ConfirmCallback([{<<"receipt">>, Receipt}]),
      PeriodicState#periodic_state{stop = true};
    {pending, _, Body} ->
      Archive(<<"still pending">>, Body),
      PeriodicState;
    {error, Body, <<"1000">>} ->
      Archive(<<"checking status">>, Body),
      PeriodicState;
    {error, Message, <<"100">>} ->
      OnFailureCallback([{<<"error_message">>, <<" ">>}]),
      Archive(<<"transaction FAILED">>, Message),
      PeriodicState#periodic_state{stop = true};
    {error, Messagex, _} ->
      OnFailureCallback([{<<"error_message">>, Messagex}]),
      Archive(<<"transaction ERROR">>, Messagex),
      PeriodicState#periodic_state{stop = true}
  end.