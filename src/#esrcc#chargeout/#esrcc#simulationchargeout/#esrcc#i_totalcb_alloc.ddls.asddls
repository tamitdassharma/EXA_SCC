@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Data Mapping'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_ALLOC
  as select from /ESRCC/I_TOTALCB_LI as totalcb_li

  association [0..1] to /ESRCC/I_ServiceChargeout as srvalloc  
    on srvalloc.Serviceproduct = $projection.ServiceProduct
   and srvalloc.CostVersion   = $projection.fplv
   and $projection.validon between srvalloc.Validfrom and srvalloc.Validto
 
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
      srvalloc.ChargeoutMethod as chargeout,    
      srvalloc.CapacityVersion as capacity_version,
      srvalloc.CostVersion as cost_version,
      srvalloc.ConsumptionVersion as consumption_version,
      srvalloc.KeyVersion as key_version,
//      srvalloc.Uom,
      validon,
      localcurr,
      groupcurr,
      ShareOfCost,
      ContractId
}
