@EndUserText.label: 'Maintain Regions'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Regions
  as select from /ESRCC/REGIONS
  association to parent /ESRCC/I_Region_S as _RegionAll on $projection.SingletonID = _RegionAll.SingletonID
  composition [0..*] of /ESRCC/I_RegionText as _RegionText
{
  key REGION as Region,
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
  _RegionAll,
  _RegionText
  
}
