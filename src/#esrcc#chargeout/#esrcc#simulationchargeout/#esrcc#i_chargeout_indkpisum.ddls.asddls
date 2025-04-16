@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-out to Receivers KPI Sum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_INDKPISUM 
as select from /ESRCC/I_INDALLOC
{
    key Fplv,
    key Ryear,
    key Poper,
    key Sysid,
    key Ccode,
    key Legalentity,
    key Costobject,
    key Costcenter,
    key serviceproduct,
    key KeyVersion,
    key Allockey,
//    key AllocType,
    key AllocationPeriod,
    key RefPeriod,
    sum( reckpivalue )  as totalreckpi
}
group by
  Fplv,
  Ryear,
  Poper,
  Sysid,
  Ccode,
  Legalentity,
  Costobject,
  Costcenter,
  serviceproduct,
  KeyVersion,
  Allockey,
//  AllocType,
  AllocationPeriod,
  RefPeriod
