@EndUserText.label: 'Profit Center - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Pfc
  as projection on /ESRCC/I_Pfc
{
  key ProfitCenter,
//  Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _ProfitCenterAll : redirected to parent /ESRCC/C_Pfc_S,
  _PfcText : redirected to composition child /ESRCC/C_PfcText,
  _PfcText.Description : localized
  
}
