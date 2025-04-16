@EndUserText.label: 'Legal Entity to Company Code Singleton -'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeCcode_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeCcode_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _LeToCompanyCode : redirected to composition child /ESRCC/C_LeCcode
  
}
