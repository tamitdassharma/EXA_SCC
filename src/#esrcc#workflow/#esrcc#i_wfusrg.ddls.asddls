@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'User Group for Workflow'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_WfUsrG
  as select from /esrcc/wfusrg
  association to parent /ESRCC/I_WfUsrG_S as _UserGroupAll on $projection.SingletonID = _UserGroupAll.SingletonID
  composition [0..*] of /ESRCC/I_WfUsrM   as _UserMapping
{
  key usergroup             as Usergroup,
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
      _UserGroupAll,
      _UserMapping
}
