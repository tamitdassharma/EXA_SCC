@EndUserText.label: 'Workflow Controller'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_WfSwitch_S
  as select from I_Language
    left outer join /ESRCC/WF_SWITCH on 0 = 0
  composition [0..*] of /ESRCC/I_WfSwitch as _WorkflowSwitch
{
  key 1 as SingletonID,
  _WorkflowSwitch,
  max( /ESRCC/WF_SWITCH.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
