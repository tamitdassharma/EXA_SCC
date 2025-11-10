@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@EndUserText.label: 'Cost Base & Stewardship'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CostBaseStewardship 
provider contract transactional_query
as projection on /ESRCC/I_CostBaseStewardship 
{
    key UUID,
    @ObjectModel.text.element: [ 'CurrencyTypedescription' ]
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
    @ObjectModel.text.element: [ 'TpProfileDesc' ]
    TpProfile,
    @ObjectModel.text.element: [ 'businessdescription' ]
    Businessdivision,
    @ObjectModel.text.element: [ 'functionalareadescription' ]
    FunctionalArea,
    @ObjectModel.text.element: [ 'profitcenterdescription' ]
    Profitcenter,
    Controllingarea,    
    @ObjectModel.text.element: [ 'ProcessTypedescription' ]
    ProcessType,
    @Semantics.currencyCode: true
    Currency,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Totalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Excludedtotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Includetotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Origtotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passtotalcost,
//    @Semantics.amount.currencyCode: 'Currency'
//    @ObjectModel.filter.enabled: false
    Stewardship,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Remainingcostbase,
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    Workflowid, 
    CommentId,
    Recalrefpoper,
    @Semantics.text: true  
    ccodedescription,
    @Semantics.text: true 
    legalentitydescription,
    @Semantics.text: true 
    costobjectdescription,
    @Semantics.text: true 
    costcenterdescription,
    @Semantics.text: true 
    costdatasetdescription,
    @Semantics.text: true 
    businessdescription,
    @Semantics.text: true 
    functionalareadescription,
    @Semantics.text: true 
    profitcenterdescription,
    @Semantics.text: true 
    statusdescription,
    @Semantics.text: true 
    ProcessTypedescription,
    @Semantics.text: true 
    TpProfileDesc,
    @Semantics.text: true 
    _Currencytype.text as CurrencyTypedescription,
    @ObjectModel.text.element: [ 'countryname' ]
    Country,
    CreatedBy,
//    @ObjectModel.filter.enabled: false
    CreatedAt,
    LastChangedBy,
//    @ObjectModel.filter.enabled: false
    LastChangedAt,
    @Semantics.text: true 
    _legalCountryText.CountryName as countryname,
    _ServiceMarkup: redirected to composition child /ESRCC/C_ServiceProductShare
    
}
