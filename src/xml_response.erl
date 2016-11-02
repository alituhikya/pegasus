%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jul 2016 7:00 AM
%%%-------------------------------------------------------------------
-module(xml_response).
-author("mb-spare").
-include("../include/response.hrl").
-include("../include/response_not_shared.hrl").

%% API
-export([get_response/2]).

get_response(erlsom,Body)->
{ok, ModelOut} = erlsom:compile_xsd_file(pegasus_util:get_file("response.xsd"), []),
  {ok,BodyDecoded,_} = erlsom:scan(Body,ModelOut),
  ResponseRaw = BodyDecoded#'AutoCreate'.'Response',
  #'Response'{
  'ErrorMessage' = ResponseRaw#'AutoCreate/Response'.'ErrorMessage',
  'Status'  = ResponseRaw#'AutoCreate/Response'.'Status',
  'StatusCode'  = ResponseRaw#'AutoCreate/Response'.'StatusCode',
  'StatusMessage'  = ResponseRaw#'AutoCreate/Response'.'StatusMessage' ,
  'ErrorMessageCode'  = ResponseRaw#'AutoCreate/Response'.'ErrorMessageCode',
  'TransactionStatus'  = ResponseRaw#'AutoCreate/Response'.'TransactionStatus',
  'TransactionReference'  = ResponseRaw#'AutoCreate/Response'.'TransactionReference'
  };

get_response(fast_xml,Body)->
ParmsList = core_util:decode_xml_params(Body),  
 AutoCreate = getValue(<<"AutoCreate">>,ParmsList), 
 ResponseRaw = getValue(<<"Response">>,AutoCreate),
  #'Response'{
    'ErrorMessage' = getValue(<<"ErrorMessage">>,ResponseRaw),
    'Status'  = getValue(<<"Status">>,ResponseRaw),
    'StatusCode'  = getValue(<<"StatusCode">>,ResponseRaw),
    'StatusMessage'  = getValue(<<"StatusMessage">>,ResponseRaw),
    'ErrorMessageCode'  = getValue(<<"ErrorMessageCode">>,ResponseRaw),
    'TransactionStatus'  = getValue(<<"TransactionStatus">>,ResponseRaw),
    'TransactionReference'  = getValue(<<"TransactionReference">>,ResponseRaw)
  }
.
getValue(Key,ParameterList)->

  case lists:keyfind(Key, 1, ParameterList) of
    {Key,Value} -> Value;
    _-> undefined
  end.

