@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Source Cost Object and Number'
@Metadata.ignorePropagatedAnnotations: true

-- Used in workflow app
@Search.searchable: true
define view entity /ESRCC/I_WF_COST_NUMBER_F4
  as select distinct from /esrcc/cst_objct as coscen
{
      @UI.lineItem: [{ position: 1 }]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key cost_center as CostCenter
}
