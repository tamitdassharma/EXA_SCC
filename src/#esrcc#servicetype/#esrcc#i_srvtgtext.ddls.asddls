@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Transaction group Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_SrvTgText
  as select from /esrcc/tgt
  association [1..1] to /ESRCC/I_SrvTg_S as _TransactionGrpAll on $projection.SingletonID = _TransactionGrpAll.SingletonID
  association to parent /ESRCC/I_SrvTg as _TransactionGrp on $projection.Transactiongroup = _TransactionGrp.Transactiongroup
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key transactiongroup as Transactiongroup,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _TransactionGrpAll,
  _TransactionGrp,
  _LanguageText
  
}
