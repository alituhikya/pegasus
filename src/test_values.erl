%%%-------------------------------------------------------------------
%%% @author james
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Nov 2016 2:50 AM
%%%-------------------------------------------------------------------
-module(test_values).
-author("james").

%% API
-export([get_test_success_value/0,get_test_failed_value/0]).

get_test_success_value()->
  {ok,200,
    [{"Cache-Control","private, max-age=0"},
      {"Content-Type","text/xml; charset=utf-8"},
      {"Server","Microsoft-IIS/8.0"},
      {"X-AspNet-Version","4.0.30319"},
      {"X-Powered-By","ASP.NET"},
      {"Date","Fri, 04 Nov 2016 23:48:12 GMT"},
      {"Content-Length","548"}],
    [],
    {'PrepaidVendorPostTransactionResponse',
      {'Response',undefined,undefined,undefined,undefined,undefined,"1000",
        "PENDING","80137840",undefined,undefined,undefined,undefined,
        undefined}},
    [],
    <<"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><PrepaidVendorPostTransactionResponse xmlns=\"http://PegPayPaymentsApi/\"><PrepaidVendorPostTransactionResult><ResponseField6>1000</ResponseField6><ResponseField7>PENDING</ResponseField7><ResponseField8>80137840</ResponseField8></PrepaidVendorPostTransactionResult></PrepaidVendorPostTransactionResponse></soap:Body></soap:Envelope>">>}.

get_test_failed_value()->
   {ok,200,
    [{"Cache-Control","private, max-age=0"},
      {"Content-Type","text/xml; charset=utf-8"},
      {"Server","Microsoft-IIS/8.0"},
      {"X-AspNet-Version","4.0.30319"},
      {"X-Powered-By","ASP.NET"},
      {"Date","Fri, 04 Nov 2016 22:03:38 GMT"},
      {"Content-Length","543"}],
    [],
    {'PrepaidVendorPostTransactionResponse',
      {'Response',undefined,undefined,undefined,undefined,undefined,"100",
        "DUPLICATE VENDOR REFERENCE",[],undefined,undefined,undefined,
        undefined,undefined}},
    [],
    <<"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap:Body><PrepaidVendorPostTransactionResponse xmlns=\"http://PegPayPaymentsApi/\"><PrepaidVendorPostTransactionResult><ResponseField6>100</ResponseField6><ResponseField7>DUPLICATE VENDOR REFERENCE</ResponseField7><ResponseField8 /></PrepaidVendorPostTransactionResult></PrepaidVendorPostTransactionResponse></soap:Body></soap:Envelope>">>}.