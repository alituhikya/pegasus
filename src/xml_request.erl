%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Jul 2016 10:59 AM
%%%-------------------------------------------------------------------
-module(xml_request).
-author("mb-spare").
-include("../include/pegasus_app_common.hrl").

%% API
-export([get_request/2,get_check_status_request/1]).

-spec(get_request(Method :: atom(),Request :: #'AutoCreate/Request'{} ) -> binary()).
get_request(manual,#'AutoCreate/Request'{
    'APIPassword' = APIPassword,
    'APIUsername' = APIUsername,
    'Method' = Method,
    'NonBlocking' =NonBlocking,
    'Amount' = Amount,
    'Account' = Account,
    'AccountProviderCode' = AccountProviderCode,
    'Narrative' = Narrative,
    'ExternalReference' = ExternalReference,
    'ProviderReferenceText' = ProviderReferenceText,
    'InstantNotificationUrl' = InstantNotificationUrl,
    'FailureNotificationUrl' = FailureNotificationUrl,
    'AuthenticationSignatureBase64' = AuthenticationSignatureBase64
})->

   erlang:iolist_to_binary([
   <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>">>,
    <<"<AutoCreate>">>,<<"<Request>">>,
    <<"<APIUsername>">>, APIUsername, <<"</APIUsername>">>,
    <<"<APIPassword>">>,APIPassword,<<"</APIPassword>">>,
    <<"<Method>">>, Method,<<"</Method>">>,
    <<"<NonBlocking>">> ,NonBlocking,<<"</NonBlocking>">>,
    <<"<Amount>">>, Amount,<<"</Amount>">>,
    <<"<Account>">>,Account,<<"</Account>">>,
    <<"<AccountProviderCode>">> , AccountProviderCode,<<"</AccountProviderCode>">>,
    <<"<Narrative>">>, Narrative,<<"</Narrative>">>,
    <<"<ExternalReference>">>, ExternalReference,<<"</ExternalReference>">>,
    <<"<ProviderReferenceText>">> ,ProviderReferenceText,<<"</ProviderReferenceText>">>,
    <<"<InstantNotificationUrl>">>, InstantNotificationUrl, <<"</InstantNotificationUrl>">>,
    <<"<FailureNotificationUrl>">>, FailureNotificationUrl,<<"</FailureNotificationUrl>">>,
    <<"<AuthenticationSignatureBase64>">>, AuthenticationSignatureBase64,<<"</AuthenticationSignatureBase64>">>,
    <<"</Request>">>,<<"</AutoCreate>">>
    ])
;
get_request(erlsom,Request)->
  RequestRecord = #'AutoCreate'{'Request' = Request},
  {ok, ModelIn} = erlsom:compile_xsd_file(pegasus_util:get_file("deposit.xsd"),[]),
  {ok,Payload} = erlsom:write(RequestRecord, ModelIn),
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" ++Payload.


-spec(get_check_status_request(Request :: #check_transaction_status{} ) -> binary()).
get_check_status_request(#check_transaction_status{
  'APIPassword' = APIPassword,
  'APIUsername' = APIUsername,
  'Method' =  Method,
  'PrivateTransactionReference'= PrivateTransactionReference
})->

  erlang:iolist_to_binary([
    <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>">>,
    <<"<AutoCreate>">>,<<"<Request>">>,
    <<"<APIUsername>">>, APIUsername, <<"</APIUsername>">>,
    <<"<APIPassword>">>,APIPassword,<<"</APIPassword>">>,
    <<"<Method>">>, Method,<<"</Method>">>,
    <<"<PrivateTransactionReference>">> ,PrivateTransactionReference,<<"</PrivateTransactionReference>">>,
    <<"</Request>">>,<<"</AutoCreate>">>
  ]).