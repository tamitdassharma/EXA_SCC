@EndUserText.label: 'Bank Information Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeBnkInfo_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeBnkInfo_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _BankInformation : redirected to composition child /ESRCC/C_LeBnkInfo
  
}
