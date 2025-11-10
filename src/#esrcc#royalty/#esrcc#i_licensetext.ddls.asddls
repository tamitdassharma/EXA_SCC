@EndUserText.label: 'License Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_LicenseText
  as select from /esrcc/licenset
  association [1..1] to /ESRCC/I_License_S      as _LicenseAll   on $projection.SingletonID = _LicenseAll.SingletonID
  association        to parent /ESRCC/I_License as _License      on $projection.License = _License.License
  association [0..*] to I_LanguageText          as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key license               as License,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _LicenseAll,
      _License,
      _LanguageText

}
