@EndUserText.label: 'Maintain Hierarchy Definition'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_HierDef
  as projection on /ESRCC/I_HierDef
{
      @ObjectModel.text.element: ['Hierarchy1Description']
  key Hierarchy1,
      @ObjectModel.text.element: ['Hierarchy2Description']
  key Hierarchy2,
      @ObjectModel.text.element: ['Hierarchy3Description']
  key Hierarchy3,
      @ObjectModel.text.element: ['Hierarchy4Description']
  key Hierarchy4,
  key ValidFrom,
      ValidTo,
      @ObjectModel.text.element: ['RuleDescription']
      RuleId,
      SrvPrdDef,
      SrvRecDef,
      Stewardship,
      ChainId,
      @ObjectModel.text.element: ['CurrencyDerivationTypeDesc']
      CurrencyDerivationType,
      IsHub,
      WorkflowId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      WorkflowStatusCriticality,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _Hierarchy1Text.description as Hierarchy1Description,
      @Semantics.text: true
      _Hierarchy2Text.description as Hierarchy2Description,
      @Semantics.text: true
      _Hierarchy3Text.description as Hierarchy3Description,
      @Semantics.text: true
      _Hierarchy4Text.description as Hierarchy4Description,

      @Semantics.text: true
      _RuleText.Description       as RuleDescription,
      @Semantics.text: true
      _WorkflowStatusText.text    as WorkflowStatusDescription,
      @Semantics.text: true
      _CurrencyTypeText.text      as CurrencyDerivationTypeDesc,

      _HierDefAll : redirected to parent /ESRCC/C_HierDef_S

}
