@EndUserText.label: 'Ledger Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Ledger_S
  as select from I_Language
    left outer join /ESRCC/LEDGER on 0 = 0
  composition [0..*] of /ESRCC/I_Ledger as _Ledger
{
  key 1 as SingletonID,
  _Ledger,
  max( /ESRCC/LEDGER.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
