%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jul 2016 6:59 AM
%%%-------------------------------------------------------------------
-author("mb-spare").
-record('Response', {anyAttribs :: anyAttribs(),
  'Status' :: string() | undefined,
  'StatusCode' :: string() | undefined,
  'StatusMessage' :: string() | undefined,
  'ErrorMessageCode' :: string() | undefined,
  'ErrorMessage' :: string() | undefined,
  'TransactionStatus' :: string() | undefined,
  'TransactionReference' :: string()| undefined}).