%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% To generate the signature concatenate the following
%% parameters in order:
%% 1. APIUsername
%% 2. APIPassword
%% 3. Amount
%% 4. Account
%% 5. Narrative
%% 6. ExternalReference
%% 7. the source IP address where the request originates
%% Next, obtain an SHA1 hash of the above string.
%% Then, encrypt the SHA1 hash you have obtained using your
%%% @end
%%% Created : 01. Jul 2016 5:23 PM
%%%-------------------------------------------------------------------
-module(pegasus_util).
-author("mb-spare").
-define(INTERNAL_ERROR, <<"An error occurred, please contact support if this error persits">>).

%% API
-export([get_type_and_param/1,get_file/1,get_message/2,get_payment_date/0,get_transacion_type/1,get_message/3]).
-include("../include/pegasus_app_common.hrl").

%% @doc yo payments has codes for different networks, this function returns those based on the the network provided
-spec(get_type_and_param(BillType :: atom())-> Code :: string()).
get_type_and_param(<<"postpaid_umeme">>) ->
  {"UMEME","POSTPAID"};
%% Prepaid Umeme
get_type_and_param(<<"prepaid_umeme">>) ->
  {"UMEME","PREPAID"};
%% NWSC Entebbe

%% old bill ids were mis-spelt but we keep them for backward compatibility
get_type_and_param(<<"nswc_entebbe">>) ->
  {"NWSC", "Entebbe"};
%% NWSC Iganga
get_type_and_param(<<"nswc_iganga">>) ->
  {"NWSC","Iganga"};
%% NWSC Jinja 249373
get_type_and_param(<<"nswc_jinja">>) ->
  {"NWSC","Jinja"};
%% NWSC Kajjansi 249374
get_type_and_param(<<"nswc_kajjansi">>) ->
  {"NWSC","Kajjansi"};
%% NWSC Kampala 249371
get_type_and_param(<<"nswc_kampala">>) ->
  {"NWSC","Kampala"};
%% NWSC Kawuku
get_type_and_param(<<"nswc_kawuku">>) ->
  {"NWSC","Kawuku"};
%% NWSC Lugazi
get_type_and_param(<<"nswc_lugazi">>) ->
  {"NWSC","Lugazi"};
%% NWSC Mukono 249378
get_type_and_param(<<"nswc_mukono">>) ->
  {"NWSC","Mukono"};
%% Other NWSC Areas 249379
get_type_and_param(<<"nswc_other_areas">>) ->
  {"NWSC","Others"};



%% new bill ids  for NWSC with correct spelling
get_type_and_param(<<"nwsc_entebbe">>) ->
  {"NWSC", "Entebbe"};
%% NWSC Iganga
get_type_and_param(<<"nwsc_iganga">>) ->
  {"NWSC","Iganga"};
%% NWSC Jinja 249373
get_type_and_param(<<"nwsc_jinja">>) ->
  {"NWSC","Jinja"};
%% NWSC Kajjansi 249374
get_type_and_param(<<"nwsc_kajjansi">>) ->
  {"NWSC","Kajjansi"};
%% NWSC Kampala 249371
get_type_and_param(<<"nwsc_kampala">>) ->
  {"NWSC","Kampala"};
%% NWSC Kawuku
get_type_and_param(<<"nwsc_kawuku">>) ->
  {"NWSC","Kawuku"};
%% NWSC Lugazi
get_type_and_param(<<"nwsc_lugazi">>) ->
  {"NWSC","Lugazi"};
%% NWSC Mukono 249378
get_type_and_param(<<"nwsc_mukono">>) ->
  {"NWSC","Mukono"};
%% Other NWSC Areas 249379
get_type_and_param(<<"nwsc_other_areas">>) ->
  {"NWSC","Others"};




