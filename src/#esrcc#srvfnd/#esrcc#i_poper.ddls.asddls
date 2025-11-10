@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Periods'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@UI.presentationVariant: [{
    sortOrder: [{
        by: 'value_position',
        direction: #ASC
    }]
}]

@Search.searchable: true
define view entity /ESRCC/I_POPER
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/POPER')
{
      @UI.hidden: true
  key value_position,
//      @ObjectModel.text.element: ['text']
//      @UI.textArrangement: #TEXT_SEPARATE
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key value_low as Poper
      
//      @UI.hidden: true
//      @Semantics.text: true
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
//      text
      
}
where
  language = $session.system_language
