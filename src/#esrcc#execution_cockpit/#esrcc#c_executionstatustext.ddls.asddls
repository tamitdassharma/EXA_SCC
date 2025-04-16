@EndUserText.label: 'Execution Cockpit Status Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_ExecutionStatusText
  as projection on /ESRCC/I_ExecutionStatusText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Application,
  key Status,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _ExecutionStatus : redirected to parent /ESRCC/C_ExecutionStatus,
  _ExecutionStatusAll : redirected to /ESRCC/C_ExecutionStatus_S
  
}
