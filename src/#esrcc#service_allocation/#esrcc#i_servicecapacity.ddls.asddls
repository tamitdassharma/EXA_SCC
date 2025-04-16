@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Capacity for Direct Charging'

define root view entity /ESRCC/I_ServiceCapacity
  as select from /esrcc/srv_cpcty
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _ServiceProduct  on  _ServiceProduct.ServiceProduct = $projection.ServiceProduct

  association [0..1] to /ESRCC/I_CAPACITY_VERSION  as _CapacityVersion on  _CapacityVersion.CapacityVersion = $projection.Fplv

  association        to I_UnitOfMeasureText        as _Uom             on  $projection.Uom = _Uom.UnitOfMeasure_E
                                                                       and _Uom.Language   = $session.system_language
  association [1..1] to /ESRCC/I_POPER             as _PoperText       on  _PoperText.Poper = $projection.Poper
  association [1..1] to /ESRCC/I_COSCEN_F4         as _CostCenter      on  $projection.CostObjectUuid = _CostCenter.CostObjectUuid
{
  key capacity_uuid         as CapacityUuid,
      ryear                 as Ryear,
      poper                 as Poper,
      fplv                  as Fplv,
      service_product       as ServiceProduct,
      cost_object_uuid      as CostObjectUuid,
      uom                   as Uom,
      planning              as Planning,

      _CostCenter.Sysid,
      _CostCenter.LegalEntity,
      _CostCenter.CompanyCode,
      _CostCenter.Costobject,
      _CostCenter.Costcenter,

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

      _ServiceProduct,
      _CapacityVersion,
      _Uom,
      _PoperText,
      _CostCenter
}
