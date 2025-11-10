@EndUserText.label: 'Maintain License Type'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LicType
  as projection on /ESRCC/I_LicType
{
  key LicenseType,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LicenseTypeAll : redirected to parent /ESRCC/C_LicType_S,
  _LicenseTypeText : redirected to composition child /ESRCC/C_LicTypeText,
  _LicenseTypeText.Description : localized
  
}
