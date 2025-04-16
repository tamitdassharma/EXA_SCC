@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Chargeout Information'
@Metadata.ignorePropagatedAnnotations: true

define view entity /ESRCC/I_ServiceChargeout
  as select from /esrcc/chargeout
  association [1..1] to /esrcc/co_rule as _Rule on _Rule.rule_id = $projection.RuleId
{
  key uuid                      as Uuid,
      serviceproduct            as Serviceproduct,
      validfrom                 as Validfrom,
      validto                   as Validto,
      chargeout_rule_id         as RuleId,
      
      _Rule.chargeout_method    as ChargeoutMethod,
      _Rule.cost_version        as CostVersion,
      _Rule.capacity_version    as CapacityVersion,
      _Rule.consumption_version as ConsumptionVersion,
      _Rule.key_version         as KeyVersion
}
