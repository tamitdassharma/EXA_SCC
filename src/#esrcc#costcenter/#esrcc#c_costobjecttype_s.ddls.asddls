@EndUserText.label: 'Cost Object Types Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CostObjectType_S
  provider contract transactional_query
  as projection on /ESRCC/I_CostObjectType_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostObjectType : redirected to composition child /ESRCC/C_CostObjectType
  
}
