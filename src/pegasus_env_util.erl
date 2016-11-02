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
-export([get_settings/0,get_settings_withdraw/0]).
get_settings() ->
  {ok, ApiUsername} = case application:get_env(pegasus_apiusername) of
                        %%undefined -> {ok, <<"90008980182">>};
                        %% undefined -> {ok, <<"100821582394">>};
                        undefined -> {ok, <<"9855460">>};
                        A -> A
                      end,
  {ok, APIPassword} = case application:get_env(pegasus_apipassword) of
                        %undefined -> {ok, <<"1078151079">>};
                        % undefined -> {ok, <<"o08C-yhRO-Ibir-BVjt-xcRa-4fN7-Ovvx-el46">>};
                        undefined -> {ok, <<"ufLW-olVn-RlJr-mvLp-mcBy-dvj2-E1Z3-lZSJ">>};
                        B -> B
                      end,
  {ok, InstantNotificationUrl} = case application:get_env(pegasus_notification_url) of
                                   undefined -> {ok, <<"https://www.chapchap.info:9097/api/service_provider/transaction/mobile_money/sync/confirm/pegasus">>};
                                   C -> C
                                 end,
  {ok, FailureNotificationUrl} = case application:get_env(pegasus_failure_url) of
                                   undefined -> {ok, <<"localhost">>};
                                   D -> D
                                 end,
  {ok, Url} = case application:get_env(pegasus_url) of
                % undefined -> {ok, "http://41.220.12.206/services/yopaymentsdev/task.php"};
                %  undefined -> {ok, "https://paymentsapi1.yo.co.ug/ybs/task.php"};
                undefined -> {ok, "https://pay1.yo.co.ug/ybs/task.php"};
                E -> E
              end,
  {ok, PrivateKey} = case application:get_env(private_key_password) of
                       undefined -> {ok, "chap4yopayments"};
                       F -> F
                     end,

  #pegasus_settings{api_username =  ApiUsername, api_password =  APIPassword,
    notification_url = InstantNotificationUrl, failure_url = FailureNotificationUrl,
    payment_url = Url, private_key_password=PrivateKey
  }.

get_settings_withdraw() ->
  {ok, ApiUsername} = case application:get_env(pegasus_apiusername) of
                        %%undefined -> {ok, <<"90008980182">>};
                         undefined -> {ok, <<"100821582394">>};
                        %undefined -> {ok, <<"9855460">>};
                        A -> A
                      end,
  {ok, APIPassword} = case application:get_env(pegasus_apipassword) of
                        %undefined -> {ok, <<"1078151079">>};
                         undefined -> {ok, <<"o08C-yhRO-Ibir-BVjt-xcRa-4fN7-Ovvx-el46">>};
                        %undefined -> {ok, <<"ufLW-olVn-RlJr-mvLp-mcBy-dvj2-E1Z3-lZSJ">>};
                        B -> B
                      end,
  {ok, InstantNotificationUrl} = case application:get_env(pegasus_notification_url) of
                                   undefined -> {ok, <<"https://www.chapchap.info:9097/api/service_provider/transaction/mobile_money/sync/confirm/pegasus">>};
                                   C -> C
                                 end,
  {ok, FailureNotificationUrl} = case application:get_env(pegasus_failure_url) of
                                   undefined -> {ok, <<"localhost">>};
                                   D -> D
                                 end,
  {ok, Url} = case application:get_env(pegasus_url) of
                % undefined -> {ok, "http://41.220.12.206/services/yopaymentsdev/task.php"};
                  undefined -> {ok, "https://paymentsapi1.yo.co.ug/ybs/task.php"};
                %undefined -> {ok, "https://pay1.yo.co.ug/ybs/task.php"};
                E -> E
              end,
  {ok, PrivateKey} = case application:get_env(private_key_password) of
                       undefined -> {ok, "chap4yopayments"};
                       F -> F
                     end,

  #pegasus_settings{api_username =  ApiUsername, api_password =  APIPassword,
    notification_url = InstantNotificationUrl, failure_url = FailureNotificationUrl,
    payment_url = Url, private_key_password=PrivateKey
  }.