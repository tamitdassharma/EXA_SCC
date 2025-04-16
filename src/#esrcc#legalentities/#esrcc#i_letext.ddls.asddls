@EndUserText.label: 'Legal Entity Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_LEText
  as select from /ESRCC/LE_T
  association [1..1] to /ESRCC/I_LE_S as _LegalEntityAll on $projection.SingletonID = _LegalEntityAll.SingletonID
  association to parent /ESRCC/I_LE as _LegalEntity on $projection.Legalentity = _LegalEntity.Legalentity
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key LEGALENTITY as Legalentity,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _LegalEntityAll,
  _LegalEntity,
  _LanguageText
  
}
