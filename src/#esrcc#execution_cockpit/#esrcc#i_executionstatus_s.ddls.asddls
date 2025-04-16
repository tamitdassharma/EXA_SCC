@EndUserText.label: 'Execution Cockpit Status Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_ExecutionStatus_S
  as select from I_Language
    left outer join /ESRCC/EXEC_ST on 0 = 0
  composition [0..*] of /ESRCC/I_ExecutionStatus as _ExecutionStatus
{
  key 1 as SingletonID,
  _ExecutionStatus,
  max( /ESRCC/EXEC_ST.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
