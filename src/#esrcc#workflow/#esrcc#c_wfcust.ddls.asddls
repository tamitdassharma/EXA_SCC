@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Workflow mapping of User and Role - Main'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_WfCust
  as projection on /ESRCC/I_WfCust
{
      @ObjectModel.text.element: ['ApplicationTypeDescription']
  key Application,
      @ObjectModel.text.element: ['ApprovalLevelDescription']
  key Approvallevel,
      @ObjectModel.text.element: ['LegalentityDescription']
  key Legalentity,
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
      @ObjectModel.text.element: ['CostobjectDescription']
  key Costobject,
  key Costcenter,
      Usergroup,
      Pfcgrole,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ApplicationTypeText.text    as ApplicationTypeDescription,
      @Semantics.text: true
      _ApprovalLevelText.text      as ApprovalLevelDescription,
      @Semantics.text: true
      _LegalEntityText.Description as LegalentityDescription,
      @Semantics.text: true
      _SystemText.Description      as SysidDescription,
      @Semantics.text: true
      _CostObjectText.text         as CostobjectDescription,

      _RoleAssignmentAll : redirected to parent /ESRCC/C_WfCust_S
}
