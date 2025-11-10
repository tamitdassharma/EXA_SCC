@EndUserText.label: 'Maintain TP Profile'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_TpProf
  as select from /ESRCC/TPPROF
  association to parent /ESRCC/I_TpProf_S as _TpProfileAll on $projection.SingletonID = _TpProfileAll.SingletonID
  composition [0..*] of /ESRCC/I_TpProfText as _TpProfileText
{
  key TPPROFILE as Tpprofile,
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
  _TpProfileAll,
  _TpProfileText
  
}
