@EndUserText.label: 'Functional Areas Description'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_FunctionalAreasText
  as select from /esrcc/fnc_areat
  association [1..1] to /ESRCC/I_FunctionalAreas_S as _FunctionalAreasAll on $projection.SingletonID = _FunctionalAreasAll.SingletonID
  association to parent /ESRCC/I_FunctionalAreas as _FunctionalAreas on $projection.FunctionalArea = _FunctionalAreas.FunctionalArea
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key functional_area as FunctionalArea,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _FunctionalAreasAll,
  _FunctionalAreas,
  _LanguageText
  
}
