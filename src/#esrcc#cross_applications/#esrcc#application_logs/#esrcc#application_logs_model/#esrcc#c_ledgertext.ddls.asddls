@EndUserText.label: 'Maintain Ledger Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LedgerText
  as projection on /ESRCC/I_LedgerText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Ledger,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _Ledger : redirected to parent /ESRCC/C_Ledger,
  _LedgerAll : redirected to /ESRCC/C_Ledger_S
  
}
