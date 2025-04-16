@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@EndUserText.label: 'Receiver Total Cost'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.semanticKey: [ 'Fplv', 'Ryear', 'Poper', 'Legalentity', 'Ccode', 'Costobject', 'Costcenter', 'Serviceproduct' ]
define view entity /ESRCC/C_ReceiverChargeout
  as projection on /ESRCC/I_ReceiverChargeout
{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,     
      ReceiverSysId,
      @ObjectModel.text.element: [ 'ccodedescription' ]
      ReceiverCompanyCode,
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
      Receivingentity,  
      @ObjectModel.text.element: [ 'costobjectdescription' ]    
      ReceiverCostObject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      ReceiverCostCenter,     
      @ObjectModel.text.element: [ 'consumptionversiontext' ]
      ConsumptionVersion,
      @ObjectModel.text.element: [ 'keyversiontext' ]
      KeyVersion,
      @Semantics.quantity.unitOfMeasure: 'ConsumptionUom'
      Reckpi,
      @ObjectModel.text.element: [ 'unitname' ]
      ConsumptionUom,
      @DefaultAggregation: #SUM
      Reckpishare,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalChargeout,
      Valueaddmarkup,
      Passthrumarkup,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthroughMarkup,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecValueaddMarkup,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalRecMarkup,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthrough,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecValueadded,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      RecCostShare,
      @Semantics.amount.currencyCode: 'Currency'
      TransferPrice,
      @Semantics.amount.currencyCode: 'Currency'
      TpPassthrumarkupCostperunit,
      @Semantics.amount.currencyCode: 'Currency'
      TpValueaddmarkupCostperunit,
      @ObjectModel.text.element: [ 'statusdescription' ]
      Status,
      Workflowid,
      CommentId,
      Currency,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      statusdescription,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      Country,
      InvoiceNumber,
      @ObjectModel.text.element: [ 'invoicestatusdescription' ]
      InvoiceStatus,
      @Semantics.text: true
      invoicestatusdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,
      _ReceivingCountryText.CountryName as receivingcountryname,
      _UoM.UnitOfMeasureName            as unitname,
      _ConsumptionVersion.text          as consumptionversiontext,
      _KeyVersion.text                  as keyversiontext,
      /* Associations */
      _ServiceCost : redirected to parent /ESRCC/C_ServiceProductShare
}
