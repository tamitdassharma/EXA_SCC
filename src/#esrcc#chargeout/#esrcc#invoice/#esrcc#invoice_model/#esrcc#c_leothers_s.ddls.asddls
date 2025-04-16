@EndUserText.label: 'Other information Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeOthers_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeOthers_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _OtherInformation : redirected to composition child /ESRCC/C_LeOthers
  
}
