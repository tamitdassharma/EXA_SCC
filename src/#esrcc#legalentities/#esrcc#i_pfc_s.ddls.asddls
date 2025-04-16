@EndUserText.label: 'Profit Center Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Pfc_S
  as select from I_Language
    left outer join /ESRCC/PFC on 0 = 0
  composition [0..*] of /ESRCC/I_Pfc as _ProfitCenter
{
  key 1 as SingletonID,
  _ProfitCenter,
  max( /ESRCC/PFC.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
