@EndUserText.label: 'Ledger Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_LedgerText
  as select from /ESRCC/LEDGER_T
  association [1..1] to /ESRCC/I_Ledger_S as _LedgerAll on $projection.SingletonID = _LedgerAll.SingletonID
  association to parent /ESRCC/I_Ledger as _Ledger on $projection.Ledger = _Ledger.Ledger
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key LEDGER as Ledger,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _LedgerAll,
  _Ledger,
  _LanguageText
  
}
