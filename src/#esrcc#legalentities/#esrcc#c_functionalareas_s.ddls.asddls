@EndUserText.label: 'Functional areas Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_FunctionalAreas_S
  provider contract transactional_query
  as projection on /ESRCC/I_FunctionalAreas_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _FunctionalAreas : redirected to composition child /ESRCC/C_FunctionalAreas
  
}
