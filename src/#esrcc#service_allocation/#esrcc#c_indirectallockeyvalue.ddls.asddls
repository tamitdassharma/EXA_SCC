@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for /ESRCC/I_INDIRECTALLOCKEYVALUE'
define root view entity /ESRCC/C_INDIRECTALLOCKEYVALUE
  provider contract transactional_query
  as projection on /ESRCC/I_INDIRECTALLOCKEYVALUE
{
  key IndirectAllocationUUID,
      Ryear,
//      @ObjectModel.text.element: ['PoperDescription']
      Poper,
      @ObjectModel.text.element: ['AllocationKeyDescription']
      AllocationKey,
      @ObjectModel.text.element: ['FplvDescription']
      Fplv,
      Value,
      Currency,
      CostObjectUuid,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,

      @ObjectModel.text.element: ['SysidDescription']
      Sysid,
      @ObjectModel.text.element: ['LegalEntityDescription']
      LegalEntity,
      @ObjectModel.text.element: ['CompanyCodeDescription']
      CompanyCode,
      @ObjectModel.text.element: ['CostObjectDescription']
      CostObject,
      @ObjectModel.text.element: ['CostCenterDescription']
      CostCenter,

      @Semantics.text: true
      _KeyVersionText.text    as FplvDescription,
      @Semantics.text: true
      _AllockeyText.AllocationKeyDescription,
//      @Semantics.text: true
//      _PoperText.text         as PoperDescription,
      @Semantics.text: true
      _CostCenter.SysidDescription,
      @Semantics.text: true
      _CostCenter.LegalEntityDescription,
      @Semantics.text: true
      _CostCenter.CompanyCodeDescription,
      @Semantics.text: true
      _CostCenter.CostObjectDescription,
      @Semantics.text: true
      _CostCenter.Description as CostCenterDescription
}
