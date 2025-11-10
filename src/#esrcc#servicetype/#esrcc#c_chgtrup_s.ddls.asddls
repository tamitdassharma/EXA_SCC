@EndUserText.label: 'Maintain Service Product Trueup Singleto'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Chgtrup_S
  provider contract transactional_query
  as projection on /ESRCC/I_Chgtrup_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServicePrdTrueUp : redirected to composition child /ESRCC/C_Chgtrup
  
}
