@EndUserText.label: 'Profit Center Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_PfcText
  as select from /ESRCC/PFCT
  association [1..1] to /ESRCC/I_Pfc_S as _ProfitCenterAll on $projection.SingletonID = _ProfitCenterAll.SingletonID
  association to parent /ESRCC/I_Pfc as _ProfitCenter on $projection.ProfitCenter = _ProfitCenter.ProfitCenter
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key PROFIT_CENTER as ProfitCenter,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _ProfitCenterAll,
  _ProfitCenter,
  _LanguageText
  
}
