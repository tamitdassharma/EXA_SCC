@EndUserText.label: 'Cost Exclusion Inclusion Reason Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Reason_S
  provider contract transactional_query
  as projection on /ESRCC/I_Reason_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Reason : redirected to composition child /ESRCC/C_Reason
  
}
