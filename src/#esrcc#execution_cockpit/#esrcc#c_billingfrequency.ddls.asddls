@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Billing Frequency Mapping - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_BillingFrequency
  as projection on /ESRCC/I_BillingFrequency as BillingFrequency
{
      @ObjectModel.text.element: ['BillingFrequencyDescription']
  key Billingfreq,
      @ObjectModel.text.element: ['BillingPeriodDesc']
  key Billingvalue,
  key Poper,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      BillingFrequency._BillingFrq.text        as BillingFrequencyDescription,
      @Semantics.text: true
      BillingFrequency._BillingPeriodText.text as BillingPeriodDesc,
      _BillingFrequencyAll : redirected to parent /ESRCC/C_BillingFrequency_S

}
