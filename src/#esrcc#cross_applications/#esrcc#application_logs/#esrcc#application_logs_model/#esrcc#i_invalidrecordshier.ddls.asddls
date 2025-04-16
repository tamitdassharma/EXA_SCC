@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy interface for Invalid Records'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity /ESRCC/I_InvalidRecordsHier
  as select from /esrcc/inv_rcrds
  association to parent /ESRCC/I_AppLogItemsChildHier as _log_items_child on $projection.parent_hid = _log_items_child.hid
{
  key invalid_record_uuid          as hid,
      log_uuid                     as parent_hid,
      3                            as hier_level,
      cast('leaf' as abap.char(8)) as drilldown_state,
      log_header_uuid              as LogHeaderUuid,
      ryear                        as Ryear,
      poper                        as Poper,
      fplv                         as Fplv,
      sysid                        as Sysid,
      legalentity                  as Legalentity,
      ccode                        as Ccode,
      belnr                        as Belnr,
      buzei                        as Buzei,
      costobject                   as Costobject,
      costcenter                   as Costcenter,
      costelement                  as Costelement,
      businessdivision             as Businessdivision,
      profitcenter                 as Profitcenter,
      @Semantics.amount.currencyCode : 'Localcurr'
      hsl                          as Hsl,
      localcurr                    as Localcurr,
      @Semantics.amount.currencyCode: 'Groupcurr'
      ksl                          as Ksl,
      groupcurr                    as Groupcurr,
      vendor                       as Vendor,
      postingtype                  as Postingtype,
      costind                      as Costind,
      usagecal                     as Usagecal,
      status                       as Status,
      workflowid                   as Workflowid,
      oldcostind                   as Oldcostind,
      oldusagecal                  as Oldusagecal,
      oldcostdataset               as Oldcostdataset,
      comments                     as Comments,
      log_header_uuid              as RootUUID,
      _log_items_child
}
