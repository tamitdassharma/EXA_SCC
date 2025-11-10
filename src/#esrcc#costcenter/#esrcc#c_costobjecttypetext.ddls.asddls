@EndUserText.label: 'Cost Object Type Text - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostObjectTypeText
  as projection on /ESRCC/I_CostObjectTypeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key CostObject,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _CostObjectType : redirected to parent /ESRCC/C_CostObjectType,
  _CostObjectTypeAll : redirected to /ESRCC/C_CostObjectType_S
  
}
