@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Charge-out Rules Description'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CoRuleText
  as select from /esrcc/co_rulet
  association [1..1] to /ESRCC/I_CoRule_S as _RuleAll on $projection.SingletonID = _RuleAll.SingletonID
  association to parent /ESRCC/I_CoRule as _Rule on $projection.RuleId = _Rule.RuleId
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key rule_id as RuleId,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _RuleAll,
  _Rule,
  _LanguageText
  
}
