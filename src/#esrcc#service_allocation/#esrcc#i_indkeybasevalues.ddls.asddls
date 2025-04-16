@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Key Base Values'

define view entity /ESRCC/I_INDKEYBASEVALUES
  as select from /esrcc/indtalloc as indalloc
   association [0..1] to /esrcc/cst_objct as cb
    on cb.cost_object_uuid = $projection.CostObjectUuid
{
  key indalloc.indirect_allocation_uuid as IndirectAllocationUuid,
  key indalloc.cost_object_uuid as CostObjectUuid,  
      indalloc.fplv as Fplv,
      indalloc.ryear as Ryear,
      indalloc.poper as Poper,
      indalloc.allocation_key as AllocationKey,
      indalloc.value,
      indalloc.currency,
            
      cb.sysid as ReceiverSysId,
      cb.company_code as ReceiverCompanyCode,
      cb.legal_entity as ReceivingEntity,
      cb.cost_object as ReceiverCostObject,
      cb.cost_center as ReceiverCostCenter,
      cb.profit_center as ReceiverProfitCenter,
      cb.functional_area as ReceiverFunctionalArea,
      cb.business_division as ReceiverBusinessDivision,
      cb.billing_frequency as ReceiverBillingFrequency

}
