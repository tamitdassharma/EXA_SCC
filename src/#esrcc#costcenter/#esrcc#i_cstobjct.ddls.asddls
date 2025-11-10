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
  association [0..1] to /esrcc/hier1_t             as _Hierarchy1Text       on  _Hierarchy1Text.hierarchy = $projection.Hierarchy1
                                                                            and _Hierarchy1Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier2_t             as _Hierarchy2Text       on  _Hierarchy2Text.hierarchy = $projection.Hierarchy2
                                                                            and _Hierarchy2Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier3_t             as _Hierarchy3Text       on  _Hierarchy3Text.hierarchy = $projection.Hierarchy3
                                                                            and _Hierarchy3Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier4_t             as _Hierarchy4Text       on  _Hierarchy4Text.hierarchy = $projection.Hierarchy4
                                                                            and _Hierarchy4Text.spras     = $session.system_language
  association [0..1] to /ESRCC/I_BILLINGFREQ       as _BillingFreqText      on  _BillingFreqText.Billingfreq = $projection.BillingFrequency
  association [0..1] to /ESRCC/I_LegalEntityAll_F4 as _LegalEntity          on  _LegalEntity.Legalentity = $projection.LegalEntity
{
  key cost_object_uuid      as CostObjectUuid,
      sysid                 as Sysid,
      legal_entity          as LegalEntity,
      company_code          as CompanyCode,
      cost_object           as CostObject,
      cost_center           as CostCenter,
      active                as Active,
      functional_area       as FunctionalArea,
      profit_center         as ProfitCenter,
      business_division     as BusinessDivision,
      hierarchy1            as Hierarchy1,
      hierarchy2            as Hierarchy2,
      hierarchy3            as Hierarchy3,
      hierarchy4            as Hierarchy4,
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
      _Hierarchy1Text,
      _Hierarchy2Text,
      _Hierarchy3Text,
      _Hierarchy4Text,
      _BillingFreqText,
      _LegalEntity
}
