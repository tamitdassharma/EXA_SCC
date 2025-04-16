@EndUserText.label: 'Cost elements Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CostElementsText
  as select from /ESRCC/CST_ELMTT
  association [1..1] to /ESRCC/I_CostElements_S as _CostElementsAll on $projection.SingletonID = _CostElementsAll.SingletonID
  association to parent /ESRCC/I_CostElements as _CostElements on $projection.CostElementUuid = _CostElements.CostElementUuid
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key COST_ELEMENT_UUID as CostElementUuid,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _CostElementsAll,
  _CostElements,
  _LanguageText
  
}
