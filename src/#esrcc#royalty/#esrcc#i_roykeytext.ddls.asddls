@EndUserText.label: 'Royalty Base Keys Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_RoyKeyText
  as select from /ESRCC/ROYKEYT
  association [1..1] to /ESRCC/I_RoyKey_S as _RoyKeyAll on $projection.SingletonID = _RoyKeyAll.SingletonID
  association to parent /ESRCC/I_RoyKey as _RoyaltyKey on $projection.RoyaltyBaseKey = _RoyaltyKey.RoyaltyBaseKey
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key ROYALTY_BASE_KEY as RoyaltyBaseKey,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _RoyKeyAll,
  _RoyaltyKey,
  _LanguageText
  
}
