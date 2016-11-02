%%%-------------------------------------------------------------------
%%% @author mb-spare
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jul 2016 5:07 PM
%%%-------------------------------------------------------------------
-module(pegasus_signature).
-author("mb-spare").

-include("../include/pegasus_app_common.hrl").
%% API
-export([
  create_tables/0,
  ensure_loaded/0,
  initiate/0,
  get_signature/6,
  get_private_key/0,
  create_private_key/0,
  get_private_key_from_db/1,
  decrypt/1
]).

%% Mnesia API
create_tables() ->
  mnesia:create_table(signature_keys, [{ram_copies, [node()]},
    {type, set}, {attributes, record_info(fields, signature_keys)},
    {index, [id]}]).

ensure_loaded() ->
  ok = mnesia:wait_for_tables([signature_keys], 10000).

%--------------------------------------------------------------------
%% @doc
%% set up all fees
%%
%% @end
%%--------------------------------------------------------------------
-spec(set_up_private_key() -> ok).
set_up_private_key() ->
  PrivateKey = create_private_key(),
  Fun = fun() -> mnesia:write(#signature_keys{private_key = PrivateKey,id = 1,public_key = nothing}),
    [_PKey] = mnesia:wread({signature_keys, 1})
  end,
  {atomic, Res} = mnesia:transaction(Fun),
  Res.

%--------------------------------------------------------------------
%% @doc
%% creates tables , ensures they are loaded and then adds the initail values to com_tracker
%%
%% @end
%%--------------------------------------------------------------------
-spec(initiate() -> ok).
initiate() ->
  create_tables(),
  ensure_loaded(),
  set_up_private_key().
create_private_key()->
  {ok, PemBin } = file:read_file(get_priv_key_file()),
  [ RSAEntry ] = public_key:pem_decode(PemBin),
  public_key:pem_entry_decode( RSAEntry, "chap4yopayments").

create_public_key()->
  {ok, PemBin } = file:read_file(get_pub_key_file()),
  [ RSAEntry ] = public_key:pem_decode(PemBin),
  public_key:pem_entry_decode( RSAEntry).

get_priv_key_file()->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/private_key.pem";
    PrivDir -> filename:absname(PrivDir)++ "/private_key.pem"
  end.
get_pub_key_file()->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/public_key.pem";
    PrivDir -> filename:absname(PrivDir)++ "/public_key.pem"
  end.


get_private_key_from_db(Id)->
  try mnesia:dirty_read({signature_keys, Id}) of
    [] -> {error, empty};
    [H|_T] ->{ok,H};
    Error -> {error,Error}
  catch
    _X:Y -> {error,Y}
  end.

get_private_key()->
  case get_private_key_from_db(1) of
    {error, _ }-> create_private_key();
    {ok,Key}-> Key
  end.

encrypt(String)->
  PrivateKey = get_private_key(),
  public_key:encrypt_private( String, PrivateKey).

decrypt(Encrypted)->
  PublicKey = create_public_key(),
  public_key:decrypt_public(base64:decode(Encrypted), PublicKey).


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
%% private encryption key.
%% Finally, obtain the base-64 representation of the above
%% encrypted data and store it in the
%% AuthenticationSignatureBase64 field.
%%% @end
-spec(get_signature(Type ::atom(),Amount :: string(),
    Account :: string(),
    Narrative :: string(),
    ExternalReference :: string(),
    Settings :: string()) -> string()).
get_signature(string,Amount,Account,Narrative,ExternalReference,Settings)->
  Raw = Settings#pegasus_settings.api_username ++
    Settings#pegasus_settings.api_username ++
    Amount ++
    Account ++
    Narrative ++
    ExternalReference ++
    core_util:get_ip(),
  RawSHA = crypto:hash(sha,Raw),
  RawEnrypt = encrypt(RawSHA),
  base64:encode(RawEnrypt);

get_signature(binary,Amount,Account,Narrative,ExternalReference,Settings)->
  Raw = erlang:iolist_to_binary([(Settings#pegasus_settings.api_username) ,
    (Settings#pegasus_settings.api_username),
    Amount,
    Account,
    Narrative,
    ExternalReference,
   core_util:get_ip_as_binary()
  ]),
  RawSHA = crypto:hash(sha,Raw),
  RawEnrypt = encrypt(RawSHA),
  base64:encode(RawEnrypt).

