@EndUserText.label: 'Cost Exclusion Inclusion Reason - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Reason
  as projection on /ESRCC/I_Reason
{
  key Reasonid,
      @ObjectModel.text.element: ['CalculationUsageDescription']
      Calculationusage,
      Defaultflag,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _ReasonAll  : redirected to parent /ESRCC/C_Reason_S,
      _ReasonText : redirected to composition child /ESRCC/C_ReasonText,
      _ReasonText.Description : localized,
      @Semantics.text: true
      _CalculationUsageText.text as CalculationUsageDescription

}
