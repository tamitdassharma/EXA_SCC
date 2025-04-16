@EndUserText.label: 'Functional areas Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_FunctionalAreasText
  as projection on /ESRCC/I_FunctionalAreasText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key FunctionalArea,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _FunctionalAreas : redirected to parent /ESRCC/C_FunctionalAreas,
  _FunctionalAreasAll : redirected to /ESRCC/C_FunctionalAreas_S
  
}
