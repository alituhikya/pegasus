-module('PegPay_client_test_1').
-compile(export_all).

-include("../include/PegPay.hrl").


'GetServerStatus'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
    {ok,200,_,_,_,_,ReturnedBody}  =  'PegPay_client':'GetServerStatus'(
        #'GetServerStatus'{
},
    _Soap_headers = [],
    _Soap_options = [{url,"https://41.190.131.222:8896/testpegpayapi/PegPay.asmx"}]),
pegasus_xml_response:get_response(ReturnedBody)
.

'GetTransactionDetails'() -> 
    'PegPay_client':'GetTransactionDetails'(
        #'GetTransactionDetails'{
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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

'QueryCustomerDetails'() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),application:start(ibrowse),
    application:start(fast_xml),
    {ok,200,_,_,_,_,ReturnedBody}  =   'PegPay_client':'QueryCustomerDetails'(
        #'QueryCustomerDetails'{
            % Optional:
            query = 
                #'QueryRequest'{
                    % Optional:
                    'QueryField1' = "2167527", %% CustomerRef/Id
                    % Optional:
                    'QueryField2' = "Kampala",
                    % Optional:
                    'QueryField3' = "?",
                    % Optional:
                    'QueryField4' = "NWSC",
                    % Optional:
                    'QueryField5' = "CHAPCHAP",
                    % Optional:
                    'QueryField6' = "07C06VC857",
                    % Optional:
                    'QueryField7' = "?",
                    % Optional:
                    'QueryField8' = "?",
                    % Optional:
                    'QueryField9' = "?",
                    % Optional:
                    'QueryField10' = "?"}},
    _Soap_headers = [],
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]),
    pegasus_xml_response:get_response(fast_xml,ReturnedBody)
.

'PostTransaction'() -> 
    'PegPay_client':'PostTransaction'(
        #'PostTransaction'{
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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

'UploadEndOfDayReport'() -> 
    'PegPay_client':'UploadEndOfDayReport'(
        #'UploadEndOfDayReport'{
            % Optional:
            lstOfTrans = 
                #'ArrayOfEODTransaction'{
                    % List with zero or more elements:
                    'EODTransaction' = [
                        #'EODTransaction'{
                            % Optional:
                            'VendorTranId' = "?",
                            % Optional:
                            'Amount' = "?",
                            % Optional:
                            'DateTime' = "?"}]},
            % Optional:
            'VendorCode' = "?",
            % Optional:
            'Password' = "?"},
    _Soap_headers = [],
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

'PrepaidVendorPostTransaction'() -> 
    'PegPay_client':'PrepaidVendorPostTransaction'(
        #'PrepaidVendorPostTransaction'{
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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

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
    _Soap_options = [{url,"https://pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx"}]).

