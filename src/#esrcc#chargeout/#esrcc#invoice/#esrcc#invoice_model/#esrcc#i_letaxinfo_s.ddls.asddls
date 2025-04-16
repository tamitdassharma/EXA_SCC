@EndUserText.label: 'Tax Information Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeTaxInfo_S
  as select from I_Language
    left outer join /ESRCC/LETAXINFO on 0 = 0
  composition [0..*] of /ESRCC/I_LeTaxInfo as _TaxInformation
{
  key 1 as SingletonID,
  _TaxInformation,
  max( /ESRCC/LETAXINFO.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
