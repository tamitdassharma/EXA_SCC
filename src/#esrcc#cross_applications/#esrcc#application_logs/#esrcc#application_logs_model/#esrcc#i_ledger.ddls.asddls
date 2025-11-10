@EndUserText.label: 'Ledger'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Ledger
  as select from /esrcc/ledger
  association to parent /ESRCC/I_Ledger_S   as _LedgerAll on $projection.SingletonID = _LedgerAll.SingletonID
  composition [0..*] of /ESRCC/I_LedgerText as _LedgerText
{
  key ledger                as Ledger,
      active                as Active,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _LedgerAll,
      _LedgerText

}
