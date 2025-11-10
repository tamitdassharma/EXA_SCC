@EndUserText.label: 'Maintain Service Product True-up Rule'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Chgtrup
  as projection on /ESRCC/I_Chgtrup
{
  key Uuid,
      @ObjectModel.text.element: ['ServiceProductDescription']
      Serviceproduct,
      Validfrom,
      Validto,
      @ObjectModel.text.element: ['ChargeoutRuleDescription']
      ChargeoutRuleId,
      @ObjectModel.text.element: ['ChargeoutMethodDescription']
      _Rule.ChargeoutMethod,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      _Rule.WorkflowStatus,
      _Rule.WorkflowStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ProductText.Description as ServiceProductDescription,
      @Semantics.text: true
      _Rule.Description        as ChargeoutRuleDescription,
      @Semantics.text: true
      _Rule.ChargeoutMethodDescription,
      @Semantics.text: true
      _Rule.WorkflowStatusDescription,

      _ServicePrdTrueUpAll : redirected to parent /ESRCC/C_Chgtrup_S

}
