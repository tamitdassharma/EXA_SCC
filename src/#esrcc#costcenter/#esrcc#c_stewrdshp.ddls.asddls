@EndUserText.label: 'Stewardship - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Stewrdshp
  as projection on /ESRCC/I_Stewrdshp
{
  key StewardshipUuid,
      Validto,
      Stewardship,
      CostObjectUuid,
      ChainId,
      ChainSequence,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @ObjectModel.text.element: ['SysidDescription']
      Sysid,

      @ObjectModel.text.element: ['LegalEntityDescription']
      LegalEntity,

      @ObjectModel.text.element: ['CompanyCodeDescription']
      CompanyCode,

      @ObjectModel.text.element: ['CostObjectDescription']
      CostObject,

      @ObjectModel.text.element: ['CostCenterDescription']
      CostCenter,
      ValidFrom,
      WorkflowStatusCriticality,

      @Semantics.text: true
      _CostObject._SysidText.description            as SysidDescription,
      @Semantics.text: true
      _CostObject._CcodeText.LegalentityDescription as LegalEntityDescription,
      @Semantics.text: true
      _CostObject._CcodeText.ccodedescription       as CompanyCodeDescription,
      @Semantics.text: true
      _CostObject._CostObjTypeText.text             as CostObjectDescription,
      @Semantics.text: true
      _CostObjectText.Description                   as CostCenterDescription,
      @Semantics.text: true
      _WorkflowStatusText.text                      as WorkflowStatusDescription,

      _StewardshipAll  : redirected to parent /ESRCC/C_Stewrdshp_S,
      _ServiceProduct  : redirected to composition child /ESRCC/C_StwdSp,
      _ServiceReceiver : redirected to composition child /ESRCC/C_StwdSpRec
}
