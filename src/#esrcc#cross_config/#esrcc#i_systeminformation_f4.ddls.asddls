@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'System Information'

@Search.searchable: true
define view entity /ESRCC/I_SystemInformation_F4
  as select from /esrcc/sys_info
  association [0..*] to /ESRCC/I_SystemInformationText as _SysInfoText    on _SysInfoText.SystemId = $projection.SystemId
  association [0..1] to /ESRCC/I_SYSTEM_TYPE           as _SystemTypeText on _SystemTypeText.SystemType = $projection.SystemType
  association [0..1] to /ESRCC/I_SIGN_FOR_VALUE        as _SalesSignText  on _SalesSignText.Sign = $projection.SignForSales
  association [0..1] to /ESRCC/I_SIGN_FOR_VALUE        as _CogsSignText   on _CogsSignText.Sign = $projection.SignForCogs
{
      @ObjectModel.text.association: '_SysInfoText'
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key system_id              as SystemId,

      @EndUserText.label: 'Source RFC Destination'
      @Consumption.filter.hidden: true
      source_rfc_destination as SourceRfcDestination,

      @EndUserText.label: 'Host RFC Destination'
      @Consumption.filter.hidden: true
      host_rfc_destination   as HostRfcDestination,

      @ObjectModel.text.association: '_SystemTypeText'
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SYSTEM_TYPE', element: 'SystemType' } }]
      system_type            as SystemType,

      @ObjectModel.text.association: '_SalesSignText'
      @UI.textArrangement: #TEXT_LAST
      @Consumption.filter.hidden: true
      sign_for_sales         as SignForSales,

      @ObjectModel.text.association: '_CogsSignText'
      @UI.textArrangement: #TEXT_LAST
      @Consumption.filter.hidden: true
      sign_for_cogs          as SignForCogs,

      _SysInfoText,
      _SystemTypeText,
      _SalesSignText,
      _CogsSignText
}
where
  is_active = 'X'
