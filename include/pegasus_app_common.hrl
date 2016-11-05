-record(pegasus_settings,{
  api_username,
  api_password,
  url,
  private_key_password
}).

-record(signature_keys, {
  private_key,
  id,
  public_key
}).
