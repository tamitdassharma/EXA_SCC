@EndUserText.label: 'Execution Cockpit Status Singleton - Mai'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_ExecutionStatus_S
  provider contract transactional_query
  as projection on /ESRCC/I_ExecutionStatus_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ExecutionStatus : redirected to composition child /ESRCC/C_ExecutionStatus
  
}
