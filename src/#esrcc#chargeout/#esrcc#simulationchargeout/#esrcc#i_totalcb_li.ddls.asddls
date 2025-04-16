@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cost & Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_LI 
   as select from /esrcc/cb_stw as cc_cost
      
    association [0..*] to /ESRCC/I_STW_SERVICEPRODUCT as srvprm
    on srvprm.LegalEntity = $projection.legalentity
    and srvprm.Sysid = $projection.sysid
    and srvprm.CompanyCode = $projection.ccode
    and srvprm.CostObject = $projection.costobject
    and srvprm.CostCenter = $projection.costcenter
    and cc_cost.validon >= srvprm.ValidFrom
    and cc_cost.validon <= srvprm.Validto
    and cc_cost.validon >= srvprm.SpValidFrom
    and cc_cost.validon <= srvprm.SpValidto 
{
    key cc_uuid,
    key ryear,
    key poper,
    key fplv,
    key sysid,
    key legalentity,
    key ccode,
    key costobject,
    key costcenter,
    key srvprm.ServiceProduct,
    validon,
    localcurr,
    groupcurr,   
    cc_cost.stewardship,
    srvprm.ShareOfCost,
    srvprm.ContractId

}
