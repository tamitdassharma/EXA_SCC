@EndUserText.label: 'Service Markup - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvMkp
  as projection on /ESRCC/I_SrvMkp
{
      @ObjectModel.text.element: ['ProductDescription']
  key Serviceproduct,
  key Validfrom,
      Origcost,
      Passcost,
      IntraOrigcost,
      IntraPasscost,
      Validto,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      WorkflowStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ProductText.Description as ProductDescription,
      @Semantics.text: true
      _WorkflowStatusText.text as WorkflowStatusDescription,
      _ServiceMarkupAll : redirected to parent /ESRCC/C_SrvMkp_S
}
