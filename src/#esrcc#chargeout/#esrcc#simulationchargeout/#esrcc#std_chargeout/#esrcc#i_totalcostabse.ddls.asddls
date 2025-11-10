@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cost & Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCOSTABSE 
   as select from /ESRCC/I_CB_LI as cb_li
 
{
    key Ryear,
    key Poper,
    key Fplv,
    key cb_li.Sysid,
    key Legalentity,
    key cb_li.Ccode,
    key Costobject,
    key Costcenter,
    validon,
    Localcurr,
    Groupcurr,   
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(virtualcost_l) as virtualtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(erpcost_l) as erptotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(excludedcost_l) as excludedtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(origcost_l) as origtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(passcost_l) as passtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(virtualcost_g) as virtualtotalcost_g,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(erpcost_g) as erptotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(excludedcost_g) as excludedtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(origcost_g) as origtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(passcost_g) as passtotalcost_g 
    
}
group by
Ryear,
Poper,
Fplv,
Sysid,
Legalentity,
Ccode,
Costobject,
Costcenter,
validon,
Localcurr,
Groupcurr
