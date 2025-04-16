@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Charge Out Analytical List'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}


define view entity /ESRCC/I_CHARGEOUT_CHARTS
  as select from /ESRCC/I_CHG_ANALYTICS
{
      @AnalyticsDetails.query.hidden: true
  key UUID,
      @AnalyticsDetails.query.hidden: true
  key ParentUUID,
      @AnalyticsDetails.query.hidden: true
  key RootUUID,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'costdatasetdescription' ]
  key Fplv,
      @AnalyticsDetails.query.display: #KEY
  key Ryear,
  key Sysid,
  key Poper,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'ccodedescription' ]      
  key Ccode,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'legalentitydescription' ]
  key Legalentity,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      @AnalyticsDetails.query.display: #KEY
  key Costobject,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'costcenterdescription' ]
  key Costcenter,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'transactiongroupdescription' ]
  key Transactiongroup,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
  key Serviceproduct,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'servicetypedescription' ]
  key Servicetype,
      @AnalyticsDetails.query.display: #KEY
  key ReceiverSysId,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'RecCcodedescription' ]
  key ReceiverCompanyCode,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
  key Receivingentity,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
  key ReceiverCostObject,
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
  key ReceiverCostCenter, 
  
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'ProcessTypedescription' ]
      ProcessType,
      
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'functionalareadescription' ]
      FunctionalArea,
      
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'businessdescription' ]
      Businessdivision,
      
      @AnalyticsDetails.query.display: #KEY
      ContractId,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalChargeout       as TotalChargeOutAmount,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecExcludedCost      as ExcludedTotalCost,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecIncludedCost      as IncludedTotalCost,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecTotalCost    as TotalCostBase,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecCostShare         as TotalCostBaseRemaining,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalRecMarkup    as SrvTotalMarkup,


      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecValueaddMarkup as ValueAddMarkup,


      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthroughMarkup as PassThruMarkup,
      
      @ObjectModel.text.element: [ 'statusdescription' ]
      @AnalyticsDetails.query.display: #KEY
      Status,      
      
      @ObjectModel.text.element: [ 'oecdDescription' ] 
      @AnalyticsDetails.query.display: #KEY
      OECD,
      
      Currency,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecStewardship          as Stewardship,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      Transactiongroupdescription,
      @Semantics.text: true
      Serviceproductdescription,
      @Semantics.text: true
      Servicetypedescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      functionalareadescription,
      @Semantics.text: true
      businessdescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      RecCcodedescription,
      @Semantics.text: true
      RecCostObjectdescription,
      @Semantics.text: true
      RecCostCenterdescription,
      @ObjectModel.text.element: [ 'legalcountryname' ]
      legalentitycountry,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      receivingentitycountry,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      oecdDescription,
      @Semantics.text: true
      ProcessTypedescription,
      @Semantics.text: true
      _legalCountryText.CountryName as legalcountryname,
      @Semantics.text: true
      _ReceivingCountryText.CountryName as receivingcountryname
}
