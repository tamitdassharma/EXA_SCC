@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_Hierarchy2_F4
  as select from /esrcc/hier2
  association [0..1] to /esrcc/hier2_t as HierarchyText on  HierarchyText.hierarchy = $projection.Hierarchy
                                                        and HierarchyText.spras     = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @ObjectModel.text.element: ['Description']
  key hierarchy                 as Hierarchy,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      HierarchyText.description as Description
}
