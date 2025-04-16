@EndUserText.label: 'Cost Exclusion Inclusion Reason Singleto'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Reason_S
  as select from I_Language
    left outer join /ESRCC/REASON on 0 = 0
  composition [0..*] of /ESRCC/I_Reason as _Reason
{
  key 1 as SingletonID,
  _Reason,
  max( /ESRCC/REASON.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
