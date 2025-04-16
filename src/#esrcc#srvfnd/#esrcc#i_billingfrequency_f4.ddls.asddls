@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Frequency'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.allowExtensions: true
@UI.presentationVariant: [{ sortOrder: [{ direction: #ASC, by: 'Billingfreq'  },
                                        { direction: #ASC, by: 'Billingperiod'  }] }]
define view entity /ESRCC/I_BILLINGFREQUENCY_F4
 as select distinct from /esrcc/billfreq as billingfrq
 
  association [0..1] to /ESRCC/I_BILLINGFREQ as frequency
  on frequency.Billingfreq = billingfrq.billingfreq
//  
  association [0..1] to /ESRCC/I_BILLINGPERIOD as period
  on period.Billingperiod = billingfrq.billingvalue
{
    @ObjectModel.text.element: [ 'billingfrequencydescription' ]
    @UI.textArrangement: #TEXT_LAST
    key billingfreq as Billingfreq,
    @ObjectModel.text.element: [ 'billingperioddescription' ]
    @UI.textArrangement: #TEXT_LAST
    key billingvalue as Billingperiod,
    frequency.text as billingfrequencydescription,
    period.text as billingperioddescription
}
