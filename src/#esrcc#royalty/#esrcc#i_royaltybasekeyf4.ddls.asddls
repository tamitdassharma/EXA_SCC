@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Royalty Base Key'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true

define view entity /ESRCC/I_RoyaltyBaseKeyF4
  as select from /esrcc/roykey
  association [0..1] to /esrcc/roykeyt as _Text on  $projection.RoyaltyBaseKey = _Text.royalty_base_key
                                                and _Text.spras                = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @ObjectModel.text.element: ['Description']
  key royalty_base_key  as RoyaltyBaseKey,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      _Text.description as Description
}
