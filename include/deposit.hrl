%% HRL file generated by ERLSOM
%%
%% It is possible (and in some cases necessary) to change the name of
%% the record fields.
%%
%% It is possible to add default values, but be aware that these will
%% only be used when *writing* an xml document.


-type anyAttrib()  :: {{string(),    %% name of the attribute
  string()},   %% namespace
  string()}.    %% value

-type anyAttribs() :: [anyAttrib()] | undefined.

%% xsd:QName values are translated to #qname{} records.
-record(qname, {uri :: string(),
  localPart :: string(),
  prefix :: string(),
  mappedPrefix :: string()}).



-record('AutoCreate', {anyAttribs :: anyAttribs(),
  'Request' :: 'AutoCreate/Request'()}).

-type 'AutoCreate'() :: #'AutoCreate'{}.


-record('AutoCreate/Request', {
  'APIUsername' :: string() | undefined,
  'APIPassword' :: string() | undefined,
  'Method' :: string() | undefined,
  'NonBlocking' :: string() | undefined,
  'Amount' :: string() | undefined,
  'Account' :: string() | undefined,
  'AccountProviderCode' :: string()  | undefined,
  'Narrative' :: string() | undefined,
  'NarrativeFileName' :: string() | undefined,
  'NarrativeFileBase64' :: string() | undefined,
  'InternalReference' :: string() | undefined,
  'ExternalReference' :: string() | undefined,
  'ProviderReferenceText' :: string() | undefined,
  'InstantNotificationUrl' :: string() | undefined,
  'FailureNotificationUrl' :: string() | undefined,
  'AuthenticationSignatureBase64' :: string() | undefined}).

-type 'AutoCreate/Request'() :: #'AutoCreate/Request'{}.