@EndUserText.label: 'Maintain Cost Object Types Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CostObjectTypeText
  as select from /ESRCC/CSTBJTYPT
  association [1..1] to /ESRCC/I_CostObjectType_S as _CostObjectTypeAll on $projection.SingletonID = _CostObjectTypeAll.SingletonID
  association to parent /ESRCC/I_CostObjectType as _CostObjectType on $projection.CostObject = _CostObjectType.CostObject
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key COST_OBJECT as CostObject,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _CostObjectTypeAll,
  _CostObjectType,
  _LanguageText
  
}
