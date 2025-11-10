@EndUserText.label: 'Maintain Royalty Computation Rules'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RoyComp
  as projection on /ESRCC/I_RoyComp
{
  key RuleId,
      @ObjectModel.text.element: [ 'RoyaltyComputationMethodDesc' ]
      RoyaltyComputationMethod,
      Value,
      @Semantics.amount.currencyCode: 'Currency'
      AmountValue,
      @ObjectModel.text.element: [ 'CurrencyName' ]
      Currency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _RuleAll  : redirected to parent /ESRCC/C_RoyComp_S,
      _RuleText : redirected to composition child /ESRCC/C_RoyCompText,
      _RuleText.Description : localized,

      @Semantics.text: true
      _ComputationMethod.text     as RoyaltyComputationMethodDesc,
      @Semantics.text: true
      _CurrencyText.CurrencyName

}
