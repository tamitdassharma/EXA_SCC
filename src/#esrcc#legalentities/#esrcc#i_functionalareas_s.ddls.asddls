@EndUserText.label: 'Functional areas Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_FunctionalAreas_S
  as select from I_Language
    left outer join /ESRCC/FNC_AREA on 0 = 0
  composition [0..*] of /ESRCC/I_FunctionalAreas as _FunctionalAreas
{
  key 1 as SingletonID,
  _FunctionalAreas,
  max( /ESRCC/FNC_AREA.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
