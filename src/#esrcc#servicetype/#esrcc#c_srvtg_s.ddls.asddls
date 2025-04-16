@EndUserText.label: 'Service Transaction Group Singleton - Ma'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrvTg_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrvTg_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _TransactionGrp : redirected to composition child /ESRCC/C_SrvTg
  
}
