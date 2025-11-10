@EndUserText.label: 'Royalty Computation Rules'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_RoyComp
  as select from /esrcc/roycomp
  association        to parent /ESRCC/I_RoyComp_S  as _RuleAll           on  $projection.SingletonID = _RuleAll.SingletonID
  composition [0..*] of /ESRCC/I_RoyCompText       as _RuleText
  association [0..1] to /ESRCC/I_ROYALTYCOMPMETHOD as _ComputationMethod on  $projection.RoyaltyComputationMethod = _ComputationMethod.RoyaltyComputationMethod
  association [0..1] to I_CurrencyText             as _CurrencyText      on  _CurrencyText.Currency = $projection.Currency
                                                                         and _CurrencyText.Language = $session.system_language
{
  key rule_id                    as RuleId,
      royalty_computation_method as RoyaltyComputationMethod,
      value                      as Value,
      @Semantics.amount.currencyCode: 'Currency'
      amountvalue                as AmountValue,
      currency                   as Currency,
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt,
      1                          as SingletonID,
      _RuleAll,
      _RuleText,

      _ComputationMethod,
      _CurrencyText

}