%% DStv Access &#40;38,000&#47;&#61;&#41; 21552
get_type_and_param(<<"dstv_access">>) ->
{"DSTV",""};
%% DStv Asia &#40;131,250&#47;&#61;&#41; 21553
get_type_and_param(<<"dstv_asia">>) ->
{"DSTV",""};
%% DStv Family &#40;73,000&#47;&#61;&#41; 21551
get_type_and_param(<<"dstv_family">>) ->
{"DSTV",""};
%% DStv Compact Plus &#40;225,000&#47;&#61;&#41; 21549
get_type_and_param(<<"dstv_compact_plus">>) ->
{"DSTV",""};
%% DStv Compact &#40;128,000&#47;&#61;&#41; 21550
get_type_and_param(<<"dstv_compact">>) ->
{"DSTV",""};
%% DStv Premium with Dual View &#40;375,250&#47;&#61;&#41; 215459
get_type_and_param(<<"dstv_premium_with_dual_view">>) ->
{"DSTV",""};
%% DStv Premium &#43; ASIA &#40;356,250&#47;&#61;&#41; 215460
get_type_and_param(<<"dstv_premium_ASIA">>) ->
{"DSTV",""};
%% DStv Premium &#40;334,000&#47;&#61;&#41; 21548
get_type_and_param(<<"dstv_premium">>) ->
{"DSTV",""};
%% DStv Premium HD&#47;SD PVR &#40;375,250&#47;&#61;&#41; 215462
get_type_and_param(<<"dstv_premium_HD_SD_PVR">>) ->
{"DSTV",""};
%% GOTV Lite  21546
get_type_and_param(<<"gotv_Lite">>) ->
{"GOTV",""};
%%  &#9;GOtv standard &#40;20,000&#47;&#61;&#41; 21554
get_type_and_param(<<"gotv_standard">>) ->
{"GOTV",""};
%% GOtv Plus &#40;28,000&#47;&#61;&#41; 21555
get_type_and_param(<<"gotv_plus">>) ->
{"GOTV",""}.

get_transacion_type("UMEME") ->
  "CASH";
get_transacion_type("DSTV") ->
  "CASH";
get_transacion_type("NWSC") ->
  "CASH";
get_transacion_type(_) ->
  "CASH".


get_file(FileName)->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/" ++ FileName;
    PrivDir -> filename:absname(PrivDir)++ "/" ++ FileName
  end.

get_message(<<"100">>,_TransactionRef, <<"FAILED: SUSPECTED DOUBLE POSTING AT PEGASUS">>)->
  <<"This transaction has already been posted">>;
get_message(<<"100">>,_TransactionRef,  <<"INVALID PHONE NUMBER">>)->
  <<"Invalid customer phone number">>;
get_message(<<"100">>,_TransactionRef, <<"INVALID TRANSACTION AMOUNT">>)->
  <<"INVALID TRANSACTION AMOUNT">>;
get_message(<<"100">>,_TransactionRef, <<"INVALID PAYMENT DATE">>)->
  <<"INVALID PAYMENT DATE">>;
get_message(<<"100">>,TransactionRef, <<"INVALID TRANSACTION TYPE">>)->
  send_alarm(<<"INVALID TRANSACTION TYPE">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,_TransactionRef, <<"INVALID CUSTOMER TELEPHONE">>)->
  <<"INVALID CUSTOMER TELEPHONE">>;
