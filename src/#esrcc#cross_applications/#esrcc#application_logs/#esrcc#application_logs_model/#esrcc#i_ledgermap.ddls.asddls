@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ledger Map'

define view entity /ESRCC/I_LedgerMap
  as select from /esrcc/ledgermap
  association [1..1] to /ESRCC/I_ExtractorConfig_S      as _ExtractorConfigAll on  _ExtractorConfigAll.SingletonID = $projection.SingletonID
  association        to parent /ESRCC/I_ExtractorConfig as _ExtractorConfig    on  _ExtractorConfig.SystemId    = $projection.Sysid
                                                                               and _ExtractorConfig.CompanyCode = $projection.Ccode
  association [0..1] to /esrcc/ledger_t                 as _LedgerText         on  _LedgerText.ledger = $projection.Ledger
                                                                               and _LedgerText.spras  = $session.system_language
{
  key sysid                 as Sysid,
  key ccode                 as Ccode,
  key ledger                as Ledger,
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

      _ExtractorConfigAll,
      _ExtractorConfig,
      _LedgerText
}
