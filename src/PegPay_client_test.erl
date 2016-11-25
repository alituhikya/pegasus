-module('PegPay_client_test').
-compile(export_all).

-include("../include/PegPay.hrl").
-include("../include/pegasus_app_common.hrl").
-include("../../core/include/core_app_common.hrl").
-include("../include/response.hrl").


'GetServerStatus'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),
    application:start(ibrowse),
    application:start(fast_xml),
    {ok,200,_,_,_,_,ReturnedBody}  =   'PegPay_client':'GetServerStatus'(
        #'GetServerStatus'{
},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]),
    pegasus_xml_response:get_response(ReturnedBody).

'GetTransactionDetails'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
    Settings = pegasus_env_util:get_settings(),
    Response = 'PegPay_client':'GetTransactionDetails'(
        #'GetTransactionDetails'{
            % Optional:
            query = 
                #'QueryRequest'{
                    'QueryField5' = Settings#pegasus_settings.api_username,
                    % Optional:
                    'QueryField6' = Settings#pegasus_settings.api_password,
                    'QueryField10' = "my id"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"},{timeout, 60000}]),
    file:write_file("/tmp/response.xml", io_lib:fwrite("~p.\n", [Response]))
.

'QuerySchoolDetails'() -> 
    'PegPay_client':'QuerySchoolDetails'(
        #'QuerySchoolDetails'{
            % Optional:
            query = 
                #'QueryRequest'{
                    % Optional:
                    'QueryField1' = "?",
                    % Optional:
                    'QueryField2' = "?",
                    % Optional:
                    'QueryField3' = "?",
                    % Optional:
                    'QueryField4' = "?",
                    % Optional:
                    'QueryField5' = "?",
                    % Optional:
                    'QueryField6' = "?",
                    % Optional:
                    'QueryField7' = "?",
                    % Optional:
                    'QueryField8' = "?",
                    % Optional:
                    'QueryField9' = "?",
                    % Optional:
                    'QueryField10' = "?"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]).

'QueryCustomerDetails'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
   Response =  'PegPay_client':'QueryCustomerDetails'(
        #'QueryCustomerDetails'{
            % Optional:
            query = 
                #'QueryRequest'{
                    % Optional:
                    'QueryField1' = "11111", %% CustomerRef/Id
                    % Optional:
                    'QueryField2' = "Kampala",
                    % Optional:
                    'QueryField4' = "NWSC",
                    % Optional:
                    'QueryField5' = "CHAPCHAP",
                    % Optional:
                    'QueryField6' = "07C06VC857"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]),
    file:write_file("/tmp/response.xml", io_lib:fwrite("~p.\n", [Response]))
.


'PostTransaction'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
    Settings = pegasus_env_util:get_settings(),
    {Bill, Param} = pegasus_util:get_type_and_param(<<"nswc_kampala">>),
    Amount  = integer_to_list(10000),
    PaymentDate = pegasus_util:get_payment_date(),
    Narration = "Paying for "++Bill ++ " "++ Param ++ " of " ++Amount ++ " via chapchap",
    TransactionType =pegasus_util:get_transacion_type(Bill),
    PhoneNumber =binary_to_list(<<"256756719888">>),
    TransactionId = "my id",

%%  dataToSign (CustRef + CustName + CustomerTel +
%%    VendorTransactionID + VendorCode + Password + PaymentDate + Teller +
%%    TransactionAmount + Narration + TransactionType;) OR literally
%%(PostField1 + PostField2 + PostField11 + PostField20 + PostField9 + PostField10 +
%%PostField5 + PostField14 + PostField7 + PostField18 + PostField8)

    Authenticationsignature = pegasus_signature:get_signature(
        #query_details_response{customer_ref = "11111",customer_name = "KAHANGIRE STEPHEN"},
        PhoneNumber,
        TransactionId,
        Settings,
        PaymentDate,
        Amount,
        Narration,
        TransactionType
    ),
   Response = 'PegPay_client':'PostTransaction'(
        #'PostTransaction'{
            % Optional:
            trans = 
                #'TransactionRequest'{
                    % Optional:
                    'PostField1' = "11111",
                    % Optional:
                    'PostField2' = "KAHANGIRE STEPHEN",
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
                    'PostField11' =PhoneNumber, %% CustomerTel
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
                    'PostField19' = "james.alituhikya@gmail.com",
                    % Optional:
                    'PostField20' = TransactionId,
                    % Optional:
                    'PostField21' = Param %%Customer Type e.g. PREPAID or POSTPAID etc.
                }},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]),
    file:write_file("/tmp/response.xml", io_lib:fwrite("~p.\n", [Response]))
.

'GetPayTVBouquetDetails'() -> 
    'PegPay_client':'GetPayTVBouquetDetails'(
        #'GetPayTVBouquetDetails'{
            % Optional:
            query = 
                #'QueryRequest'{
                    % Optional:
                    'QueryField1' = "?",
                    % Optional:
                    'QueryField2' = "?",
                    % Optional:
                    'QueryField3' = "?",
                    % Optional:
                    'QueryField4' = "?",
                    % Optional:
                    'QueryField5' = "?",
                    % Optional:
                    'QueryField6' = "?",
                    % Optional:
                    'QueryField7' = "?",
                    % Optional:
                    'QueryField8' = "?",
                    % Optional:
                    'QueryField9' = "?",
                    % Optional:
                    'QueryField10' = "?"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]).

