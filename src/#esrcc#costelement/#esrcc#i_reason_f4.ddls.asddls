@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reason'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_REASON_F4
  as select from /esrcc/reason
  association [0..1] to /esrcc/reasont            as _ReasonText on  _ReasonText.reasonid = $projection.Reasonid
                                                                 and _ReasonText.spras    = $session.system_language

  association [0..1] to /ESRCC/I_USAGECALCULATION as _UsageText  on  _UsageText.usagecal = $projection.CalculationUsage


{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['reasondescription']
      @UI.lineItem: [{ position: 20 }]
  key reasonid                as Reasonid,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _ReasonText.description as reasondescription,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['usagedescription']
      @UI.lineItem: [{ position: 10 }]
      calculationusage        as CalculationUsage,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _UsageText.text         as usagedescription,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @EndUserText.label: 'Default'
      @UI.lineItem: [{ position: 30 }]
      defaultflag             as Defaultflag

}
