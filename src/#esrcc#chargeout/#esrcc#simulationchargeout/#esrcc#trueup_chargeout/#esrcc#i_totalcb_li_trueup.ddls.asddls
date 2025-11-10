@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cost & Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_LI_TRUEUP 
   as select from /ESRCC/I_CB_STEWARDSHIP_TRUEUP as cc_cost
      
    association [0..*] to /ESRCC/I_STW_SERVICEPRODUCT as srvprm
    on srvprm.LegalEntity = $projection.Legalentity
    and srvprm.Sysid = $projection.Sysid
    and srvprm.CompanyCode = $projection.Ccode
    and srvprm.CostObject = $projection.Costobject
    and srvprm.CostCenter = $projection.Costcenter
    and cc_cost.validon >= srvprm.ValidFrom
    and cc_cost.validon <= srvprm.Validto
    and cc_cost.validon >= srvprm.SpValidFrom
    and cc_cost.validon <= srvprm.SpValidto 
{
//    key '' as cc_uuid,
    key Ryear,
    key Poper,
    key Fplv,
    key Sysid,
    key Legalentity,
    key Ccode,
    key Costobject,
    key Costcenter,
    key srvprm.ServiceProduct,
    validon,
    Localcurr,
    Groupcurr,   
    cc_cost.stewardship,
    srvprm.ShareOfCost
//    srvprm.ContractId

}
