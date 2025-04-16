@EndUserText.label: 'Service Transaction group Text - Maintai'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvTgText
  as projection on /ESRCC/I_SrvTgText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Transactiongroup,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _TransactionGrp : redirected to parent /ESRCC/C_SrvTg,
  _TransactionGrpAll : redirected to /ESRCC/C_SrvTg_S
  
}