get_message(<<"100">>,TransactionRef,  <<"INVALID PAYMENT TYPE">>)->
  send_alarm(<<"INVALID PAYMENT TYPE">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"TELLER DETAILS REQUIRED">>)->
  send_alarm(  <<"TELLER DETAILS REQUIRED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,_TransactionRef,  <<"TRANSACTION DETAILS ALREADY RECEIVED">>)->
  <<"TRANSACTION DETAILS ALREADY RECEIVED">>;
get_message(<<"100">>,_TransactionRef,  <<"GENERAL ERROR AT Utility">>)->
  <<"GENERAL ERROR AT Utility">>;
get_message(<<"100">>,TransactionRef,  <<"VENDOR CREDENTIALS HAVE BEEN DEACTIVATED.PLEASE CONTACT PEGASUS TECHNOLOGIES">>)->
  send_alarm(<<"VENDOR CREDENTIALS HAVE BEEN DEACTIVATED.PLEASE CONTACT PEGASUS TECHNOLOGIES">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,_TransactionRef, <<"INVALID PHONE NUMBER">>)->
  <<"INVALID PHONE NUMBER">>;
get_message(<<"100">>,_TransactionRef,<<"INVALID CUSTOMER REFERENCE">>)->
  <<"INVALID CUSTOMER METRE/ACCOUNT NUMBER">>;
get_message(<<"100">>,TransactionRef,<<"CUSTOMER NAME NOT SUPPLIED">>)->
  send_alarm(<<"CUSTOMER NAME NOT SUPPLIED">>,TransactionRef),
 ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"TRANSACTION TYPE NOT SUPPLIED. EG CASH,EFT">>)->
  send_alarm(<<"TRANSACTION TYPE NOT SUPPLIED. EG CASH,EFT">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"PAYMENT TYPE NOT SUPPLIED. EG 2,3,4">>)->
  send_alarm(<<"PAYMENT TYPE NOT SUPPLIED. EG 2,3,4">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>)->
  send_alarm(<<"VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"TELLER DETAILS NOT SUPPLIED">>)->
  send_alarm(<<"TELLER DETAILS NOT SUPPLIED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"SIGNATURE NOT VALID AT PEGPAY">>)->
  send_alarm(<<"SIGNATURE NOT VALID AT PEGPAY">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"SIGNATURE NOT PROVIDED">>)->
  send_alarm(<<"SIGNATURE NOT PROVIDED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"DUPLICATE VENDOR REFERENCE AT PEGPAY">>)->
  send_alarm(<<"DUPLICATE VENDOR REFERENCE AT PEGPAY">>,TransactionRef),
  <<"duplicate transaction">>;
get_message(<<"100">>,_TransactionRef,  <<"SUSPECTED DOUBLE POSTING AT PEGPAY">>)->
  <<"SUSPECTED DOUBLE POSTING">>;
get_message(<<"100">>,TransactionRef, <<"ORIGINAL VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>)->
  send_alarm(<<"ORIGINAL VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"TRANSACTION NARATION IS REQUIRED">>)->
  send_alarm(<<"TRANSACTION NARATION IS REQUIRED">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"INVALID ORIGINAL VENDOR TRANSACTION REFERENCE">>)->
  send_alarm( <<"INVALID ORIGINAL VENDOR TRANSACTION REFERENCE">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"INVALID TRANSACTION REVERSAL STATUS SUPPLIED. EG 0 or 1">>)->
  send_alarm(<<"INVALID TRANSACTION REVERSAL STATUS SUPPLIED. EG 0 or 1">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"AMOUNT TO REVERSE DOES NOT MATCH WITH AMOUNT REVERSING">>)->
  send_alarm(<<"AMOUNT TO REVERSE DOES NOT MATCH WITH AMOUNT REVERSING">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"INVALID PAYMENT CODE">>)->
  send_alarm(<<"INVALID PAYMENT CODE">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"INVALID CUSTOMER TYPE EG POSTPAID or PREPAID">>)->
  send_alarm(<<"INVALID CUSTOMER TYPE EG POSTPAID or PREPAID">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"UTILITY CREDENTIALS NOT SET">>)->
  send_alarm(<<"UTILITY CREDENTIALS NOT SET">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"UNABLE TO CONNECT TO UTILITY">>)->
  send_alarm(<<"UNABLE TO CONNECT TO UTILITY">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"PEGPAY DB UNAVAILABLE">>)->
  send_alarm(<<"PEGPAY DB UNAVAILABLE">>,TransactionRef),
  <<"Service provider temporarily unavailable, please try again">>;
get_message(<<"100">>,TransactionRef,  <<"GENERAL ERROR AT PEGPAY">>)->
  send_alarm( <<"GENERAL ERROR AT PEGPAY">>,TransactionRef),
  <<"General Error at service provider">>;
get_message(<<"100">>,TransactionRef, <<"TRANSACTION DOESN'T EXIST IN PEGPAY">>)->
  send_alarm(<<"TRANSACTION DOESN'T EXIST IN PEGPAY">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef,  <<"INVALID TIN">>)->
  send_alarm(<<"INVALID TIN">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"PLEASE SUPPLY AN AREA FOR (Water) PAYMENTS">>)->
  send_alarm( <<"PLEASE SUPPLY AN AREA FOR (Water) PAYMENTS">>,TransactionRef),
  <<"PLEASE SUPPLY AN AREA FOR (Water) PAYMENTS">>;
get_message(<<"100">>,TransactionRef,  <<"INSUFFICIENT VENDOR ACCOUNT BALANCE">>)->
  send_alarm(<<"INSUFFICIENT VENDOR ACCOUNT BALANCE">>,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"100">>,TransactionRef, <<"GENERAL ERROR AT PEGPAY">>)->
  send_alarm(<<"GENERAL ERROR AT PEGPAY">>,TransactionRef),
  <<"General Error at service provider">>;
get_message(<<"100">>,TransactionRef,  <<"UNKNOWN URA PAYMENT TYPE">>)->
  send_alarm(<<"UNKNOWN URA PAYMENT TYPE">>,TransactionRef),
  <<"UNKNOWN URA PAYMENT TYPE">>;
get_message(Code,_TransactionRef,_)->
  get_message(Code,_TransactionRef).


get_message(<<"0">>,_TransactionRef)->
<<"SUCCESS">>;
get_message(<<"1000">>,_TransactionRef)->
  <<"PENDING">>;
get_message(<<"100">>,_)->
  <<"FAILED">>;
get_message(<<"1">>,_TransactionRef)-> _Title  = <<"INVALID CUSTOMER REFERENCE">>,
  <<"Invalid account number">>;
get_message(<<"200">>,_TransactionRef)->_Title  = <<"INVALID CUSTOMER REFERENCE">>,
  <<"Invalid account number">>;
get_message(<<"2">>,TransactionRef )->
  Title  = <<"INVALID PEGPAY VENDOR CREDENTIALS">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;

get_message(<<"3">>,_TransactionRef )->Title  = <<"INVALID TRANSACTION AMOUNT">>,
  Title;
get_message(<<"4">>,_TransactionRef )->Title  = <<"INVALID PAYMENT DATE">>,
  Title;
get_message(<<"5">>,TransactionRef )->Title  = <<"INVALID TRANSACTION TYPE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"6">>,TransactionRef )->Title  = <<"INVALID CUSTOMER TELEPHONE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"7">>,TransactionRef )->Title  = <<"INVALID PAYMENT TYPE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"8">>,TransactionRef )->Title  = <<"TELLER DETAILS REQUIRED">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"9">>,_TransactionRef )->Title  = <<"TRANSACTION DETAILS ALREADY RECEIVED">>,
  Title;
get_message(<<"10">>,_TransactionRef )->Title  = <<"GENERAL ERROR AT Utility">>,
  Title;
get_message(<<"11">>,TransactionRef )->Title  = <<"VENDOR CREDENTIALS HAVE BEEN DEACTIVATED.PLEASE CONTACT PEGASUS TECHNOLOGIES">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"12">>,TransactionRef )->Title  = <<"INVALID PHONE NUMBER">>,
  send_alarm(Title,TransactionRef),
  Title;
get_message(<<"13">>,TransactionRef )->Title  = <<"CUSTOMER NAME NOT SUPPLIED">>,
  send_alarm(Title,TransactionRef),
  Title;
get_message(<<"14">>,TransactionRef )->Title  = <<"TRANSACTION TYPE NOT SUPPLIED. EG CASH,EFT">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"15">>,TransactionRef )->Title  = <<"PAYMENT TYPE NOT SUPPLIED. EG 2,3,4">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"16">>,TransactionRef )->Title  = <<"VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"17">>,TransactionRef )->Title  = <<"TELLER DETAILS NOT SUPPLIED">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"18">>,TransactionRef )->Title  = <<"SIGNATURE NOT VALID AT PEGPAY">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"19">>,TransactionRef )->Title  = <<"SIGNATURE NOT PROVIDED">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"20">>,TransactionRef )->Title  = <<"DUPLICATE VENDOR REFERENCE AT PEGPAY">>,
  send_alarm(Title,TransactionRef),
  <<"duplicate transaction">>;
get_message(<<"21">>,_TransactionRef )-> _T = <<"SUSPECTED DOUBLE POSTING AT PEGPAY">>,
  <<"SUSPECTED DOUBLE POSTING">>;
get_message(<<"22">>,TransactionRef )->Title  = <<"ORIGINAL VENDOR TRANSACTION REFERENCE NOT SUPPLIED">>,
  send_alarm(Title,TransactionRef),
?INTERNAL_ERROR;
get_message(<<"23">>,TransactionRef )->Title  = <<"TRANSACTION NARATION IS REQUIRED">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"24">>,TransactionRef )->Title  = <<"INVALID ORIGINAL VENDOR TRANSACTION REFERENCE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"25">>,TransactionRef )->Title  = <<"INVALID TRANSACTION REVERSAL STATUS SUPPLIED. EG 0 or 1">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"26">>,TransactionRef )->Title  = <<"AMOUNT TO REVERSE DOES NOT MATCH WITH AMOUNT REVERSING">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"27">>,TransactionRef )->Title  = <<"INVALID PAYMENT CODE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"28">>,TransactionRef )->Title  = <<"INVALID CUSTOMER TYPE EG POSTPAID or PREPAID">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"29">>,TransactionRef )->Title  = <<"UTILITY CREDENTIALS NOT SET">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"30">>,TransactionRef )->Title  = <<"UNABLE TO CONNECT TO UTILITY">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"31">>,TransactionRef )->Title  = <<"PEGPAY DB UNAVAILABLE">>,
  send_alarm(Title,TransactionRef),
  <<"Service provider temporarily unavailable, please try again">>;
