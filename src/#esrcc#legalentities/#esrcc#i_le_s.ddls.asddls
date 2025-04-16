@EndUserText.label: 'Legal Entity Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LE_S
  as select from I_Language
    left outer join /ESRCC/LE on 0 = 0
  composition [0..*] of /ESRCC/I_LE as _LegalEntity
{
  key 1 as SingletonID,
  _LegalEntity,
  max( /ESRCC/LE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
