@EndUserText.label: 'Charge-out'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_ChargeoutBc_S
  as select from I_Language
    left outer join /ESRCC/CHARGEOUT on 0 = 0
  composition [0..*] of /ESRCC/I_ChargeoutBc as _Chargeout
{
  key 1 as SingletonID,
  _Chargeout,
  max( /ESRCC/CHARGEOUT.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
