@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Royalty Base Value'

define root view entity /ESRCC/C_RoyaltyBaseValue
  provider contract transactional_query
  as projection on /ESRCC/I_RoyaltyBaseValue
{
  key Uuid,
      Ryear,
      Poper,
      Fplv,
      @ObjectModel.text.element: [ 'RoyaltyBaseKeyDescription' ]
      RoyaltyBaseKey,      
      @Semantics.amount.currencyCode: 'Currency'
      AmountValue,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      UnitValue,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      Sysid,
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      LegalEntity,
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      CompanyCode,
      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      CostObject,
      @ObjectModel.text.element: [ 'CostCenterDescription' ]
      CostCenter,
      @ObjectModel.text.element: [ 'LicenseDescription' ]
      License,
      ValidOn,

      @ObjectModel.text.element: [ 'UomDescription' ]
      Uom,
      @ObjectModel.text.element: [ 'CurrencyName' ]
      Currency,
      CostObjectUuid,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,

      @Semantics.text: true
      _CostCenter.SysidDescription,
      @Semantics.text: true
      _CostCenter.LegalEntityDescription,
      @Semantics.text: true
      _CostCenter.CompanyCodeDescription,
      @Semantics.text: true
      _CostCenter.CostObjectDescription,
      @Semantics.text: true
      _CostCenter.Description        as CostCenterDescription,
      @Semantics.text: true
      _license.Description           as LicenseDescription,
      @Semantics.text: true
      _RoyaltyBaseKey.Description    as RoyaltyBaseKeyDescription,
      @Semantics.text: true
      _UomText.UnitOfMeasureLongName as UomDescription,
      @Semantics.text: true
      _CurrencyText.CurrencyName
}
