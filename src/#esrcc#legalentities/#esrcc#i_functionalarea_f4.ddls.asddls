@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Functional Area'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_FunctionalArea_F4
  as select from /esrcc/fnc_area
  association [1..1] to /esrcc/fnc_areat as _Text on  _Text.functional_area = $projection.FunctionalArea
                                                  and _Text.spras           = $session.system_language
{
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key functional_area   as FunctionalArea,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _Text.description as Description
}
