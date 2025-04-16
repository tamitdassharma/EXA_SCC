@EndUserText.label: 'Billing Frequency Mapping Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_BillingFrequency_S
  as select from I_Language
    left outer join /ESRCC/BILLFREQ on 0 = 0
  composition [0..*] of /ESRCC/I_BillingFrequency as _BillingFrequency
{
  key 1 as SingletonID,
  _BillingFrequency,
  max( /ESRCC/BILLFREQ.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
