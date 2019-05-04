# Pegasus
Erlang Library to Connect to Pegasus Systems for bill payments

- Get User Details
- Make bill payment
- Get Transaction Status

## Contents
- [Introduction](#introduction)
- [Building](#building)
- [Testing](#testing)
- [Getting User Details](#getting-user-details)
- [Making a bill payment](#making-a-bill-payment)
- [Contributors](#contributors)

## Introduction 
This can be used to connect to pegasus systems for bill payments via api. This will be used in conjunction
with the api documentation

The following functions are exposed:
- get_details
- pay_bill
- get_transaction_status



## Documentation overview
A [use cases document](doc/use_cases.md) gives an overview of the
application by describing the 3 main use cases:

1. Getting user Details
2. Make bill payments
3. Get transaction status

For more details there are additional documents:
-

## Building
rebar is used to build the software. 

```
rebar get-deps
rebar compile
```

## Testing
rebar can also be used to run the tests.

```
rebar -C test.config eunit

```
and for common test
```
rebar -C test.config ct

```
The call can also be mocked by tweaking with the `test` environment variable such that the call is not actually made for
testing purposes

## Getting User Details
This can be performed by running function `pegasus:get_details()`.
This function expects a `#payment` record that will have
- Account Number/ Meter Number : `customer_id`
- The bill being paid for: `type`
- The transaction id `transaction_id`
This will return a tuple of the form: `{ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}`


## Making a bill payment
This can be performed by running function `pegasus:pay_bill()`.
This function expects a `#payment` record that will have
- Account Number/ Meter Number : `customer_id`
- The bill being paid for: `type` (the various types can be found in `pegasus_util`)
- The transaction id `transaction_id`
- The user's email: `email`
- The transaction amount: `amount`
- The user's phone number `phone_number`
This will return a tuple of the form: `{ok, Message :: binary(), Trace :: term()} | {error, Message :: binary(), Trace :: term()}` and then
start polling the status of the transaction. Therefore with n the payment record should be the following:
- the confirmation callback should be function with one parameter, that parameter passed will be the receipt/token
- the failure callback should be a function with one parameter, that parameter passed will be the error
- the archive call back should be a function with one parameter, that parameter passed will be the status : `archive`
- start the polling after time period: `start_after` in milliseconds
- poll after every time `poll_interval` in milliseconds

## The Signature
The key files should be placed in the priv folder and the private key password set in the environment variable

## Environment variables
Can be found in `pegasus_env_util`
- pegasus_apiusername
- pegasus_apipassword
- private_key_password
- pegasus_url
- private_key_password
- test



## Contributors
This application was developed by James Alituhikya(@badnessJust).  The development of this library was sponsored by [chapchap ltd](https://www.chapchap.co).