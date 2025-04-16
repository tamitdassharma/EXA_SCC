@EndUserText.label: 'Cost Object'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CstObjct
  as select from /esrcc/cst_objct
  association        to parent /ESRCC/I_CstObjct_S as _CostObjectAll        on  $projection.SingletonID = _CostObjectAll.SingletonID
  composition [0..*] of /ESRCC/I_CstObjctText      as _CostObjectText
  association [0..1] to /ESRCC/I_COMPANYCODES_F4   as _CcodeText            on  _CcodeText.Sysid       = $projection.Sysid
                                                                            and _CcodeText.Ccode       = $projection.CompanyCode
                                                                            and _CcodeText.Legalentity = $projection.LegalEntity
  association [0..1] to /esrcc/sys_infot           as _SysidText            on  _SysidText.system_id = $projection.Sysid
                                                                            and _SysidText.spras     = $session.system_language
  association [0..1] to /ESRCC/I_COSTOBJECTS       as _CostObjTypeText      on  _CostObjTypeText.Costobject = $projection.CostObject
  association [0..1] to /ESRCC/I_PROFITCENTER_F4   as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter
  association [0..1] to /ESRCC/I_FunctionalArea_F4 as _FunctionalAreaText   on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4    as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision
  association [0..1] to /ESRCC/I_BILLINGFREQ       as _BillingFreqText      on  _BillingFreqText.Billingfreq = $projection.BillingFrequency
  association [0..1] to /ESRCC/I_LegalEntityAll_F4 as _LegalEntity          on  _LegalEntity.Legalentity = $projection.LegalEntity
{
  key cost_object_uuid      as CostObjectUuid,
      sysid                 as Sysid,
      legal_entity          as LegalEntity,
      company_code          as CompanyCode,
      cost_object           as CostObject,
      cost_center           as CostCenter,
      functional_area       as FunctionalArea,
      profit_center         as ProfitCenter,
      business_division     as BusinessDivision,
      billing_frequency     as BillingFrequency,
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
      _CostObjectAll,
      _CostObjectText,
      _SysidText,
      _CcodeText,
      _CostObjTypeText,
      _FunctionalAreaText,
      _ProfitCenterText,
      _BusinessDivisionText,
      _BillingFreqText,
      _LegalEntity
}
