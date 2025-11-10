@EndUserText.label: 'Maintain Licensor Licensee Mapping'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LicMap
  as projection on /ESRCC/I_LicMap
{
  key Uuid,
      @ObjectModel.text.element: ['LicenseDescription']
      License,
      Active,
      LicensorCostObjectUuid,

      @ObjectModel.text.element: ['LicensorSysidDescription']
      LicensorSysid,

      @ObjectModel.text.element: ['LicensorLegalEntityDescription']
      LicensorLegalEntity,

      @ObjectModel.text.element: ['LicensorCompanyCodeDescription']
      LicensorCompanyCode,

      @ObjectModel.text.element: ['LicensorCostObjectDescription']
      LicensorCostObject,

      @ObjectModel.text.element: ['LicensorCostCenterDescription']
      LicensorCostCenter,

      LicenseeCostObjectUuid,

      @ObjectModel.text.element: ['LicenseeSysidDescription']
      LicenseeSysid,

      @ObjectModel.text.element: ['LicenseeLegalEntityDescription']
      LicenseeLegalEntity,

      @ObjectModel.text.element: ['LicenseeCompanyCodeDescription']
      LicenseeCompanyCode,

      @ObjectModel.text.element: ['LicenseeCostObjectDescription']
      LicenseeCostObject,

      @ObjectModel.text.element: ['LicenseeCostCenterDescription']
      LicenseeCostCenter,

      ErpSalesOrder,
      AgreementId,

      @ObjectModel.text.element: ['InvoiceCurrencyDescription']
      InvoiceCurrency,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LicenseeAll : redirected to parent /ESRCC/C_LicMap_S,

      @Semantics.text: true
      _LicenseText.Description         as LicenseDescription,

      @Semantics.text: true
      _Licensor.SysidDescription       as LicensorSysidDescription,
      @Semantics.text: true
      _Licensor.CompanyCodeDescription as LicensorCompanyCodeDescription,
      @Semantics.text: true
      _Licensor.LegalEntityDescription as LicensorLegalEntityDescription,
      @Semantics.text: true
      _Licensor.CostObjectDescription  as LicensorCostObjectDescription,
      @Semantics.text: true
      _Licensor.Description            as LicensorCostCenterDescription,

      @Semantics.text: true
      _Licensee.SysidDescription       as LicenseeSysidDescription,
      @Semantics.text: true
      _Licensee.CompanyCodeDescription as LicenseeCompanyCodeDescription,
      @Semantics.text: true
      _Licensee.LegalEntityDescription as LicenseeLegalEntityDescription,
      @Semantics.text: true
      _Licensee.CostObjectDescription  as LicenseeCostObjectDescription,
      @Semantics.text: true
      _Licensee.Description            as LicenseeCostCenterDescription,

      @Semantics.text: true
      _InvoiceCurrency.CurrencyName    as InvoiceCurrencyDescription

}
