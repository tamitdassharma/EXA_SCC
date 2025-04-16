@EndUserText.label: 'Tax Information Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeTaxInfo_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeTaxInfo_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _TaxInformation : redirected to composition child /ESRCC/C_LeTaxInfo
  
}
