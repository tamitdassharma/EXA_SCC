@EndUserText.label: 'User Group for Work Flow Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_WfUsrG_S
  as select from I_Language
    left outer join /ESRCC/WFUSRG on 0 = 0
  composition [0..*] of /ESRCC/I_WfUsrG as _UserGroup
{
  key 1 as SingletonID,
  _UserGroup,
  max( /ESRCC/WFUSRG.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
