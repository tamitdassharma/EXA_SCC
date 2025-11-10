@EndUserText.label: 'Maintain Cost Object Types Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CostObjectType_S
  as select from I_Language
    left outer join /ESRCC/CSTOBJTYP on 0 = 0
  composition [0..*] of /ESRCC/I_CostObjectType as _CostObjectType
{
  key 1 as SingletonID,
  _CostObjectType,
  max( /ESRCC/CSTOBJTYP.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
