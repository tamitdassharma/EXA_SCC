@EndUserText.label: 'System Information Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SysInfo_S
  as select from I_Language
    left outer join /ESRCC/SYS_INFO on 0 = 0
  composition [0..*] of /ESRCC/I_SysInfo as _SystemInfo
{
  key 1 as SingletonID,
  _SystemInfo,
  max( /ESRCC/SYS_INFO.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
