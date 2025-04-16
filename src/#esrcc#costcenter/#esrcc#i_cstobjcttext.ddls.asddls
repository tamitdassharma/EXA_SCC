@EndUserText.label: 'Cost Object Description'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CstObjctText
  as select from /esrcc/cst_objtt
  association [1..1] to /ESRCC/I_CstObjct_S as _CostObjectAll on $projection.SingletonID = _CostObjectAll.SingletonID
  association to parent /ESRCC/I_CstObjct as _CostObject on $projection.CostObjectUuid = _CostObject.CostObjectUuid
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key cost_object_uuid as CostObjectUuid,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _CostObjectAll,
  _CostObject,
  _LanguageText
  
}
