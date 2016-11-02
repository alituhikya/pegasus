%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% To generate the signature concatenate the following
%% parameters in order:
%% 1. APIUsername
%% 2. APIPassword
%% 3. Amount
%% 4. Account
%% 5. Narrative
%% 6. ExternalReference
%% 7. the source IP address where the request originates
%% Next, obtain an SHA1 hash of the above string.
%% Then, encrypt the SHA1 hash you have obtained using your
%%% @end
%%% Created : 01. Jul 2016 5:23 PM
%%%-------------------------------------------------------------------
-module(pegasus_util).
-author("mb-spare").

%% API
-export([get_network_code/1,get_file/1]).
-include("../include/pegasus_app_common.hrl").

%% @doc yo payments has codes for different networks, this function returns those based on the the network provided
-spec(get_network_code(Network :: atom())-> Code :: string()).
get_network_code(mtn)->
  "MTN_UGANDA";
get_network_code(airtel)->
  "AIRTEL_UGANDA";
get_network_code(_)->
  throw(<<"unsupported network">>).

get_file(FileName)->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/" ++ FileName;
    PrivDir -> filename:absname(PrivDir)++ "/" ++ FileName
  end.
