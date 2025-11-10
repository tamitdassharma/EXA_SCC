@EndUserText.label: 'Hierarchy Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_Hier3Text
  as select from /ESRCC/HIER3_T
  association [1..1] to /ESRCC/I_Hier3_S as _HierarchyAll on $projection.SingletonID = _HierarchyAll.SingletonID
  association to parent /ESRCC/I_Hier3 as _Hierarchy on $projection.Hierarchy = _Hierarchy.Hierarchy
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key HIERARCHY as Hierarchy,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _HierarchyAll,
  _Hierarchy,
  _LanguageText
  
}
