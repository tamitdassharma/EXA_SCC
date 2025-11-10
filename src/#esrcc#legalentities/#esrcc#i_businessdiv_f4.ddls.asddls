@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Division'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_BUSINESSDIV_F4
  as select from /esrcc/bus_div as businessdiv
  association [0..1] to /esrcc/bus_divt as businessdivt on  businessdiv.business_division = businessdivt.business_division
                                                        and businessdivt.spras            = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @ObjectModel.text.element: ['Description']
  key business_division        as BusinessDivision,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      businessdivt.description as Description
}
