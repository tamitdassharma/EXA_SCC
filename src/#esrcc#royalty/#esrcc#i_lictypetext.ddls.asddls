@EndUserText.label: 'License Type Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_LicTypeText
  as select from /esrcc/lictyept
  association [1..1] to /ESRCC/I_LicType_S as _LicenseTypeAll on $projection.SingletonID = _LicenseTypeAll.SingletonID
  association to parent /ESRCC/I_LicType as _LicenseType on $projection.LicenseType = _LicenseType.LicenseType
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key license_type as LicenseType,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _LicenseTypeAll,
  _LicenseType,
  _LanguageText
  
}
