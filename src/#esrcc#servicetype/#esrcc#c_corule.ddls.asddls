@EndUserText.label: 'Charge out Rules - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CoRule
  as projection on /ESRCC/I_CoRule
{
  key RuleId,
//      @ObjectModel.text.element: ['CostVersionDescription']
//      CostVersion,
      @ObjectModel.text.element: ['ChargeoutMethodDescription']
      ChargeoutMethod,
      @ObjectModel.text.element: ['CapacityVersionDescription']
      CapacityVersion,
      @ObjectModel.text.element: ['ConsumptionVersionDescription']
      ConsumptionVersion,
      @ObjectModel.text.element: ['KeyVersionDescription']
      KeyVersion,
      @ObjectModel.text.element: ['AllocationKeyDescription']
      AdhocAllocationKey,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      WorkflowStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ChargeOut.text                             as ChargeoutMethodDescription,
      @Semantics.text: true
      _CapacityVersionText.text                   as CapacityVersionDescription,
      @Semantics.text: true
      _ConsumptionVersionText.text                as ConsumptionVersionDescription,
//      @Semantics.text: true
//      _CostVersionText.text                       as CostVersionDescription,
      @Semantics.text: true
      _KeyVersionText.text                        as KeyVersionDescription,
      @Semantics.text: true
      _AllocationKeyText.AllocationKeyDescription as AllocationKeyDescription,
      @Semantics.text: true
      _WorkflowStatusText.text                    as WorkflowStatusDescription,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideCostVersion,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideCapacityVersion,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideConsumptionVersion,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideKeyVersion,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideAdhocAllocationKey,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideWeightageTab,

      _RuleAll   : redirected to parent /ESRCC/C_CoRule_S,
      _RuleText  : redirected to composition child /ESRCC/C_CoRuleText,
      _Weightage : redirected to composition child /ESRCC/C_AllocWeightage,
      _RuleText.Description : localized

}
