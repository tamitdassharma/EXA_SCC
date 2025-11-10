@EndUserText.label: 'Maintain TP Profile Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_TpProf_S
  provider contract transactional_query
  as projection on /ESRCC/I_TpProf_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _TpProfile : redirected to composition child /ESRCC/C_TpProf
  
}
