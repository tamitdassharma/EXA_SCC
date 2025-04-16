@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Base Chargeout'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /ESRCC/I_COSTBASE_CHARGEOUT as select from /esrcc/cb_stw

{
    key cc_uuid as CcUuid,
    fplv as Fplv,
    ryear as Ryear,
    poper as Poper,
    sysid as Sysid,
    legalentity as Legalentity,
    ccode as Ccode,
    costobject as Costobject,
    costcenter as Costcenter,
    billfrequency as Billfrequency,
    functionalarea as Functionalarea,
    businessdivision as Businessdivision,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,
    billingperiod as Billingperiod,
    localcurr as Localcurr,
    groupcurr as Groupcurr,
    totalcost_l as TotalcostL,
    totalcost_g as TotalcostG,
    excludedtotalcost_l as ExcludedtotalcostL,
    excludedtotalcost_g as ExcludedtotalcostG,
    origtotalcost_l as OrigtotalcostL,
    origtotalcost_g as OrigtotalcostG,
    passtotalcost_l as PasstotalcostL,
    passtotalcost_g as PasstotalcostG,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
//    comments as Comments,
    validon as Validon,
    processtype as Processtype,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
}
