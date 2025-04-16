@EndUserText.label: 'Cost Exclusion Inclusion Reason Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_ReasonText
  as select from /ESRCC/REASONT
  association [1..1] to /ESRCC/I_Reason_S as _ReasonAll on $projection.SingletonID = _ReasonAll.SingletonID
  association to parent /ESRCC/I_Reason as _Reason on $projection.Reasonid = _Reason.Reasonid
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key REASONID as Reasonid,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _ReasonAll,
  _Reason,
  _LanguageText
  
}
