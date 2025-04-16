@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'System Information Text'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.dataCategory: #TEXT
@Search.searchable: true
define view entity /ESRCC/I_SystemInformationText
  as select from /esrcc/sys_infot
{
      @Semantics.language: true
  key spras       as Spras,
  key system_id   as SystemId,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      description as Description
}
