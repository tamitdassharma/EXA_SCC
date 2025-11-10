@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyStewrdshpP
{
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Sysid' },
                                       additionalBinding: [{ localElement: 'LegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'CompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'CostObject', element: 'Costobject' },
                                                           { localElement: 'CostCenter', element: 'Costcenter' },
                                                           { localElement: 'CostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true
                                       }]
  Sysid          : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'LegalEntity' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'CompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'CostObject', element: 'Costobject' },
                                                           { localElement: 'CostCenter', element: 'Costcenter' },
                                                           { localElement: 'CostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true
                                       }]
  LegalEntity    : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'CompanyCode' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'LegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'CostObject', element: 'Costobject' },
                                                           { localElement: 'CostCenter', element: 'Costcenter' },
                                                           { localElement: 'CostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  CompanyCode    : /esrcc/ccode_de;

  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costobject' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'LegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'CompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'CostCenter', element: 'Costcenter' },
                                                           { localElement: 'CostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  CostObject     : /esrcc/costobject_de;

  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid', usage: #FILTER },
                                                           { localElement: 'LegalEntity', element: 'LegalEntity', usage: #FILTER },
                                                           { localElement: 'CompanyCode', element: 'CompanyCode', usage: #FILTER },
                                                           { localElement: 'CostObject', element: 'Costobject', usage: #FILTER },
                                                           { localElement: 'CostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  CostCenter     : /esrcc/costcenter;

  ValidFrom      : /esrcc/validfrom;

  ValidTo        : /esrcc/validto;

  @UI.hidden     : true
  @EndUserText.label: 'Cost Object UUID'
  CostObjectUuid : sysuuid_x16;
}
