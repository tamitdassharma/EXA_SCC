@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyLeOthersP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Legalentity' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'CompanyCode', element: 'Ccode' }],
                                       useForValidation: true }]
  LegalEntity      : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_ROLE', element: 'Role' },
                                       useForValidation: true }]
  Role             : /esrcc/srvrole;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Sysid' },
                                       additionalBinding: [{ localElement: 'LegalEntity', element: 'Legalentity' },
                                                           { localElement: 'CompanyCode', element: 'Ccode' }],
                                       useForValidation: true }]
  Sysid            : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'LegalEntity', element: 'Legalentity' }],
                                       useForValidation: true }]
  CompanyCode      : /esrcc/ccode_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' } }]
  CostObject       : /esrcc/costobject_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' },
                                       useForValidation: true }]
  BusinessDivision : /esrcc/businessdivision;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TRANSACTIONGROUP_F4', element: 'Transactiongroup' },
                                       useForValidation: true }]
  TransactionGroup : /esrcc/tg;
}
