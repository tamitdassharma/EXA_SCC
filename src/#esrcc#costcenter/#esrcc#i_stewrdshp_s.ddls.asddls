@EndUserText.label: 'Maintain Stewardship Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Stewrdshp_S
  as select from I_Language
    left outer join /ESRCC/STEWRDSHP on 0 = 0
  composition [0..*] of /ESRCC/I_Stewrdshp as _Stewardship
{
  key 1 as SingletonID,
  _Stewardship,
  max( /ESRCC/STEWRDSHP.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
