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
-include_lib("public_key/include/public_key.hrl").
-include("../include/response.hrl").
%% API
-export([
  initiate/0,
  get_signature/9,
  get_private_key/0,
  create_private_key/0,
  decrypt/1
]).


%--------------------------------------------------------------------
%% @doc
%% adds private key to memory
%%
%% @end
%%--------------------------------------------------------------------
-spec(initiate() -> ok).
initiate() ->
  create_private_key().

create_private_key() ->
  {ok, PemBin} = file:read_file(get_priv_key_file()),
  [RSAEntry] = public_key:pem_decode(PemBin),
  PrivateKey = public_key:pem_entry_decode(RSAEntry, "chap4yopayments"),
  RsaKey = public_key:der_decode('RSAPrivateKey', PrivateKey#'PrivateKeyInfo'.privateKey),
  application:set_env(pegasus, private_key, RsaKey),
  RsaKey
.

create_public_key() ->
  {ok, PemBin} = file:read_file(get_pub_key_file()),
  [RSAEntry] = public_key:pem_decode(PemBin),
  public_key:pem_entry_decode(RSAEntry).

get_priv_key_file() ->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/key.pem";
    PrivDir -> filename:absname(PrivDir) ++ "/key.pem"
  end.

get_pub_key_file() ->
  case code:priv_dir(pegasus) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv") ++ "/cert.pem";
    PrivDir -> filename:absname(PrivDir) ++ "/cert.pem"
  end.


get_private_key() ->
  case pegasus_env_util:get_private_key() of
    {ok, Key} -> Key;
    {error, _} -> create_private_key()
  end.

encrypt(String) ->
  PrivateKey = get_private_key(),
  public_key:encrypt_private(String, PrivateKey).

decrypt(Encrypted) ->
  PublicKey = create_public_key(),
  public_key:decrypt_public(base64:decode(Encrypted), PublicKey).


%%% @doc
%%% To generate the signature concatenate the following
%%  dataToSign (CustRef + CustName + CustomerTel +
%%    VendorTransactionID + VendorCode + Password + PaymentDate + Teller +
%%    TransactionAmount + Narration + TransactionType;) OR literally
%% (PostField1 + PostField2 + PostField11 + PostField20 + PostField9 + PostField10 +
%% PostField5 + PostField14 + PostField7 + PostField18 + PostField8)
%% %% Next, obtain an SHA1 hash of the above string.
%% Then, encrypt the SHA1 hash you have obtained using your
%% private encryption key.
%% Finally, obtain the base-64 representation of the above
%% encrypted data and store it in the
%% AuthenticationSignatureBase64 field.
%% OR IN OTHER WORDS
%% Compute sha1 hash of concatenated string
%% Use RSA to encrypt hash with private Key
%% Convert encrypted text into base64 string The base 64 string is the digital
%%% @end
-spec(get_signature(
    CustomerId :: string(),
    CustomerName:: string(),
    PhoneNumber :: string(),
    TransactionId :: string(),
    Settings :: string(),
    PaymentDate :: string(),
    Amount :: string(),
    Narration :: string(),
    TransactionType :: string()
) -> string()).
get_signature(
    CustomerId,
    CustomerName,
    PhoneNumber,
    TransactionId,
    Settings,
    PaymentDate,
    Amount,
    Narration,
    TransactionType

) ->
  Raw = CustomerId++
    CustomerName ++
    PhoneNumber ++
    TransactionId ++
    Settings#pegasus_settings.api_username ++
    Settings#pegasus_settings.api_password ++
    PaymentDate ++
    PhoneNumber ++
    Amount ++
    Narration ++
    TransactionType,
  RawSHA = crypto:hash(sha, Raw),
  RawEnrypt = encrypt(RawSHA),
  base64:encode(RawEnrypt).

