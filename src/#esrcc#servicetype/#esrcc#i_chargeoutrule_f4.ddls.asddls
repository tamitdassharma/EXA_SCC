@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-out Rules'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_ChargeoutRule_F4
  as select from /esrcc/co_rule
  association [0..1] to /esrcc/co_rulet              as _Text                   on  _Text.rule_id = $projection.RuleId
                                                                                and _Text.spras   = $session.system_language
  association        to /ESRCC/I_CHGOUT              as _ChargeOut              on  _ChargeOut.Chargeout = $projection.ChargeoutMethod
  association [0..1] to /ESRCC/I_COST_VERSION        as _CostVersionText        on  _CostVersionText.CostVersion = $projection.CostVersion
  association [0..1] to /ESRCC/I_CAPACITY_VERSION    as _CapacityVersionText    on  _CapacityVersionText.CapacityVersion = $projection.CapacityVersion
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionVersionText on  _ConsumptionVersionText.ConsumptionVersion = $projection.ConsumptionVersion
  association [0..1] to /ESRCC/I_KEY_VERSION         as _KeyVersionText         on  _KeyVersionText.KeyVersion = $projection.KeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4   as _AdhocKeyText           on  _AdhocKeyText.Allocationkey = $projection.AdhocAllocationKey
{
      @UI.lineItem: [{ position: 10 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['RuleDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key rule_id                                as RuleId,

      @UI.lineItem: [{ position: 20 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['ChargeoutMethodDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_CHGOUT', element: 'Chargeout' } }]
      chargeout_method                       as ChargeoutMethod,

      @UI.lineItem: [{ position: 30 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['CostVersionDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_COST_VERSION', element: 'CostVersion' } } ]
      cost_version                           as CostVersion,

      @UI.lineItem: [{ position: 40 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['CapacityVersionDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_CAPACITY_VERSION', element: 'CapacityVersion' } } ]
      capacity_version                       as CapacityVersion,

      @UI.lineItem: [{ position: 50 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['ConsumptionVersionDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_CONSUMPTION_VERSION', element: 'ConsumptionVersion' } } ]
      consumption_version                    as ConsumptionVersion,

      @UI.lineItem: [{ position: 60 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['KeyVersionDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_KEY_VERSION', element: 'KeyVersion' } } ]
      key_version                            as KeyVersion,

      @UI.lineItem: [{ position: 70 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text: { element: ['AdhocKeyDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_ALLOCATION_KEY_F4', element: 'Allocationkey' } } ]
      adhoc_allocation_key                   as AdhocAllocationKey,

      @UI.hidden: true
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      _Text.description                      as RuleDescription,

      @UI.hidden: true
      @Semantics.text: true
      _ChargeOut.text                        as ChargeoutMethodDescription,

      @UI.hidden: true
      @Semantics.text: true
      _CostVersionText.text                  as CostVersionDescription,

      @UI.hidden: true
      @Semantics.text: true
      _CapacityVersionText.text              as CapacityVersionDescription,

      @UI.hidden: true
      @Semantics.text: true
      _ConsumptionVersionText.text           as ConsumptionVersionDescription,

      @UI.hidden: true
      @Semantics.text: true
      _KeyVersionText.text                   as KeyVersionDescription,

      @UI.hidden: true
      @Semantics.text: true
      _AdhocKeyText.AllocationKeyDescription as AdhocKeyDescription
}
where
  workflow_status = 'F' -- Finalized
