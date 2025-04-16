@EndUserText.label: 'Group Configuration - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_GroupConfig
  as projection on /ESRCC/I_GroupConfig
{
  key Id,
      @ObjectModel.text.element: ['GroupCurrencyDescription']
      GroupCurrency,
      @ObjectModel.text.element: ['CostSignDescription']
      CostSign,
      ConversionRateType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _CurrencyText.CurrencyName as GroupCurrencyDescription,
      @Semantics.text: true
      _CostSignText.text         as CostSignDescription,
      _GroupConfigAll : redirected to parent /ESRCC/C_GroupConfig_S

}
