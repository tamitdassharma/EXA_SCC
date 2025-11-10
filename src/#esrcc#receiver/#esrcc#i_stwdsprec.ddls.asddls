@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship Service Receiver'

define view entity /ESRCC/I_StwdSpRec
  as select from /esrcc/stwdsprec
  association        to parent /ESRCC/I_StwdSp as _ServiceProduct  on  _ServiceProduct.ServiceProductUuid = $projection.ServiceProductUuid
  association [1..1] to /ESRCC/I_Stewrdshp_S   as _StewardshipAll  on  _StewardshipAll.SingletonID = $projection.SingletonID
  association [1..1] to /ESRCC/I_CstObjct      as _CostObject      on  _CostObject.CostObjectUuid = $projection.CostObjectUuid
  association [1..1] to /esrcc/cst_objtt       as _CostObjectText  on  _CostObjectText.cost_object_uuid = $projection.CostObjectUuid
                                                                   and _CostObjectText.spras            = $session.system_language
  association [0..1] to I_CurrencyText         as _InvoiceCurrency on  _InvoiceCurrency.Currency = $projection.InvoiceCurrency
                                                                   and _InvoiceCurrency.Language = $session.system_language
{
  key serv_prod_rec_uuid                                        as ServiceReceiverUuid,
      _ServiceProduct.ServiceProduct                            as ServiceProduct,
      cost_object_uuid                                          as CostObjectUuid,
      _ServiceProduct.StewardshipUuid                           as StewardshipUuid,
      service_product_uuid                                      as ServiceProductUuid,
      invoice_currency                                          as InvoiceCurrency,
      active                                                    as Active,
      erp_sales_order                                           as ErpSalesOrder,
      contract_id                                               as ContractId,
      cast( _CostObject.Sysid as /esrcc/recsysid )              as Sysid,
      cast( _CostObject.LegalEntity as /esrcc/receivingntity )  as LegalEntity,
      cast( _CostObject.CompanyCode as /esrcc/recccode_de )     as CompanyCode,
      cast( _CostObject.CostObject as /esrcc/reccostobject_de ) as CostObject,
      cast( _CostObject.CostCenter as /esrcc/reccostcenter )    as CostCenter,

      @Semantics.user.createdBy: true
      created_by                                                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                                     as LocalLastChangedAt,
      1                                                         as SingletonID,
      _StewardshipAll,
      _ServiceProduct,
      _CostObject,
      _CostObjectText,
      _InvoiceCurrency
}
