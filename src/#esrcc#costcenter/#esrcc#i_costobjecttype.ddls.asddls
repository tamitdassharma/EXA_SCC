@EndUserText.label: 'Maintain Cost Object Types'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CostObjectType
  as select from /esrcc/cstobjtyp
  association to parent /ESRCC/I_CostObjectType_S      as _CostObjectTypeAll on $projection.SingletonID = _CostObjectTypeAll.SingletonID
  composition [0..*] of /ESRCC/I_CostObjectTypeText    as _CostObjectTypeText
{
  key cost_object           as CostObject,
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
      _CostObjectTypeAll,
      _CostObjectTypeText

}
