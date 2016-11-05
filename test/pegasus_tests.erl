%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jul 2016 5:04 PM
%%%-------------------------------------------------------------------
-module(pegasus_tests).
-author("mb-spare").

-include_lib("eunit/include/eunit.hrl").
-include("../../core/include/core_app_common.hrl").
-include("../include/response.hrl").
pegasus_test()->
  application:start(asn1),
  application:start(crypto),
  application:start(public_key),
  application:start(ssl),application:start(ibrowse),
  application:start(fast_xml),
  periodic_sup:start_link(),
  TransactionId = number_manipulator:get_guid(),
  CustomerId = <<"11111">>,
  BillId = <<"nswc_kampala">>,
  Email = <<"james.alituhikya@gmail.com">>,
  Amount = 10000,
  PhoneNumber = <<"256756719888">>,
  {ok, {StatusDescription, CustomerName}, Body} = pegasus:get_details(#payment{customer_id = CustomerId, type = BillId, transaction_id = TransactionId}),
  ?debugFmt("StatusDescription ~w CustomerName ~w Body ~w ~n",[StatusDescription,CustomerName,Body]),
  CustomerDetails = [{<<"CustomerName">>, CustomerName}],
  {ok, {Description, Peg_pay_id}, Body2} = pegasus:pay_bill(#payment{
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
    on_confirm_callback = fun(_)-> ?debugMsg("on confirm XXXXXXXXXXXXXXXX~n") end,
    on_indeterminate_callback = fun(_)-> ?debugMsg("on failed XXXXXXXXXXXXXXXX~n") end,
    archive = fun(_,_)-> ?debugMsg("archive XXXXXXXXXXXXXXXX~n") end
    }),
  ?debugFmt("Description ~w Peg_pay_id ~w Body2 ~w ~n",[Description,Peg_pay_id,Body2]),
  receive
    after 3000 ->
    {ok, {Bescription, Receipt}, Body3} = pegasus:check_transaction_status(TransactionId),
    ?debugFmt("Bescription ~w Receipt ~w Body2 ~w ~n",[Bescription,Receipt,Body3])
  end.




