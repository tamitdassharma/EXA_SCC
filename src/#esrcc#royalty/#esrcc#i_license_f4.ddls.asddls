@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Licenses'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_License_F4
  as select from /esrcc/license
  association [0..1] to /esrcc/licenset             as _Text            on  _Text.license = $projection.License
                                                                        and _Text.spras   = $session.system_language
  association [1..1] to /ESRCC/I_LicenseType_F4     as _LicenseTypeText on  _LicenseTypeText.LicenseType = $projection.LicenseType
  association [1..1] to /ESRCC/I_RoyaltyCompRule_F4 as _ComputationRule on  _ComputationRule.RuleId = $projection.RuleId
{
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
  key license                      as License,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LicenseType_F4', element: 'LicenseType' } }]
      @ObjectModel.text.element: ['LicenseTypeDescription']
      @UI.textArrangement: #TEXT_LAST
      license_type                 as LicenseType,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RoyaltyCompRule_F4', element: 'RuleId' } }]
      @ObjectModel.text.element: ['RuleDescription']
      @UI.textArrangement: #TEXT_LAST
      rule_id                      as RuleId,

      valid_from                   as ValidFrom,
      valid_to                     as ValidTo,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description            as Description,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _LicenseTypeText.Description as LicenseTypeDescription,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _ComputationRule.Description as RuleDescription
}
