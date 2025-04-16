@EndUserText.label: 'Workflow mapping of User and Role Single'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_WfCust_S
  provider contract transactional_query
  as projection on /ESRCC/I_WfCust_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _RoleAssignment : redirected to composition child /ESRCC/C_WfCust
  
}
