@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Billing Frequency Mapping'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_BillingFrequency
  as select from /esrcc/billfreq
  association to parent /ESRCC/I_BillingFrequency_S as _BillingFrequencyAll on $projection.SingletonID = _BillingFrequencyAll.SingletonID
  association to /ESRCC/I_BILLINGFREQ               as _BillingFrq          on $projection.Billingfreq = _BillingFrq.Billingfreq
  association to /ESRCC/I_BILLINGPERIOD             as _BillingPeriodText   on $projection.Billingvalue = _BillingPeriodText.Billingperiod
{
//      @ObjectModel.text.association: '_BillingFrq'
  key billingfreq           as Billingfreq,
//      @ObjectModel.text.association: '_BillingPeriodText'
  key billingvalue          as Billingvalue,
  key poper                 as Poper,
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
      1                     as SingletonID,
      _BillingFrequencyAll,
      _BillingFrq,
      _BillingPeriodText
}
