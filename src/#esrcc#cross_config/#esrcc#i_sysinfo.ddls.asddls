@EndUserText.label: 'System information'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SysInfo
  as select from /esrcc/sys_info
  association        to parent /ESRCC/I_SysInfo_S as _SystemInfoAll  on $projection.SingletonID = _SystemInfoAll.SingletonID
  composition [0..*] of /ESRCC/I_SysInfoText      as _SystemInfoText
  association [0..1] to /ESRCC/I_SYSTEM_TYPE      as _SystemTypeText on _SystemTypeText.SystemType = $projection.SystemType
  association [0..1] to /ESRCC/I_SIGN_FOR_VALUE   as _SalesSignText  on _SalesSignText.Sign = $projection.SignForSales
  association [0..1] to /ESRCC/I_SIGN_FOR_VALUE   as _CogsSignText   on _CogsSignText.Sign = $projection.SignForCogs
{
  key system_id              as SystemId,
      source_rfc_destination as SourceRfcDestination,
      host_rfc_destination   as HostRfcDestination,
      system_type            as SystemType,
      sign_for_sales         as SignForSales,
      sign_for_cogs          as SignForCogs,
      is_active              as IsActive,
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,
      1                      as SingletonID,
      _SystemInfoAll,
      _SystemInfoText,
      _SystemTypeText,
      _SalesSignText,
      _CogsSignText

}
