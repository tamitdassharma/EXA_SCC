@EndUserText.label: 'Service Type - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrType
  as projection on /ESRCC/I_SrType
{
  key Srvtype,
//  Active,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _ServiceTypeAll : redirected to parent /ESRCC/C_SrType_S,
  _ServiceTypeText : redirected to composition child /ESRCC/C_SrTypeText,
  _ServiceTypeText.Description : localized
  
}
