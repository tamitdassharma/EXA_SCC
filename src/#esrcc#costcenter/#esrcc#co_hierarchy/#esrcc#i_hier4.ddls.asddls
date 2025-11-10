@EndUserText.label: 'Activity'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Hier4
  as select from /esrcc/hier4
  association to parent /ESRCC/I_Hier4_S as _HierarchyAll on $projection.SingletonID = _HierarchyAll.SingletonID
  composition [0..*] of /ESRCC/I_Hier4Text as _HierarchyText
{
  key hierarchy as Hierarchy,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _HierarchyAll,
  _HierarchyText
  
}
