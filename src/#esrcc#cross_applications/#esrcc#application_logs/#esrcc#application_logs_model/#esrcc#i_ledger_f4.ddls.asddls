@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ledger'

@Search.searchable: true
define view entity /ESRCC/I_Ledger_F4
  as select from /esrcc/ledger
  association [0..1] to /esrcc/ledger_t as _LedgerText on  _LedgerText.ledger = $projection.Ledger
                                                       and _LedgerText.spras  = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @ObjectModel.text.element: ['Description']
  key ledger                  as Ledger,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      _LedgerText.description as Description
}
where
  active = 'X'
