@EndUserText.label: 'Hierarchy Definition Singletone'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_HierDef_S
  as select from I_Language
    left outer join /ESRCC/HIER_DEF on 0 = 0
  composition [0..*] of /ESRCC/I_HierDef as _HierDef
{
  key 1 as SingletonID,
  _HierDef,
  max( /ESRCC/HIER_DEF.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