get_message(<<"32">>,TransactionRef )->Title  = <<"GENERAL ERROR AT PEGPAY">>,
  send_alarm(Title,TransactionRef),
  <<"General Error at service provider">>;
get_message(<<"33">>,TransactionRef )->Title  = <<"TRANSACTION DOESN'T EXIST IN PEGPAY">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"34">>,_TransactionRef )->Title  = <<"INVALID TIN">>,
  Title;
get_message(<<"35">>,TransactionRef )->Title  = <<"PLEASE SUPPLY AN AREA FOR (Water) PAYMENTS">>,
  send_alarm(Title,TransactionRef),
  Title;
get_message(<<"41">>,TransactionRef )->Title  = <<"INSUFFICIENT VENDOR ACCOUNT BALANCE">>,
  send_alarm(Title,TransactionRef),
  ?INTERNAL_ERROR;
get_message(<<"101">>,TransactionRef )->Title  = <<"GENERAL ERROR AT PEGPAY">>,
  send_alarm(Title,TransactionRef),
  <<"General Error at service provider">>;
get_message(<<"100">>,TransactionRef )->Title  = <<"UNKNOWN URA PAYMENT TYPE">>,
  send_alarm(Title,TransactionRef),
  Title;
get_message(StatusCode,TransactionRef ) ->
  send_alarm(StatusCode,TransactionRef),
  <<"An error occured">>.


%%INVALID BOUQUET FOR DSTV
%%INVALID UTILITY REFERENCE NUMBER
%%FAILED TO GET BOUQUET DETAILS


send_alarm(Title,Message) ->
core_emailer:send_mail_gun(
Message,
Title,
<<"alarm@chapchap.co">>,
<<"alarm">>,
pegasus_env_util:get_alarm_emails(),
<<"Suppoprt">>).

% dd/MM/yyyy e.g. 28/12/2015
get_payment_date()->
  TimeNow = os:timestamp(),
  {{Y,M,D},_} = calendar:now_to_local_time(TimeNow),
  YYYY = integer_to_list(Y),
  Mraw = integer_to_list(M),
  MrawLenth = length(Mraw),
  MM = if
         MrawLenth =:= 1 ->
           "0" ++ Mraw;
         true -> Mraw
       end,
  Draw = integer_to_list(D),
  DrawLength = length(Draw),
  DD = if
         DrawLength =:= 1 ->
           "0" ++ Draw;
         true -> Draw
       end,
  DD ++ "/" ++ MM ++"/"++YYYY.

