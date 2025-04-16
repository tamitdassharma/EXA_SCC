@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Chargeout Information with Allocation Weightage'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ServiceChargeoutWght
  as select from /ESRCC/I_ServiceChargeout
  association [1..1] to /esrcc/aloc_wgt as _Weightage on _Weightage.rule_id = $projection.RuleId
{
  key Uuid,
      Serviceproduct,
      Validfrom,
      Validto,
      RuleId,
      ChargeoutMethod,
      CostVersion,
      CapacityVersion,
      ConsumptionVersion,
      KeyVersion,

      _Weightage.allocation_key    as AllocationKey,
      _Weightage.allocation_period as AllocationPeriod,
      _Weightage.ref_period        as RefPeriod,
      _Weightage.weightage         as Weightage
}
