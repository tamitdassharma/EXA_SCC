@EndUserText.label: 'Legal Entity to Company Code Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeCcode_S
  as select from I_Language
    left outer join /ESRCC/LE_CCODE on 0 = 0
  composition [0..*] of /ESRCC/I_LeCcode as _LeToCompanyCode
{
  key 1 as SingletonID,
  _LeToCompanyCode,
  max( /ESRCC/LE_CCODE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
