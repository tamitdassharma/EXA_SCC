@EndUserText.label: 'Business Division Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_BusDivText
  as projection on /ESRCC/I_BusDivText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key BusinessDivision,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _BusinessDivision : redirected to parent /ESRCC/C_BusDiv,
  _BusinessDivisionAll : redirected to /ESRCC/C_BusDiv_S
  
}
