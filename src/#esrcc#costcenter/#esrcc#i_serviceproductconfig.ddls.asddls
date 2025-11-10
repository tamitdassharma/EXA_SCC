@EndUserText.label: 'Stewardship'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define root view entity /ESRCC/I_SERVICEPRODUCTCONFIG
 as select from /ESRCC/I_STEWARDSHIPCONFIG
  
  association [1..1] to /ESRCC/I_CstObjct    as _RecCostObject         on _RecCostObject.CostObjectUuid = $projection.ReceiverCostObjectUuid
  
  association [0..*] to /esrcc/co_rule as _stdcorule on _stdcorule.rule_id = $projection.chargeoutruleid
  
  association [0..*] to /esrcc/aloc_wgt as _stdalocwgt on _stdalocwgt.rule_id = $projection.chargeoutruleid
  
  association [0..*] to /esrcc/co_rule as _trucorule on _trucorule.rule_id = $projection.TrueupChargeoutRuleId
  
  association [0..*] to /esrcc/aloc_wgt as _trualocwgt on _trualocwgt.rule_id = $projection.chargeoutruleid
  
{
    key StewardshipUuid,
    key ServiceProductUuid,
    key _stwdsprec.service_product_uuid as ServiceProductRecUuid,
    ValidFrom,
    Validto,
    Stewardship,
    CostObjectUuid,
    ChainId,
    ChainSequence,
    WorkflowId,
    WorkflowStatus,
    WorkflowStatusCriticality,
//    CommentId,
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
    
    _SrvPro.Servicetype,
    _SrvPro.Transactiongroup,
    _SrvPro.OecdTpg,
    _SrvPro.IpOwner,
    
    _SrvMarkup.IntraOrigcost,
    _SrvMarkup.IntraPasscost,
    _SrvMarkup.Origcost,
    _SrvMarkup.Passcost,
    _SrvMarkup.Validfrom as MarkupValidFrom,
    _SrvMarkup.Validto   as MarkupValidto,
    _SrvMarkup.WorkflowStatus as MarkupStatus,
    _SrvMarkup.WorkflowStatusCriticality as MarkupStatusCriticality,
   
    
    _SrvRule.ChargeoutRuleId,
    _SrvRule.Validfrom as RuleValidFrom,
    _SrvRule.Validto   as RuleValidTo,    
    
    
    _TruRule.ChargeoutRuleId as TrueupChargeoutRuleId,
    _TruRule.Validfrom as TruRuleValidFrom,
    _TruRule.Validto   as TruRuleValidTo,
    
    _stwdsprec.cost_object_uuid as ReceiverCostObjectUuid,
    _stwdsprec.contract_id as ContractId,
    _stwdsprec.erp_sales_order as ErpSalesOrder,
    _stwdsprec.invoice_currency as InvoiceCurrency,
    _stwdsprec.active,
    

//    _stwdsprec.
    /* Associations */
    _CostObject,
    _SrvMarkup,
    _SrvPro,
    _SrvRule,
    _stwdsprec,
    _TruRule,
    _stdcorule,
    _stdalocwgt,
    _trucorule,
    _trualocwgt,
    _RecCostObject 
}
