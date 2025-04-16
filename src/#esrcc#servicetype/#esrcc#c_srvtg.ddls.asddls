@EndUserText.label: 'Service Transaction Group - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvTg
  as projection on /ESRCC/I_SrvTg
{
  key Transactiongroup,
//  Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _TransactionGrpAll : redirected to parent /ESRCC/C_SrvTg_S,
  _TransactionGrpText : redirected to composition child /ESRCC/C_SrvTgText,
  _TransactionGrpText.Description : localized
  
}
