@EndUserText.label: 'Royalty Base Keys'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_RoyKey
  as select from /ESRCC/ROYKEY
  association to parent /ESRCC/I_RoyKey_S as _RoyKeyAll on $projection.SingletonID = _RoyKeyAll.SingletonID
  composition [0..*] of /ESRCC/I_RoyKeyText as _RoyaltyKeyText
{
  key ROYALTY_BASE_KEY as RoyaltyBaseKey,
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
  _RoyKeyAll,
  _RoyaltyKeyText
  
}
