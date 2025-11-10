@EndUserText.label: 'Maintain Regions'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Regions
  as projection on /ESRCC/I_Regions
{
  key Region,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _RegionAll : redirected to parent /ESRCC/C_Region_S,
  _RegionText : redirected to composition child /ESRCC/C_RegionText,
  _RegionText.Description : localized
  
}
