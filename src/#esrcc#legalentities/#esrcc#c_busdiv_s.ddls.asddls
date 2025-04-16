@EndUserText.label: 'Business Division Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_BusDiv_S
  provider contract transactional_query
  as projection on /ESRCC/I_BusDiv_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _BusinessDivision : redirected to composition child /ESRCC/C_BusDiv
  
}
