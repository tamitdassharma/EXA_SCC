@EndUserText.label: 'Service Product Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvProText
  as projection on /ESRCC/I_SrvProText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Serviceproduct,
  Description,
  Activities,
  Benefit,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _ServiceProduct : redirected to parent /ESRCC/C_SrvPro,
  _ServiceProductAll : redirected to /ESRCC/C_SrvPro_S
  
}
