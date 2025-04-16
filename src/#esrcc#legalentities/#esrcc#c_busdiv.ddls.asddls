@EndUserText.label: 'Business Division - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_BusDiv
  as projection on /ESRCC/I_BusDiv
{
  key BusinessDivision,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _BusinessDivisionAll : redirected to parent /ESRCC/C_BusDiv_S,
  _BusinessDivisioText : redirected to composition child /ESRCC/C_BusDivText,
  _BusinessDivisioText.Description : localized
  
}
