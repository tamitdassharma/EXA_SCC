@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Charge-Out Receiver'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHG_ANALYTICS
  provider contract transactional_query
  as projection on /ESRCC/I_CHG_ANALYTICS
{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      @ObjectModel.text.element: [ 'costdatasetdescription' ]
      Fplv,
      Ryear,
      Poper,
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
      ProcessType,
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
      @ObjectModel.filter.enabled: false
      Billingfrequqncy,
      @ObjectModel.filter.enabled: false
      Billingperiod,
      @ObjectModel.text.element: [ 'functionalareadescription' ]
      FunctionalArea,
      @ObjectModel.text.element: [ 'businessdescription' ]
      Businessdivision,
      @ObjectModel.text.element: [ 'profitcenterdescription' ]
      Profitcenter,
      @ObjectModel.filter.enabled: false
      Controllingarea,
      @ObjectModel.text.element: [ 'servicetypedescription' ]
      Servicetype,
      @ObjectModel.text.element: [ 'transactiongroupdescription' ]
      Transactiongroup,
      ContractId,
      @ObjectModel.filter.enabled: false
      Chargeout,
      @ObjectModel.filter.enabled: false
      Uom,
      @ObjectModel.filter.enabled: false
      Reckpi,
      @ObjectModel.filter.enabled: false
      Reckpishare,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      TotalChargeout,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      TotalRecMarkup,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecValueaddMarkup,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthroughMarkup,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecCostShare,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecValueadded,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecPassthrough,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecStewardship,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecIncludedCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecOrigTotalCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecPassTotalCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecExcludedCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecTotalCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecVirtualTotalCost,
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'Currency'
      RecERPTotalCost,
      @ObjectModel.text.element: [ 'statusdescription' ]
      Status,
      @ObjectModel.text.element: [ 'oecdDescription' ]
      OECD,
      @ObjectModel.filter.enabled: false
      Currency,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      Serviceproductdescription,
      @Semantics.text: true
      Transactiongroupdescription,
      @Semantics.text: true
      Servicetypedescription,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      functionalareadescription,
      @Semantics.text: true
      businessdescription,
      @Semantics.text: true
      profitcenterdescription,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      RecCcodedescription,
      @Semantics.text: true
      RecCostObjectdescription,
      @Semantics.text: true
      RecCostCenterdescription,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      oecdDescription,
      @Semantics.text: true
      ProcessTypedescription,
      @ObjectModel.filter.enabled: false
      legalentitycountry,
      @ObjectModel.filter.enabled: false
      receivingentitycountry,
      @ObjectModel.filter.enabled: false
      legalentitycurrecy,
      @ObjectModel.filter.enabled: false
      ReceiverCurrency,
      @ObjectModel.filter.enabled: false
      legalentityregion,
      @ObjectModel.filter.enabled: false
      legalentityregiondesc,
      @ObjectModel.filter.enabled: false
      ReceiverRegion,
      @ObjectModel.filter.enabled: false
      ReceiverRegionDesc
}
