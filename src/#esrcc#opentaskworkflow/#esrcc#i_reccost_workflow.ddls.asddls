@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_RECCOST_WORKFLOW 
            as select from /ESRCC/I_ReceiverChargeout as reccost                                                           

{
    key UUID,
    key ParentUUID,
    key RootUUID,
    key Currencytype,
    _ServiceCost._CostCenterCost.Fplv,
    _ServiceCost._CostCenterCost.Ryear,
    _ServiceCost._CostCenterCost.Poper,
    _ServiceCost._CostCenterCost.Sysid,
    _ServiceCost._CostCenterCost.Legalentity,
    _ServiceCost._CostCenterCost.Ccode,
    _ServiceCost._CostCenterCost.Costobject,
    _ServiceCost._CostCenterCost.Costcenter,
    _ServiceCost.Serviceproduct,
    ReceiverSysId,
    ReceiverCompanyCode,
    Receivingentity,
    ReceiverCostObject,
    ReceiverCostCenter,
    Reckpi as Reckpi,  
    Reckpishare as Reckpishare,
    _ServiceCost.Chargeout as Chargeout,
  //Direct Allocation   
    TransferPrice,
    _ServiceCost.Servicecostperunit,
    _ServiceCost.Valueaddcostperunit,
    _ServiceCost.Passthrucostperunit,  
        
    TotalRecMarkup,   
    Valueaddmarkup,    
    Passthrumarkup,   
   
    RecCostShare,
    
    RecValueadded,
    RecPassthrough,
    TotalChargeout,
    
    Status,
    Workflowid, 
    CreatedBy,
    CreatedAt,
    LastChangedAt,
    LastChangedBy,
    
    Currency,
    _ServiceCost._CostCenterCost.costdatasetdescription,   
    _ServiceCost._CostCenterCost.legalentitydescription,
    ccodedescription,
    costobjectdescription,
    costcenterdescription,
    _ServiceCost.Serviceproductdescription,
    _ServiceCost.Servicetypedescription,
    statusdescription,
    receivingentitydescription,
    ccodedescription as Reccodedescription,
    costobjectdescription as Reccostobjectdescription,
    costcenterdescription as Reccostcenterdescription,
    Country as receivingentitycountry,
    _ServiceCost._CostCenterCost.Country as legalentitycountry,
    //association
    _ReceivingCountryText,
    _ServiceCost._CostCenterCost._legalCountryText
} where Workflowid is not initial
