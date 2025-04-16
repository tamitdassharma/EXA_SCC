@EndUserText.label: 'Tax Information'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeTaxInfo
  as select from /esrcc/letaxinfo
  association        to parent /ESRCC/I_LeTaxInfo_S as _TaxInformationAll on $projection.SingletonID = _TaxInformationAll.SingletonID
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _LegalEntityText   on _LegalEntityText.Legalentity = $projection.LegalEntity
{
  key legal_entity           as LegalEntity,
      vat_number             as VatNumber,
      tax_registation_number as TaxRegistationNumber,
      tax_percentage         as TaxPercentage,
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,
      1                      as SingletonID,
      _TaxInformationAll,
      _LegalEntityText

}
