@EndUserText.label: 'Allocation Key Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_AllocationKey_S
  provider contract transactional_query
  as projection on /ESRCC/I_AllocationKey_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _AllocationKey : redirected to composition child /ESRCC/C_AllocationKey
  
}
