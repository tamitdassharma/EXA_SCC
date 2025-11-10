@EndUserText.label: 'Maintain Hierarchy Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Hier3_S
  provider contract transactional_query
  as projection on /ESRCC/I_Hier3_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Hierarchy : redirected to composition child /ESRCC/C_Hier3
  
}
