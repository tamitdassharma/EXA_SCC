@EndUserText.label: 'Maintain Regions Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Region_S
  as select from I_Language
    left outer join /ESRCC/REGIONS on 0 = 0
  composition [0..*] of /ESRCC/I_Regions as _Regions
{
  key 1 as SingletonID,
  _Regions,
  max( /ESRCC/REGIONS.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
