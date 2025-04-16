@EndUserText.label: 'Cost elements Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CostElements_S
  as select from I_Language
    left outer join /esrcc/cst_elmnt on 0 = 0
  composition [0..*] of /ESRCC/I_CostElements as _CostElements
{
  key 1 as SingletonID,
  _CostElements,
  max( /esrcc/cst_elmnt.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
