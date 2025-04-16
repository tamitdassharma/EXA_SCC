@EndUserText.label: 'Legal Entity Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LE_S
  provider contract transactional_query
  as projection on /ESRCC/I_LE_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _LegalEntity : redirected to composition child /ESRCC/C_LE
  
}
