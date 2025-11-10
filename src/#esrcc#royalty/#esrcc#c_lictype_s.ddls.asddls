@EndUserText.label: 'Maintain License Type Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LicType_S
  provider contract transactional_query
  as projection on /ESRCC/I_LicType_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _LicenseType : redirected to composition child /ESRCC/C_LicType
  
}
