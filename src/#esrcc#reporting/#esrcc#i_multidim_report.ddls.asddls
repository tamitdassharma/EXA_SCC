@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flexible Reporting Utility'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.query: true

define view entity /ESRCC/I_MULTIDIM_REPORT
  as select from /ESRCC/I_MultiDimension
 
{
      //    DIMENSIONS
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 2
      @Semantics.fiscal.year: true
  key Ryear,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Semantics.fiscal.period: true
      @Consumption.filter: { selectionType : #INTERVAL, multipleSelections: false, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 3
  key Poper,
      @AnalyticsDetails.query.display: #TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: false, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 1
  key Fplv,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
  key Sysid,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 4
  key Legalentity,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 5
  key Ccode,
      @AnalyticsDetails.query.display: #TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 6
      @Consumption.semanticObject: 'BusinessConfiguration'
  key Costobject,

      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 7
      @AnalyticsDetails.query.display: #KEY_TEXT
  key Costcenter,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 8
  key Serviceproduct,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 9
  key Receivingentity,
  @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 9
  key ReceiverSysId,
  @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 9
  key ReceiverCostObject,
  @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 9
  key ReceiverCostCenter,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      Servicetype,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      Transactiongroup,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      FunctionalArea,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      Businessdivision,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      Profitcenter,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      ContractId,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      Currency,
     
      
      //    Measures
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecTotalCost,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecExcludedCost,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecIncludedCost,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecOrigTotalCost,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecPassTotalCost,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecStewardship,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecCostShare,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecValueadded,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthrough,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      TotalRecMarkup,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecValueaddMarkup,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthroughMarkup,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Currency'
      TotalChargeout
      
}
