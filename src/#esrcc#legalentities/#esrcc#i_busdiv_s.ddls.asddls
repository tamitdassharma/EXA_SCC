@EndUserText.label: 'Business Division Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_BusDiv_S
  as select from I_Language
    left outer join /ESRCC/BUS_DIV on 0 = 0
  composition [0..*] of /ESRCC/I_BusDiv as _BusinessDivision
{
  key 1 as SingletonID,
  _BusinessDivision,
  max( /ESRCC/BUS_DIV.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
