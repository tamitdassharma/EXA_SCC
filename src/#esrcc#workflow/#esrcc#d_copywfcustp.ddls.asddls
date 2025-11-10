@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyWfCustP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPLICATION_TYPE', element: 'ApplicationType'} }]
  Application   : /esrcc/application_type_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPROVAL_LEVEL', element: 'ApprovalLevel'} }]
  Approvallevel : /esrcc/approvallevel;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity'}, useForValidation: true }]
  Legalentity   : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId'}, useForValidation: true }]
  Sysid         : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject'}, useForValidation: true }]
  Costobject    : /esrcc/costobject_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_WF_COST_NUMBER_F4', element: 'CostCenter'}, useForValidation: true }]
  Costcenter    : /esrcc/costcenter;
}
