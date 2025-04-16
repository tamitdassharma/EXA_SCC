@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Data Set'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_COSTDATASET
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/COSTDATASET')
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_ONLY
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
  key value_low as costdataset,
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.8 }
      @UI.hidden: true
      text
}
where
  language = $session.system_language
