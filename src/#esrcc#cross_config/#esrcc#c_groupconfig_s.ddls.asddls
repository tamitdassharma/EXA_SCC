@EndUserText.label: 'Group Configuration Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_GroupConfig_S
  provider contract transactional_query
  as projection on /ESRCC/I_GroupConfig_S
{
  key SingletonID,
      LastChangedAtMax,
      TransportRequestID,
      HideTransport,
      _GroupConfig : redirected to composition child /ESRCC/C_GroupConfig

}
