@EndUserText.label: 'Profit Center Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Pfc_S
  provider contract transactional_query
  as projection on /ESRCC/I_Pfc_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ProfitCenter : redirected to composition child /ESRCC/C_Pfc
  
}
