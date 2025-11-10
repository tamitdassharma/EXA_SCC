@EndUserText.label: 'Cost Object Type Host Mapping'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CostObjectTypeMapping
  as select from /esrcc/cobjtymp
  association [1..1] to /ESRCC/I_ExtObj_S      as _ExtractionObjectAll on $projection.SingletonID = _ExtractionObjectAll.SingletonID
  association        to parent /ESRCC/I_ExtObj as _ExtractionObject    on $projection.ObjectType = _ExtractionObject.ObjectType
{
  key object_type             as ObjectType,
  key source_cost_object_type as SourceCostObjectType,
      active                  as Active,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,
      1                       as SingletonID,

      _ExtractionObjectAll,
      _ExtractionObject
}
