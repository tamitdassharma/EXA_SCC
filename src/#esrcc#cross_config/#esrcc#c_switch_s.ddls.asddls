@EndUserText.label: 'Maintain Switch Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Switch_S
  provider contract transactional_query
  as projection on /ESRCC/I_Switch_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Switch : redirected to composition child /ESRCC/C_Switch
  
}
