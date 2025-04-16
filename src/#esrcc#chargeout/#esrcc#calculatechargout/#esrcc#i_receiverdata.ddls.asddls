@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receiver Total Cost Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ReceiverData
  as select from /esrcc/rec_chg
{
  key rec_uuid            as UUID,
  key srv_uuid            as ParentUUID,
  key cc_uuid             as RootUUID,
      receiversysid       as ReceiverSysId,
      receivercompanycode as ReceiverCompanyCode,
      receivingentity     as Receivingentity,
      receivercostobject  as ReceiverCostObject,
      receivercostcenter  as ReceiverCostCenter,
      'L'                 as Currencytype,
      valueaddmarkup      as Valueaddmarkup,
      passthrumarkup      as Passthrumarkup,
      reckpi              as Reckpi,
      reckpishare         as Reckpishare,      
      consumptionuom      as ConsumptionUom,
      status              as Status,
      workflowid          as Workflowid,
      commentid           as CommentId,
      exchdate            as Exchdate,
      invoicingcurrency   as InvoicingCurrency,
      invoiceuuid         as InvoiceUUID,
      invoicenumber       as InvoiceNumber,
      invoicestatus       as InvoiceStatus,
      created_by          as CreatedBy,
      created_at          as CreatedAt,
      last_changed_by     as LastChangedBy,
      last_changed_at     as LastChangedAt
}
union
select from /esrcc/rec_chg
{
  key rec_uuid            as UUID,
  key srv_uuid            as ParentUUID,
  key cc_uuid             as RootUUID,
      receiversysid       as ReceiverSysId,
      receivercompanycode as ReceiverCompanyCode,
      receivingentity     as Receivingentity,
      receivercostobject  as ReceiverCostObject,
      receivercostcenter  as ReceiverCostCenter,
      'I'                 as Currencytype,
      valueaddmarkup      as Valueaddmarkup,
      passthrumarkup      as Passthrumarkup,
      reckpi              as Reckpi,
      reckpishare         as Reckpishare,      
      consumptionuom      as ConsumptionUom,
      status              as Status,
      workflowid          as Workflowid,
      commentid           as CommentId,
      exchdate            as Exchdate,
      invoicingcurrency   as InvoicingCurrency,
      invoiceuuid         as InvoiceUUID,
      invoicenumber       as InvoiceNumber,
      invoicestatus       as InvoiceStatus,
      created_by          as CreatedBy,
      created_at          as CreatedAt,
      last_changed_by     as LastChangedBy,
      last_changed_at     as LastChangedAt
}
union select from /esrcc/rec_chg
{
  key rec_uuid            as UUID,
  key srv_uuid            as ParentUUID,
  key cc_uuid             as RootUUID,
      receiversysid       as ReceiverSysId,
      receivercompanycode as ReceiverCompanyCode,
      receivingentity     as Receivingentity,
      receivercostobject  as ReceiverCostObject,
      receivercostcenter  as ReceiverCostCenter,
      'G'                 as Currencytype,
      valueaddmarkup      as Valueaddmarkup,
      passthrumarkup      as Passthrumarkup,
      reckpi              as Reckpi,
      reckpishare         as Reckpishare,      
      consumptionuom      as ConsumptionUom,
      status              as Status,
      workflowid          as Workflowid,
      commentid           as CommentId,
      exchdate            as Exchdate,
      invoicingcurrency   as InvoicingCurrency,
      invoiceuuid         as InvoiceUUID,
      invoicenumber       as InvoiceNumber,
      invoicestatus       as InvoiceStatus,
      created_by          as CreatedBy,
      created_at          as CreatedAt,
      last_changed_by     as LastChangedBy,
      last_changed_at     as LastChangedAt
}

