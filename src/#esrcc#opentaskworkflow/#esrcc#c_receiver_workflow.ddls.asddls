@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Receivers Chargeout Cost'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_RECEIVER_WORKFLOW 
provider contract transactional_query
as projection on /ESRCC/I_RECCOST_WORKFLOW
{   
    key UUID,
    key ParentUUID,
    key RootUUID,
    key Currencytype,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'costdatasetdescription' ]
    Fplv,
    @ObjectModel.filter.enabled: false
    Ryear,
    @ObjectModel.filter.enabled: false
    Poper,
    @ObjectModel.filter.enabled: false
    Sysid,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    Legalentity,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'ccodedescription' ]
    Ccode,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    Costobject,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    Costcenter,
    @ObjectModel.text.element: [ 'Serviceproductdescription' ]
    Serviceproduct,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    Receivingentity,
    ReceiverSysId,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'Reccodedescription' ]
    ReceiverCompanyCode,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'Reccostobjectdescription' ]
    ReceiverCostObject,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'Reccostcenterdescription' ]
    ReceiverCostCenter,
    Reckpi,
    @ObjectModel.filter.enabled: false
    Currency,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalRecMarkup, 
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    RecCostShare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    RecValueadded,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    RecPassthrough,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalChargeout,
    Workflowid,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    @Semantics.text: true
    costdatasetdescription,
    @Semantics.text: true
    legalentitydescription,
    @Semantics.text: true
    ccodedescription,
    @Semantics.text: true
    costobjectdescription,
    @Semantics.text: true
    costcenterdescription,
    @Semantics.text: true
    Serviceproductdescription,
    @Semantics.text: true
    Servicetypedescription,
    @Semantics.text: true
    statusdescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    Reccodedescription,
    @Semantics.text: true
    Reccostcenterdescription,
    @Semantics.text: true
    Reccostobjectdescription,
    @ObjectModel.text.element: [ 'reccountryname' ]
    receivingentitycountry,
    @ObjectModel.text.element: [ 'legalcountryname' ]
    legalentitycountry,
    @Semantics.text: true
    _ReceivingCountryText.CountryName as reccountryname,
    @Semantics.text: true
    _legalCountryText.CountryName as legalcountryname
    
}
