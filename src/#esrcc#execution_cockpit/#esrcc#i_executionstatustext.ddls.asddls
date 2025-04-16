@EndUserText.label: 'Execution Cockpit Status Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_ExecutionStatusText
  as select from /esrcc/execst_t
  association [1..1] to /ESRCC/I_ExecutionStatus_S as _ExecutionStatusAll on $projection.SingletonID = _ExecutionStatusAll.SingletonID
  association to parent /ESRCC/I_ExecutionStatus as _ExecutionStatus on $projection.Application = _ExecutionStatus.Application and $projection.Status = _ExecutionStatus.Status
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key application as Application,
  key status as Status,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _ExecutionStatusAll,
  _ExecutionStatus,
  _LanguageText
  
}
