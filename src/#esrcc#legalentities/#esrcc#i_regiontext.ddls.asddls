@EndUserText.label: 'Maintain Regions Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_RegionText
  as select from /ESRCC/REGIONST
  association [1..1] to /ESRCC/I_Region_S as _RegionAll on $projection.SingletonID = _RegionAll.SingletonID
  association to parent /ESRCC/I_Regions as _Regions on $projection.Region = _Regions.Region
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key REGION as Region,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _RegionAll,
  _Regions,
  _LanguageText
  
}
