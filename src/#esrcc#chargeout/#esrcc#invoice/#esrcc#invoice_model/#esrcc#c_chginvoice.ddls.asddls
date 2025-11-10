@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Invoice Chargeout'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHGINVOICE
  provider contract transactional_query
  as projection on /ESRCC/I_CHGINVOICE
{
  key     UUID,
  key     ParentUUID,
  key     RootUUID,
          @ObjectModel.text.element: [ 'currencytypetext' ]
  key     Currencytype,
          @ObjectModel.text.element: [ 'ChargeoutTypedescription' ]
  key     Chargeamountytpe,
          @ObjectModel.text.element: [ 'costdatasetdescription' ]
          Fplv,
          Ryear,
          Poper,
          Recalrefpoper,
          Sysid,
          @ObjectModel.text.element: [ 'legalentitydescription' ]
          Legalentity,
          @ObjectModel.text.element: [ 'ccodedescription' ]
          Ccode,
          @ObjectModel.text.element: [ 'costobjectdescription' ]
          Costobject,
          @ObjectModel.text.element: [ 'costcenterdescription' ]
          Costcenter,
          @ObjectModel.text.element: [ 'profitcenterdescription' ]
          Profitcenter,
          @ObjectModel.text.element: [ 'businessdescription' ]
          Businessdivision,
          @ObjectModel.text.element: [ 'functionalareadescription' ]
          FunctionalArea,          
//          @ObjectModel.text.element: [ 'ProcessTypedescription' ]
//          ProcessType,
          @ObjectModel.text.element: [ 'serviceproductdescription' ]
          Serviceproduct,                 
          ReceiverSysId,
          @ObjectModel.text.element: [ 'RecCcodedescription' ]
          ReceiverCompanyCode,
          @ObjectModel.text.element: [ 'receivingentitydescription' ]
          Receivingentity,
          @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
          ReceiverCostObject,
          @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
          ReceiverCostCenter,
          @ObjectModel.text.element: [ 'chargeoutdescription' ]
          Chargeout,
          @ObjectModel.text.element: [ 'servicetypedescription' ]
          Servicetype,
          @ObjectModel.text.element: [ 'transactiongroupdescription' ]
          Transactiongroup,
          ContractId,
          ErpSalesOrder,
          PostingDate,
          PostingPeriod,
          ErpFlag,
//          @Semantics.amount.currencyCode: 'Currency'
//          TransferPrice,
//          @Semantics.quantity.unitOfMeasure: 'Uom'
//          Reckpi,
//          ConsumptionUom,
          Currency,
//          Reckpishare,          
          @Semantics.amount.currencyCode: 'Currency'
          TotalChargeout,
          InvoiceUUID,
          InvoiceNumber,
          @ObjectModel.text.element: [ 'invoicestatusdescription' ]
          InvoiceStatus,
          Filename,
          Mimetype,
          @Semantics.largeObject: {
             mimeType: 'Mimetype',
             fileName: 'Filename',
             contentDispositionPreference: #INLINE }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/DEFAULT_VIRTUAL_ELEMENT'
  virtual Stream : abap.rawstring(0),
          //          legalentitycountry,

          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,

          //descriptions
//          @Semantics.text: true
//          billingfrequencydescription,
//          @Semantics.text: true
//          billingperioddescription,
          @Semantics.text: true
          legalentitydescription,
          @Semantics.text: true
          costobjectdescription,
          @Semantics.text: true
          costcenterdescription,
          @Semantics.text: true
          profitcenterdescription,
          @Semantics.text: true
          businessdescription,
          @Semantics.text: true
          functionalareadescription,
          @Semantics.text: true
          Serviceproductdescription,
          @Semantics.text: true
          Transactiongroupdescription,
          @Semantics.text: true
          Servicetypedescription,
          @Semantics.text: true
          ccodedescription,
          @Semantics.text: true
          oecdDescription,
          @Semantics.text: true
          costdatasetdescription,
          @Semantics.text: true
          RecCcodedescription,
          @Semantics.text: true
          receivingentitydescription,
          @Semantics.text: true
          RecCostCenterdescription,
          @Semantics.text: true
          RecCostObjectdescription,
          @Semantics.text: true
          chargeoutdescription,
          @Semantics.text: true
          invoicestatusdescription,
          @Semantics.text: true
          _chargeouttype.text as ChargeoutTypedescription,
          invoicestatuscriticallity,
          @Semantics.text: true
          _CurrencyTypeText.text as currencytypetext,    
          @ObjectModel.text.element: [ 'legalentitycountryname' ]
          legalentitycountry,
          @ObjectModel.text.element: [ 'receivingentitycountryname' ]
          receivingentitycountry,
          legalentitycountryname,
          _ReceivingCountryText.CountryName as receivingentitycountryname
}
