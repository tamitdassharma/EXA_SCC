@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Profit Center'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_PROFITCENTER_F4
  as select from /esrcc/pfc as profitcenter
  association [0..1] to /esrcc/pfct as profitcentert on  profitcenter.profit_center = profitcentert.profit_center
                                                     and profitcentert.spras        = $session.system_language
{
      @ObjectModel.text.element: ['profitcenterdescription']
      @UI.textArrangement: #TEXT_SEPARATE
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key profit_center             as ProfitCenter,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      profitcentert.description as profitcenterdescription
}
