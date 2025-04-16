@EndUserText.label: 'Charge out Rules Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CoRule_S
  provider contract transactional_query
  as projection on /ESRCC/I_CoRule_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Rule : redirected to composition child /ESRCC/C_CoRule
  
}
