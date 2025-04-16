@EndUserText.label: 'Cost element characteristics Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CostElmenetCharacte_S
  provider contract transactional_query
  as projection on /ESRCC/I_CostElmenetCharacte_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostElementChar : redirected to composition child /ESRCC/C_CostElmenetCharacte
  
}
