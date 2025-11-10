@EndUserText.label: 'Maintain TP Profile Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_TpProfText
  as select from /ESRCC/TPPROFT
  association [1..1] to /ESRCC/I_TpProf_S as _TpProfileAll on $projection.SingletonID = _TpProfileAll.SingletonID
  association to parent /ESRCC/I_TpProf as _TpProfile on $projection.Tpprofile = _TpProfile.Tpprofile
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key TPPROFILE as Tpprofile,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _TpProfileAll,
  _TpProfile,
  _LanguageText
  
}
