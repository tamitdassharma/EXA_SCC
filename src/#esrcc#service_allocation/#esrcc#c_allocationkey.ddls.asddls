@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Allocation Key - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_AllocationKey
  as projection on /ESRCC/I_AllocationKey
{
  key Allocationkey,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _AllocationKeyAll  : redirected to parent /ESRCC/C_AllocationKey_S,
      _AllocationKeyText : redirected to composition child /ESRCC/C_AllocationKeyText,
      _AllocationKeyText.Description : localized

}
