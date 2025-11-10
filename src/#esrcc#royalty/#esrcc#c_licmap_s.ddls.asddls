@EndUserText.label: 'Maintain Licensor Licensee Mapping Singl'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LicMap_S
  provider contract transactional_query
  as projection on /ESRCC/I_LicMap_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Licensee : redirected to composition child /ESRCC/C_LicMap
  
}
