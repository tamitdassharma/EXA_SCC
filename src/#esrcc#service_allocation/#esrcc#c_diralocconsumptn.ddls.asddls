@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for /ESRCC/I_DIRALOCCONSUMPTN'
define root view entity /ESRCC/C_DIRALOCCONSUMPTN
  provider contract transactional_query
  as projection on /ESRCC/I_DIRALOCCONSUMPTN
{
  key DirectAllocationUuid,
      @ObjectModel.text.element: [ 'ServiceProductDescription' ]
      ServiceProduct,
      CostObjectUuid,
      ProviderCostObjectUuid,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      Sysid,
      @ObjectModel.text.element: [ 'ReceivingEntityDescription' ]
      ReceivingEntity,
      @ObjectModel.text.element: [ 'ReceivingCompanyDescription' ]
      ReceivingCompany,
      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      Costobject,
      @ObjectModel.text.element: [ 'CostCenterDescription' ]
      Costcenter,

      @ObjectModel.text.element: [ 'ProviderSysidDescription' ]
      ProviderSysid,
      @ObjectModel.text.element: [ 'ProviderEntityDescription' ]
      ProviderEntity,
      @ObjectModel.text.element: [ 'ProviderCompanyDescription' ]
      ProviderCompany,
      @ObjectModel.text.element: [ 'ProviderCostObjectDescription' ]
      ProviderCostobject,
      @ObjectModel.text.element: [ 'ProviderCostCenterDescription' ]
      ProviderCostcenter,

      Ryear,
      @ObjectModel.text.element: [ 'PoperDescription' ]
      Poper,
      @ObjectModel.text.element: [ 'FplvDescription' ]
      Fplv,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Consumption,
      @Semantics.unitOfMeasure: true
      Uom,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,

      @Semantics.text: true
      _ServiceProductText.Description            as ServiceProductDescription,
      @Semantics.text: true
      _CostCenter.SysidDescription,
      @Semantics.text: true
      _CostCenter.LegalEntityDescription         as ReceivingEntityDescription,
      @Semantics.text: true
      _CostCenter.CompanyCodeDescription         as ReceivingCompanyDescription,
      @Semantics.text: true
      _CostCenter.CostObjectDescription,
      @Semantics.text: true
      _CostCenter.Description                    as CostCenterDescription,
      @Semantics.text: true
      _PoperText.text                            as PoperDescription,
      @Semantics.text: true
      _ConsumptionText.text                      as FplvDescription,
      @Semantics.text: true
      _ProviderCostCenter.SysidDescription       as ProviderSysidDescription,
      @Semantics.text: true
      _ProviderCostCenter.LegalEntityDescription as ProviderEntityDescription,
      @Semantics.text: true
      _ProviderCostCenter.CompanyCodeDescription as ProviderCompanyDescription,
      @Semantics.text: true
      _ProviderCostCenter.CostObjectDescription  as ProviderCostObjectDescription,
      @Semantics.text: true
      _ProviderCostCenter.Description            as ProviderCostCenterDescription
}
