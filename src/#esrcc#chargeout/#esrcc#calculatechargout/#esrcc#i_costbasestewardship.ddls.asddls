@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Center Cost'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.query: true

define root view entity /ESRCC/I_CostBaseStewardship
as select from /ESRCC/I_CostBaseData as cc_cost   
  
 composition [0..*] of /ESRCC/I_ServiceProductShare            as _ServiceMarkup

 association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _legalentity
  on _legalentity.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as ccode  
  on ccode.Ccode        = $projection.Ccode
  and ccode.Sysid       = $projection.Sysid
  and ccode.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COSTOBJECTS as costobject  
  on costobject.Costobject = $projection.Costobject
  
  association [0..1] to /ESRCC/I_COSCEN_F4 as costcenter
  on  costcenter.LegalEntity = $projection.Legalentity
  and costcenter.CompanyCode = $projection.Ccode
  and costcenter.Costcenter  = $projection.Costcenter
  and costcenter.Sysid       = $projection.Sysid
  and costcenter.Costobject  = $projection.Costobject
  
  association [0..1] to /ESRCC/I_COSTDATASET as costdataset
  on costdataset.costdataset = $projection.Fplv
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as profitcenter
  on profitcenter.ProfitCenter = $projection.Profitcenter
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as businessdiv
  on businessdiv.BusinessDivision = $projection.Businessdivision

  association [0..1] to /ESRCC/I_FunctionalArea_F4 as functionalarea
  on functionalarea.FunctionalArea = $projection.FunctionalArea
  
  association [0..1] to /ESRCC/I_STATUS as status
  on status.Status = $projection.Status
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.country
  and _legalCountryText.Language = $session.system_language  
  
  association [0..1] to /ESRCC/I_PROCESSTYPE as _Processtype
  on _Processtype.ProcessType = $projection.ProcessType
  
  association [0..1] to /ESRCC/I_CURR as _Currencytype
  on _Currencytype.Currencytype = $projection.Currencytype
  
{
    key UUID,
    key Currencytype,
    Fplv as Fplv,
    Ryear as Ryear,
    Poper as Poper,
    RefPoper,
    Sysid as Sysid,
    cc_cost.Legalentity as Legalentity,
    cc_cost.Ccode as Ccode,
    cc_cost.Costobject as Costobject,
    cc_cost.Costcenter as Costcenter,    
    cc_cost.Businessdivision as Businessdivision,
    cc_cost.FunctionalArea as FunctionalArea,
    cc_cost.Profitcenter as Profitcenter,
    Controllingarea as Controllingarea,    
    ProcessType as ProcessType,
    Currency,
    VirtualCost,
    ERPCost,
    Totalcost,
    Excludedtotalcost,
    ( Totalcost - Excludedtotalcost ) as Includetotalcost,
    Origtotalcost,
    Passtotalcost,  
    Stewardship as Stewardship,
    cast((Totalcost -  Excludedtotalcost) * (1 - (Stewardship / 100)) as abap.dec(23,2)) as Remainingcostbase,
    cc_cost.Status,
    Workflowid,
    CommentId,
    ChainId, 
    Recalrefpoper,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    ccode.ccodedescription,
    _legalentity.Description as legalentitydescription,
    costobject.text as costobjectdescription,
    costcenter.Description as costcenterdescription,
    costdataset.text as costdatasetdescription,
    businessdiv.Description as businessdescription,
    functionalarea.Description as functionalareadescription,
    profitcenter.profitcenterdescription,
    status.text as statusdescription,
    _legalentity.Country,
    _legalentity.LocalCurr,
    _legalentity.Region,
    _legalentity.RegionDesc,
    _legalentity.TpProfile,
    _legalentity.TpProfileDesc,
    _legalCountryText,
    _Processtype.text as ProcessTypedescription,
    // Make association public   
    _ServiceMarkup,
    _Currencytype
    
}

