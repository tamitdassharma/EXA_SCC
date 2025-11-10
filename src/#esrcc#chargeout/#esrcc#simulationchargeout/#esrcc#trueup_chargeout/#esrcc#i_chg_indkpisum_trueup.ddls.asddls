@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-out to Receivers KPI Sum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHG_INDKPISUM_TRUEUP 
as select from /ESRCC/I_INDALLOC_TRUEUP
{
    key fplv,
    key ryear,
    key poper,
    key sysid,
    key ccode,
    key legalentity,
    key costobject,
    key costcenter,
    key serviceproduct,
    key KeyVersion,
    key Allockey,
//    key AllocType,
    key AllocationPeriod,
    key RefPeriod,
    sum( reckpivalue )  as totalreckpi
}
group by
  fplv,
  ryear,
  poper,
  sysid,
  ccode,
  legalentity,
  costobject,
  costcenter,
  serviceproduct,
  KeyVersion,
  Allockey,
//  AllocType,
  AllocationPeriod,
  RefPeriod
