@EndUserText.label: 'Maintain Regions Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Region_S
  provider contract transactional_query
  as projection on /ESRCC/I_Region_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Regions : redirected to composition child /ESRCC/C_Regions
  
}
