%%%-------------------------------------------------------------------
%%% @author james
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Feb 2016 5:26 PM
%%%-------------------------------------------------------------------
-module(pegasus_env_util).
-author("james").

-include("../include/pegasus_app_common.hrl").
%% API
% "07C06VC857"
% "https://test.pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx?WSDL"
% "https://197.221.144.222:8019/TestPegPayApi/PegPay.asmx"
% application:set_env(pegasus,pegasus_url,"https://test.pegasus.co.ug:8019/TestPegPayApi/PegPay.asmx?WSDL").
% application:set_env(pegasus,pegasus_apipassword,"07C06VC857").
-export([get_settings/0,get_alarm_emails/0,get_private_key/0,test/0]).
get_settings() ->
  #pegasus_settings{
    api_username =  application:get_env(pegasus,pegasus_apiusername,"CHAPCHAP"), %"CHAPCHAP"
    api_password =  application:get_env(pegasus,pegasus_apipassword,"84Y56LO654"), %  "07C06VC857"
    url = application:get_env(pegasus,pegasus_url,"https://pegasus.co.ug:8896/LivePegPayApi/PegPay.asmx"),
    private_key_password = application:get_env(private_key_password,"chap4yopayments")
  }.

get_alarm_emails() ->
  {ok, Emails} = case application:get_env(pegasus,alarm_emails) of
                        undefined -> {ok,[<<"james.alituhikya@gmail.com">>,<<"maali.toni@gmail.com">>,<<"lydia.ashaba@gmail.com">>]};
                        A -> A
                      end,
  Emails.

get_private_key() ->
   case application:get_env(pegasus,private_key) of
                   undefined -> {error,not_set};
                       {ok, PrivateKey}  ->  {ok, PrivateKey}
   end.

%% default value is prod, ie no test
test()->
  application:get_env(pegasus,test,prod).