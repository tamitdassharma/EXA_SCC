@EndUserText.label: 'Service Markup Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrvMkp_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrvMkp_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServiceMarkup : redirected to composition child /ESRCC/C_SrvMkp
  
}
