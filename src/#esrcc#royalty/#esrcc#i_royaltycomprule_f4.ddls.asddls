@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Royalty Computation Rules'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_RoyaltyCompRule_F4
  as select from /esrcc/roycomp
  association [0..1] to /esrcc/roycompt            as _Text              on  _Text.rule_id = $projection.RuleId
                                                                         and _Text.spras   = $session.system_language
  association [0..1] to /ESRCC/I_ROYALTYCOMPMETHOD as _ComputationMethod on  _ComputationMethod.RoyaltyComputationMethod = $projection.RoyaltyComputationMethod
  association [0..1] to I_CurrencyText             as _CurrencyText      on  _CurrencyText.Currency = $projection.Currency
                                                                         and _CurrencyText.Language = $session.system_language
{
      @ObjectModel.text.element: [ 'Description' ]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
  key rule_id                     as RuleId,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_ROYALTYCOMPMETHOD', element: 'RoyaltyComputationMethod' } }]
      @ObjectModel.text.element: [ 'RoyaltyComputationMethodDesc' ]
      @UI.textArrangement: #TEXT_LAST
      royalty_computation_method  as RoyaltyComputationMethod,

      @Consumption.filter.hidden: true
      value                       as Value,
      
      @Consumption.filter.hidden: true
      amountvalue                 as AmountValue,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency', element: 'Currency' } } ]
      @ObjectModel.text.element: [ 'CurrencyName' ]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.filter.hidden: true
      currency                    as Currency,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description           as Description,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _ComputationMethod.text     as RoyaltyComputationMethodDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _CurrencyText.CurrencyName
}
