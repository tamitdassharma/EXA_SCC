@EndUserText.label: 'Company Code Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CcodeText
  as projection on /ESRCC/I_CcodeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Sysid,
  key Ccode,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _LeToCompanyCode : redirected to parent /ESRCC/C_LeCcode,
  _LeToCompanyCodeAll : redirected to /ESRCC/C_LeCcode_S
  
}
