@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Allocation Key'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_AllocationKey
  as select from /esrcc/allockeys
  association        to parent /ESRCC/I_AllocationKey_S as _AllocationKeyAll   on $projection.SingletonID = _AllocationKeyAll.SingletonID
  composition [0..*] of /ESRCC/I_AllocationKeyText      as _AllocationKeyText
{
  key allocationkey         as Allocationkey,
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
      _AllocationKeyAll,
      _AllocationKeyText

}
