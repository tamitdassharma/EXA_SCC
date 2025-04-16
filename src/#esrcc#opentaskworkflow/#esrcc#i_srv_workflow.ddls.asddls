@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Final Charge Out Amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_SRV_WORKFLOW
  as select from /ESRCC/I_ServiceProductShare as srvcost

{
  key UUID,
  key ParentUUID,
  key Currencytype,
      _CostCenterCost.Fplv,
      _CostCenterCost.Ryear,
      _CostCenterCost.Poper,
      _CostCenterCost.Sysid,
      _CostCenterCost.Legalentity,
      _CostCenterCost.Ccode,
      _CostCenterCost.Costobject,
      _CostCenterCost.Costcenter,
      Serviceproduct,
      Servicetype,
      Transactiongroup,
      CapacityVersion,
      Costshare,
      Srvcostshare,
      Valueaddshare,
      Passthroughshare,
      Chargeout,
      Planning,
      PlanningUom,
      Servicecostperunit,
      Valueaddcostperunit,
      Passthrucostperunit,
      srvcost.Status,
      Workflowid,
      hidedirectalloc,
      statuscriticallity,
      _CostCenterCost.costdatasetdescription,
      _CostCenterCost.legalentitydescription,
      _CostCenterCost.ccodedescription,
      _CostCenterCost.costobjectdescription,
      _CostCenterCost.costcenterdescription,
      Serviceproductdescription,
      Servicetypedescription,
      Transactiongroupdescription,
      statusdescription,
      _CostCenterCost.Stewardship,
      Currency,
      _CostCenterCost.Country,
      chargeoutdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,

      //      associations
      _UoM,
      _CurrencyTypeText,
      _CostCenterCost._legalCountryText

}
