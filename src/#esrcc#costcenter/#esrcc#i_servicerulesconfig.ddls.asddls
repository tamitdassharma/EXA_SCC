@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Rules'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_SERVICERULESCONFIG
  as select from /ESRCC/I_SERVICEPRODUCTCONFIG

  association [0..1] to /esrcc/co_rulet              as _ruletext                  on  _ruletext.rule_id = $projection.ChargeoutRuleId
                                                                                   and _ruletext.spras   = $session.system_language
  association [0..1] to /ESRCC/I_CHGOUT              as _ChargeOut                 on  _ChargeOut.Chargeout = $projection.ChargeoutMethod
  association [0..1] to /ESRCC/I_CAPACITY_VERSION    as _CapacityVersionText       on  _CapacityVersionText.CapacityVersion = $projection.CapacityVersion
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionVersionText    on  _ConsumptionVersionText.ConsumptionVersion = $projection.ConsumptionVersion
  association [0..1] to /ESRCC/I_KEY_VERSION         as _KeyVersionText            on  _KeyVersionText.KeyVersion = $projection.KeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllocKeyText                on _AllocKeyText.Allocationkey = $projection.AllocationKey
  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD  as _AllocPeriodText             on _AllocPeriodText.AllocationPeriod = $projection.AllocationPeriod

  association [0..1] to /esrcc/co_rulet              as _Truruletext               on  _Truruletext.rule_id = $projection.TrueupChargeoutRuleId
                                                                                   and _Truruletext.spras   = $session.system_language
  association [0..1] to /ESRCC/I_CHGOUT              as _TruChargeOut              on  _TruChargeOut.Chargeout = $projection.TruChargeoutMethod
  association [0..1] to /ESRCC/I_CAPACITY_VERSION    as _TruCapacityVersionText    on  _TruCapacityVersionText.CapacityVersion = $projection.TruCapacityVersion
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _TruConsumptionVersionText on  _TruConsumptionVersionText.ConsumptionVersion = $projection.TruConsumptionVersion
  association [0..1] to /ESRCC/I_KEY_VERSION         as _TruKeyVersionText         on  _TruKeyVersionText.KeyVersion = $projection.TruKeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _TruAllocKeyText                on _TruAllocKeyText.Allocationkey = $projection.TruAllocationKey
  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD  as _TruAllocPeriodText             on _TruAllocPeriodText.AllocationPeriod = $projection.TruAllocationPeriod

{
  key StewardshipUuid,
  key ServiceProductUuid,
  key ServiceProductRecUuid,
      ValidFrom,
      Validto,
      Stewardship,
      CostObjectUuid,
      ChainId,
      ChainSequence,
      WorkflowStatus,
      WorkflowStatusCriticality,
 
      Sysid,
      LegalEntity,
      CompanyCode,
      CostObject,
      CostCenter,
      BusinessDivision,
      FunctionalArea,
      ProfitCenter,
      Hierarchy1,
      Hierarchy2,
      Hierarchy3,
      Hierarchy4,

      ServiceProduct,
      ShareOfCost,
      SpValidFrom,
      SpValidto,
      Servicetype,
      Transactiongroup,
      OecdTpg,
      IpOwner,

      IntraOrigcost,
      IntraPasscost,
      Origcost,
      Passcost,
      MarkupValidFrom,
      MarkupValidto,
      MarkupStatus,
      MarkupStatusCriticality,

      ChargeoutRuleId,
      RuleValidFrom,
      RuleValidTo,
      _stdcorule.chargeout_method                              as ChargeoutMethod,
      _stdcorule.capacity_version                              as CapacityVersion,
      _stdcorule.consumption_version                           as ConsumptionVersion,
      _stdcorule.key_version                                   as KeyVersion,
      _stdcorule.workflow_status                               as StdWorkflowStatus,
      case _stdcorule.workflow_status 
      -- Red
        when 'R' then 1
        when 'E' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                                        as StdWorkflowStatusCriticality,
      _stdalocwgt.allocation_key                               as AllocationKey,
      _stdalocwgt.allocation_period                            as AllocationPeriod,
      _stdalocwgt.ref_period                                   as RefPeriod,
      _stdalocwgt.weightage                                    as Weightage,
      


      TrueupChargeoutRuleId,
      TruRuleValidFrom,
      TruRuleValidTo,
      _trucorule.chargeout_method                              as TruChargeoutMethod,
      _trucorule.capacity_version                              as TruCapacityVersion,
      _trucorule.consumption_version                           as TruConsumptionVersion,
      _trucorule.key_version                                   as TruKeyVersion,
      _trucorule.workflow_status                               as TruWorkflowStatus,
      _trualocwgt.allocation_key                               as TruAllocationKey,
      _trualocwgt.allocation_period                            as TruAllocationPeriod,
      _trualocwgt.ref_period                                   as TruRefPeriod,
      _trualocwgt.weightage                                    as TruWeightage,
      
      case _trucorule.workflow_status 
      -- Red
        when 'R' then 1
        when 'E' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                                        as TruWorkflowStatusCriticality,

      ReceiverCostObjectUuid,
      cast( _RecCostObject.Sysid as /esrcc/recsysid )              as ReceiverSysid,
      cast( _RecCostObject.LegalEntity as /esrcc/receivingntity )  as ReceiverLegalEntity,
      cast( _RecCostObject.CompanyCode as /esrcc/recccode_de )     as ReceiverCompanyCode,
      cast( _RecCostObject.CostObject as /esrcc/reccostobject_de ) as ReceiverCostobject,
      cast( _RecCostObject.CostCenter as /esrcc/reccostcenter )    as ReceiverCostCenter,
   
      ContractId,
      ErpSalesOrder,
      InvoiceCurrency,
      active,
      
      _RecCostObject.BusinessDivision                          as RecBusinessDivision,
      _RecCostObject.FunctionalArea                            as RecFunctionalArea,
      _RecCostObject.ProfitCenter                              as RecProfitCenter,
      _RecCostObject.Hierarchy1                                as RecHierarchy1,
      _RecCostObject.Hierarchy2                                as RecHierarchy2,
      _RecCostObject.Hierarchy3                                as RecHierarchy3,
      _RecCostObject.Hierarchy4                                as RecHierarchy4,


      /* Associations */
      _CostObject,
      _RecCostObject,
      _SrvMarkup,
      _SrvPro,
      _SrvRule,
      _stdalocwgt,
      _stdcorule,
      _stwdsprec,
      _trualocwgt,
      _trucorule,
      _TruRule,
      _ruletext,
      _ChargeOut,
      _CapacityVersionText,
      _ConsumptionVersionText,
      _KeyVersionText,
      _AllocKeyText,
      _AllocPeriodText,
      
      _TruChargeOut,
      _TruCapacityVersionText,
      _TruConsumptionVersionText,
      _TruKeyVersionText,
      _Truruletext,
      _TruAllocKeyText,
      _TruAllocPeriodText
}
