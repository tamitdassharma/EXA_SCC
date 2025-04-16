@EndUserText.label: 'Workflow Controller - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_WfSwitch_S
  provider contract transactional_query
  as projection on /ESRCC/I_WfSwitch_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _WorkflowSwitch : redirected to composition child /ESRCC/C_WfSwitch
  
}
