@EndUserText.label: 'Service Product Singleton - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrvPro_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrvPro_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServiceProduct : redirected to composition child /ESRCC/C_SrvPro
  
}
