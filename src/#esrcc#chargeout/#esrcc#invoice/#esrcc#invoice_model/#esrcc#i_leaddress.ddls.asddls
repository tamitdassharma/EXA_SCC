@EndUserText.label: 'Legal Entity Address'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeAddress
  as select from /esrcc/le_addres
  association        to parent /ESRCC/I_LeAddress_S as _LeAddressAll    on $projection.SingletonID = _LeAddressAll.SingletonID
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _LegalEntityText on _LegalEntityText.Legalentity = $projection.LegalEntity
{
  key legal_entity          as LegalEntity,
      customer_number       as CustomerNumber,
      contact_person        as ContactPerson,
      street_1              as Street1,
      street_2              as Street2,
      city                  as City,
      zip                   as Zip,
      state                 as State,
      country               as Country,
      telephone             as Telephone,
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
      _LeAddressAll,
      _LegalEntityText

}
