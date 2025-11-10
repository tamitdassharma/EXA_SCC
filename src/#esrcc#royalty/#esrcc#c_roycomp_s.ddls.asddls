@EndUserText.label: 'Maintain Royalty Computation Rule Single'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RoyComp_S
  provider contract transactional_query
  as projection on /ESRCC/I_RoyComp_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Rule : redirected to composition child /ESRCC/C_RoyComp
  
}
