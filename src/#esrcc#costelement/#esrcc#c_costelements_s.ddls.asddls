@EndUserText.label: 'Cost elements Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CostElements_S
  provider contract transactional_query
  as projection on /ESRCC/I_CostElements_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostElements : redirected to composition child /ESRCC/C_CostElements
  
}
