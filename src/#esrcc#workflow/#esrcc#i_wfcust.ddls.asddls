@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Workflow mapping of User and Role'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_WfCust
  as select from /esrcc/wfcust
  association        to parent /ESRCC/I_WfCust_S       as _RoleAssignmentAll   on  $projection.SingletonID = _RoleAssignmentAll.SingletonID
  association [0..1] to /ESRCC/I_APPLICATION_TYPE      as _ApplicationTypeText on  $projection.Application = _ApplicationTypeText.ApplicationType
  association [0..1] to /ESRCC/I_APPROVAL_LEVEL        as _ApprovalLevelText   on  $projection.Approvallevel = _ApprovalLevelText.ApprovalLevel
  association [0..1] to /ESRCC/I_LegalEntityAll_F4     as _LegalEntityText     on  $projection.Legalentity = _LegalEntityText.Legalentity
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemText          on  $projection.Sysid = _SystemText.SystemId
                                                                               and _SystemText.Spras = $session.system_language
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObjectText      on  $projection.Costobject = _CostObjectText.Costobject
  association [0..1] to /ESRCC/I_UserGroup_F4          as _UserGroup           on  _UserGroup.Usergroup = $projection.Usergroup
{
  key application           as Application,
  key approvallevel         as Approvallevel,
  key legalentity           as Legalentity,
  key sysid                 as Sysid,
  key costobject            as Costobject,
  key costcenter            as Costcenter,
      usergroup             as Usergroup,
      pfcgrole              as Pfcgrole,
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
      _RoleAssignmentAll,
      _ApplicationTypeText,
      _ApprovalLevelText,
      _LegalEntityText,
      _SystemText,
      _CostObjectText,
      _UserGroup
}
