@EndUserText.label: 'Maintain Ledger Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Ledger_S
  provider contract transactional_query
  as projection on /ESRCC/I_Ledger_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Ledger : redirected to composition child /ESRCC/C_Ledger
  
}
