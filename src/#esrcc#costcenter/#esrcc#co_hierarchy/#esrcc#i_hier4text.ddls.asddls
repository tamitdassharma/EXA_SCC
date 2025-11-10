@EndUserText.label: 'Activity Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_Hier4Text
  as select from /esrcc/hier4_t
  association [1..1] to /ESRCC/I_Hier4_S as _HierarchyAll on $projection.SingletonID = _HierarchyAll.SingletonID
  association to parent /ESRCC/I_Hier4 as _Hierarchy on $projection.Hierarchy = _Hierarchy.Hierarchy
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key hierarchy as Hierarchy,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _HierarchyAll,
  _Hierarchy,
  _LanguageText
  
}
