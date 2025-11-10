@EndUserText.label: 'Maintain Ledger'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Ledger
  as projection on /ESRCC/I_Ledger
{
  key Ledger,
  Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LedgerAll : redirected to parent /ESRCC/C_Ledger_S,
  _LedgerText : redirected to composition child /ESRCC/C_LedgerText,
  _LedgerText.Description : localized
  
}
