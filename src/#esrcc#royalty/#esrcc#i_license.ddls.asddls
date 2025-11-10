@EndUserText.label: 'License'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_License
  as select from /esrcc/license
  association        to parent /ESRCC/I_License_S   as _LicenseAll      on $projection.SingletonID = _LicenseAll.SingletonID
  composition [0..*] of /ESRCC/I_LicenseText        as _LicenseText
  association [1..1] to /ESRCC/I_LicenseType_F4     as _LicenseTypeText on _LicenseTypeText.LicenseType = $projection.LicenseTyp
  association [1..1] to /ESRCC/I_RoyaltyCompRule_F4 as _ComputationRule on _ComputationRule.RuleId = $projection.RuleId
{
  key license               as License,
      license_type          as LicenseTyp,
      rule_id               as RuleId, 
      valid_from            as ValidFrom,
      valid_to              as ValidTo,
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
      _LicenseAll,
      _LicenseText,
      _LicenseTypeText,
      _ComputationRule

}
