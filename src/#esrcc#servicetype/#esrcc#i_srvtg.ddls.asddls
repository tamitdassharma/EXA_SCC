@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Transaction Group'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvTg
  as select from /esrcc/srvtg
  association to parent /ESRCC/I_SrvTg_S as _TransactionGrpAll on $projection.SingletonID = _TransactionGrpAll.SingletonID
  composition [0..*] of /ESRCC/I_SrvTgText as _TransactionGrpText
{
  key transactiongroup as Transactiongroup,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _TransactionGrpAll,
  _TransactionGrpText
  
}
