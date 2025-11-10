@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ledger'
@Metadata.allowExtensions: true

define view entity /ESRCC/C_LedgerMap
  as projection on /ESRCC/I_LedgerMap
{
  key Sysid,
  key Ccode,
      @ObjectModel.text.element: ['LedgerDescription']
  key Ledger,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _LedgerText.description as LedgerDescription,
      
      _ExtractorConfigAll : redirected to /ESRCC/C_ExtractorConfig_S,
      _ExtractorConfig    : redirected to parent /ESRCC/C_ExtractorConfig

}
