@EndUserText.label: 'Cost Object Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CstObjct_S
  as select from I_Language
    left outer join /ESRCC/CST_OBJCT on 0 = 0
  composition [0..*] of /ESRCC/I_CstObjct as _CostObject
{
  key 1 as SingletonID,
  _CostObject,
  max( /ESRCC/CST_OBJCT.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
