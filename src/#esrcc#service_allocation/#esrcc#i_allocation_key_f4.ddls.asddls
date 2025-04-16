@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Key'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS

@Search.searchable: true
define view entity /ESRCC/I_ALLOCATION_KEY_F4
  as select from /esrcc/allockeys
  association [0..1] to /esrcc/allockeyt as _AllocationKeyText on  _AllocationKeyText.allocationkey = $projection.Allocationkey
                                                               and _AllocationKeyText.spras         = $session.system_language
{
      @ObjectModel.text.element: ['AllocationKeyDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.lineItem: [{ position: 1 }]
  key allocationkey                  as Allocationkey,

      @Consumption.filter.hidden: true
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      _AllocationKeyText.description as AllocationKeyDescription
}
