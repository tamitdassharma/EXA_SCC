@EndUserText.label: 'Stewardship'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_SERVICERELATIONCONFIG
  as select from /ESRCC/I_SERVICERULESCONFIG

  association [1..1] to /ESRCC/I_STATUS as _WorkflowStatusText    on _WorkflowStatusText.Status = $projection.WorkflowStatus

  association [1..1] to /ESRCC/I_STATUS as _MarkupStatusText      on _MarkupStatusText.Status = $projection.MarkupStatus

  association [1..1] to /ESRCC/I_STATUS as _StdWorkflowStatusText on _StdWorkflowStatusText.Status = $projection.StdWorkflowStatus

  association [1..1] to /ESRCC/I_STATUS as _TruWorkflowStatusText on _TruWorkflowStatusText.Status = $projection.TruWorkflowStatus

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
      @ObjectModel.text.element: [ 'StewardshipStatusDescription' ]
      WorkflowStatus,
      WorkflowStatusCriticality,
      Sysid,
      @ObjectModel.text.element: [ 'LegalentityDescription' ]
      LegalEntity,
      @ObjectModel.text.element: [ 'ccodedescription' ]
      CompanyCode,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      CostObject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      CostCenter,
      @ObjectModel.text.element: [ 'busineesdescription' ]
      BusinessDivision,
      @ObjectModel.text.element: [ 'functionalareadescription' ]
      FunctionalArea,
      @ObjectModel.text.element: [ 'profitcenterdescription' ]
      ProfitCenter,
      Hierarchy1,
      Hierarchy2,
      Hierarchy3,
      Hierarchy4,

      @ObjectModel.text.element: [ 'serviceproductdescription' ]
      ServiceProduct,
      ShareOfCost,
      SpValidFrom,
      SpValidto,
      @ObjectModel.text.element: [ 'servicetypedescription' ]
      Servicetype,
      @ObjectModel.text.element: [ 'transactiongrpdescription' ]
      Transactiongroup,
      @ObjectModel.text.element: [ 'oecdtext' ]
      OecdTpg,
      IpOwner,

      IntraOrigcost,
      IntraPasscost,
      Origcost,
      Passcost,
      MarkupValidFrom,
      MarkupValidto,
      @ObjectModel.text.element: [ 'MarkupStatusText' ]
      MarkupStatus,
      MarkupStatusCriticality,

      @ObjectModel.text.element: [ 'ruledescription' ]
      ChargeoutRuleId,
      RuleValidFrom,
      RuleValidTo,
      @ObjectModel.text.element: [ 'ChargeoutMethodDescription' ]
      ChargeoutMethod,
      @ObjectModel.text.element: [ 'CapacityVersionDescription' ]
      CapacityVersion,
      @ObjectModel.text.element: [ 'ConsumptionVersionDescription' ]
      ConsumptionVersion,
      @ObjectModel.text.element: [ 'KeyVersionDescription' ]
      KeyVersion,
      @ObjectModel.text.element: [ 'AllocationKeyDescription' ]
      AllocationKey,
      @ObjectModel.text.element: [ 'AllocationPeriodDescription' ]
      AllocationPeriod,
      RefPeriod,
      Weightage,
      @ObjectModel.text.element: [ 'StdStatusText' ]
      StdWorkflowStatus,
      StdWorkflowStatusCriticality,

      @ObjectModel.text.element: [ 'TruRuledescription' ]
      TrueupChargeoutRuleId,
      TruRuleValidFrom,
      TruRuleValidTo,
      @ObjectModel.text.element: [ 'TruChargeoutMethodDescription' ]
      TruChargeoutMethod,
      @ObjectModel.text.element: [ 'TruCapacityVersionDescription' ]
      TruCapacityVersion,
      @ObjectModel.text.element: [ 'TruConsumpVersionDescr' ]
      TruConsumptionVersion,
      @ObjectModel.text.element: [ 'TruKeyVersionDescription' ]
      TruKeyVersion,
      @ObjectModel.text.element: [ 'TruAllocationKeyDescription' ]
      TruAllocationKey,
      @ObjectModel.text.element: [ 'TruAllocationPeriodDescription' ]
      TruAllocationPeriod,
      TruRefPeriod,
      TruWeightage,
      @ObjectModel.text.element: [ 'TruStatusText' ]
      TruWorkflowStatus,
      TruWorkflowStatusCriticality,

      ReceiverCostObjectUuid,
      ReceiverSysid,
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
      ReceiverLegalEntity,
      @ObjectModel.text.element: [ 'receivercostobjectdescription' ]
      ReceiverCostobject,
      @ObjectModel.text.element: [ 'receivercostcenterdescription' ]
      ReceiverCostCenter,
      @ObjectModel.text.element: [ 'receiverccodedescription' ]
      ReceiverCompanyCode,
      ContractId,
      ErpSalesOrder,
      InvoiceCurrency,
      active,
      @ObjectModel.text.element: [ 'recbusineesdescription' ]
      RecBusinessDivision,
      @ObjectModel.text.element: [ 'recfunctionalareadescription' ]
      RecFunctionalArea,
      @ObjectModel.text.element: [ 'recprofitcenterdescription' ]
      RecProfitCenter,
      RecHierarchy1,
      RecHierarchy2,
      RecHierarchy3,
      RecHierarchy4,


      // Descriptions
      _CostObject._CcodeText.LegalentityDescription,
      _CostObject._CcodeText.ccodedescription,
      _CostObject._CostObjTypeText.text                        as costobjectdescription,
      _CostObject._CostObjectText.Description                  as costcenterdescription,
      _CostObject._BusinessDivisionText.Description            as busineesdescription,
      _CostObject._ProfitCenterText.profitcenterdescription    as profitcenterdescription,
      _CostObject._FunctionalAreaText.Description              as functionalareadescription,
      _WorkflowStatusText.text                                 as StewardshipStatusDescription,

      _SrvPro._ServiceProductText.Description                  as serviceproductdescription,
      _SrvPro._ServiceType.Description                         as servicetypedescription,
      _SrvPro._TransactionGroup.Description                    as transactiongrpdescription,
      _SrvPro._OECD.text                                       as oecdtext,
      _MarkupStatusText.text                                   as MarkupStatusText,

      _ruletext.description                                    as ruledescription,
      _AllocKeyText.AllocationKeyDescription,
      _CapacityVersionText.text                                as CapacityVersionDescription,
      _ConsumptionVersionText.text                             as ConsumptionVersionDescription,
      _KeyVersionText.text                                     as KeyVersionDescription,
      _ChargeOut.text                                          as ChargeoutMethodDescription,
      _AllocPeriodText.text                                    as AllocationPeriodDescription,
      _StdWorkflowStatusText.text                              as StdStatusText,

      _Truruletext.description                                 as TruRuledescription,
      _TruAllocKeyText.AllocationKeyDescription                as TruAllocationKeyDescription,
      _TruCapacityVersionText.text                             as TruCapacityVersionDescription,
      _TruConsumptionVersionText.text                          as TruConsumpVersionDescr,
      _TruKeyVersionText.text                                  as TruKeyVersionDescription,
      _TruChargeOut.text                                       as TruChargeoutMethodDescription,
      _TruAllocPeriodText.text                                 as TruAllocationPeriodDescription,
      _TruWorkflowStatusText.text                              as TruStatusText,
      //

      _RecCostObject._CcodeText.LegalentityDescription         as receivingentitydescription,
      _RecCostObject._CcodeText.ccodedescription               as receiverccodedescription,
      _RecCostObject._CostObjTypeText.text                     as receivercostobjectdescription,
      _RecCostObject._CostObjectText.Description               as receivercostcenterdescription,
      _RecCostObject._BusinessDivisionText.Description         as recbusineesdescription,
      _RecCostObject._ProfitCenterText.profitcenterdescription as recprofitcenterdescription,
      _RecCostObject._FunctionalAreaText.Description           as recfunctionalareadescription

//      /* Associations */
//      _AllocKeyText,
//      _AllocPeriodText,
//      _CapacityVersionText,
//      _ChargeOut,
//      _ConsumptionVersionText,
//      _CostObject,
//      _KeyVersionText,
//      _RecCostObject,
//      _ruletext,
//      _SrvMarkup,
//      _SrvPro,
//      _SrvRule,
//      _stdalocwgt,
//      _stdcorule,
//      _stwdsprec,
//      _TruAllocKeyText,
//      _TruAllocPeriodText,
//      _trualocwgt,
//      _TruCapacityVersionText,
//      _TruChargeOut,
//      _TruConsumptionVersionText,
//      _trucorule,
//      _TruKeyVersionText,
//      _TruRule,
//      _Truruletext

}
