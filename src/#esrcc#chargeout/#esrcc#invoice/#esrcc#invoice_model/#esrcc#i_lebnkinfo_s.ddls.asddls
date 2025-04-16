@EndUserText.label: 'Bank Information Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeBnkInfo_S
  as select from I_Language
    left outer join /ESRCC/LEBNKINFO on 0 = 0
  composition [0..*] of /ESRCC/I_LeBnkInfo as _BankInformation
{
  key 1 as SingletonID,
  _BankInformation,
  max( /ESRCC/LEBNKINFO.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