'ReactivatePayTvCard'() -> 
    'PegPay_client':'ReactivatePayTvCard'(
        #'ReactivatePayTvCard'{
            % Optional:
            query = 
                #'QueryRequest'{
                    % Optional:
                    'QueryField1' = "?",
                    % Optional:
                    'QueryField2' = "?",
                    % Optional:
                    'QueryField3' = "?",
                    % Optional:
                    'QueryField4' = "?",
                    % Optional:
                    'QueryField5' = "?",
                    % Optional:
                    'QueryField6' = "?",
                    % Optional:
                    'QueryField7' = "?",
                    % Optional:
                    'QueryField8' = "?",
                    % Optional:
                    'QueryField9' = "?",
                    % Optional:
                    'QueryField10' = "?"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]).

%%'UploadEndOfDayReport'() ->
%%    'PegPay_client':'UploadEndOfDayReport'(
%%        #'UploadEndOfDayReport'{
%%            % Optional:
%%            lstOfTrans =
%%                #'ArrayOfEODTransaction'{
%%                    % List with zero or more elements:
%%                    'EODTransaction' = [
%%                        #'EODTransaction'{
%%                            % Optional:
%%                            'VendorTranId' = "?",
%%                            % Optional:
%%                            'Amount' = "?",
%%                            % Optional:
%%                            'DateTime' = "?"}]},
%%            % Optional:
%%            'VendorCode' = "?",
%%            % Optional:
%%            'Password' = "?"},
%%    _Soap_headers = [],
%%    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]).

'PrepaidVendorPostTransaction'() ->

    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
    Settings = pegasus_env_util:get_settings(),
    {Bill, Param} = pegasus_util:get_type_and_param(<<"nswc_kampala">>),
    Amount  = integer_to_list(10000),
    PaymentDate = pegasus_util:get_payment_date(),
    Narration = "Paying for "++Bill ++ " "++ Param ++ " of " ++Amount ++ " via chapchap",
    TransactionType =pegasus_util:get_transacion_type(Bill),
    PhoneNumber =binary_to_list(<<"256756719888">>),
    TransactionId = "new id",

%%  dataToSign (CustRef + CustName + CustomerTel +
%%    VendorTransactionID + VendorCode + Password + PaymentDate + Teller +
%%    TransactionAmount + Narration + TransactionType;) OR literally
%%(PostField1 + PostField2 + PostField11 + PostField20 + PostField9 + PostField10 +
%%PostField5 + PostField14 + PostField7 + PostField18 + PostField8)

    Authenticationsignature = pegasus_signature:get_signature(
        #query_details_response{customer_ref = "11111",customer_name = "KAHANGIRE STEPHEN"},
        PhoneNumber,
        TransactionId,
        Settings,
        PaymentDate,
        Amount,
        Narration,
        TransactionType
    ),
    Response =
        'PegPay_client':'PrepaidVendorPostTransaction'(
        #'PrepaidVendorPostTransaction'{
            % Optional:
            trans = 
                #'TransactionRequest'{
                    % Optional:
                    'PostField1' = "11111",
                    % Optional:
                    'PostField2' = "KAHANGIRE STEPHEN",
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
                    'PostField11' =PhoneNumber, %% CustomerTel
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
                    'PostField19' = "james.alituhikya@gmail.com",
                    % Optional:
                    'PostField20' = TransactionId,
                    % Optional:
                    'PostField21' = Param %%Customer Type e.g. PREPAID or POSTPAID etc.
                }},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]),
    file:write_file("/tmp/response.xml", io_lib:fwrite("~p.\n", [Response]))
.

'ReversePrepaidTransaction'() -> 
    'PegPay_client':'ReversePrepaidTransaction'(
        #'ReversePrepaidTransaction'{
            % Optional:
            trans = 
                #'TransactionRequest'{
                    % Optional:
                    'PostField1' = "?",
                    % Optional:
                    'PostField2' = "?",
                    % Optional:
                    'PostField3' = "?",
                    % Optional:
                    'PostField4' = "?",
                    % Optional:
                    'PostField5' = "?",
                    % Optional:
                    'PostField6' = "?",
                    % Optional:
                    'PostField7' = "?",
                    % Optional:
                    'PostField8' = "?",
                    % Optional:
                    'PostField9' = "?",
                    % Optional:
                    'PostField10' = "?",
                    % Optional:
                    'PostField11' = "?",
                    % Optional:
                    'PostField12' = "?",
                    % Optional:
                    'PostField13' = "?",
                    % Optional:
                    'PostField14' = "?",
                    % Optional:
                    'PostField15' = "?",
                    % Optional:
                    'PostField16' = "?",
                    % Optional:
                    'PostField17' = "?",
                    % Optional:
                    'PostField18' = "?",
                    % Optional:
                    'PostField19' = "?",
                    % Optional:
                    'PostField20' = "?",
                    % Optional:
                    'PostField21' = "?",
                    % Optional:
                    'PostField22' = "?",
                    % Optional:
                    'PostField23' = "?",
                    % Optional:
                    'PostField24' = "?",
                    % Optional:
                    'PostField25' = "?",
                    % Optional:
                    'PostField26' = "?",
                    % Optional:
                    'PostField27' = "?",
                    % Optional:
                    'PostField28' = "?",
                    % Optional:
                    'PostField29' = "?",
                    % Optional:
                    'PostField30' = "?",
                    % Optional:
                    'PostField31' = "?",
                    % Optional:
                    'PostField32' = "?",
                    % Optional:
                    'PostField33' = "?",
                    % Optional:
                    'PostField34' = "?"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"}]).

