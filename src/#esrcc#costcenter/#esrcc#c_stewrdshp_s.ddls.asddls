@EndUserText.label: 'Maintain Stewardship Singleton - Maintai'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Stewrdshp_S
  provider contract transactional_query
  as projection on /ESRCC/I_Stewrdshp_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Stewardship : redirected to composition child /ESRCC/C_Stewrdshp
  
}
