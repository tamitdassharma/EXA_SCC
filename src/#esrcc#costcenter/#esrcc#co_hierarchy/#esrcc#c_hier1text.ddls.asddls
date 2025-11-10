@EndUserText.label: 'Maintain Hierarchy Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Hier1Text
  as projection on /ESRCC/I_Hier1Text
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Hierarchy,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _Hierarchy : redirected to parent /ESRCC/C_Hier1,
  _HierarchyAll : redirected to /ESRCC/C_Hier1_S
  
}
