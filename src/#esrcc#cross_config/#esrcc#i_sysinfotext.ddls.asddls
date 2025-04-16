@EndUserText.label: 'System Information Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_SysInfoText
  as select from /ESRCC/SYS_INFOT
  association [1..1] to /ESRCC/I_SysInfo_S as _SystemInfoAll on $projection.SingletonID = _SystemInfoAll.SingletonID
  association to parent /ESRCC/I_SysInfo as _SystemInfo on $projection.SystemId = _SystemInfo.SystemId
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key SYSTEM_ID as SystemId,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _SystemInfoAll,
  _SystemInfo,
  _LanguageText
  
}
