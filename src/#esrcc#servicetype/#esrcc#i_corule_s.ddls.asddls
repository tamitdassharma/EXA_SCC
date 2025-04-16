@EndUserText.label: 'Charge-out Rules Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CoRule_S
  as select from I_Language
    left outer join /esrcc/co_rule on 0 = 0
  composition [0..*] of /ESRCC/I_CoRule as _Rule
{
  key 1 as SingletonID,
  _Rule,
  max( /esrcc/co_rule.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
