@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out for Receivers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_RECEIVERS 
as select from /ESRCC/I_CHARGEOUT_UNITCOST  as services                                     
                                                                                  
association [0..*] to /ESRCC/I_SRVPRODUCT_RECEIVERS as srvallocreceivers  
                   on  srvallocreceivers.SystemId       = $projection.sysid
                   and srvallocreceivers.CompanyCode    = $projection.ccode
                   and srvallocreceivers.LegalEntity    = $projection.legalentity
                   and srvallocreceivers.CostObject     = $projection.costobject
                   and srvallocreceivers.CostCenter     = $projection.costcenter                  
                   and srvallocreceivers.ServiceProduct = $projection.serviceproduct                   
                   and srvallocreceivers.Active = 'X'
                   and services.validon between srvallocreceivers.StewardshipValidFrom and srvallocreceivers.StewardshipValidTo
                   and services.validon between srvallocreceivers.ServiceValidFrom and srvallocreceivers.ServiceValidTo

association [0..1] to /ESRCC/I_LE as _legalentity
            on _legalentity.Legalentity = $projection.legalentity
{
//    key cc_uuid,
//    key srv_uuid,
    key ryear,
    key poper,
    key fplv,
    key sysid,
    key legalentity,
    key ccode,
    key costobject,
    key costcenter,
    key services.ServiceProduct as serviceproduct, 
    key srvallocreceivers.ReceiverSysId,
    key srvallocreceivers.ReceiverCompanyCode,
    key srvallocreceivers.ReceivingEntity,
    key srvallocreceivers.ReceiverCostObject,
    key srvallocreceivers.ReceiverCostCenter,
    srvallocreceivers.ErpSalesOrder,
    srvallocreceivers.ContractId,    
    consumption_version,
    key_version,
    PlanningUoM,
    chargeout, 
    validon,
    case when srvallocreceivers.InvoicingCurrency = '' then
    _legalentity.LocalCurr
    else
    srvallocreceivers.InvoicingCurrency 
    end as InvoicingCurrency
  
    
}
