@EndUserText.label: 'Cost element characteristics Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CostElmenetCharacte_S
  as select from I_Language
    left outer join /esrcc/cstelmtch on 0 = 0
  composition [0..*] of /ESRCC/I_CostElmenetCharacte as _CostElementChar
{
  key 1 as SingletonID,
  _CostElementChar,
  max( /esrcc/cstelmtch.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
