@EndUserText.label: 'Legal Entity Address Singleton - Maintai'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeAddress_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeAddress_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _LeAddress : redirected to composition child /ESRCC/C_LeAddress
  
}
