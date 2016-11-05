%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Feb 2016 5:26 PM
%%%-------------------------------------------------------------------
-module(pegasus_env_util).
-author("mb-spare").

-include("../include/pegasus_app_common.hrl").
%% API
-export([get_settings/0,get_alarm_emails/0,get_private_key/0]).
get_settings() ->
  {ok, ApiUsername} = case application:get_env(pegasus,pegasus_apiusername) of
                        undefined -> {ok, "CHAPCHAP"};
                        A -> A
                      end,
  {ok, APIPassword} = case application:get_env(pegasus,pegasus_apipassword) of
                        undefined -> {ok, "07C06VC857"};
                        B -> B
                      end,
  {ok, Url} = case application:get_env(pegasus,pegasus_url) of
                undefined -> {ok, "https://197.221.144.222:8019/TestLevelOneApi/PegPay.asmx"};
                E -> E
              end,
  {ok, PrivateKey} = case application:get_env(private_key_password) of
                       undefined -> {ok, "chap4yopayments"};
                       F -> F
                     end,

  #pegasus_settings{api_username =  ApiUsername, api_password =  APIPassword,
    url = Url, private_key_password=PrivateKey
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