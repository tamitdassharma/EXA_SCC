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
as select from /ESRCC/I_ServicesCostbase  as services                                     
                                                                                  
association [0..*] to /ESRCC/I_SRVPRODUCT_RECEIVERS as srvallocreceivers  
                   on  srvallocreceivers.SystemId       = $projection.Sysid
                   and srvallocreceivers.CompanyCode    = $projection.Ccode
                   and srvallocreceivers.LegalEntity    = $projection.Legalentity
                   and srvallocreceivers.CostObject     = $projection.Costobject
                   and srvallocreceivers.CostCenter     = $projection.Costcenter                  
                   and srvallocreceivers.ServiceProduct = $projection.serviceproduct                   
                   and srvallocreceivers.Active = 'X'
                   and services.validon between srvallocreceivers.StewardshipValidFrom and srvallocreceivers.StewardshipValidTo
                   and services.validon between srvallocreceivers.ServiceValidFrom and srvallocreceivers.ServiceValidTo

association [0..1] to /ESRCC/I_LE as _legalentity
            on _legalentity.Legalentity = $projection.Legalentity
{
    key cc_uuid,
    key srv_uuid,
    key Ryear,
    key Poper,
    key Fplv,
    key Sysid,
    key Legalentity,
    key Ccode,
    key Costobject,
    key Costcenter,
    key services.ServiceProduct as serviceproduct, 
    key srvallocreceivers.ReceiverSysId,
    key srvallocreceivers.ReceiverCompanyCode,
    key srvallocreceivers.ReceivingEntity,
    key srvallocreceivers.ReceiverCostObject,
    key srvallocreceivers.ReceiverCostCenter,
    services.ContractId,    
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
