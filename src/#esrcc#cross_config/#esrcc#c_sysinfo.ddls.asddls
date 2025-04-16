@EndUserText.label: 'System information - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SysInfo
  as projection on /ESRCC/I_SysInfo
{
  key SystemId,
      SourceRfcDestination,
      HostRfcDestination,
      @ObjectModel.text.element: ['SystemTypeDescription']
      SystemType,
      @ObjectModel.text.element: ['SignForSalesDescription']
      SignForSales,
      @ObjectModel.text.element: ['SignForCogsDescription']
      SignForCogs,
      IsActive,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _SystemTypeText.text as SystemTypeDescription,
      _SalesSignText.text  as SignForSalesDescription,
      _CogsSignText.text   as SignForCogsDescription,
      _SystemInfoAll  : redirected to parent /ESRCC/C_SysInfo_S,
      _SystemInfoText : redirected to composition child /ESRCC/C_SysInfoText,
      _SystemInfoText.Description : localized

}
