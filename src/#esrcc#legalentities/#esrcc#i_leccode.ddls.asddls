@EndUserText.label: 'Legal Entity to Company Code'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeCcode
  as select from /esrcc/le_ccode
  association        to parent /ESRCC/I_LeCcode_S      as _LeToCompanyCodeAll on  $projection.SingletonID = _LeToCompanyCodeAll.SingletonID
  composition [0..*] of /ESRCC/I_CcodeText             as _CompanyCodeText
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText     on  _SystemInfoText.SystemId = $projection.Sysid
                                                                              and _SystemInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_LegalEntityAll_F4     as _LegalEntity        on  _LegalEntity.Legalentity = $projection.Legalentity
{
  key sysid                     as Sysid,
  key ccode                     as Ccode,
      legalentity               as Legalentity,
      controllingarea           as Controllingarea,
      active                    as Active,
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,
      1                         as SingletonID,
      _LeToCompanyCodeAll,
      _SystemInfoText,
      _CompanyCodeText,
      _LegalEntity

}
