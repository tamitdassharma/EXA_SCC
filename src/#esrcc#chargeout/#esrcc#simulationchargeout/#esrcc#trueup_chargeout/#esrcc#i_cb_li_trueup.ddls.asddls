@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge Out Cost Base Line Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CB_LI_TRUEUP 
    as select from /esrcc/cb_li
{
    key ryear as Ryear,
    key poper as Poper,
    key fplv  as Fplv,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
//    key costelement as Costelement,
    cast(concat(ryear,concat((right(poper,2) ), '01')) as abap.dats ) as validon,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(hsl) as Hsl,
    localcurr as Localcurr,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(ksl) as Ksl,
    groupcurr as Groupcurr,
    
    costind as Costind,
    usagecal as Usagecal,
    value_source as ValueSource,
    
    @Semantics.amount.currencyCode: 'Localcurr'
    case when value_source = 'SCC' then
    sum(cast( hsl as abap.dec(23,2)))
    else
    0 end as virtualcost_l,
    
    @Semantics.amount.currencyCode: 'Localcurr'
    case when value_source <> 'SCC' then
    sum(cast( hsl as abap.dec(23,2)))
    else
    0 end as erpcost_l,
    
    @Semantics.amount.currencyCode: 'Localcurr' 
    case when usagecal = 'E' then
    sum(cast( hsl as abap.dec(23,2)))
    else
    0 end as excludedcost_l,
     
    @Semantics.amount.currencyCode: 'Localcurr' 
    case when costind = 'ORIG' and usagecal = 'I' then
    sum(cast( hsl as abap.dec(23,2)))
    else
    0 end as origcost_l,
    
    @Semantics.amount.currencyCode: 'Localcurr'  
    case when costind = 'PASS' and usagecal = 'I' then
    sum(cast( hsl as abap.dec(23,2)))
    else
    0 end as passcost_l,
    
    @Semantics.amount.currencyCode: 'Localcurr'
    case when value_source = 'SCC' then
    sum(cast( ksl as abap.dec(23,2)))
    else
    0 end as virtualcost_g,
    
    @Semantics.amount.currencyCode: 'Localcurr'
    case when value_source <> 'SCC' then
    sum(cast( ksl as abap.dec(23,2)))
    else
    0 end as erpcost_g,
    
    @Semantics.amount.currencyCode: 'Groupcurr'  
    case when usagecal = 'E' then
     sum(cast( ksl as abap.dec(23,2)))
    else
    0  end as excludedcost_g,
    
    @Semantics.amount.currencyCode: 'Groupcurr'   
    case when costind = 'ORIG' and usagecal = 'I' then
     sum(cast( ksl as abap.dec(23,2)))
    else
    0  end as origcost_g,
    
    @Semantics.amount.currencyCode: 'Groupcurr'   
    case when costind = 'PASS' and usagecal = 'I' then
    sum(cast( ksl as abap.dec(23,2)))
    else
    0  end as passcost_g      
      
} where status = 'A' or status = 'F'
group by
ryear,
poper,
fplv,
sysid,
legalentity,
ccode,
costobject,
costcenter,
localcurr,
groupcurr,
usagecal,
costind,
value_source
