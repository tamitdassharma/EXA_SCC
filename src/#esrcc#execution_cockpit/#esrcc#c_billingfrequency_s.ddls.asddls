@EndUserText.label: 'Billing Frequency Mapping Singleton - Ma'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_BillingFrequency_S
  provider contract transactional_query
  as projection on /ESRCC/I_BillingFrequency_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _BillingFrequency : redirected to composition child /ESRCC/C_BillingFrequency
  
}
