@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Stewardship Service Product'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity /ESRCC/C_StwdSp
  as projection on /ESRCC/I_StwdSp
{
  key ServiceProductUuid,
      @ObjectModel.text.element: ['ServiceProductDescription']
      ServiceProduct,
      ValidFrom,
      ValidTo,
      ShareOfCost,
      ErpSalesOrder,
      ContractId,
      StewardshipUuid,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ServiceProductText.Description as ServiceProductDescription,

      /* Associations */
      _Stewardship    : redirected to parent /ESRCC/C_Stewrdshp,
      _StewardshipAll : redirected to /ESRCC/C_Stewrdshp_S
}
