@EndUserText.label: 'Service Type Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrType_S
  as select from I_Language
    left outer join /ESRCC/SRTYPE on 0 = 0
  composition [0..*] of /ESRCC/I_SrType as _ServiceType
{
  key 1 as SingletonID,
  _ServiceType,
  max( /ESRCC/SRTYPE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
