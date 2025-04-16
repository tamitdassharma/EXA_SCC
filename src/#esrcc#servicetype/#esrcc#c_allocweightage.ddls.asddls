@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Weightage'
@Metadata.allowExtensions: true

define view entity /ESRCC/C_AllocWeightage
  as projection on /ESRCC/I_AllocWeightage
{
  key RuleId,
      @ObjectModel.text.element: ['AllocationKeyDescription']
  key AllocationKey,
      @ObjectModel.text.element: ['AllocationPeriodDescription']
      AllocationPeriod,
      RefPeriod,
      Weightage,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _AllocKeyText.AllocationKeyDescription,
      @Semantics.text: true
      _AllocPeriodText.text as AllocationPeriodDescription,

      /* Associations */
      _Rule    : redirected to parent /ESRCC/C_CoRule,
      _RuleAll : redirected to /ESRCC/C_CoRule_S
}
