@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Execution Cockpit Status'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_ExecutionStatus
  as select from /esrcc/exec_st
  association        to parent /ESRCC/I_ExecutionStatus_S as _ExecutionStatusAll on $projection.SingletonID = _ExecutionStatusAll.SingletonID
  composition [0..*] of /ESRCC/I_ExecutionStatusText      as _ExecutionStatusText

  association [0..1] to /ESRCC/I_APPLICATION_TYPE         as _ApplicationText    on _ApplicationText.ApplicationType = $projection.Application
  association [0..1] to /ESRCC/I_COLORCODE_F4             as _ColorCodeText      on _ColorCodeText.ColorCode = $projection.Color
{
  key application           as Application,
  key status                as Status,
      color                 as Color,
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
      _ExecutionStatusAll,
      _ExecutionStatusText,
      _ApplicationText,
      _ColorCodeText
}
