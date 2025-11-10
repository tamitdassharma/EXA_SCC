@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Source Cost Object and Number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_COSNUMBER_F4
  as select distinct from /esrcc/cst_objct as coscen
  association [0..1] to /esrcc/cst_objtt as _Text on  _Text.cost_object_uuid = coscen.cost_object_uuid
                                                  and _Text.spras            = $session.system_language


{
      @ObjectModel.text.element: [ 'Description' ]
      @UI.lineItem: [{ position: 3 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key cost_center       as Costcenter,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _Text.description as Description
}
