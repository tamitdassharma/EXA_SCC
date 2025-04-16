@EndUserText.label: 'Charge-out - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_ChargeoutBc_S
  provider contract transactional_query
  as projection on /ESRCC/I_ChargeoutBc_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Chargeout : redirected to composition child /ESRCC/C_ChargeoutBc
  
}
