@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Workflow Controller'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_WfSwitch
  as select from /esrcc/wf_switch
  association        to parent /ESRCC/I_WfSwitch_S as _WorkflowSwitchAll   on $projection.SingletonID = _WorkflowSwitchAll.SingletonID
  association [0..1] to /ESRCC/I_APPLICATION_TYPE  as _ApplicationTypeText on $projection.Application = _ApplicationTypeText.ApplicationType
{
  key application           as Application,
      workflowactive        as Workflowactive,
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
      _WorkflowSwitchAll,
      _ApplicationTypeText
}
