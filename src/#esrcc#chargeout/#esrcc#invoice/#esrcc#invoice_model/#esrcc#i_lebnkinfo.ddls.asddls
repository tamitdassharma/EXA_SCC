@EndUserText.label: 'Bank Information'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeBnkInfo
  as select from /esrcc/lebnkinfo
  association        to parent /ESRCC/I_LeBnkInfo_S as _BankInformationAll on $projection.SingletonID = _BankInformationAll.SingletonID
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _LegalEntityText    on _LegalEntityText.Legalentity = $projection.LegalEntity
{
  key legal_entity          as LegalEntity,
      bank_account_number   as BankAccountNumber,
      bic_code              as BicCode,
      payment_terms         as PaymentTerms,
      free_text             as FreeText,
      contact_person        as ContactPerson,
      agreement_id          as AgreementId,
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
      _BankInformationAll,
      _LegalEntityText

}
