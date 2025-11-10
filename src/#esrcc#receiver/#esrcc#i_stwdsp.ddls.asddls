@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship Service Product'

define view entity /ESRCC/I_StwdSp
  as select from /esrcc/stwd_sp
  association [1..1] to /ESRCC/I_Stewrdshp_S       as _StewardshipAll     on _StewardshipAll.SingletonID = $projection.SingletonID
  association        to parent /ESRCC/I_Stewrdshp  as _Stewardship        on _Stewardship.StewardshipUuid = $projection.StewardshipUuid
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _ServiceProductText on _ServiceProductText.ServiceProduct = $projection.ServiceProduct
  composition [0..*] of /ESRCC/I_StwdSpRec          as _ServiceReceiver
{
  key service_product_uuid  as ServiceProductUuid,
      service_product       as ServiceProduct,
      valid_from            as ValidFrom,
      valid_to              as ValidTo,
      share_of_cost         as ShareOfCost,
      erp_sales_order       as ErpSalesOrder,
      contract_id           as ContractId,
      stewardship_uuid      as StewardshipUuid,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _StewardshipAll,
      _Stewardship,
      _ServiceReceiver,
      _ServiceProductText
}
