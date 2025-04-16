@EndUserText.label: 'Company Code Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CcodeText
  as select from /ESRCC/CCODET
  association [1..1] to /ESRCC/I_LeCcode_S as _LeToCompanyCodeAll on $projection.SingletonID = _LeToCompanyCodeAll.SingletonID
  association to parent /ESRCC/I_LeCcode as _LeToCompanyCode on $projection.Sysid = _LeToCompanyCode.Sysid and $projection.Ccode = _LeToCompanyCode.Ccode
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key SYSID as Sysid,
  key CCODE as Ccode,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _LeToCompanyCodeAll,
  _LeToCompanyCode,
  _LanguageText
  
}
