@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Indirect allocation key values'
define root view entity /ESRCC/I_INDIRECTALLOCKEYVALUE
  as select from /esrcc/indtalloc as IndirectAllocationKeyValues
  association [0..1] to /ESRCC/I_COSCEN_F4         as _CostCenter     on $projection.CostObjectUuid = _CostCenter.CostObjectUuid
  association [0..1] to /ESRCC/I_KEY_VERSION       as _KeyVersionText on $projection.Fplv = _KeyVersionText.KeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllockeyText   on $projection.AllocationKey = _AllockeyText.Allocationkey
//  association        to /ESRCC/I_POPER             as _PoperText      on _PoperText.Poper = $projection.Poper
{
  key indirect_allocation_uuid as IndirectAllocationUUID,
      ryear                    as Ryear,
      poper                    as Poper,
      allocation_key           as AllocationKey,
      fplv                     as Fplv,
      value                    as Value,
      currency                 as Currency,
      cost_object_uuid         as CostObjectUuid,
      _CostCenter.Sysid,
      _CostCenter.LegalEntity,
      _CostCenter.CompanyCode,
      _CostCenter.Costobject,
      _CostCenter.Costcenter,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      _CostCenter,
      _KeyVersionText,
      _AllockeyText
//      _PoperText

}
