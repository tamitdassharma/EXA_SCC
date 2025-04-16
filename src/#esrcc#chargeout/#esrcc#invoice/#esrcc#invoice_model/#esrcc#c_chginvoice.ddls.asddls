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
          @ObjectModel.text.element: [ 'costdatasetdescription' ]
          _ServiceCost._CostCenterCost.Fplv,
          _ServiceCost._CostCenterCost.Ryear,
          _ServiceCost._CostCenterCost.Poper,
          Sysid,
          @ObjectModel.text.element: [ 'legalentitydescription' ]
          Legalentity,
          @ObjectModel.text.element: [ 'ccodedescription' ]
          Ccode,
          @ObjectModel.text.element: [ 'costobjectdescription' ]
          Costobject,
          @ObjectModel.text.element: [ 'costcenterdescription' ]
          Costcenter,
          @ObjectModel.text.element: [ 'ProcessTypedescription' ]
          _ServiceCost._CostCenterCost.ProcessType,
          @ObjectModel.text.element: [ 'serviceproductdescription' ]
          _ServiceCost.Serviceproduct,
          ReceiverSysId,
          @ObjectModel.text.element: [ 'RecCcodedescription' ]
          ReceiverCompanyCode,
          @ObjectModel.text.element: [ 'receivingentitydescription' ]
          Receivingentity,
          @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
          ReceiverCostObject,
          @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
          ReceiverCostCenter,
          @ObjectModel.text.element: [ 'billingfrequencydescription' ]
          _ServiceCost._CostCenterCost.Billingfrequqncy,
          @ObjectModel.text.element: [ 'billingperioddescription' ]
          _ServiceCost._CostCenterCost.Billingperiod,
          @ObjectModel.text.element: [ 'chargeoutdescription' ]
          _ServiceCost.Chargeout,
          @ObjectModel.text.element: [ 'servicetypedescription' ]
          _ServiceCost.Servicetype,
          @ObjectModel.text.element: [ 'transactiongroupdescription' ]
          _ServiceCost.Transactiongroup,
          _ServiceCost.ContractId,
          @Semantics.amount.currencyCode: 'Currency'
          TransferPrice,
//          @Semantics.quantity.unitOfMeasure: 'Uom'
          Reckpi,
          ConsumptionUom,
          Currency,
          Reckpishare,
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
          @Semantics.text: true
          _ServiceCost._CostCenterCost.billingfrequencydescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.billingperioddescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.legalentitydescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.costobjectdescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.costcenterdescription,
          @Semantics.text: true
          _ServiceCost.Serviceproductdescription,
          @Semantics.text: true
          _ServiceCost.Transactiongroupdescription,
          @Semantics.text: true
          _ServiceCost.Servicetypedescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.ccodedescription,
          @Semantics.text: true
          _ServiceCost.oecdDescription,
          @Semantics.text: true
          _ServiceCost._CostCenterCost.costdatasetdescription,
          @Semantics.text: true
          RecCcodedescription,
          @Semantics.text: true
          receivingentitydescription,
          @Semantics.text: true
          RecCostCenterdescription,
          @Semantics.text: true
          RecCostObjectdescription,
          @Semantics.text: true
          _ServiceCost.chargeoutdescription,
          @Semantics.text: true
          invoicestatusdescription,
          @Semantics.text: true
          ProcessTypedescription,
          invoicestatuscriticallity,
          @Semantics.text: true
          _CurrencyTypeText.text as currencytypetext,    
          @ObjectModel.text.element: [ 'legalentitycountryname' ]
          _ServiceCost._CostCenterCost.Country as legalentitycountry,
          @ObjectModel.text.element: [ 'receivingentitycountryname' ]
          receivingentitycountry,
          _ServiceCost._CostCenterCost._legalCountryText.CountryName as legalentitycountryname,
          _ReceivingCountryText.CountryName as receivingentitycountryname
}
