@EndUserText.label: 'Allocation Key Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_AllocationKey_S
  as select from I_Language
    left outer join /ESRCC/ALLOCKEYS on 0 = 0
  composition [0..*] of /ESRCC/I_AllocationKey as _AllocationKey
{
  key 1 as SingletonID,
  _AllocationKey,
  max( /ESRCC/ALLOCKEYS.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
