@EndUserText.label: 'Hierarchy Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Hier3_S
  as select from I_Language
    left outer join /ESRCC/HIER3 on 0 = 0
  composition [0..*] of /ESRCC/I_Hier3 as _Hierarchy
{
  key 1 as SingletonID,
  _Hierarchy,
  max( /ESRCC/HIER3.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
