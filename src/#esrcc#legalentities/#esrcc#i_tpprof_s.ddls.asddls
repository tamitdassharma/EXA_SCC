@EndUserText.label: 'Maintain TP Profile Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_TpProf_S
  as select from I_Language
    left outer join /ESRCC/TPPROF on 0 = 0
  composition [0..*] of /ESRCC/I_TpProf as _TpProfile
{
  key 1 as SingletonID,
  _TpProfile,
  max( /ESRCC/TPPROF.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
