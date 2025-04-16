@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Service Cost Share'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_SRV_WORKFLOW 
provider contract transactional_query
as projection on /ESRCC/I_SRV_WORKFLOW
{
    key UUID,
    key ParentUUID,
    @ObjectModel.text.element: [ 'currencytypetext' ]
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
    
    @ObjectModel.text.element: [ 'Serviceproductdescription' ]
    Serviceproduct,   
    
    @ObjectModel.text.element: [ 'Servicetypedescription' ]
    Servicetype,
    
    @ObjectModel.text.element: [ 'Transactiongroupdescription' ]
    Transactiongroup,
//    @DefaultAggregation: #SUM
    Costshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Srvcostshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthroughshare,
    
    @ObjectModel.text.element: [ 'chargeoutdescription' ]
    Chargeout,
    @Semantics.quantity.unitOfMeasure: 'PlanningUom'
    Planning,
    @ObjectModel.text.element: [ 'unitname' ]
    PlanningUom,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Servicecostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddcostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthrucostperunit,
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
    Transactiongroupdescription,
    @Semantics.text: true
    statusdescription,
    @Semantics.text: true
    chargeoutdescription,
    @ObjectModel.text.element: [ 'legalcountryname' ]
    Country,
    
    Currency,
    
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    Workflowid,
    
    CreatedBy,
    
    CreatedAt,
    
    LastChangedAt,
    
    LastChangedBy,
    
    @Semantics.text: true
    _UoM.UnitOfMeasureName as unitname,
    @Semantics.text: true
    _CurrencyTypeText.text as currencytypetext,
    @Semantics.text: true
    _legalCountryText.CountryName as legalcountryname
    
}
