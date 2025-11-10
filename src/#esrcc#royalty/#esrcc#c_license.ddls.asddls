@EndUserText.label: 'Maintain License'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_License
  as projection on /ESRCC/I_License
{
  key License,
      @ObjectModel.text.element: ['LicenseTypeDescription']
      LicenseTyp,
      @ObjectModel.text.element: ['ComputationRuleDesc']
      RuleId,
      ValidFrom,
      ValidTo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LicenseAll  : redirected to parent /ESRCC/C_License_S,
      _LicenseText : redirected to composition child /ESRCC/C_LicenseText,
      _LicenseText.Description : localized,

      @Semantics.text: true
      _LicenseTypeText.Description as LicenseTypeDescription,
      @Semantics.text: true
      _ComputationRule.Description as ComputationRuleDesc

}
