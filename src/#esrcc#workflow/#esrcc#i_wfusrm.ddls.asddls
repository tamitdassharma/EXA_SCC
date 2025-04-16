@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Workflow User Mapping'

define view entity /ESRCC/I_WfUsrM
  as select from /esrcc/wfusrm
  association [1..1] to /ESRCC/I_WfUsrG_S      as _UserGroupAll on _UserGroupAll.SingletonID = $projection.SingletonID
  association        to parent /ESRCC/I_WfUsrG as _UserGroup    on _UserGroup.Usergroup = $projection.Usergroup
{
  key usergroup             as Usergroup,
  key userid                as Userid,
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
      _UserGroup
}
