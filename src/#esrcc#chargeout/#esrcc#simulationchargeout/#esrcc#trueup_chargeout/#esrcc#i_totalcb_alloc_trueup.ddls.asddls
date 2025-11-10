@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Data Mapping'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_ALLOC_TRUEUP
  as select from /ESRCC/I_TOTALCB_LI_TRUEUP as totalcb_li
//  as select from /ESRCC/I_STW_SERVICEPRODUCT as srvprm
  
  association [0..1] to /ESRCC/I_SRVCHARGEOUT_TRUEUP as srvalloc  
    on srvalloc.Serviceproduct = $projection.ServiceProduct
   and $projection.validon between srvalloc.Validfrom and srvalloc.Validto
 
{
//  key cc_uuid,
  key Ryear,
  key Poper,
  key Fplv,
  key Sysid,
  key Legalentity,
  key Ccode,
  key Costobject,
  key Costcenter,
  key ServiceProduct,
      srvalloc.ChargeoutMethod as chargeout,    
      srvalloc.CapacityVersion as capacity_version,
//      srvalloc.CostVersion as cost_version,
      srvalloc.ConsumptionVersion as consumption_version,
      srvalloc.KeyVersion as key_version,
//      srvalloc.Uom,
      validon,
      Localcurr,
      Groupcurr,
      ShareOfCost
//      ContractId
}
