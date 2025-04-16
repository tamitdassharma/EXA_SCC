@EndUserText.label: 'Service Type Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrType_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrType_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServiceType : redirected to composition child /ESRCC/C_SrType
  
}
