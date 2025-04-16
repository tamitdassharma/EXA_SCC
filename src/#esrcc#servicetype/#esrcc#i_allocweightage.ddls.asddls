@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Weightage'

define view entity /ESRCC/I_AllocWeightage
  as select from /esrcc/aloc_wgt
  association [1..1] to /ESRCC/I_CoRule_S          as _RuleAll         on $projection.SingletonID = _RuleAll.SingletonID
  association        to parent /ESRCC/I_CoRule     as _Rule            on $projection.RuleId = _Rule.RuleId
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllocKeyText    on _AllocKeyText.Allocationkey = $projection.AllocationKey
  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD  as _AllocPeriodText on _AllocPeriodText.AllocationPeriod = $projection.AllocationPeriod
{
  key rule_id               as RuleId,
  key allocation_key        as AllocationKey,
      allocation_period     as AllocationPeriod,
      ref_period            as RefPeriod,
      weightage             as Weightage,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,

      _RuleAll,
      _Rule,
      _AllocKeyText,
      _AllocPeriodText
}
