@EndUserText.label: 'Other Information'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeOthers
  as select from /esrcc/le_others
  association        to parent /ESRCC/I_LeOthers_S     as _OtherInformationAll on  $projection.SingletonID = _OtherInformationAll.SingletonID
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CompanyCodeText     on  _CompanyCodeText.Sysid       = $projection.Sysid
                                                                               and _CompanyCodeText.Ccode       = $projection.CompanyCode
                                                                               and _CompanyCodeText.Legalentity = $projection.LegalEntity
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemText          on  _SystemText.SystemId = $projection.Sysid
                                                                               and _SystemText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_ROLE                  as _Role                on  _Role.Role = $projection.Role
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObject          on  _CostObject.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4        as _BusinessDivision    on  _BusinessDivision.BusinessDivision = $projection.BusinessDivision
  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4   as _TransactionGroup    on  _TransactionGroup.Transactiongroup = $projection.TransactionGroup
{
  key legal_entity            as LegalEntity,
  key role                    as Role,
  key sysid                   as Sysid,
  key company_code            as CompanyCode,
  key cost_object             as Costobject,
  key business_division       as BusinessDivision,
  key transaction_group       as TransactionGroup,
      account                 as Account,
      business_partner_number as BusinessPartnerNumber,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,
      1                       as SingletonID,
      _OtherInformationAll,
      _CompanyCodeText,
      _SystemText,
      _Role,
      _CostObject,
      _BusinessDivision,
      _TransactionGroup
}
