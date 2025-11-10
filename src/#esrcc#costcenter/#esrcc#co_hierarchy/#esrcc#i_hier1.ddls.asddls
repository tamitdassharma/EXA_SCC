@EndUserText.label: 'Hierarchy'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Hier1
  as select from /ESRCC/HIER1
  association to parent /ESRCC/I_Hier1_S as _HierarchyAll on $projection.SingletonID = _HierarchyAll.SingletonID
  composition [0..*] of /ESRCC/I_Hier1Text as _HierarchyText
{
  key HIERARCHY as Hierarchy,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.lastChangedBy: true
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _HierarchyAll,
  _HierarchyText
  
}
