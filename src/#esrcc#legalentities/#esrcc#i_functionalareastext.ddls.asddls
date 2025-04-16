@EndUserText.label: 'Functional areas Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_FunctionalAreasText
  as select from /ESRCC/FNC_AREAT
  association [1..1] to /ESRCC/I_FunctionalAreas_S as _FunctionalAreasAll on $projection.SingletonID = _FunctionalAreasAll.SingletonID
  association to parent /ESRCC/I_FunctionalAreas as _FunctionalAreas on $projection.FunctionalArea = _FunctionalAreas.FunctionalArea
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key FUNCTIONAL_AREA as FunctionalArea,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _FunctionalAreasAll,
  _FunctionalAreas,
  _LanguageText
  
}
