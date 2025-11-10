@EndUserText.label: 'Switch'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Switch
  as select from /esrcc/switch
  association        to parent /ESRCC/I_Switch_S  as _SwitchAll           on $projection.SingletonID = _SwitchAll.SingletonID
  association [0..1] to /ESRCC/I_APPLICATION_TYPE as _ApplicationTypeText on $projection.Application = _ApplicationTypeText.ApplicationType
{
  key application           as Application,
  key switch_name           as SwitchName,
      active                as Active,
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
      _SwitchAll,
      _ApplicationTypeText

}
