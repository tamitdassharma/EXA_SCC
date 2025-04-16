@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for Service Capacity'

define root view entity /ESRCC/C_ServiceCapacity
  provider contract transactional_query
  as projection on /ESRCC/I_ServiceCapacity
{
  key CapacityUuid,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      Sysid,
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      LegalEntity,
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      CompanyCode,
      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      Costobject,
      @ObjectModel.text.element: [ 'CostCenterDescription' ]
      Costcenter,

      @ObjectModel.text.element: [ 'FplvDescription' ]
      Fplv,
      Ryear,
      @ObjectModel.text.element: [ 'PoperDescription' ]
      Poper,
      @ObjectModel.text.element: [ 'ServiceProductDescription' ]
      ServiceProduct,
      CostObjectUuid,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Planning,
      @Semantics.unitOfMeasure: true
      Uom,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,

      @Semantics.text: true
      _ServiceProduct.Description        as ServiceProductDescription,
      @Semantics.text: true
      _CostCenter.SysidDescription,
      @Semantics.text: true
      _CostCenter.LegalEntityDescription as LegalEntityDescription,
      @Semantics.text: true
      _CostCenter.CompanyCodeDescription as CompanyCodeDescription,
      @Semantics.text: true
      _CostCenter.CostObjectDescription,
      @Semantics.text: true
      _CostCenter.Description            as CostCenterDescription,
      @Semantics.text: true
      _CapacityVersion.text              as FplvDescription,
      @Semantics.text: true
      _PoperText.text                    as PoperDescription
}
