@EndUserText.label: 'License Type Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LicType_S
  as select from I_Language
    left outer join /ESRCC/LICTYPE on 0 = 0
  composition [0..*] of /ESRCC/I_LicType as _LicenseType
{
  key 1 as SingletonID,
  _LicenseType,
  max( /ESRCC/LICTYPE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
