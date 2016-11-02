%%%-------------------------------------------------------------------
%%% @author MB-SPARE
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Nov 2015 8:42 PM
%%%-------------------------------------------------------------------
-author("alituhikyaj").

-include("../include/pegasus_app_common.hrl").
-include("../deps/authenticator/include/usr.hrl").



-define(TEST_USR, #usr{auth_name = <<"android">>, auth_code = <<"999">>, client_role = <<"android">>}).
-define(TEST_ARGSLIST, [{<<"amount">>, <<"5000">>}, {<<"phone_number">>, <<"0771257287">>}]).