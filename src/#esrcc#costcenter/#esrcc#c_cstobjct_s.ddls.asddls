@EndUserText.label: 'Cost Object Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CstObjct_S
  provider contract transactional_query
  as projection on /ESRCC/I_CstObjct_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostObject : redirected to composition child /ESRCC/C_CstObjct
  
}
