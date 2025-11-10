@EndUserText.label: 'Maintain Royalty Base Keys Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RoyKey_S
  provider contract transactional_query
  as projection on /ESRCC/I_RoyKey_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _RoyaltyKey : redirected to composition child /ESRCC/C_RoyKey
  
}
