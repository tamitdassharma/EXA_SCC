@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out Markup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_UNITCOST
     as select from /ESRCC/I_TOTALCB_ALLOC as totalcb_li
     
    association [0..1] to /ESRCC/I_ServiceCapacity as dirplan
    on  dirplan.Sysid = $projection.sysid
    and dirplan.CompanyCode = $projection.ccode
    and dirplan.LegalEntity = $projection.legalentity
    and dirplan.Costobject = $projection.costobject
    and dirplan.Costcenter = $projection.costcenter
    and dirplan.Ryear = totalcb_li.ryear
    and dirplan.Poper = totalcb_li.poper
    and dirplan.Fplv = totalcb_li.capacity_version
    and dirplan.ServiceProduct = totalcb_li.ServiceProduct
    
    association [0..1] to /esrcc/srvpro as srvpro
    on srvpro.serviceproduct = totalcb_li.ServiceProduct

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
    key ServiceProduct,
    srvpro.servicetype,
    srvpro.transactiongroup,  
    srvpro.oecdtpg,
    srvpro.ip_owner, 
    capacity_version,
    cost_version,
    consumption_version, 
    key_version,   
    chargeout, 
    validon,
    localcurr,
    groupcurr,
    ShareOfCost as costshare,
    ContractId,   
    @Semantics.quantity.unitOfMeasure: 'PlanningUoM'
    dirplan.Planning as planning,
    dirplan.Uom as PlanningUoM
//    Uom  

}
