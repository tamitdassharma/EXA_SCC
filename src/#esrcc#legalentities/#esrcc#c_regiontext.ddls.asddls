@EndUserText.label: 'Maintain Regions Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RegionText
  as projection on /ESRCC/I_RegionText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Region,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _Regions : redirected to parent /ESRCC/C_Regions,
  _RegionAll : redirected to /ESRCC/C_Region_S
  
}
