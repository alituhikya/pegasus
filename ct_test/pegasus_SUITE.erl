%%%-------------------------------------------------------------------
%%% @author james
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Nov 2016 11:58 AM
%%%-------------------------------------------------------------------
-module(pegasus_SUITE).
-author("james").
-include_lib("common_test/include/ct.hrl").
-include("../include/test_values.hrl").
-include("../deps/core/include/core_app_common.hrl").
%% API
-export([]).
-export([all/0]).
-export([get_items_test/1]).
-define(APPS, [nprocreg, sync, crypto, ranch, cowboy]).
all() -> [get_items_test].
get_items_test(_Config) ->

  application:start(asn1),
  application:start(crypto),
  application:start(public_key),
  application:start(ssl),
  application:start(ibrowse),
  application:start(fast_xml),
  periodic_sup:start_link(),
  TransactionId = number_manipulator:get_guid(),
  CustomerId = <<"2167527">>,
  BillId = <<"nswc_kampala">>,
  Email = <<"james.alituhikya@gmail.com">>,
  Amount = 2000,
  PhoneNumber = <<"256756719888">>,
  {ok, {StatusDescription, CustomerName}, Body} = pegasus:get_details(#payment{email = <<"james.alituhikya@gmail.com">>,customer_id = CustomerId, type = BillId, transaction_id = TransactionId}),

  io:format("StatusDescription ~w CustomerName ~w Body ~w ~n",[StatusDescription,CustomerName,Body]),
  CustomerDetails = [{<<"CustomerName">>, CustomerName}],
  Payment2 = #payment{
    email = Email,
    amount = Amount,
    customer_id = CustomerId,
    customer_details = CustomerDetails,
    type = BillId,
    transaction_id = TransactionId,
    phone_number = PhoneNumber,
    start_after = 1000,
    max = 3,
    poll_interval = 1000,
    on_confirm_callback = fun(_)-> io:format("on confirm XXXXXXXXXXXXXXXX~n") end,
    on_indeterminate_callback = fun(_)-> io:format("on failed XXXXXXXXXXXXXXXX~n") end,
    archive = fun(_,_)-> io:format("archive XXXXXXXXXXXXXXXX~n") end
  },
  io:format("Email ~w ~n ",[Payment2#payment.email]),
  {ok, {Description, Peg_pay_id}, Body2} = pegasus:pay_bill(Payment2),
  io:format("Description ~w Peg_pay_id ~w Body2 ~w ~n",[Description,Peg_pay_id,Body2]),
  receive
  after 10000 ->
    {ok, {Bescription, Receipt}, Body3} = pegasus:check_transaction_status(TransactionId),
    io:format("Bescription ~w Receipt ~w Body2 ~w ~n",[Bescription,Receipt,Body3])
  end.