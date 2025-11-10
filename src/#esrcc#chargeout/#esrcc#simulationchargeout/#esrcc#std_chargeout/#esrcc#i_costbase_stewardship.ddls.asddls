@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out Markup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_COSTBASE_STEWARDSHIP
     as select from /ESRCC/I_TOTALCOSTABSE as totalcb_li
   
    association [0..1] to /ESRCC/I_Stewardship as cc2le
    on  cc2le.LegalEntity = totalcb_li.Legalentity
    and cc2le.Sysid = totalcb_li.Sysid
    and cc2le.CompanyCode = totalcb_li.Ccode
    and cc2le.CostObject = totalcb_li.Costobject
    and cc2le.CostCenter = totalcb_li.Costcenter
    and totalcb_li.validon between cc2le.ValidFrom and cc2le.Validto
    
    association [0..1] to /esrcc/le_ccode as ccode
    on ccode.sysid  = $projection.Sysid
    and ccode.ccode = $projection.Ccode
    and ccode.legalentity = $projection.Legalentity
    and ccode.active = 'X'
    
{
    key Ryear,
    key Poper,
    key Fplv,
    key Sysid,
    key Legalentity,
    key totalcb_li.Ccode,
    key Costobject,
    key Costcenter,

// Additonal Characteristicsa
    cc2le.FunctionalArea,
    cc2le.ProfitCenter,
    cc2le.BusinessDivision,
    ccode.controllingarea,
    cc2le.BillingFrequency as billfrequency,    
    cc2le.chain_id,
    validon,
    Localcurr,
    Groupcurr,
    cc2le.stewardship,
//cost center cost evaluation   
    virtualtotalcost_l,
    erptotalcost_l,
    ( origtotalcost_l + passtotalcost_l + excludedtotalcost_l ) as Totalcost_l,
    excludedtotalcost_l,
    ( origtotalcost_l + passtotalcost_l) as includetotalcost_l, 
    origtotalcost_l,
    passtotalcost_l,
    virtualtotalcost_g,
    erptotalcost_g,
    ( origtotalcost_g + passtotalcost_g + excludedtotalcost_g ) as Totalcost_g,
    excludedtotalcost_g,
    ( origtotalcost_g + passtotalcost_g) as includetotalcost_g,    
    origtotalcost_g,
    passtotalcost_g
       
}
