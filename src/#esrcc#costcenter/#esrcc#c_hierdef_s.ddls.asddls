@EndUserText.label: 'Maintain Hierarchy Definition Singletone'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_HierDef_S
  provider contract transactional_query
  as projection on /ESRCC/I_HierDef_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _HierDef : redirected to composition child /ESRCC/C_HierDef
  
}
