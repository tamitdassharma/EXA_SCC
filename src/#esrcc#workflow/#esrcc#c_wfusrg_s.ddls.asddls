@EndUserText.label: 'User Group for Work Flow Singleton - Mai'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_WfUsrG_S
  provider contract transactional_query
  as projection on /ESRCC/I_WfUsrG_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _UserGroup : redirected to composition child /ESRCC/C_WfUsrG
  
}
