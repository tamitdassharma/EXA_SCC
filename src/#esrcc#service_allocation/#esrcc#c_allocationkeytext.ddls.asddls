@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Allocation Key Text - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_AllocationKeyText
  as projection on /ESRCC/I_AllocationKeyText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Allocationkey,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _AllocationKey : redirected to parent /ESRCC/C_AllocationKey,
  _AllocationKeyAll : redirected to /ESRCC/C_AllocationKey_S
  
}
