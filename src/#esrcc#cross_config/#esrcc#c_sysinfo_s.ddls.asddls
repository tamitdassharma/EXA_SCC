@EndUserText.label: 'System Information Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SysInfo_S
  provider contract transactional_query
  as projection on /ESRCC/I_SysInfo_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _SystemInfo : redirected to composition child /ESRCC/C_SysInfo
  
}
