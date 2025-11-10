@EndUserText.label: 'Maintain License Type Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LicTypeText
  as projection on /ESRCC/I_LicTypeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key LicenseType,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _LicenseType : redirected to parent /ESRCC/C_LicType,
  _LicenseTypeAll : redirected to /ESRCC/C_LicType_S
  
}
