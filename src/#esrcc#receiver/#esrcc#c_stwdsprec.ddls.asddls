@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship Service Receiver'
@Metadata.allowExtensions: true

define view entity /ESRCC/C_StwdSpRec
  as projection on /ESRCC/I_StwdSpRec
{
  key ServiceReceiverUuid,
      @ObjectModel.text.element: ['ServiceProductDescription']
      ServiceProduct,
      CostObjectUuid,
      StewardshipUuid,

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

      @ObjectModel.text.element: ['InvoiceCurrencyDescription']
      InvoiceCurrency,

      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _CostObject._SysidText.description            as SysidDescription,
      @Semantics.text: true
      _CostObject._CcodeText.LegalentityDescription as LegalEntityDescription,
      @Semantics.text: true
      _CostObject._CcodeText.ccodedescription       as CompanyCodeDescription,
      @Semantics.text: true
      _CostObject._CostObjTypeText.text             as CostObjectDescription,
      @Semantics.text: true
      _CostObjectText.description                   as CostCenterDescription,
      @Semantics.text: true
      _ServiceProduct.Description                   as ServiceProductDescription,
      @Semantics.text: true
      _InvoiceCurrency.CurrencyName                 as InvoiceCurrencyDescription,

      /* Associations */
      _Stewardship    : redirected to parent /ESRCC/C_Stewrdshp,
      _StewardshipAll : redirected to /ESRCC/C_Stewrdshp_S
}
