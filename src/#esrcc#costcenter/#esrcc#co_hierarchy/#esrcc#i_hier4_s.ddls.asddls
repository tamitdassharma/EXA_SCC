@EndUserText.label: 'Activity Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Hier4_S
  as select from I_Language
    left outer join /esrcc/hier4 on 0 = 0
  composition [0..*] of /ESRCC/I_Hier4 as _Hierarchy
{
  key 1 as SingletonID,
  _Hierarchy,
  max( /esrcc/hier4.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
