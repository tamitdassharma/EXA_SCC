@EndUserText.label: 'Workflow mapping of User and Role Single'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_WfCust_S
  as select from I_Language
    left outer join /ESRCC/WFCUST on 0 = 0
  composition [0..*] of /ESRCC/I_WfCust as _RoleAssignment
{
  key 1 as SingletonID,
  _RoleAssignment,
  max( /ESRCC/WFCUST.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
